create view vw_RecogidaClientes
as
select Clientes.Nombre, Clientes.PrimerApellido, Clientes.SegundoApellido, Hoteles.Hotel, Excursiones.Matricula 
from Clientes inner join Hoteles on ( Clientes.CodHotel = Hoteles.CodHotel)
inner join Excursiones on ( Clientes.CodCliente = Excursiones.CodCliente)
where Excursiones.Fecha = cast(getdate() as DATE)
go


