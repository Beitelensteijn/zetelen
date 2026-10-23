#!/usr/bin/env python3
"""API-check voor de Tweede Kamer OData API (component api-check, story E1-S2).

Licht per entiteit de API door en schrijft een markdownrapport met alleen
aantallen en veldnamen. Er komt nooit een waarde uit een record in het rapport,
dus ook geen namen van personen.

Alleen standaardbibliotheek. Gebruik:
  python3 pipeline/api_check.py
  python3 pipeline/api_check.py --uitvoer docs/plan/api-check-rapport.md

Op een Mac met python.org Python kan SSL_CERT_FILE=/etc/ssl/cert.pem nodig zijn
(zie docs/plan/api-check-handmatig.md).
"""
import argparse
import datetime as dt
import json
import time
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

BASE = "https://gegevensmagazijn.tweedekamer.nl/OData/v4/2.0"

# Entiteiten uit het informatiemodel die het plan nodig heeft (componentbestand api-check)
ENTITEITEN = [
    "Stemming", "Besluit", "Zaak", "Persoon", "Fractie", "FractieZetel",
    "FractieZetelPersoon", "Activiteit", "ActiviteitActor", "Commissie",
    "Document", "ZaakActor", "Agendapunt", "Vergadering",
]

EERSTE_JAAR = 2010
MAX_TOP = 250
# Pad van Stemming naar de datum van de vergadering; Stemming en Besluit hebben zelf geen datum
DATUMPAD = "Besluit/Agendapunt/Activiteit/Datum"
# Hetzelfde pad vanaf Besluit
DATUMPAD_BESLUIT = "Agendapunt/Activiteit/Datum"
PAUZE = 0.2  # seconden tussen aanroepen, om de API niet onnodig te belasten


class ApiFout(Exception):
    def __init__(self, status):
        super().__init__(f"HTTP {status}")
        self.status = status


def http_get(url, accept="application/json"):
    """Echte aanroep. Geeft (status, body) terug, ook bij een HTTP-fout."""
    req = urllib.request.Request(
        url, headers={"Accept": accept, "User-Agent": "zetelen-api-check/1.0"}
    )
    time.sleep(PAUZE)
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            return r.status, r.read()
    except urllib.error.HTTPError as e:
        return e.code, e.read()


class Api:
    """Dunne laag over de OData API. `get` is vervangbaar voor de tests."""

    def __init__(self, get=http_get, base=BASE):
        self.get = get
        self.base = base

    def url(self, pad, **params):
        query = "&".join(
            f"${k}={urllib.parse.quote(str(v), safe='')}" for k, v in params.items()
        )
        return f"{self.base}/{pad}" + (f"?{query}" if query else "")

    def json(self, pad, **params):
        status, body = self.get(self.url(pad, **params))
        if status != 200:
            raise ApiFout(status)
        return status, json.loads(body)

    def tel(self, entiteit, filter=None):
        params = {"top": 0, "count": "true"}
        if filter:
            params["filter"] = filter
        _, data = self.json(entiteit, **params)
        return data["@odata.count"]


def lees_metadata(xml_bytes):
    """Geeft per entiteit de velden (naam, type) en de relaties (naam) terug."""
    root = ET.fromstring(xml_bytes)
    tag = lambda e: e.tag.rsplit("}", 1)[-1]
    uit = {}
    for e in root.iter():
        if tag(e) != "EntityType":
            continue
        velden = [(c.get("Name"), c.get("Type")) for c in e if tag(c) == "Property"]
        relaties = [c.get("Name") for c in e if tag(c) == "NavigationProperty"]
        uit[e.get("Name")] = {"velden": velden, "relaties": relaties}
    return uit


def probeer(fn):
    """Voert een controle uit; een API-fout wordt een tekst in het rapport in plaats van een crash."""
    try:
        return fn()
    except ApiFout as e:
        return f"fout: {e}"


