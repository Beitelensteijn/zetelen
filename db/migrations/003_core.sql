-- Core-laag: opgeschoond datamodel boven de raw-laag (component core-model, story E1-S5).
-- Twee soorten tabellen:
--   handmatig: kabinet, kamerperiode, fractie_partij. Gevuld in deze migratie, nagekeken door Niels
--   afgeleid:  besluit, fractiestem, persoonsstem, fractie, persoon, zaak, besluit_zaak. Elke keer
--              volledig opnieuw opgebouwd door core.herbouw(), na de dagelijkse verversing
-- Overal weggelaten: verwijderde records, stemmingen voor 2010 en besluiten zonder datum.
-- Een periode loopt van begin tot (niet tot en met) einde; einde leeg = loopt nog.

create schema if not exists core;

-- Handmatig: kabinetten (E1-S8). Bron Wikidata (CC0), besluit Niels 23 oktober 2026.
-- Een kabinet loopt tot het volgende kabinet is beëdigd: de demissionaire fase telt bij het
-- kabinet waar die uit voortkomt (besluit Niels, 24 oktober 2026).
create table core.kabinet (
    naam text primary key,
    begin date not null,
    einde date,
    wikidata_id text not null,
    bron text not null,
    gecontroleerd_op date,          -- datum waarop Niels de rij heeft nagekeken; leeg = nog niet
    coalitiefracties text[]         -- in R1 nog niet gevuld
);

insert into core.kabinet (naam, begin, einde, wikidata_id, bron) values
    ('Balkenende IV', '2007-02-22', '2010-10-14', 'Q1719725', 'Wikidata, opgehaald 24 oktober 2026'),
    ('Rutte I', '2010-10-14', '2012-11-05', 'Q168828', 'Wikidata, opgehaald 24 oktober 2026'),
    ('Rutte II', '2012-11-05', '2017-10-26', 'Q1638648', 'Wikidata, opgehaald 24 oktober 2026'),
    ('Rutte III', '2017-10-26', '2022-01-10', 'Q42293409', 'Wikidata, opgehaald 24 oktober 2026'),
    ('Rutte IV', '2022-01-10', '2024-07-02', 'Q110111120', 'Wikidata, opgehaald 24 oktober 2026'),
    ('Schoof', '2024-07-02', '2026-02-23', 'Q126527270', 'Wikidata, opgehaald 24 oktober 2026'),
    ('Jetten', '2026-02-23', null, 'Q137926983', 'Wikidata, opgehaald 24 oktober 2026');

-- Handmatig: Kamerperiodes. Begin = installatie van de nieuwe Kamer, afgeleid uit de API
-- (de dag waarop tientallen Kamerleden tegelijk in een fractie beginnen, FractieZetelPersoon.Van).
-- Verkiezingsdatum: kennis van Claude, te controleren bij de Kiesraad.
create table core.kamerperiode (
    naam text primary key,
    begin date not null,
    einde date,
    verkiezingsdatum date not null,
    bron text not null,
    gecontroleerd_op date
);

