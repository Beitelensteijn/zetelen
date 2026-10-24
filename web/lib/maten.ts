// De maten op de site, voor de methodiekpagina (E3-S3). Een nieuwe analyse voegt hier haar maat toe
// voordat ze live gaat; een test controleert dat elke maat compleet is.
// Bron van de tekst over cohesie: docs/plan/definitie-cohesie.md (goedgekeurd door Niels, 24 oktober 2026).
export type Maat = { id: string; naam: string; definitie: string; formule: string; keuzes: string[]; beperkingen: string[] };

export const MATEN: Maat[] = [
  {
    id: "cohesie",
    naam: "Cohesie tussen fracties",
    definitie:
      "Cohesie tussen twee fracties is het percentage van hun gezamenlijke stemmingen waarin ze hetzelfde stemden. Een gezamenlijke stemming is een besluit waarover beide fracties voor of tegen stemden; stemmingen waarbij een van de twee niet deelnam of afwezig was, tellen niet mee. Bij een hoofdelijke stemming telt als stem van de fractie wat de meerderheid van haar leden stemde.",
    formule:
      "het aantal gezamenlijke stemmingen met dezelfde stem, gedeeld door het aantal gezamenlijke stemmingen, maal 100. Bij minder dan 25 gezamenlijke stemmingen geen percentage maar \"te weinig data\".",
    keuzes: [
      "Per kabinet en per Kamerperiode. Een kabinet loopt tot het volgende is beëdigd: de demissionaire tijd telt mee bij het kabinet waar die uit voortkomt.",
      "Twee varianten: alle stemmingen, en alleen de stemmingen waarover de Kamer verdeeld was (minstens één fractie voor en één tegen). Veel stemmingen zijn unaniem; de tweede variant laat die weg.",
      "Een stem die de fractie zelf als vergissing heeft gemeld, telt niet mee: de bron zegt niet wat de fractie wel bedoelde.",
      "Bij een hoofdelijke stemming en een gelijke stand binnen de fractie is er geen fractiestem.",
      "Hamerstukken en besluiten zonder stemming tellen niet mee.",
    ],
    beperkingen: [
      "Cohesie telt stemmen, geen redenen. Twee fracties kunnen om heel verschillende redenen hetzelfde stemmen.",
      "Elk besluit telt even zwaar, of het nu gaat om een wet of om een procedurele motie.",
      "De volgorde van de fracties in de zaal komt uit de cijfers (fracties die vaak hetzelfde stemmen, zitten naast elkaar), niet uit de echte zaalindeling of een links-rechtsschaal.",
    ],
  },
];