def check_entiteit(api, naam, meta, sinds):
    veldnamen = [v for v, _ in meta["velden"]]
    r = {"naam": naam, "velden": meta["velden"], "relaties": meta["relaties"]}

    # Toegang zonder registratie en standaard paginering: aanroep zonder $top en zonder sleutel
    status, body = api.get(api.url(naam))
    r["toegang"] = status
    if status == 200:
        data = json.loads(body)
        r["standaard_pagina"] = len(data.get("value", []))
        r["volgende_link"] = "@odata.nextLink" in data
    # Maximale paginagrootte: MAX_TOP moet werken, MAX_TOP + 1 moet een fout geven
    r["top_max_ok"] = api.get(api.url(naam, top=MAX_TOP))[0] == 200
    r["top_max_plus_fout"] = api.get(api.url(naam, top=MAX_TOP + 1))[0] != 200

    r["aantal"] = probeer(lambda: api.tel(naam))
    if "Verwijderd" in veldnamen:
        r["verwijderd"] = probeer(lambda: api.tel(naam, "Verwijderd eq true"))
    if "ApiGewijzigdOp" in veldnamen:
        r["gewijzigd_recent"] = probeer(
            lambda: api.tel(naam, f"ApiGewijzigdOp ge {sinds}")
        )

    # Grootte-schatting: gemiddelde JSON-grootte per record uit een pagina van MAX_TOP.
    # De records zelf worden alleen gemeten, nooit bewaard of weggeschreven.
    try:
        _, data = api.json(naam, top=MAX_TOP)
        records = data.get("value", [])
        if records:
            totaal = sum(len(json.dumps(x, ensure_ascii=False).encode()) for x in records)
            r["bytes_per_record"] = totaal / len(records)
    except ApiFout as e:
        r["bytes_per_record"] = f"fout: {e}"
    return r


def periodefilter(pad, jaar):
    return (
        f"{pad} ge {jaar}-01-01T00:00:00Z and "
        f"{pad} lt {jaar + 1}-01-01T00:00:00Z"
    )


def stemmingen_per_jaar(api, tot_jaar):
    """Per jaar het aantal stemmingen (niet verwijderd, met een persoon)
    en het aantal besluiten met een stemming (met een persoonsstem)."""
    jaren = []
    for jaar in range(EERSTE_JAAR, tot_jaar + 1):
        periode = periodefilter(DATUMPAD, jaar)
        periode_besluit = periodefilter(DATUMPAD_BESLUIT, jaar)
        jaren.append({
            "jaar": jaar,
            "totaal": api.tel("Stemming", periode),
            "niet_verwijderd": api.tel("Stemming", f"{periode} and Verwijderd eq false"),
            "met_persoon": api.tel("Stemming", f"{periode} and Persoon_Id ne null"),
            "besluiten": api.tel("Besluit", f"Stemming/any() and {periode_besluit}"),
            "besluiten_persoon": api.tel(
                "Besluit", f"Stemming/any(s:s/Persoon_Id ne null) and {periode_besluit}"
            ),
        })
    voor = api.tel("Stemming", f"{DATUMPAD} lt {EERSTE_JAAR}-01-01T00:00:00Z")
    return jaren, voor


def getal(n):
    """1030560 -> 1.030.560; 12.5 -> 12,5. Teksten (foutmeldingen) blijven staan."""
    if isinstance(n, bool) or not isinstance(n, (int, float)):
        return str(n)
    if isinstance(n, float):
        return f"{n:,.1f}".replace(",", "_").replace(".", ",").replace("_", ".")
    return f"{n:,}".replace(",", ".")


def janee(b):
    return "ja" if b else "nee"


