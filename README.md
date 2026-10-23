# Zetelen

Zetelen is een publieke website over het stemgedrag in de Tweede Kamer, gebouwd op de open data van de Kamer. Een Python-script in GitHub Actions haalt dagelijks de gegevens op uit de OData API van de Tweede Kamer en laadt ze in een Supabase-database (Postgres), waar SQL ze in drie lagen verwerkt: een ruwe kopie, een opgeschoond datamodel en voorberekende analyses. Een Next.js-site op Vercel leest alleen die analyses en toont ze, met bij elke analyse twee onderbouwde lezingen naast elkaar. Het plan staat in `docs/plan/`, het onderhoud in `docs/onderhoud.md`.
