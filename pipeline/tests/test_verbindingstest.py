"""Tests voor het opschonen van foutmeldingen in pipeline/verbindingstest.py."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import verbindingstest  # noqa: E402


def test_host_gebruiker_en_ip_verdwijnen():
    tekst = ('connection to server at "aws-0-eu-west-1.pooler.supabase.com" (52.1.2.3), port 5432 failed: '
             'FATAL: some error for user "postgres.abcdef123"')
    schoon = verbindingstest.zonder_gegevens(tekst)
    assert "supabase.com" not in schoon and "52.1.2.3" not in schoon and "abcdef123" not in schoon
    assert "FATAL: some error" in schoon


def test_bekende_fout_geeft_vaste_uitleg():
    assert "Wachtwoord" in verbindingstest.uitleg(Exception("password authentication failed for user x"))


def test_onbekende_fout_toont_opgeschoonde_tekst():
    melding = verbindingstest.uitleg(Exception('server at "db.xyz.supabase.co" said: disk full'))
    assert "disk full" in melding and "xyz" not in melding