def schrijf_rapport(resultaten, jaren, voor_eerste_jaar, totaal_stemming, peildatum, sinds):
    regels = [
        "# API-check rapport",
        "",
        f"Gemaakt door `pipeline/api_check.py` op {peildatum}. Basis-URL: `{BASE}`.",
        "Alleen aantallen en veldnamen, geen waarden uit records en geen namen van personen.",
        "Dit rapport is leidend boven oudere documentatie van de API.",
        "",
        "## Overzicht per entiteit",
        "",
        "| Entiteit | Toegang (HTTP) | Records | Verwijderd | Gewijzigd sinds "
        f"{sinds[:10]} | Standaard per pagina | Volgende-link | `$top={MAX_TOP}` werkt "
        f"| `$top={MAX_TOP + 1}` geeft fout | Bytes per record (JSON) | Schatting raw (MB) |",
        "|---|---|---|---|---|---|---|---|---|---|---|",
    ]
    totaal_mb = 0.0
    for r in resultaten:
        mb = ""
        if isinstance(r.get("bytes_per_record"), float) and isinstance(r.get("aantal"), int):
            mb_waarde = r["bytes_per_record"] * r["aantal"] / 1_000_000
            totaal_mb += mb_waarde
            mb = getal(mb_waarde)
        regels.append(
            f"| {r['naam']} | {r['toegang']} | {getal(r.get('aantal', ''))} "
            f"| {getal(r.get('verwijderd', 'geen veld'))} "
            f"| {getal(r.get('gewijzigd_recent', 'geen veld'))} "
            f"| {getal(r.get('standaard_pagina', ''))} | {janee(r.get('volgende_link'))} "
            f"| {janee(r['top_max_ok'])} | {janee(r['top_max_plus_fout'])} "
            f"| {getal(r.get('bytes_per_record', ''))} | {mb} |"
        )
    regels += [
        "",
        f"Schatting raw-laag voor alle {len(resultaten)} entiteiten samen: {getal(totaal_mb)} MB.",
        f"Methode: gemiddelde JSON-grootte van de eerste {MAX_TOP} records per entiteit, maal het aantal records. "
        "Grof: de eerste pagina hoeft niet representatief te zijn, en opslag in Postgres en indexes "
        "wijken af van JSON. Meten bij component `ingest`.",
        "",
        "## Wijzigingen en verwijderingen",
        "",
        "Herkenbaar per entiteit als het veld `ApiGewijzigdOp` bestaat en erop gefilterd kan worden "
        "(kolom 'Gewijzigd sinds'), en verwijderingen als het veld `Verwijderd` bestaat (kolom 'Verwijderd').",
        "",
        "## Stemmingen per jaar",
        "",
        f"Jaar van de vergadering: `{DATUMPAD}`. Stemming en Besluit hebben zelf geen datum.",
        "Een stemming is hier een rij in Stemming: de stem van een fractie of een persoon op een besluit.",
        "",
        "| Jaar | Stemmingen | Niet verwijderd | Met persoon (`Persoon_Id`) "
        "| Besluiten met een stemming | Besluiten met een persoonsstem |",
        "|---|---|---|---|---|---|",
    ]
    for j in jaren:
        regels.append(
            f"| {j['jaar']} | {getal(j['totaal'])} | {getal(j['niet_verwijderd'])} "
            f"| {getal(j['met_persoon'])} | {getal(j['besluiten'])} | {getal(j['besluiten_persoon'])} |"
        )
    som_jaren = sum(j["totaal"] for j in jaren)
    niet_te_dateren = totaal_stemming - som_jaren - voor_eerste_jaar
    regels += [
        "",
        f"- Stemmingen totaal: {getal(totaal_stemming)}",
        f"- Voor {EERSTE_JAAR}: {getal(voor_eerste_jaar)}",
        f"- {EERSTE_JAAR} tot en met {jaren[-1]['jaar']}: {getal(som_jaren)}",
        f"- Niet te dateren via `{DATUMPAD}` (totaal min de rest): {getal(niet_te_dateren)}",
        "",
        "## Velden per entiteit",
        "",
        "Uit de live `$metadata`.",
    ]
    for r in resultaten:
        regels += ["", f"### {r['naam']}", ""]
        regels.append("Velden: " + ", ".join(f"`{n}` ({t.split('.')[-1]})" for n, t in r["velden"]))
        regels.append("")
        regels.append("Relaties: " + (", ".join(f"`{n}`" for n in r["relaties"]) or "geen"))
    return "\n".join(regels) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--uitvoer", default="docs/plan/api-check-rapport.md")
    args = parser.parse_args()

    api = Api()
    nu = dt.datetime.now(dt.timezone.utc)
    peildatum = nu.strftime("%Y-%m-%d")
    sinds = (nu - dt.timedelta(days=7)).strftime("%Y-%m-%dT00:00:00Z")

    status, xml_bytes = api.get(api.url("$metadata"), accept="application/xml")
    if status != 200:
        raise SystemExit(f"$metadata niet op te halen: HTTP {status}")
    meta = lees_metadata(xml_bytes)
    ontbrekend = [e for e in ENTITEITEN if e not in meta]
    if ontbrekend:
        raise SystemExit(f"Entiteiten niet in $metadata: {', '.join(ontbrekend)}")

    resultaten = []
    for naam in ENTITEITEN:
        print(f"Controle {naam} ...", flush=True)
        resultaten.append(check_entiteit(api, naam, meta[naam], sinds))

    print("Stemmingen per jaar ...", flush=True)
    jaren, voor = stemmingen_per_jaar(api, nu.year)
    totaal_stemming = next(r["aantal"] for r in resultaten if r["naam"] == "Stemming")

    rapport = schrijf_rapport(resultaten, jaren, voor, totaal_stemming, peildatum, sinds)
    with open(args.uitvoer, "w", encoding="utf-8") as f:
        f.write(rapport)
    print(f"Rapport geschreven: {args.uitvoer}")


if __name__ == "__main__":
    main()
