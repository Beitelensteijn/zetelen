// Lezen uit de Data API van Supabase (schema api), op de server.
// De pagina's worden statisch gebouwd en elk uur ververst (ISR): is de database even weg,
// dan blijft de laatste goede versie staan (E3-S9).
export const VERVERS_SECONDEN = 3600;

export async function leesApi<T>(pad: string): Promise<T | null> {
  const basis = process.env.SUPABASE_URL;
  const sleutel = process.env.SUPABASE_PUBLISHABLE_KEY;
  if (!basis || !sleutel) return null;
  try {
    const antwoord = await fetch(`${basis.replace(/\/$/, "")}/rest/v1/${pad}`, {
      headers: { apikey: sleutel, "Accept-Profile": "api", Accept: "application/json" },
      next: { revalidate: VERVERS_SECONDEN },
    });
    if (!antwoord.ok) return null;
    return (await antwoord.json()) as T;
  } catch {
    return null;
  }
}

export async function laatstBijgewerkt(): Promise<Date | null> {
  const rijen = await leesApi<Array<{ laatst_bijgewerkt: string | null }>>("laatst_bijgewerkt");
  const waarde = rijen?.[0]?.laatst_bijgewerkt;
  return waarde ? new Date(waarde) : null;
}

// 24 oktober 2026, 06:31 (Nederlandse tijd)
export function datumTekst(d: Date): string {
  return new Intl.DateTimeFormat("nl-NL", {
    day: "numeric",
    month: "long",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    timeZone: "Europe/Amsterdam",
  }).format(d);
}
