-- Analyse-laag: cohesie tussen fracties en eensgezindheid binnen fracties
-- (component cohesie-analyse, stories E2-S1 en E2-S2). Definitie: docs/plan/definitie-cohesie.md.
-- Alle tabellen zijn afgeleid en unlogged, en worden na elke verversing opnieuw opgebouwd door
-- analyses.herbouw() (na core.herbouw()). Publiek leesbaar via de views api.cohesie en api.eensgezindheid.

create schema if not exists analyses;

-- De stem van een fractie op een besluit zoals cohesie die gebruikt: alleen voor of tegen.
-- Uit core.fractiestem, zonder vergissingen. Bij hoofdelijke stemmingen (geen fractiestem in de bron)
-- afgeleid uit de meerderheid van de leden; bij een gelijke stand geen stem.
create unlogged table analyses.fractie_besluit_stem (
    besluit_id uuid not null,
    fractie_id uuid not null,
    stem text not null check (stem in ('Voor', 'Tegen')),
    afgeleid boolean not null,          -- true = afgeleid uit de leden (hoofdelijk)
    primary key (besluit_id, fractie_id)
);

-- Cohesie per fractiepaar (fractie_a < fractie_b), periode en variant.
--   gezamenlijk (G): besluiten waarop beide fracties voor of tegen stemden
--   gelijk (S):      het deel daarvan waarop ze hetzelfde stemden
--   cohesie:         S / G x 100, leeg als G kleiner is dan 25 ("te weinig data")
create unlogged table analyses.cohesie (
    periodesoort text not null check (periodesoort in ('kabinet', 'kamerperiode')),
    periode text not null,
    variant text not null check (variant in ('alle', 'verdeeld')),
    fractie_a uuid not null,
    fractie_b uuid not null,
    gezamenlijk integer not null,
    gelijk integer not null,
    cohesie numeric(4, 1),
    te_weinig_data boolean not null,
    primary key (periodesoort, periode, variant, fractie_a, fractie_b),
    check (fractie_a < fractie_b)
);

-- Eensgezindheid per fractie en periode. Alleen zichtbaar waar de bron de stem per lid kent.
--   hoofdelijk:              hoofdelijke stemmingen waarin minstens een lid van de fractie voor of tegen stemde
--   hoofdelijk_verdeeld:     het deel daarvan met leden aan beide kanten
--   afwijkers_handopsteken:  stemmingen met handopsteken waarin een lid anders stemde dan de fractie
create unlogged table analyses.eensgezindheid (
    periodesoort text not null check (periodesoort in ('kabinet', 'kamerperiode')),
    periode text not null,
    fractie_id uuid not null,
    hoofdelijk integer not null,
    hoofdelijk_verdeeld integer not null,
    afwijkers_handopsteken integer not null,
    primary key (periodesoort, periode, fractie_id)
);

create function analyses.herbouw()
returns table (tabel text, rijen bigint)
language plpgsql
as $$
begin
    truncate analyses.fractie_besluit_stem, analyses.cohesie, analyses.eensgezindheid;

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

    return query
        select 'fractie_besluit_stem', count(*) from analyses.fractie_besluit_stem
        union all select 'cohesie', count(*) from analyses.cohesie
        union all select 'eensgezindheid', count(*) from analyses.eensgezindheid;
end;
$$;

-- Rechten (zie 005_api_rechten.sql): RLS aan, alleen lezen voor bezoekers via api
revoke execute on function analyses.herbouw() from public;

alter table analyses.fractie_besluit_stem enable row level security;
alter table analyses.cohesie enable row level security;
alter table analyses.eensgezindheid enable row level security;

create policy lezen on analyses.cohesie for select to anon, authenticated using (true);
create policy lezen on analyses.eensgezindheid for select to anon, authenticated using (true);

grant usage on schema analyses to anon, authenticated;
grant select on analyses.cohesie, analyses.eensgezindheid to anon, authenticated;

-- Publieke views. Cohesie in beide richtingen, zodat de site per fractie kan filteren,
-- met de afkortingen erbij voor de leesbaarheid
create view api.cohesie with (security_invoker = true) as
    select c.periodesoort, c.periode, c.variant,
           c.fractie_a as fractie, fa.afkorting as fractie_afkorting,
           c.fractie_b as andere_fractie, fb.afkorting as andere_fractie_afkorting,
           c.gezamenlijk, c.gelijk, c.cohesie, c.te_weinig_data
    from analyses.cohesie c
    join core.fractie fa on fa.id = c.fractie_a
    join core.fractie fb on fb.id = c.fractie_b
    union all
    select c.periodesoort, c.periode, c.variant,
           c.fractie_b, fb.afkorting, c.fractie_a, fa.afkorting,
           c.gezamenlijk, c.gelijk, c.cohesie, c.te_weinig_data
    from analyses.cohesie c
    join core.fractie fa on fa.id = c.fractie_a
    join core.fractie fb on fb.id = c.fractie_b;

create view api.eensgezindheid with (security_invoker = true) as
    select e.periodesoort, e.periode, e.fractie_id as fractie, f.afkorting as fractie_afkorting,
           e.hoofdelijk, e.hoofdelijk_verdeeld, e.afwijkers_handopsteken
    from analyses.eensgezindheid e
    join core.fractie f on f.id = e.fractie_id;

grant select on api.cohesie, api.eensgezindheid to anon, authenticated;
