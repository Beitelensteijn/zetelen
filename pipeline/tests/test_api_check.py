"""Tests voor pipeline/api_check.py met nagebootste API-antwoorden (geen netwerk nodig)."""
import json
import sys
import urllib.parse
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import api_check  # noqa: E402

# Verzonnen naam in de nagebootste records; mag nooit in het rapport komen
CANARY = "Jan Testpersoon"

METADATA = b"""<?xml version="1.0"?>
<edmx:Edmx xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
 <edmx:DataServices><Schema xmlns="http://docs.oasis-open.org/odata/ns/edm" Namespace="tk">
  <EntityType Name="Stemming">
   <Property Name="Id" Type="Edm.Guid"/>
   <Property Name="ActorNaam" Type="Edm.String"/>
   <Property Name="Persoon_Id" Type="Edm.Guid"/>
   <Property Name="ApiGewijzigdOp" Type="Edm.DateTimeOffset"/>
   <Property Name="Verwijderd" Type="Edm.Boolean"/>
   <NavigationProperty Name="Besluit" Type="tk.Besluit"/>
  </EntityType>
  <EntityType Name="Zaal">
   <Property Name="Id" Type="Edm.Guid"/>
   <Property Name="Naam" Type="Edm.String"/>
  </EntityType>
 </Schema></edmx:DataServices>
</edmx:Edmx>"""


def nep_get(url, accept="application/json"):
    """Bootst de API na op basis van de query in de URL."""
    pad, _, query = url.partition("?")
    params = dict(urllib.parse.parse_qsl(query))
    if pad.endswith("$metadata"):
        return 200, METADATA
    if params.get("$top") == "251":
        return 400, b'{"error":{"message":"limit of 250"}}'
    if params.get("$count") == "true":
        flt = params.get("$filter", "")
        if "Stemming/any(s:s/Persoon_Id ne null)" in flt:
            n = 1
        elif "Stemming/any()" in flt:
            n = 2
        elif "Persoon_Id ne null" in flt:
            n = 3
        elif "Verwijderd eq false" in flt:
            n = 9
        elif "Verwijderd eq true" in flt:
            n = 1
        elif "ApiGewijzigdOp" in flt:
            n = 4
        elif " lt 2010-" in flt and " ge " not in flt:
            n = 5
        elif flt:
            n = 10
        else:
            n = 1000
        return 200, json.dumps({"@odata.count": n, "value": []}).encode()
    records = [{"Id": str(i), "ActorNaam": CANARY} for i in range(250)]
    body = {"value": records}
    if "$top" not in params:
        body["@odata.nextLink"] = url + "?$skip=250"
    return 200, json.dumps(body).encode()


def maak_rapport(tot_jaar=2012):
    api = api_check.Api(get=nep_get, base="https://nep")
    meta = api_check.lees_metadata(METADATA)
    sinds = "2026-10-16T00:00:00Z"
    resultaten = [api_check.check_entiteit(api, n, meta[n], sinds) for n in ("Stemming", "Zaal")]
    jaren, voor = api_check.stemmingen_per_jaar(api, tot_jaar)
    return resultaten, api_check.schrijf_rapport(resultaten, jaren, voor, 1000, "2026-10-23", sinds)


def test_metadata_velden_en_relaties():
    meta = api_check.lees_metadata(METADATA)
    assert [v for v, _ in meta["Stemming"]["velden"]] == ["Id", "ActorNaam", "Persoon_Id", "ApiGewijzigdOp", "Verwijderd"]
    assert meta["Stemming"]["relaties"] == ["Besluit"]


def test_entiteit_heeft_aantal_paginering_en_wijzigingen():
    resultaten, _ = maak_rapport()
    st, zaal = resultaten
    assert st["toegang"] == 200
    assert st["aantal"] == 1000
    assert st["verwijderd"] == 1
    assert st["gewijzigd_recent"] == 4
    assert st["standaard_pagina"] == 250 and st["volgende_link"] is True
    assert st["top_max_ok"] is True and st["top_max_plus_fout"] is True
    # Zaal heeft geen Verwijderd en geen ApiGewijzigdOp
    assert "verwijderd" not in zaal and "gewijzigd_recent" not in zaal


def test_rapport_bevat_per_entiteit_aantal_en_velden():
    _, rapport = maak_rapport()
    assert "| Stemming | 200 | 1.000 |" in rapport
    assert "### Stemming" in rapport and "`Persoon_Id` (Guid)" in rapport
    assert "### Zaal" in rapport


def test_rapport_per_jaar_en_niet_te_dateren():
    _, rapport = maak_rapport(tot_jaar=2012)
    assert "| 2010 | 10 | 9 | 3 | 2 | 1 |" in rapport
    assert "| 2012 | 10 | 9 | 3 | 2 | 1 |" in rapport
    # 1000 totaal - 30 (2010-2012) - 5 (voor 2010)
    assert "Niet te dateren via" in rapport and ": 965" in rapport


def test_geen_namen_in_rapport():
    _, rapport = maak_rapport()
    assert CANARY not in rapport
    assert "Jan" not in rapport


def test_getal_notatie():
    assert api_check.getal(1030560) == "1.030.560"
    assert api_check.getal(1234.56) == "1.234,6"
    assert api_check.getal("fout: HTTP 500") == "fout: HTTP 500"
