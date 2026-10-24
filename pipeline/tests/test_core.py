"""Tests voor de core-laag (db/migrations/003_core.sql, functie core.herbouw).

Draaien alleen met TEST_DATABASE_URL (in CI: een Postgres-container). Gooien de schema's
raw, core en beheer leeg, dus nooit tegen Supabase draaien.
"""
import os
import sys
import uuid
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

URL = os.environ.get("TEST_DATABASE_URL")
pytestmark = pytest.mark.skipif(not URL, reason="TEST_DATABASE_URL niet gezet")


def nieuw():
    return str(uuid.uuid4())


@pytest.fixture
def conn():
    import migreer
    import psycopg

    with psycopg.connect(URL, autocommit=True) as c:
        c.execute("drop schema if exists api cascade; drop schema if exists core cascade; drop schema if exists raw cascade; "
                  "drop schema if exists beheer cascade;")
        migreer.migreer(c)
        yield c


class Bron:
    """Schrijft een minimale keten in raw: activiteit, agendapunt, besluit, stemmingen."""

    def __init__(self, conn):
        self.c = conn
        self.fractie_a, self.fractie_b = nieuw(), nieuw()
        for f, afk in ((self.fractie_a, "A"), (self.fractie_b, "B")):
            conn.execute('insert into raw.fractie ("Id", "Afkorting", "NaamNL", "DatumActief", "Verwijderd") '
                         "values (%s, %s, %s, '2000-01-01', false)", (f, afk, f"Fractie {afk}"))
        self.persoon = nieuw()
        conn.execute('insert into raw.persoon ("Id", "Roepnaam", "Achternaam", "Verwijderd") '
                     "values (%s, 'Test', 'Persoon', false)", (self.persoon,))

    def besluit(self, datum, soort="Met handopsteken", verwijderd=False):
        act, ap, b = nieuw(), nieuw(), nieuw()
        self.c.execute('insert into raw.activiteit ("Id", "Datum", "Verwijderd") values (%s, %s, false)', (act, datum))
        self.c.execute('insert into raw.agendapunt ("Id", "Activiteit_Id", "Verwijderd") values (%s, %s, false)', (ap, act))
        self.c.execute('insert into raw.besluit ("Id", "Agendapunt_Id", "StemmingsSoort", "Verwijderd") '
                       "values (%s, %s, %s, %s)", (b, ap, soort, verwijderd))
        return b

    def stem(self, besluit, fractie, soort, persoon=None, verwijderd=False, vergissing=False):
        self.c.execute('insert into raw.stemming ("Id", "Besluit_Id", "Fractie_Id", "Persoon_Id", "Soort", '
                       '"FractieGrootte", "Vergissing", "Verwijderd") values (%s, %s, %s, %s, %s, 10, %s, %s)',
                       (nieuw(), besluit, fractie, persoon, soort, vergissing, verwijderd))


def herbouw(conn):
    return dict(conn.execute("select * from core.herbouw()").fetchall())


def test_periodes_sluiten_op_elkaar_aan(conn):
    for tabel in ("core.kabinet", "core.kamerperiode"):
        rijen = conn.execute(f"select begin, einde from {tabel} order by begin").fetchall()
        for (_, einde), (begin_volgende, _) in zip(rijen, rijen[1:]):
            assert einde == begin_volgende, tabel
        assert rijen[-1][1] is None, f"laatste periode in {tabel} loopt nog"


def test_fractiestem_en_persoonsstem(conn):
    bron = Bron(conn)
    b = bron.besluit("2025-03-04T15:00:00+01:00")
    bron.stem(b, bron.fractie_a, "Voor")
    bron.stem(b, bron.fractie_b, "Tegen", vergissing=True)
    h = bron.besluit("2025-03-04T15:00:00+01:00", soort="Hoofdelijk")
    bron.stem(h, bron.fractie_a, "Voor", persoon=bron.persoon)

    aantallen = herbouw(conn)
    assert aantallen["besluit"] == 2
    assert aantallen["fractiestem"] == 2
    assert aantallen["persoonsstem"] == 1
    assert conn.execute("select vergissing from core.fractiestem where fractie_id = %s",
                        (bron.fractie_b,)).fetchone()[0] is True
    # Hoofdelijk: alleen persoonsstemmen, geen fractiestem
    assert conn.execute("select count(*) from core.fractiestem where besluit_id = %s", (h,)).fetchone()[0] == 0
    assert conn.execute("select naam from core.persoon").fetchone()[0] == "Test Persoon"


