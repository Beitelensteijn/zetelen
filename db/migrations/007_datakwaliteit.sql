-- Datakwaliteit (component datakwaliteit, story E7-S5).
-- Controles die na elke verversing draaien (pipeline/ververs.py, na de herbouw van core en analyses).
-- Elke controle krijgt een oordeel:
--   goed     binnen de grens
--   signaal  afwijking die Niels moet bekijken; de verversing gaat door
--   fout     harde fout (bijvoorbeeld meer dan 150 zetels); de verversing faalt, dus er komt een melding
-- De uitkomst staat per run in beheer.datakwaliteit; de details in de views hieronder.

create table beheer.datakwaliteit (
    id bigint generated always as identity primary key,
    gemeten_op timestamptz not null default now(),
    controle text not null,
    waarde bigint not null,
    oordeel text not null check (oordeel in ('goed', 'signaal', 'fout')),
    toelichting text not null
);

alter table beheer.datakwaliteit enable row level security;

-- Detail: besluiten waarvan de uitslag volgens de stemmen niet past bij de officiele uitslag in de bron.
-- Bij handopsteken telt de fractiegrootte, bij hoofdelijk het aantal leden. Vergissingen tellen mee:
-- officieel telt een stem zoals hij is uitgebracht.
create view beheer.afwijkende_uitslag with (security_invoker = true) as
with stemmen as (
    select besluit_id,
           sum(fractiegrootte) filter (where soort = 'Voor') as voor,
           sum(fractiegrootte) filter (where soort = 'Tegen') as tegen
    from core.fractiestem
    group by besluit_id
    union all
    select ps.besluit_id,
           count(*) filter (where ps.soort = 'Voor'),
           count(*) filter (where ps.soort = 'Tegen')
    from core.persoonsstem ps
    join core.besluit b on b.id = ps.besluit_id and b.stemmingssoort = 'Hoofdelijk'
    group by ps.besluit_id
)
select b.id as besluit_id, b.datum, b.stemmingssoort, b.besluitsoort,
       coalesce(s.voor, 0) as zetels_voor, coalesce(s.tegen, 0) as zetels_tegen,
       (select string_agg(z.nummer, ', ') from core.besluit_zaak bz join core.zaak z on z.id = bz.zaak_id
        where bz.besluit_id = b.id) as zaaknummers
from core.besluit b
join stemmen s on s.besluit_id = b.id
where (b.besluitsoort = 'Stemmen - aangenomen' and coalesce(s.voor, 0) <= coalesce(s.tegen, 0))
   or (b.besluitsoort in ('Stemmen - verworpen', 'Stemmen - niet aangenomen') and coalesce(s.voor, 0) > coalesce(s.tegen, 0))
   or (b.besluitsoort = 'Stemmen - gestaakt' and coalesce(s.voor, 0) <> coalesce(s.tegen, 0));

create function beheer.controleer_datakwaliteit()
returns table (controle text, waarde bigint, oordeel text, toelichting text)
language plpgsql
as $$
declare
    n bigint;
    totaal bigint;
begin
    create temporary table uitkomst (controle text, waarde bigint, oordeel text, toelichting text) on commit drop;

    -- 1. Nooit meer dan 150 zetels op een besluit (E7-S5)
    select count(*) into n from (
        select besluit_id from core.fractiestem group by besluit_id having sum(fractiegrootte) > 150
        union all
        select besluit_id from core.persoonsstem group by besluit_id having count(*) > 150
    ) x;
    insert into uitkomst values ('Besluiten met meer dan 150 zetels', n,
        case when n = 0 then 'goed' else 'fout' end,
        'Som van de fractiegrootte (handopsteken) of het aantal leden (hoofdelijk) per besluit');

    -- 2. Uitslag volgens de stemmen tegen de officiele uitslag in de bron
    select count(*) into n from beheer.afwijkende_uitslag;
    select count(*) into totaal from core.besluit;
    insert into uitkomst values ('Besluiten waarvan de uitslag niet past bij de stemmen', n,
        case when n = 0 then 'goed' else 'signaal' end,
        format('Van %s besluiten; details in beheer.afwijkende_uitslag', translate(to_char(totaal, 'FM999,999,999'), ',', '.')));

    -- 3. Geladen stemmingen die niet (meer) te dateren zijn (tellen niet mee, besluit Niels 23 oktober 2026)
    select count(*) into n
    from raw.stemming s
    where not coalesce(s."Verwijderd", false)
      and not exists (
          select 1 from raw.besluit b
          join raw.agendapunt a on a."Id" = b."Agendapunt_Id"
          join raw.activiteit ac on ac."Id" = a."Activiteit_Id"
          where b."Id" = s."Besluit_Id" and ac."Datum" is not null);
    insert into uitkomst values ('Geladen stemmingen zonder datum', n,
        case when n = 0 then 'goed' else 'signaal' end,
        'Stemmingen in raw waarvan de datum via agendapunt en activiteit inmiddels ontbreekt. Stemmingen die al bij het laden geen datum hadden (5.766 volgens het API-checkrapport) worden niet geladen');

    -- 4. Besluiten in raw die buiten het datumfilter zijn gevallen (datum van de vergadering inmiddels voor 2010)
    select count(*) into n
    from raw.besluit b
    join raw.agendapunt a on a."Id" = b."Agendapunt_Id"
    join raw.activiteit ac on ac."Id" = a."Activiteit_Id"
    where ac."Datum" < timestamptz '2010-01-01 00:00:00+01';
    insert into uitkomst values ('Besluiten in raw met een datum voor 2010', n,
        case when n = 0 then 'goed' else 'signaal' end,
        'Vielen na de eerste laad buiten het datumfilter; de verversing ruimt ze niet op. Tellen niet mee in core');

    insert into beheer.datakwaliteit (controle, waarde, oordeel, toelichting)
    select u.controle, u.waarde, u.oordeel, u.toelichting from uitkomst u;

    return query select u.controle, u.waarde, u.oordeel, u.toelichting from uitkomst u;
end;
$$;

revoke execute on function beheer.controleer_datakwaliteit() from public;
