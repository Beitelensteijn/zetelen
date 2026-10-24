// Controle op de gebouwde site (E1-S6, overgenomen in site-shell): geen geheime sleutel in de build,
// en de publieke sleutel niet in de code die naar de browser gaat (die is alleen voor de server).
// Gericht zoeken: Next.js zet zelf willekeurige sleutels in .next, waar een algemene scan op aanslaat.
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

const VERBODEN = [
  { naam: "secret-sleutel van Supabase", patroon: /sb_secret_[A-Za-z0-9_-]{10,}/ },
  { naam: "service_role-sleutel (JWT)", patroon: /"role"\s*:\s*"service_role"/ },
  { naam: "naam van een geheime variabele", patroon: /SUPABASE_SERVICE_ROLE|DATABASE_URL=postgres/ },
  { naam: "connectiestring met wachtwoord", patroon: /postgres(ql)?:\/\/[^\s"'@]+:[^\s"'@]+@/ },
];

function bestanden(map) {
  return readdirSync(map).flatMap((n) => {
    const pad = join(map, n);
    return statSync(pad).isDirectory() ? bestanden(pad) : [pad];
  });
}

const fouten = [];
for (const pad of bestanden(".next").filter((p) => !p.includes(`${join(".next", "cache")}`))) {
  const inhoud = readFileSync(pad, "latin1");
  for (const v of VERBODEN) if (v.patroon.test(inhoud)) fouten.push(`${v.naam} in ${pad}`);
}

const publiek = process.env.SUPABASE_PUBLISHABLE_KEY;
if (publiek) {
  for (const pad of bestanden(join(".next", "static"))) {
    if (readFileSync(pad, "latin1").includes(publiek)) fouten.push(`publieke sleutel in browsercode: ${pad}`);
  }
}

if (fouten.length) {
  console.error("Controle op de build mislukt:\n" + fouten.map((f) => `  ${f}`).join("\n"));
  process.exit(1);
}
console.log("Controle op de build geslaagd: geen geheimen gevonden.");
