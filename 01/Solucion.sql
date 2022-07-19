create table provincia
 (
  idprovincia int identity primary key,
  nombre varchar(100)
 )
 go
 create table municipio 
  (
   idMunicipio int identity primary key,
   idProvincia int references provincia(idprovincia) on update cascade,
   nombre varchar (150)
  )
go
create index ak_municipio on municipio(nombre)
go

create table cliente
 (
   idCliente int identity primary key,
   nif char(9) unique,
   nombre varchar(45),
   apellido1 varchar(50),
   apellido2 varchar(50),
   telefono char(9)
 )
go
create table tipoCable
 (
  idTipo int primary key,
  nombre varchar(50)
 )
 go
 create table instalacion
  (
    idInstalacion int identity primary key,
	idCliente int references cliente(idCliente) on update cascade ,
	idMunicipio int references municipio(idMunicipio) on update cascade,
	direccion varchar(200),
	idTipoCable int references tipoCable(idTipo) on update cascade,
	metros int,
	fecha date
  )
go
create index ak_instalacion on instalacion(fecha)
go
/*
 1- vista que nos da la cantiadad de instalaciones por cada cliente.
*/
create view vwInstalacionesPorCliente as
select nombre,apellido1,apellido2, count(*) "Cantidad instalaciones"  from instalacion 
 inner join cliente on cliente.idCliente=instalacion.idCliente
 group by cliente.idCliente,cliente.apellido1,cliente.apellido2,cliente.nombre
go

/*
  2- Procedimiento al que le pasamos el nombre del municipio y nos da la relacióm
  de instalaciones indicando el nombre del cliente

*/
create procedure spInstalacionesDelMunicipio  @nom varchar(150) as
 declare @id int

 set @id=(select idMunicipio from municipio where nombre = @nom)

 if (@id is null)
   begin
       raiserror ('No existe el municipio',16,10)
	   return
   end
 select nombre,apellido1,apellido2,direccion,idInstalacion from instalacion IT 
  			  inner join cliente C on IT.idCliente = C.idCliente
go

/*
 3- procedimiento almacenado al que le damos un intervalo de fechas y nos da la cantidad
  de cable utilizado de cada tipo.
*/
create procedure spTipoEntreFechas @ini date , @fin date
as
 select T.idtipo,T.nombre ,sum(metros) "Cantidad utilizada"  from instalacion IT 
    inner join tipoCable T on IT.idTipoCable=T.idTipo
	where fecha between @ini and @fin
	group by t.idTipo, t.nombre

go

/*
  4- El sistema no debe dejar que haya más de 3 instalaciones en un día.
*/

create trigger trNoMasDeTresAlDia on instalacion for insert,update
as
 declare @fecha date 
 set @fecha= (select fecha from inserted)
 if (select count(*) from instalacion where fecha=@fecha) > 3
   begin
      raiserror ('No pueden haber más de tres instalaciones por día',16,10)
	  rollback transaction
   end
go
