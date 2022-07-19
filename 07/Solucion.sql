/*
 Solución examen "la ruta de la tapa"

*/
create table tarjeta 
  ( idTarjeta int identity primary key,
    fechaDescaga datetime  default sysdatetime()
  )
go
create table persona
 (
  telefono char(9) primary key,
   nombre varchar(50) not null, 
 )
go
create table relacionTarjetaPersona
 (
  idTarjeta int not null references tarjeta(idTarjeta) on update cascade,
  telefono  char(9) not null references persona(telefono) on update cascade,
  primary key (idTarjeta,telefono)
 )
go
create table bar -- establecimiento
  (
    idBar int identity primary key,
	nombre varchar (150)
  )
go
create unique index ak_index on bar (nombre) --para buscar por nombre mas rapidamente.
go
create table barTarjeta  --tarjeta que se sella en el bar
 (
  idBar int not null references bar(idBar) on update cascade,
  idTarjeta int not null references tarjeta(idTarjeta) on update cascade,
  cantidadTapas int not null default 1,
  primary key (idBar,idTarjeta)
 )
 go
 create index ak_Portarjeta on barTarjeta (idTarjeta) -- para buscar mas rapido 
				-- donde ha estado la tarjeta.
go
/*
  No dejar que hayan mas de 4 personas en la misma tarjeta
*/
create trigger trNoMasDe4Personas on relacionTarjetaPersona for update,insert
as
  declare @idTarjeta int
  set @idTarjeta =(select idTarjeta from inserted)
  if ( select count(*) from relacionTarjetaPersona where idTarjeta =@idTarjeta) > 4
    begin
	   raiserror('No pueden haber más de 4 personas en la tarjeta',16,10)
	   rollback transaction
	end
go



/*
  Una vista que nos de los numeros de las tarjetas con más establecimientos sellados
*/

 create view vwCuentaVecesPorTarjeta  as  -- cantidad de bares visitados por tarjetas.
    select count(*) Veces from bartarjeta  group by idTarjeta
 go


 create view vwMaximaCantidad as -- ahora tenemos el maximo de la vista anterior
   select max(veces) maximo from vwCuentaVecesPorTarjeta
 go
  
  -- ahora lo pedido

  create view vwTarjetasMasBorrachas  as
     select idTarjeta from barTarjeta 
	 group by idTarjeta 
	 having count(*) = (select maximo from vwMaximaCantidad) -- sea el maximo
  go

  /*
   Procedimiento almacenado al que le pasamos el nombre del bar y nos da
   el total de tarjetas y la cantaidad de tapas servidas
  */
  create procedure spTotalBar  @nombreBar varchar(150)
  as
    declare @idBar int
	set @idBar=(select idBar from bar where nombre= @nombreBar)

	if (@idBar is null)  -- no existe el nombre
	   begin
	       raiserror ('No existe este establecimiento',16,10)
		   return
	   end

  select count(*) "Total tarjetas", sum(cantidadTapas) "Total tapas" from barTarjeta
    where idBar=@idBar
 go
 /*  
  procedimiento almacenado al que le pasamos "cantidad de tapas" y nos da los 
  establecimientos donde se han servidor, como minimo, esa cantidad de tapas
 */

 create procedure spSuperanCantidadDetapas @nTapas int
 as
  select b.idbar,nombre from bar B
  inner join barTarjeta T on b.idBar= t.idBar
  group by b.idBar,nombre
  having sum (cantidadTapas) >= @nTapas
 go

