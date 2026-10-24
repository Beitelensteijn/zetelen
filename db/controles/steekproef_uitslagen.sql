-- Steekproef voor de vergelijking met de officiele stemmingsuitslagen (E7-S5): 10 willekeurige
-- besluiten met de stemmen per fractie zoals de database ze heeft. Alleen lezen.
-- Draaien in VS Code (verbinding met Supabase). Vergelijk per besluit met de uitslag op
-- tweedekamer.nl (zoek op het zaaknummer of op de datum bij "Stemmingsuitslagen") en leg de
-- uitkomst vast in docs/steekproeven/ (sjabloon: R1-uitslagen.md).

with steekproef as (
    select id from core.besluit order by random() limit 10
)
select b.datum, b.stemmingssoort, b.besluitsoort,
       -- Soort en onderwerp, niet de titel: bij moties en amendementen is de titel die van het hele dossier
       (select string_agg(z.nummer || ' ' || coalesce(z.soort, '') || ': ' || coalesce(z.onderwerp, z.titel, ''), ' | ')
        from core.besluit_zaak bz join core.zaak z on z.id = bz.zaak_id where bz.besluit_id = b.id) as zaak,
       (select string_agg(f.afkorting, ', ' order by f.afkorting)
        from core.fractiestem s join core.fractie f on f.id = s.fractie_id
        where s.besluit_id = b.id and s.soort = 'Voor') as voor,
       (select string_agg(f.afkorting, ', ' order by f.afkorting)
        from core.fractiestem s join core.fractie f on f.id = s.fractie_id
        where s.besluit_id = b.id and s.soort = 'Tegen') as tegen,
       (select sum(fractiegrootte) from core.fractiestem s where s.besluit_id = b.id and s.soort = 'Voor') as zetels_voor,
       (select sum(fractiegrootte) from core.fractiestem s where s.besluit_id = b.id and s.soort = 'Tegen') as zetels_tegen,
       b.id as besluit_id
from steekproef st
join core.besluit b on b.id = st.id
order by b.datum;
-- Bij een hoofdelijke stemming zijn voor, tegen en de zetels leeg: vergelijk dan met
-- select soort, count(*) from core.persoonsstem where besluit_id = '<besluit_id>' group by soort;
