-- Stemmatrix per periode voor de coalitiebouwer (component coalitie-analyse, E2-S8).
-- Het aantal combinaties van fracties is te groot om vooraf te rekenen; de browser rekent op dit
-- compacte overzicht (keuze uit coalitie-analyse.md, optie 1). Per periode een rij:
--   fracties  [{id, afkorting}] in vaste volgorde
--   stemmen   per besluit een tekst met per fractie V (voor), T (tegen) of - (geen stem)
--   zetels    per fractie de wijzigingen van de fractiegrootte: [[besluitnummer, zetels], ...]
-- Stem: zoals in analyses.fractie_besluit_stem (zonder vergissingen, afgeleid bij hoofdelijk).
-- Zetels: fractiegrootte bij handopsteken; bij hoofdelijk het aantal leden dat voor of tegen stemde.

create unlogged table analyses.stemmatrix (
    periodesoort text not null check (periodesoort in ('kabinet', 'kamerperiode')),
    periode text not null,
    fracties jsonb not null,
    stemmen jsonb not null,
    zetels jsonb not null,
    primary key (periodesoort, periode)
);

alter table analyses.stemmatrix enable row level security;
create policy lezen on analyses.stemmatrix for select to anon, authenticated using (true);
grant select on analyses.stemmatrix to anon, authenticated;

create view api.stemmatrix with (security_invoker = true) as
    select periodesoort, periode, fracties, stemmen, zetels from analyses.stemmatrix;
grant select on api.stemmatrix to anon, authenticated;

create function analyses.herbouw_stemmatrix()
returns bigint
language plpgsql
as $$
begin
    truncate analyses.stemmatrix;

    insert into analyses.stemmatrix (periodesoort, periode, fracties, stemmen, zetels)
    with besluit_periode as (
        select p.periodesoort, p.periode, b.id as besluit_id,
               row_number() over (partition by p.periodesoort, p.periode order by b.datum, b.id) - 1 as nr
        from core.besluit b
        cross join lateral (values ('kabinet', b.kabinet), ('kamerperiode', b.kamerperiode)) p(periodesoort, periode)
        where p.periode is not null
          and exists (select 1 from analyses.fractie_besluit_stem s where s.besluit_id = b.id)
    ),
    fractie_nr as (
        select periodesoort, periode, fractie_id, afkorting,
               row_number() over (partition by periodesoort, periode order by afkorting, fractie_id) - 1 as fnr
        from analyses.fractie_periode
    ),
    grootte as (
        select f.besluit_id, f.fractie_id, f.fractiegrootte as zetels
        from core.fractiestem f
        where f.fractiegrootte is not null
        union all
        select ps.besluit_id, ps.fractie_id, count(*)
        from core.persoonsstem ps
        join core.besluit b on b.id = ps.besluit_id and b.stemmingssoort = 'Hoofdelijk'
        where ps.soort in ('Voor', 'Tegen') and not ps.vergissing and ps.fractie_id is not null
        group by ps.besluit_id, ps.fractie_id
    ),
    cel as (
        select bp.periodesoort, bp.periode, bp.nr, fn.fnr, fn.fractie_id,
               case s.stem when 'Voor' then 'V' when 'Tegen' then 'T' else '-' end as teken,
               case when s.stem is not null then g.zetels end as zetels
        from besluit_periode bp
        join fractie_nr fn on fn.periodesoort = bp.periodesoort and fn.periode = bp.periode
        left join analyses.fractie_besluit_stem s on s.besluit_id = bp.besluit_id and s.fractie_id = fn.fractie_id
        left join grootte g on g.besluit_id = bp.besluit_id and g.fractie_id = fn.fractie_id
    ),
    regels as (
        select periodesoort, periode, nr, string_agg(teken, '' order by fnr) as regel
        from cel group by periodesoort, periode, nr
    ),
    wijziging as (
        select periodesoort, periode, fnr, nr, zetels,
               lag(zetels) over (partition by periodesoort, periode, fnr order by nr) as vorige
        from cel where zetels is not null
    ),
    zetelreeks as (
        select periodesoort, periode, fnr,
               jsonb_agg(jsonb_build_array(nr, zetels) order by nr) filter (where vorige is distinct from zetels) as reeks
        from wijziging group by periodesoort, periode, fnr
    )
    select fn.periodesoort, fn.periode,
           jsonb_agg(jsonb_build_object('id', fn.fractie_id, 'afkorting', fn.afkorting) order by fn.fnr),
           (select jsonb_agg(r.regel order by r.nr) from regels r
            where r.periodesoort = fn.periodesoort and r.periode = fn.periode),
           jsonb_agg(coalesce(z.reeks, '[]'::jsonb) order by fn.fnr)
    from fractie_nr fn
    left join zetelreeks z on z.periodesoort = fn.periodesoort and z.periode = fn.periode and z.fnr = fn.fnr
    group by fn.periodesoort, fn.periode;

    return (select count(*) from analyses.stemmatrix);
end;
$$;

revoke execute on function analyses.herbouw_stemmatrix() from public;
