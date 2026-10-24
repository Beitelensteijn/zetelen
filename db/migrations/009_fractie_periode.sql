-- Fracties per periode, voor de zaal, de boog en de fractiepagina's (component cohesie-pagina).
-- Zetels komen uit de stemmingen zelf (fractiegrootte bij de laatste stemming in de periode), niet uit
-- het fractierecord: de stemmen van 50PLUS sinds 2025 staan in de bron op het oude record.
-- in_zaal: de fractie stemde mee in de laatste twee weken van de periode. Fracties die halverwege
-- ophielden (bijvoorbeeld GroenLinks-PvdA onder Jetten) staan wel in de matrix, niet in de zaal.

create unlogged table analyses.fractie_periode (
    periodesoort text not null check (periodesoort in ('kabinet', 'kamerperiode')),
    periode text not null,
    fractie_id uuid not null,
    afkorting text,
    naam text,
    zetels integer not null,
    stemmingen integer not null,
    eerste_stemming date not null,
    laatste_stemming date not null,
    in_zaal boolean not null,
    primary key (periodesoort, periode, fractie_id)
);

alter table analyses.fractie_periode enable row level security;
create policy lezen on analyses.fractie_periode for select to anon, authenticated using (true);
grant select on analyses.fractie_periode to anon, authenticated;

create view api.fractie_periode with (security_invoker = true) as
    select periodesoort, periode, fractie_id as fractie, afkorting, naam, zetels, stemmingen,
           eerste_stemming, laatste_stemming, in_zaal
    from analyses.fractie_periode;

grant select on api.fractie_periode to anon, authenticated;

