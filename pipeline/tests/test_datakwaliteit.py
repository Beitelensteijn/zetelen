"""Tests voor de datakwaliteitscontroles (db/migrations/007_datakwaliteit.sql).

Draaien alleen met TEST_DATABASE_URL (in CI: een Postgres-container); nooit tegen Supabase.
"""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from test_core import URL, Bron, conn, herbouw, nieuw  # noqa: E402,F401

pytestmark = pytest.mark.skipif(not URL, reason="TEST_DATABASE_URL niet gezet")

DATUM = "2025-03-04T15:00:00+01:00"


def controles(conn):
    return {r[0]: (r[1], r[2]) for r in conn.execute("select * from beheer.controleer_datakwaliteit()").fetchall()}


def besluitsoort(conn, besluit, soort):
    conn.execute('update raw.besluit set "BesluitSoort" = %s where "Id" = %s', (soort, besluit))


def test_schone_data_geeft_alleen_goed(conn):
    bron = Bron(conn)
    b = bron.besluit(DATUM)
    besluitsoort(conn, b, "Stemmen - aangenomen")
    bron.stem(b, bron.fractie_a, "Voor")
    bron.stem(b, bron.fractie_b, "Tegen", vergissing=True)
    conn.execute('update raw.stemming set "FractieGrootte" = 9 where "Fractie_Id" = %s', (bron.fractie_b,))
    herbouw(conn)
    uitkomst = controles(conn)
    assert {oordeel for _, oordeel in uitkomst.values()} == {"goed"}
    assert conn.execute("select count(*) from beheer.datakwaliteit").fetchone()[0] == len(uitkomst)


def test_meer_dan_150_zetels_is_een_fout(conn):
    bron = Bron(conn)
    b = bron.besluit(DATUM)
    for i in range(16):  # 16 fracties van 10 zetels = 160
        f = nieuw()
        conn.execute('insert into raw.fractie ("Id", "Afkorting", "Verwijderd") values (%s, %s, false)', (f, f"F{i}"))
        bron.stem(b, f, "Voor")
    herbouw(conn)
    assert controles(conn)["Besluiten met meer dan 150 zetels"] == (1, "fout")


def test_uitslag_die_niet_past_is_een_signaal(conn):
    bron = Bron(conn)
    b = bron.besluit(DATUM)
    besluitsoort(conn, b, "Stemmen - aangenomen")
    bron.stem(b, bron.fractie_a, "Tegen")
    bron.stem(b, bron.fractie_b, "Tegen")
    herbouw(conn)
    assert controles(conn)["Besluiten waarvan de uitslag niet past bij de stemmen"] == (1, "signaal")
    assert conn.execute("select zetels_voor, zetels_tegen from beheer.afwijkende_uitslag").fetchone() == (0, 20)


def test_verversing_faalt_bij_een_fout(conn):
    import ververs

    bron = Bron(conn)
    b = bron.besluit(DATUM)
    for i in range(16):
        f = nieuw()
        conn.execute('insert into raw.fractie ("Id", "Afkorting", "Verwijderd") values (%s, %s, false)', (f, f"F{i}"))
        bron.stem(b, f, "Voor")
    herbouw(conn)
    with pytest.raises(ververs.DatakwaliteitFout):
        ververs.controleer_datakwaliteit(conn)
