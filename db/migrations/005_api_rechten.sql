-- Rechten en het publieke schema api (component rechten, story E1-S6).
-- Uitgangspunt: alles dicht, alleen lezen via de views in schema api.
--   api     het enige schema dat in Supabase open staat (Data API, "Exposed schemas"). Views met
--           security_invoker, zodat ze met de rechten van de bezoeker lezen en RLS niet omzeilen
--   core    RLS aan op elke tabel; anon en authenticated mogen alleen lezen wat een api-view nodig heeft
--   raw     RLS aan zonder beleid en geen rechten voor bezoekers
--   beheer  RLS aan; bezoekers zien alleen tijdstip en status van geslaagde verversingen
-- De eigenaar (postgres, gebruikt door ingest en de migraties) omzeilt RLS en houdt alle rechten.
-- Besluit Niels (24 oktober 2026): geen aparte schrijfrol voor de verversing; zie rechten.md.

-- In Supabase bestaan anon en authenticated al; in de testdatabase van CI niet
do $$
begin
    if not exists (select from pg_roles where rolname = 'anon') then
        create role anon nologin;
    end if;
    if not exists (select from pg_roles where rolname = 'authenticated') then
        create role authenticated nologin;
    end if;
end
$$;

-- RLS aan op elke tabel in de eigen schema's: wat geen beleid heeft, is voor bezoekers onzichtbaar
alter table core.kabinet enable row level security;
alter table core.kamerperiode enable row level security;
alter table core.fractie_partij enable row level security;
alter table core.fractie enable row level security;
alter table core.persoon enable row level security;
alter table core.besluit enable row level security;
alter table core.fractiestem enable row level security;
alter table core.persoonsstem enable row level security;
alter table core.zaak enable row level security;
alter table core.besluit_zaak enable row level security;

alter table raw.stemming enable row level security;
alter table raw.besluit enable row level security;
alter table raw.zaak enable row level security;
alter table raw.persoon enable row level security;
alter table raw.fractie enable row level security;
alter table raw.fractiezetel enable row level security;
alter table raw.fractiezetelpersoon enable row level security;
alter table raw.activiteit enable row level security;
alter table raw.activiteitactor enable row level security;
alter table raw.commissie enable row level security;
alter table raw.document enable row level security;
alter table raw.zaakactor enable row level security;
alter table raw.agendapunt enable row level security;
alter table raw.vergadering enable row level security;
alter table raw.besluit_zaak enable row level security;
alter table raw.laadstatus enable row level security;

alter table beheer.migraties enable row level security;
alter table beheer.verversing enable row level security;

-- Functies zijn standaard door iedereen uit te voeren; de herbouw alleen door de eigenaar
revoke execute on function core.herbouw() from public;

-- Leesbeleid op de tabellen onder de api-views
create policy lezen on core.kabinet for select to anon, authenticated using (true);
create policy lezen on core.kamerperiode for select to anon, authenticated using (true);
create policy lezen on core.fractie for select to anon, authenticated using (true);
create policy lezen_geslaagd on beheer.verversing for select to anon, authenticated using (status = 'geslaagd');

grant usage on schema core to anon, authenticated;
grant select on core.kabinet, core.kamerperiode, core.fractie to anon, authenticated;
grant usage on schema beheer to anon, authenticated;
grant select (klaar_op, status) on beheer.verversing to anon, authenticated;

-- Het publieke schema
create schema api;
grant usage on schema api to anon, authenticated;

create view api.kabinet with (security_invoker = true) as
    select naam, begin, einde from core.kabinet;

create view api.kamerperiode with (security_invoker = true) as
    select naam, begin, einde, verkiezingsdatum from core.kamerperiode;

create view api.fractie with (security_invoker = true) as
    select id, afkorting, naam, actief_van, actief_tot, partij from core.fractie;

-- Voor de "laatst bijgewerkt"-datum op de site (interface naar site-shell)
create view api.laatst_bijgewerkt with (security_invoker = true) as
    select max(klaar_op) as laatst_bijgewerkt from beheer.verversing where status = 'geslaagd';

grant select on api.kabinet, api.kamerperiode, api.fractie, api.laatst_bijgewerkt to anon, authenticated;
