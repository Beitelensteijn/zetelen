-- Steekproef voor de handmatige nacontrole van cohesie (E2-S2): 10 willekeurige besluiten waarop
-- twee fracties allebei voor of tegen stemden, met de zaak erbij. Alleen lezen.
-- Draaien in VS Code (verbinding met Supabase). Pas de afkortingen en het kabinet aan.
-- Controleer per regel de stemmen op tweedekamer.nl (zoek op het zaaknummer) en tel zelf hoe vaak
-- ze gelijk stemden; vergelijk dat met de regel uit api.cohesie onderaan.

with paar as (
    select (select id from core.fractie where afkorting = 'VVD' and actief_tot is null) as a,
           (select id from core.fractie where afkorting = 'CDA' and actief_tot is null) as b,
           'Schoof'::text as kabinet
)
-- Soort en onderwerp, niet de titel: bij moties en amendementen is de titel die van het hele dossier
select b.datum, z.nummer as zaaknummer, z.soort, coalesce(z.onderwerp, z.titel) as onderwerp,
       sa.stem as stem_a, sb.stem as stem_b,
       sa.afgeleid or sb.afgeleid as afgeleid_uit_leden
from paar
join core.besluit b on b.kabinet = paar.kabinet
join analyses.fractie_besluit_stem sa on sa.besluit_id = b.id and sa.fractie_id = paar.a
join analyses.fractie_besluit_stem sb on sb.besluit_id = b.id and sb.fractie_id = paar.b
left join core.besluit_zaak bz on bz.besluit_id = b.id
left join core.zaak z on z.id = bz.zaak_id
order by random()
limit 10;

-- De berekende uitkomst voor hetzelfde paar en kabinet
select variant, gezamenlijk, gelijk, cohesie
from api.cohesie
where periodesoort = 'kabinet' and periode = 'Schoof'
  and fractie_afkorting = 'VVD' and andere_fractie_afkorting = 'CDA';
