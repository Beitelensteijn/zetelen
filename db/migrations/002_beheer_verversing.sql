-- Logboek van de dagelijkse verversing (component bewaking).
-- Een rij per run, geschreven door pipeline/ververs.py. Bron voor de "laatst bijgewerkt"-datum
-- op de site: de laatste run met status 'geslaagd'. Bevat geen waarden uit records en geen geheimen.

create table beheer.verversing (
    id bigint generated always as identity primary key,
    gestart_op timestamptz not null default now(),
    klaar_op timestamptz,
    status text not null default 'bezig' check (status in ('bezig', 'geslaagd', 'mislukt')),
    records integer,
    fout text
);

comment on table beheer.verversing is 'Een rij per run van de dagelijkse verversing; fout bevat alleen het fouttype';
