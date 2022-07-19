
create procedure sp_HistorialCliente @nombre varchar(20),@primer varchar(20),@segundo varchar(20)
as
select Excursiones.Fecha, Excursiones.Matricula, Conductores.Nombre,Conductores.Apellidos 
from Excursiones inner join Clientes
on (Excursiones.CodCliente = Clientes.CodCliente)
inner join Transportes on ( Excursiones.Matricula = Transportes.Matricula)
inner join Conductores on ( Transportes.CodConductor = Conductores.CodConductor)
where Clientes.Nombre = @nombre
and Clientes.PrimerApellido = @primer
and Clientes.SegundoApellido = @segundo
go