insert into core.kamerperiode (naam, begin, einde, verkiezingsdatum, bron) values
    ('2006-2010', '2006-11-30', '2010-06-17', '2006-11-22', 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Claude, te controleren'),
    ('2010-2012', '2010-06-17', '2012-09-20', '2010-06-09', 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Claude, te controleren'),
    ('2012-2017', '2012-09-20', '2017-03-23', '2012-09-12', 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Claude, te controleren'),
    ('2017-2021', '2017-03-23', '2021-03-31', '2017-03-15', 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Claude, te controleren'),
    ('2021-2023', '2021-03-31', '2023-12-06', '2021-03-17', 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Claude, te controleren'),
    ('2023-2025', '2023-12-06', '2025-11-12', '2023-11-22', 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Claude, te controleren'),
    ('2025-', '2025-11-12', null, '2025-10-29', 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Claude, te controleren');

-- Handmatig: partij per fractie. Fractie en partij zijn niet hetzelfde; een fractie kan aan
-- geen partij gekoppeld zijn (groepen, afgesplitste Kamerleden). Voorstel Claude, na te kijken door Niels.
-- Bevat de fracties die op of na 1 januari 2010 actief waren.
create table core.fractie_partij (
    fractie_id uuid primary key,
    afkorting text not null,        -- alleen voor de leesbaarheid van deze tabel
    partij text,
    opmerking text,
    gecontroleerd_op date
);

insert into core.fractie_partij (fractie_id, afkorting, partij, opmerking) values
    ('77f9b6f1-b1a9-4d1b-a05e-9936e79d8fa5', 'SGP', 'Staatkundig Gereformeerde Partij', null),
    ('8d46d23c-4f20-49be-b279-5439a2ef8d17', 'PvdA', 'Partij van de Arbeid', null),
    ('7476e97a-3243-4122-9df6-ba7d82a5279b', 'VVD', 'Volkspartij voor Vrijheid en Democratie', null),
    ('4e9f6f5b-2544-4667-8134-6b85c4ebb4e0', 'D66', 'Democraten 66', null),
    ('62c1a13c-85ff-40ed-90f7-a9546d61f869', 'CDA', 'Christen-Democratisch Appèl', null),
    ('8fd1a907-0355-4d27-8dc1-fd5a531b471e', 'GL', 'GroenLinks', null),
    ('a3689bb6-3914-4d5c-a6a8-42e24582e299', 'SP', 'Socialistische Partij', null),
    ('d720f5af-0516-408a-b830-0b6ffb8a581c', 'ChristenUnie', 'ChristenUnie', null),
    ('65129918-f256-4975-9da4-488da34d6695', 'PVV', 'Partij voor de Vrijheid', null),
    ('d3b4d880-ef37-4ce6-99ec-4940266ac466', 'PvdD', 'Partij voor de Dieren', null),
    ('489c052b-1917-4a1e-918d-1ef58fda123b', 'Verdonk', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('e133cd98-1b5c-47e0-ac4d-031f34199767', 'BRINK', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('292e65d3-7337-424e-a956-9066f285861a', 'GrKH', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('c82898bb-a5b0-4915-8452-3c9469363b0b', 'Van Bemmel', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('43eff828-86b7-4cb1-9c73-4ea0e33f93ac', 'DPK', null, 'Na te gaan: fractie van een dag (20 september 2012)'),
    ('a34bf6c8-834e-4dba-b4d2-f2f1b3957bd2', '50PLUS', '50PLUS', null),
    ('831e85cb-62dc-4341-84ec-78c3c593c244', 'BONTES', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('e2c3dd23-f247-430a-9c94-53f9f5c06c0b', 'Van Vliet', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('4517964b-fe02-4b7c-b5df-a4357d750ca4', 'Van Klaveren', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('fc594dee-bad8-4caf-ba89-9496537c3527', 'GrBvK', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('92dec5db-fce3-4235-b432-2feec47d3241', 'Baay-Timmerman', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('b4907c2d-282d-465e-bf23-18369f68086c', '50PLUS/Klein', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('b094bfef-e14b-4868-8d2e-78e12c6077d1', '50PLUS/Baay-Timmerman', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('eb72ccb0-e80a-42d0-8b15-ebc30051447c', 'Klein', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('b04f833d-8704-4f2c-bd98-83f3068dbb24', 'GrKÖ', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('5b457d01-2569-40e3-9201-b99b1d80c471', 'Houwers', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('2833a04a-0b87-4f74-bd9e-6597f695db43', 'Monasch', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('e0b7b638-de3c-47cc-85bd-341dd65ea33d', 'FVD', 'Forum voor Democratie', null),
    ('deb74bb5-63a9-4ffc-98ed-af577167452e', 'DENK', 'DENK', null),
    ('5452aab2-d0cb-40a8-82b7-144c6e6bc5ca', 'vKA', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('8140f3a2-f9c1-48a6-a0b2-7e6eb78b3006', 'Van Haga', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('68b24085-9d89-4c00-a61c-a06a1493dcdd', 'Krol', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('ae60c2d3-5f87-4170-8f0c-503c36ddd130', 'Groep Krol/vKA', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('9baf43e2-3081-4fb1-93c4-6f002f395271', 'Krol', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('6f14bed5-cf7c-4340-a334-b538bbea85a7', 'vKA', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('18e95d6d-1684-4fa0-968a-1a6140d2d793', 'BIJ1', 'BIJ1', null),
    ('626555ac-e836-44e3-9978-a6a7f0abc3ce', 'BBB', 'BoerBurgerBeweging', null),
    ('fab6e7e1-9d63-446a-a6e1-e1c74e3f679e', 'JA21', 'JA21', null),
    ('ae48391e-ce4d-47e0-86e3-ee310282f66f', 'Volt', 'Volt', null),
    ('ea1ba564-db2c-4c57-b867-91ac4dcc5643', 'Fractie Den Haan', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('7113623f-909d-4a24-a48e-c7577f851e63', 'Groep Van Haga', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('acc6e04b-e53e-489b-8904-dc91d3af2e11', 'Omtzigt', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('ab3fa1a5-3bd9-413e-957f-61b2a697c967', 'Gündoğan', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('56803c7e-9424-4122-9aea-eb4b548ba700', 'Ephraim', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('0208097d-ef04-438a-8c29-eebb84956204', 'GroenLinks-PvdA', null, 'Gezamenlijke fractie van GroenLinks en PvdA; geen partij gekoppeld'),
    ('ad182a43-bc8c-40b3-894d-4a92515e70e7', 'Nieuw Sociaal Contract', 'Nieuw Sociaal Contract', null),
    ('a9e74299-15f9-455c-8330-b84f176d1a7e', '50PLUS', '50PLUS', null),
    ('848c3fca-8931-4236-8fe9-33b6a598fa4d', 'Groep Markuszower', null, 'Leden vormen sinds april 2026 De Nederlandse Alliantie (core-model.md); fractienaam niet gewijzigd. Na te gaan'),
    ('65b21c25-91e8-4844-a67c-bc5866e457b5', 'Lid Keijzer', null, 'Groep of afgesplitst Kamerlid; geen partij'),
    ('d60f373a-5bb2-477f-9979-a8f3a0514e6b', 'PRO', null, 'Na te gaan: mogelijk de partij die uit GroenLinks en PvdA is ontstaan');

-- Afgeleid: fracties, met de partij uit de handmatige tabel
create table core.fractie (
    id uuid primary key,
    afkorting text,
    naam text,
    actief_van date,
    actief_tot date,
    partij text
);

-- Afgeleid: Kamerleden, alleen naam en fractielabel (data-minimalisatie)
create table core.persoon (
    id uuid primary key,
    naam text not null,
    fractielabel text
);

-- Afgeleid: besluiten met minstens een stemming, met de datum van de vergadering en de periodes
create table core.besluit (
    id uuid primary key,
    datum date not null,
    stemmingssoort text,            -- 'Met handopsteken' of 'Hoofdelijk'
    besluitsoort text,
    besluittekst text,
    kabinet text references core.kabinet (naam),
    kamerperiode text references core.kamerperiode (naam)
);

-- Afgeleid: stem per fractie per besluit. Bestaat niet bij hoofdelijke stemmingen:
-- daar heeft de bron alleen stemmen per Kamerlid (zie core.persoonsstem)
create table core.fractiestem (
    besluit_id uuid not null references core.besluit (id),
    fractie_id uuid not null references core.fractie (id),
    soort text not null check (soort in ('Voor', 'Tegen', 'Niet deelgenomen')),
    fractiegrootte integer,
    vergissing boolean not null,
    primary key (besluit_id, fractie_id)
);

-- Afgeleid: stem per Kamerlid per besluit, vooral bij hoofdelijke stemmingen
create table core.persoonsstem (
    besluit_id uuid not null references core.besluit (id),
    persoon_id uuid not null references core.persoon (id),
    fractie_id uuid references core.fractie (id),
    soort text not null check (soort in ('Voor', 'Tegen', 'Niet deelgenomen')),
    vergissing boolean not null,
    primary key (besluit_id, persoon_id)
);

-- Afgeleid: zaken (moties, wetsvoorstellen) waarover besloten is, en de koppeling met besluiten
create table core.zaak (
    id uuid primary key,
    nummer text,
    soort text,
    titel text,
    onderwerp text,
    gestart_op date
);

create table core.besluit_zaak (
    besluit_id uuid not null references core.besluit (id),
    zaak_id uuid not null references core.zaak (id),
    primary key (besluit_id, zaak_id)
);

create index on core.fractiestem (fractie_id);
create index on core.persoonsstem (persoon_id);
create index on core.besluit (datum);

-- Bouwt alle afgeleide tabellen opnieuw op uit raw, in een transactie: tijdens het herbouwen
-- ziet een lezer de oude inhoud. Geeft per tabel het aantal rijen terug, voor de log.
create function core.herbouw()
returns table (tabel text, rijen bigint)
language plpgsql
as $$
begin
    truncate core.besluit_zaak, core.fractiestem, core.persoonsstem, core.besluit,
             core.zaak, core.fractie, core.persoon;

    insert into core.fractie (id, afkorting, naam, actief_van, actief_tot, partij)
    select f."Id", f."Afkorting", f."NaamNL",
           (f."DatumActief" at time zone 'Europe/Amsterdam')::date,
           (f."DatumInactief" at time zone 'Europe/Amsterdam')::date,
           fp.partij
    from raw.fractie f
    left join core.fractie_partij fp on fp.fractie_id = f."Id"
    where not coalesce(f."Verwijderd", false);

    insert into core.persoon (id, naam, fractielabel)
    select p."Id",
           concat_ws(' ', coalesce(p."Roepnaam", p."Voornamen", p."Initialen"), p."Tussenvoegsel", p."Achternaam"),
           p."Fractielabel"
    from raw.persoon p
    where not coalesce(p."Verwijderd", false);

    insert into core.besluit (id, datum, stemmingssoort, besluitsoort, besluittekst, kabinet, kamerperiode)
    select b."Id", d.datum, b."StemmingsSoort", b."BesluitSoort", b."BesluitTekst", k.naam, kp.naam
    from raw.besluit b
    join raw.agendapunt a on a."Id" = b."Agendapunt_Id" and not coalesce(a."Verwijderd", false)
    join raw.activiteit ac on ac."Id" = a."Activiteit_Id" and not coalesce(ac."Verwijderd", false)
    cross join lateral (select (ac."Datum" at time zone 'Europe/Amsterdam')::date as datum) d
    left join core.kabinet k on d.datum >= k.begin and (k.einde is null or d.datum < k.einde)
    left join core.kamerperiode kp on d.datum >= kp.begin and (kp.einde is null or d.datum < kp.einde)
    where not coalesce(b."Verwijderd", false)
      and d.datum >= date '2010-01-01'
      and exists (select 1 from raw.stemming s where s."Besluit_Id" = b."Id" and not coalesce(s."Verwijderd", false));

    insert into core.fractiestem (besluit_id, fractie_id, soort, fractiegrootte, vergissing)
    select s."Besluit_Id", s."Fractie_Id", s."Soort", s."FractieGrootte", coalesce(s."Vergissing", false)
    from raw.stemming s
    join core.besluit b on b.id = s."Besluit_Id"
    join core.fractie f on f.id = s."Fractie_Id"
    where s."Persoon_Id" is null and s."Soort" is not null and not coalesce(s."Verwijderd", false);

    insert into core.persoonsstem (besluit_id, persoon_id, fractie_id, soort, vergissing)
    select s."Besluit_Id", s."Persoon_Id", f.id, s."Soort", coalesce(s."Vergissing", false)
    from raw.stemming s
    join core.besluit b on b.id = s."Besluit_Id"
    join core.persoon p on p.id = s."Persoon_Id"
    left join core.fractie f on f.id = s."Fractie_Id"
    where s."Soort" is not null and not coalesce(s."Verwijderd", false);

    insert into core.zaak (id, nummer, soort, titel, onderwerp, gestart_op)
    select z."Id", z."Nummer", z."Soort", z."Titel", z."Onderwerp",
           (z."GestartOp" at time zone 'Europe/Amsterdam')::date
    from raw.zaak z
    where not coalesce(z."Verwijderd", false)
      and exists (select 1 from raw.besluit_zaak bz join core.besluit b on b.id = bz."Besluit_Id" where bz."Zaak_Id" = z."Id");

    insert into core.besluit_zaak (besluit_id, zaak_id)
    select bz."Besluit_Id", bz."Zaak_Id"
    from raw.besluit_zaak bz
    join core.besluit b on b.id = bz."Besluit_Id"
    join core.zaak z on z.id = bz."Zaak_Id";

    return query
        select 'besluit', count(*) from core.besluit
        union all select 'fractiestem', count(*) from core.fractiestem
        union all select 'persoonsstem', count(*) from core.persoonsstem
        union all select 'fractie', count(*) from core.fractie
        union all select 'persoon', count(*) from core.persoon
        union all select 'zaak', count(*) from core.zaak
        union all select 'besluit_zaak', count(*) from core.besluit_zaak;
end;
$$;