-- De herbouw met stap 4 erbij (stap 1 tot en met 3 ongewijzigd uit 006_analyse_cohesie.sql)
create or replace function analyses.herbouw()
returns table (tabel text, rijen bigint)
language plpgsql
as $$
begin
    truncate analyses.fractie_besluit_stem, analyses.cohesie, analyses.eensgezindheid, analyses.fractie_periode;

    -- 1. Fractiestem per besluit: eerst de stem uit de bron, dan de afgeleide bij hoofdelijk
    insert into analyses.fractie_besluit_stem (besluit_id, fractie_id, stem, afgeleid)
    select besluit_id, fractie_id, soort, false
    from core.fractiestem
    where soort in ('Voor', 'Tegen') and not vergissing;

    insert into analyses.fractie_besluit_stem (besluit_id, fractie_id, stem, afgeleid)
    select ps.besluit_id, ps.fractie_id,
           case when count(*) filter (where ps.soort = 'Voor') > count(*) filter (where ps.soort = 'Tegen')
                then 'Voor' else 'Tegen' end,
           true
    from core.persoonsstem ps
    join core.besluit b on b.id = ps.besluit_id and b.stemmingssoort = 'Hoofdelijk'
    where ps.soort in ('Voor', 'Tegen') and not ps.vergissing and ps.fractie_id is not null
      and not exists (select 1 from core.fractiestem f
                      where f.besluit_id = ps.besluit_id and f.fractie_id = ps.fractie_id)
    group by ps.besluit_id, ps.fractie_id
    having count(*) filter (where ps.soort = 'Voor') <> count(*) filter (where ps.soort = 'Tegen');

    -- 2. Cohesie per paar, periode en variant
    insert into analyses.cohesie (periodesoort, periode, variant, fractie_a, fractie_b,
                                 gezamenlijk, gelijk, cohesie, te_weinig_data)
    with verdeeld as (
        select besluit_id,
               bool_or(stem = 'Voor') and bool_or(stem = 'Tegen') as verdeeld
        from analyses.fractie_besluit_stem
        group by besluit_id
    ),
    besluit_periode as (
        select b.id as besluit_id, p.periodesoort, p.periode, v.verdeeld
        from core.besluit b
        join verdeeld v on v.besluit_id = b.id
        cross join lateral (values ('kabinet', b.kabinet), ('kamerperiode', b.kamerperiode)) p(periodesoort, periode)
        where p.periode is not null
    ),
    -- Elk paar telt in variant 'alle', en ook in 'verdeeld' als het besluit verdeeld was.
    -- In een doorgang (geen tussenresultaat dat twee keer gebruikt wordt): scheelt schijfruimte
    varianten as (
        select bp.periodesoort, bp.periode, v.variant,
               a.fractie_id as fractie_a, b.fractie_id as fractie_b, (a.stem = b.stem) as gelijk
        from besluit_periode bp
        join analyses.fractie_besluit_stem a on a.besluit_id = bp.besluit_id
        join analyses.fractie_besluit_stem b on b.besluit_id = bp.besluit_id and a.fractie_id < b.fractie_id
        cross join lateral (values ('alle', true), ('verdeeld', bp.verdeeld)) v(variant, telt_mee)
        where v.telt_mee
    )
    select periodesoort, periode, variant, fractie_a, fractie_b,
           count(*), count(*) filter (where gelijk),
           case when count(*) >= 25
                then round(100.0 * count(*) filter (where gelijk) / count(*), 1) end,
           count(*) < 25
    from varianten
    group by periodesoort, periode, variant, fractie_a, fractie_b;

    -- 3. Eensgezindheid per fractie en periode
    insert into analyses.eensgezindheid (periodesoort, periode, fractie_id,
                                        hoofdelijk, hoofdelijk_verdeeld, afwijkers_handopsteken)
    with leden as (
        select ps.besluit_id, ps.fractie_id, b.stemmingssoort, b.kabinet, b.kamerperiode,
               count(*) filter (where ps.soort = 'Voor') as voor,
               count(*) filter (where ps.soort = 'Tegen') as tegen,
               bool_or(f.soort in ('Voor', 'Tegen') and ps.soort in ('Voor', 'Tegen') and ps.soort <> f.soort) as afwijker
        from core.persoonsstem ps
        join core.besluit b on b.id = ps.besluit_id
        left join core.fractiestem f on f.besluit_id = ps.besluit_id and f.fractie_id = ps.fractie_id
        where ps.fractie_id is not null and not ps.vergissing
        group by ps.besluit_id, ps.fractie_id, b.stemmingssoort, b.kabinet, b.kamerperiode
    ),
    per_periode as (
        select p.periodesoort, p.periode, l.*
        from leden l
        cross join lateral (values ('kabinet', l.kabinet), ('kamerperiode', l.kamerperiode)) p(periodesoort, periode)
        where p.periode is not null
    )
    select periodesoort, periode, fractie_id,
           count(*) filter (where stemmingssoort = 'Hoofdelijk' and voor + tegen > 0),
           count(*) filter (where stemmingssoort = 'Hoofdelijk' and voor > 0 and tegen > 0),
           count(*) filter (where stemmingssoort <> 'Hoofdelijk' and afwijker)
    from per_periode
    group by periodesoort, periode, fractie_id;


    -- 4. Fracties per periode, voor de zaal en de fractiepagina's (component cohesie-pagina)
    insert into analyses.fractie_periode (periodesoort, periode, fractie_id, afkorting, naam, zetels,
                                          stemmingen, eerste_stemming, laatste_stemming, in_zaal)
    with stem_periode as (
        select p.periodesoort, p.periode, s.fractie_id, b.datum, b.id as besluit_id
        from analyses.fractie_besluit_stem s
        join core.besluit b on b.id = s.besluit_id
        cross join lateral (values ('kabinet', b.kabinet), ('kamerperiode', b.kamerperiode)) p(periodesoort, periode)
        where p.periode is not null
    ),
    einde as (
        select periodesoort, periode, max(datum) as laatste from stem_periode group by periodesoort, periode
    ),
    per_fractie as (
        select periodesoort, periode, fractie_id, count(*) as stemmingen,
               min(datum) as eerste, max(datum) as laatste
        from stem_periode
        group by periodesoort, periode, fractie_id
    ),
    -- Zetels: de fractiegrootte bij de laatste stemming met handopsteken van die fractie in de periode
    grootte as (
        select distinct on (p.periodesoort, p.periode, f.fractie_id)
               p.periodesoort, p.periode, f.fractie_id, f.fractiegrootte
        from core.fractiestem f
        join core.besluit b on b.id = f.besluit_id
        cross join lateral (values ('kabinet', b.kabinet), ('kamerperiode', b.kamerperiode)) p(periodesoort, periode)
        where p.periode is not null and f.fractiegrootte is not null
        order by p.periodesoort, p.periode, f.fractie_id, b.datum desc
    )
    select pf.periodesoort, pf.periode, pf.fractie_id, fr.afkorting, fr.naam, coalesce(g.fractiegrootte, 0),
           pf.stemmingen, pf.eerste, pf.laatste,
           -- In de zaal: stemde nog mee in de laatste twee weken van de periode
           pf.laatste >= e.laatste - 14
    from per_fractie pf
    join einde e on e.periodesoort = pf.periodesoort and e.periode = pf.periode
    join core.fractie fr on fr.id = pf.fractie_id
    left join grootte g on g.periodesoort = pf.periodesoort and g.periode = pf.periode and g.fractie_id = pf.fractie_id;

    return query
        select 'fractie_besluit_stem', count(*) from analyses.fractie_besluit_stem
        union all select 'cohesie', count(*) from analyses.cohesie
        union all select 'eensgezindheid', count(*) from analyses.eensgezindheid
        union all select 'fractie_periode', count(*) from analyses.fractie_periode;
end;
$$;

revoke execute on function analyses.herbouw() from public;
