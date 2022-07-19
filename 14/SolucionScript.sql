create table usuario
 (
   nif char(9)  constraint "Ya existe este NIF" primary key,
   tlf char(9) constraint "TLF no puede repetirse" unique, -- unico
   nombre varchar (30),
   apellido1 varchar(40),
   apellido2 varchar (40),
   usuario varchar(30) constraint "Usuario Web no puede duplicarse" unique, -- sin duplicados
   password varchar(30)
 )
 go

 create table receta
 (
  idReceta int identity primary key,
  nombre varchar(150) not null,
  FechaSubida date default current_timestamp, -- hora actual del sistema
  preparacion varchar(4000),
  idUsuario char(9) references usuario(nif) on update cascade
 )
go
-- evitar que un usuario tenga mas de 25 recetas ->TRIGGER

create trigger trNoMuchas on receta for update,insert
as
 declare @idUsuario char(9)
 set @idUsuario=(select idusuario from inserted) -- usuario que sube la receta

 -- comprobar que no tiene mas de 25 subidas (la que se esta insertando 
 --  ya se cuenta en el count(*)  from receta

 if ( select COUNT(*) from receta where idUsuario = @idUsuario) > 25 
    begin
	   raiserror ('No puede subir más de 25 recetas',16,1)
	   rollback transaction
	end
GO

-- ahora ingredientes y relación de ingredientes en la receta

create table ingrediente
 (
  idIngrediente int identity primary key,
  nombre varchar(100) unique
 )
 go
create table recetaIngrediente
 (
  idReceta int not null references receta(idreceta) on update cascade,
  idIngrediente int not null references ingrediente(idIngrediente) on update cascade,
  primary key (idReceta,idIngrediente)
 )
go


/* Una vista nos dé la cantidad de recetas que ha creado cada usuario */

create view vwCuantoPorCadaUno
as
select nif,usuario.nombre,apellido1,apellido2, COUNT(idReceta) "Cantidad recetas" from usuario 
left join receta on usuario.nif=receta.idUsuario -- lef join para que aparezcan con cero los que no tienen recetas.
group by nif,usuario.nombre,apellido1,apellido2
go
/*
Un procedimiento almacenado al que le pasamos el
teléfono del usuario y dos da la relación de recetas que
ha creado, solo la fecha de subida y denominación de la receta
*/

create procedure spDameRecetas @tlf char(9) 
as

 select receta.nombre,fechaSubida from usuario
 inner join receta on usuario.nif=receta.idUsuario
 where usuario.tlf=@tlf 
 order by FechaSubida desc -- DESC: para que aparezcan las mas nuevas al principio.

