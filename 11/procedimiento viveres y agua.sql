create procedure sp_CantidadViveresyAgua @fecha date
as
select COUNT(*) "Cestas de viveres", (COUNT(*)*2) "Botellas de Agua" from Excursiones
where Excursiones.Fecha = @fecha
go


