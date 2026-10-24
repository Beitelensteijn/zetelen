-- Onderzoek: waarom heeft raw meer agendapunten en besluiten dan de API met hetzelfde datumfilter?
-- Alleen aantallen, geen inhoud. Draait via de workflow Controlequery.
select 'agendapunt: activiteit niet geladen' as oorzaak, count(*) as aantal
from raw.agendapunt a where not exists (select 1 from raw.activiteit ac where ac."Id" = a."Activiteit_Id")
union all
select 'agendapunt: activiteit verwijderd', count(*)
from raw.agendapunt a join raw.activiteit ac on ac."Id" = a."Activiteit_Id" where ac."Verwijderd"
union all
select 'agendapunt: activiteit zonder datum', count(*)
from raw.agendapunt a join raw.activiteit ac on ac."Id" = a."Activiteit_Id" where ac."Datum" is null
union all
select 'agendapunt: zelf verwijderd', count(*) from raw.agendapunt where "Verwijderd"
union all
select 'besluit: agendapunt niet geladen', count(*)
from raw.besluit b where not exists (select 1 from raw.agendapunt a where a."Id" = b."Agendapunt_Id")
union all
select 'besluit: agendapunt verwijderd', count(*)
from raw.besluit b join raw.agendapunt a on a."Id" = b."Agendapunt_Id" where a."Verwijderd"
union all
select 'besluit: activiteit verwijderd', count(*)
from raw.besluit b join raw.agendapunt a on a."Id" = b."Agendapunt_Id"
join raw.activiteit ac on ac."Id" = a."Activiteit_Id" where ac."Verwijderd"
union all
select 'besluit: zelf verwijderd', count(*) from raw.besluit where "Verwijderd";