def test_verwijderd_voor_2010_en_zonder_stemming_vallen_weg(conn):
    bron = Bron(conn)
    oud = bron.besluit("2009-12-31T12:00:00+01:00")
    bron.stem(oud, bron.fractie_a, "Voor")
    weg = bron.besluit("2025-01-10T12:00:00+01:00", verwijderd=True)
    bron.stem(weg, bron.fractie_a, "Voor")
    zonder = bron.besluit("2025-01-10T12:00:00+01:00")
    met_verwijderde_stem = bron.besluit("2025-01-10T12:00:00+01:00")
    bron.stem(met_verwijderde_stem, bron.fractie_a, "Voor", verwijderd=True)
    assert herbouw(conn)["besluit"] == 0
    assert zonder  # besluit zonder stemming bestaat in raw, maar niet in core


def test_demissionaire_fase_hoort_bij_het_oude_kabinet(conn):
    bron = Bron(conn)
    dag_voor_jetten = bron.besluit("2026-02-22T14:00:00+01:00")
    eerste_dag_jetten = bron.besluit("2026-02-23T14:00:00+01:00")
    for b in (dag_voor_jetten, eerste_dag_jetten):
        bron.stem(b, bron.fractie_a, "Voor")
    herbouw(conn)
    kabinet = dict(conn.execute("select id::text, kabinet from core.besluit").fetchall())
    assert kabinet[dag_voor_jetten] == "Schoof"
    assert kabinet[eerste_dag_jetten] == "Jetten"


def test_datum_in_nederlandse_tijd(conn):
    bron = Bron(conn)
    # 23:30 UTC op 22 februari is 00:30 op 23 februari in Nederland: eerste dag van Jetten
    b = bron.besluit("2026-02-22T23:30:00+00:00")
    bron.stem(b, bron.fractie_a, "Voor")
    herbouw(conn)
    assert conn.execute("select datum::text, kabinet from core.besluit").fetchone() == ("2026-02-23", "Jetten")


def test_besluit_zaak_koppeling(conn):
    bron = Bron(conn)
    b = bron.besluit("2025-05-01T12:00:00+02:00")
    bron.stem(b, bron.fractie_a, "Voor")
    zaak = nieuw()
    conn.execute('insert into raw.zaak ("Id", "Nummer", "Soort", "Titel", "Verwijderd") '
                 "values (%s, '2025Z00001', 'Motie', 'Testmotie', false)", (zaak,))
    conn.execute('insert into raw.besluit_zaak ("Besluit_Id", "Zaak_Id") values (%s, %s)', (b, zaak))
    aantallen = herbouw(conn)
    assert aantallen["zaak"] == 1 and aantallen["besluit_zaak"] == 1


def test_herbouw_twee_keer_geeft_hetzelfde(conn):
    bron = Bron(conn)
    b = bron.besluit("2025-03-04T15:00:00+01:00")
    bron.stem(b, bron.fractie_a, "Voor")
    assert herbouw(conn) == herbouw(conn)


def test_partij_koppeling(conn):
    # SGP staat in de handmatige tabel met een partij; een onbekende fractie krijgt geen partij
    sgp = conn.execute("select fractie_id from core.fractie_partij where afkorting = 'SGP'").fetchone()[0]
    conn.execute('insert into raw.fractie ("Id", "Afkorting", "Verwijderd") values (%s, %s, false)', (sgp, "SGP"))
    Bron(conn)
    herbouw(conn)
    partijen = dict(conn.execute("select afkorting, partij from core.fractie").fetchall())
    assert partijen["SGP"] == "Staatkundig Gereformeerde Partij"
    assert partijen["A"] is None


def test_beschrijving_komt_overeen_met_het_schema(conn):
    # Elke tabel in schema core heeft een eigen kop in docs/datamodel.md, en andersom
    tekst = (Path(__file__).resolve().parents[2] / "docs" / "datamodel.md").read_text(encoding="utf-8")
    beschreven = {regel[4:].strip() for regel in tekst.splitlines() if regel.startswith("### ")}
    schema = {r[0] for r in conn.execute(
        "select table_name from information_schema.tables where table_schema = 'core'"
    )}
    assert beschreven == schema


def test_afgeleide_tabellen_unlogged_handmatige_gelogd(conn):
    persistentie = dict(conn.execute(
        "select relname, relpersistence from pg_class "
        "where relnamespace = 'core'::regnamespace and relkind = 'r'"
    ).fetchall())
    for tabel in ("kabinet", "kamerperiode", "fractie_partij"):
        assert persistentie[tabel] == "p", tabel
    for tabel in ("besluit", "fractiestem", "persoonsstem", "fractie", "persoon", "zaak", "besluit_zaak"):
        assert persistentie[tabel] == "u", tabel
