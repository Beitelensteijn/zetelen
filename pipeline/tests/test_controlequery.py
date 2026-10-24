"""Tests voor pipeline/controlequery.py: alleen bestanden uit db/controles/, en alleen lezen."""
import os
import subprocess
import sys
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / "controlequery.py"
URL = os.environ.get("TEST_DATABASE_URL")


def draai(bestand, url="postgresql://niet-gebruikt@127.0.0.1:1/x"):
    return subprocess.run([sys.executable, str(SCRIPT), bestand], capture_output=True, text=True,
                          env={**os.environ, "DATABASE_URL": url})


def test_bestand_buiten_de_map_wordt_geweigerd():
    uit = draai("../../pipeline/requirements.txt")
    assert uit.returncode != 0 and "Geen bestand in db/controles/" in uit.stderr


@pytest.mark.skipif(not URL, reason="TEST_DATABASE_URL niet gezet")
def test_schrijvende_query_faalt(tmp_path):
    kaart = SCRIPT.parents[1] / "db" / "controles" / "_test_schrijven.sql"
    kaart.write_text("create table public._mag_niet (x int);")
    try:
        uit = draai(kaart.name, URL)
        assert uit.returncode != 0
    finally:
        kaart.unlink()
