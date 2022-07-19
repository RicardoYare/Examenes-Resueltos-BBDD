create trigger tr_CapacidadVehiculo on Excursiones for insert, update
as
declare @fecha date
set @fecha = (select Fecha from inserted)
declare @coche char(7)
set @coche = (select Matricula from inserted)
if ( select COUNT(*) from Excursiones where Fecha = @fecha and Matricula = @coche) > 4
	begin
		raiserror 99999 'Solo caben 4 ocupantes por vehiculo'
		rollback transaction
	end
go
