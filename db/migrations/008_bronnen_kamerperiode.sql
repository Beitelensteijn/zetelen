-- Bronnen bij de verkiezingsdata in core.kamerperiode (component core-model).
-- Nagezocht door Claude op 24 oktober 2026 bij de Kiesraad; alle zeven datums kwamen overeen met de
-- waarden uit 003_core.sql. De kolom gecontroleerd_op blijft leeg: die vult Niels na zijn eigen controle.

update core.kamerperiode set bron = 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Kiesraad, https://www.kiesraad.nl/adviezen-en-publicaties/proces-verbalen/2006/11/27/proces-verbaal-zitting-kiesraad-uitslag-tweede-kamerverkiezing-2006' where naam = '2006-2010';
update core.kamerperiode set bron = 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Kiesraad, https://www.verkiezingsuitslagen.nl/verkiezingen/detail/TK20100609' where naam = '2010-2012';
update core.kamerperiode set bron = 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Kiesraad, https://www.kiesraad.nl/actueel/nieuws/2012/09/17/officiele-uitslag-tweede-kamerverkiezing-12-september-2012' where naam = '2012-2017';
update core.kamerperiode set bron = 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Tweede Kamer, https://www.tweedekamer.nl/nieuws/kamernieuws/kiesraad-stelt-definitieve-verkiezingsuitslag-vast' where naam = '2017-2021';
update core.kamerperiode set bron = 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Kiesraad, https://www.kiesraad.nl/actueel/nieuws/2021/03/26/officiele-uitslag-tweede-kamerverkiezing-17-maart-2021 (gestemd van 15 tot en met 17 maart; 17 maart is de verkiezingsdag)' where naam = '2021-2023';
update core.kamerperiode set bron = 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Kiesraad, https://www.kiesraad.nl/actueel/nieuws/2023/12/01/kiesraad-stelt-uitslag-tweede-kamerverkiezing-22-november-2023-vast' where naam = '2023-2025';
update core.kamerperiode set bron = 'Begin: API (FractieZetelPersoon); verkiezingsdatum: Kiesraad, https://www.kiesraad.nl/actueel/nieuws/2025/11/7/kiesraad-uitslag-tweede-kamerverkiezing-betrouwbaar' where naam = '2025-';
