#!/usr/bin/env python3
"""Handmatige API-check voor de Tweede Kamer OData API.

Alleen standaardbibliotheek, werkt met de python3 die op een Mac zit.
Dit script is niet gedraaid tegen de live API (de omgeving waarin het is
geschreven kon de API niet bereiken). Het schrijft niets anders weg dan
metadata.xml in de huidige map.

Gebruik:
  python3 api_check.py basic
  python3 api_check.py fields Stemming
  python3 api_check.py count Stemming --field <veldnaam uit de vorige stap>
"""
import argparse
import json
import sys
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

BASE = "https://gegevensmagazijn.tweedekamer.nl/OData/v4/2.0"


def get(url, accept="application/json"):
    req = urllib.request.Request(
        url, headers={"Accept": accept, "User-Agent": "zetelen-api-check/0.1"}
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status, r.read()
    except urllib.error.HTTPError as e:
        print(f"HTTP-fout {e.code} {e.reason} bij {url}")
        print(e.read()[:500].decode("utf-8", "replace"))
        sys.exit(1)
    except urllib.error.URLError as e:
        print(f"Verbindingsfout bij {url}: {e.reason}")
        sys.exit(1)


def cmd_basic(_args):
    url = f"{BASE}/Stemming?$top=1&$count=true"
    status, body = get(url)
    data = json.loads(body)
    print("Status:", status)
    print("Totaal aantal stemmingen (@odata.count):", data.get("@odata.count"))
    records = data.get("value", [])
    if not records:
        print("Geen records in het antwoord. Noteer dit.")
        return
    print("Velden zoals de API ze teruggeeft:", ", ".join(records[0].keys()))
    print(json.dumps(records[0], indent=2, ensure_ascii=False))


def cmd_fields(args):
    status, body = get(f"{BASE}/$metadata", accept="application/xml")
    with open("metadata.xml", "wb") as f:
        f.write(body)
    print("metadata.xml opgeslagen, status:", status)
    root = ET.fromstring(body)
    entities = {
        e.get("Name"): e for e in root.iter() if e.tag.rsplit("}", 1)[-1] == "EntityType"
    }
    print("Entiteiten:", ", ".join(sorted(entities)))
    ent = entities.get(args.entity)
    if ent is None:
        print(f"Entiteit {args.entity} niet gevonden. Kies er een uit de lijst hierboven.")
        return
    print(f"\nVelden van {args.entity}:")
    for p in (c for c in ent if c.tag.rsplit("}", 1)[-1] == "Property"):
        print(f"  {p.get('Name')}  ({p.get('Type')})")
    navs = [c for c in ent if c.tag.rsplit("}", 1)[-1] == "NavigationProperty"]
    if navs:
        print(f"\nRelaties van {args.entity}:")
        for n in navs:
            print(f"  {n.get('Name')}  ({n.get('Type')})")


def cmd_count(args):
    total_url = f"{BASE}/{args.entity}?$top=1&$count=true"
    _, body = get(total_url)
    total = json.loads(body).get("@odata.count")
    flt = urllib.parse.quote(f"{args.field} ne null", safe="")
    url = f"{BASE}/{args.entity}?$filter={flt}&$top=1&$count=true"
    _, body = get(url)
    filtered = json.loads(body).get("@odata.count")
    print(f"Totaal {args.entity}: {total}")
    print(f"Met ingevulde waarde in {args.field}: {filtered}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("basic").set_defaults(func=cmd_basic)
    f = sub.add_parser("fields")
    f.add_argument("entity")
    f.set_defaults(func=cmd_fields)
    c = sub.add_parser("count")
    c.add_argument("entity")
    c.add_argument("--field", required=True)
    c.set_defaults(func=cmd_count)
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
