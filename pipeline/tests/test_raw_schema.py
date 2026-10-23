"""Tests voor pipeline/raw_schema.py (geen database nodig)."""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import raw_schema  # noqa: E402
from api_check import lees_metadata  # noqa: E402

META = lees_metadata(raw_schema.METADATA.read_bytes())


def test_alle_entiteiten_in_metadata():
    assert all(e in META for e in raw_schema.ENTITEITEN)


def test_persoon_zonder_uitgesloten_velden():
    namen = [n for n, _ in raw_schema.kolommen(META, "Persoon")]
    assert "Achternaam" in namen and "Id" in namen
    for veld in ("Geboortedatum", "Woonplaats", "Geslacht"):
        assert veld not in namen


def test_typen_uit_metadata():
    typen = dict(raw_schema.kolommen(META, "Stemming"))
    assert typen["Id"] == "uuid"
    assert typen["FractieGrootte"] == "integer"
    assert typen["Vergissing"] == "boolean"
    assert typen["ApiGewijzigdOp"] == "timestamptz"


def test_onbekend_type_geeft_fout():
    meta = {"X": {"velden": [("Id", "Edm.Guid"), ("Raar", "Edm.Geography")], "relaties": []}}
    with pytest.raises(ValueError, match="Edm.Geography"):
        raw_schema.kolommen(meta, "X")


def test_migratie_in_de_repo_is_actueel():
    # Het bestand in db/migrations moet gelijk zijn aan wat de generator nu maakt
    assert raw_schema.MIGRATIE.read_text(encoding="utf-8") == raw_schema.migratie_sql(META)


def test_migratie_bevat_alle_tabellen():
    sql = raw_schema.migratie_sql(META)
    for e in raw_schema.ENTITEITEN:
        assert f"create table raw.{e.lower()} (" in sql
    assert "create table raw.besluit_zaak (" in sql
    assert "create table raw.laadstatus (" in sql
