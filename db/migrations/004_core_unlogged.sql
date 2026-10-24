-- Afgeleide tabellen van de core-laag als unlogged (component core-model, besluit Niels 24 oktober 2026).
-- Reden: core.herbouw() schrijft elke nacht alle afgeleide tabellen opnieuw. Gelogd verdubbelt dat de
-- schrijflast via het transactielog (WAL); op 24 oktober liep de schijf daardoor vol.
-- Gevolg: na een crash van de database zijn deze tabellen leeg tot de volgende herbouw. Er gaat niets
-- verloren dat niet opnieuw op te bouwen is: raw en de handmatige tabellen blijven gelogd.
-- Volgorde: eerst de tabellen die naar andere verwijzen.

alter table core.besluit_zaak set unlogged;
alter table core.fractiestem set unlogged;
alter table core.persoonsstem set unlogged;
alter table core.besluit set unlogged;
alter table core.zaak set unlogged;
alter table core.fractie set unlogged;
alter table core.persoon set unlogged;
