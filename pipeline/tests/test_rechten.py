"""Tests voor de rechten (db/migrations/005_api_rechten.sql en pipeline/controleer_rechten.py).

Draaien alleen met TEST_DATABASE_URL (in CI: een Postgres-container). Gooien de schema's
leeg, dus nooit tegen Supabase draaien.
"""
import os
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

URL = os.environ.get("TEST_DATABASE_URL")
pytestmark = pytest.mark.skipif(not URL, reason="TEST_DATABASE_URL niet gezet")


@pytest.fixture
def conn():
    import migreer
    import psycopg

    with psycopg.connect(URL, autocommit=True) as c:
        c.execute("drop schema if exists api cascade; drop schema if exists analyses cascade; drop schema if exists core cascade; "
                  "drop schema if exists raw cascade; drop schema if exists beheer cascade;")
        migreer.migreer(c)
        yield c
        c.execute("reset role")


def overtredingen(conn):
    import controleer_rechten

    return {naam: o for naam, o in controleer_rechten.controleer(conn) if o}


def als_anon(conn, sql):
    import psycopg

    conn.execute("set role anon")
    try:
        return conn.execute(sql).fetchall()
    except psycopg.Error as e:
        return type(e).__name__
    finally:
        conn.execute("reset role")


def test_na_de_migraties_geen_overtredingen(conn):
    assert overtredingen(conn) == {}


def test_tabel_zonder_rls_wordt_gevonden(conn):
    conn.execute("create table core.testtabel (x int)")
    gevonden = overtredingen(conn)
    assert any("core.testtabel" in o for lijst in gevonden.values() for o in lijst)


def test_schrijfrecht_voor_anon_wordt_gevonden(conn):
    conn.execute("grant insert on core.kabinet to anon")
    assert any("INSERT op core.kabinet" in o for lijst in overtredingen(conn).values() for o in lijst)


def test_view_zonder_security_invoker_wordt_gevonden(conn):
    conn.execute("create view api.lek as select naam from core.kabinet")
    assert any("api.lek" in o for lijst in overtredingen(conn).values() for o in lijst)


def test_anon_leest_api(conn):
    assert len(als_anon(conn, "select * from api.kabinet")) == 7
    assert als_anon(conn, "select * from api.fractie") == []


def test_anon_kan_niet_schrijven(conn):
    assert als_anon(conn, "insert into api.kabinet (naam, begin) values ('x', '2030-01-01')") == "InsufficientPrivilege"
    assert als_anon(conn, "update api.kabinet set naam = 'x'") == "InsufficientPrivilege"
    assert als_anon(conn, "delete from api.kabinet") == "InsufficientPrivilege"
    assert als_anon(conn, "delete from core.kabinet") == "InsufficientPrivilege"


def test_anon_kan_raw_en_beheer_niet_lezen(conn):
    assert als_anon(conn, "select * from raw.stemming") == "InsufficientPrivilege"
    assert als_anon(conn, "select * from beheer.migraties") == "InsufficientPrivilege"
    assert als_anon(conn, "select fout from beheer.verversing") == "InsufficientPrivilege"
    assert als_anon(conn, "select * from core.herbouw()") == "InsufficientPrivilege"


def test_laatst_bijgewerkt_alleen_geslaagde_runs(conn):
    conn.execute("insert into beheer.verversing (klaar_op, status) values "
                 "('2026-10-20 05:00+00', 'geslaagd'), ('2026-10-21 05:00+00', 'mislukt')")
    tijd = als_anon(conn, "select laatst_bijgewerkt from api.laatst_bijgewerkt")[0][0]
    assert tijd.isoformat().startswith("2026-10-20")
