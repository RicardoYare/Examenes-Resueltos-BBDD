create database JuegoDeTronas
go
use JuegoDeTronas 
go

create table actor
 (
  idActor int primary key,
  nombre varchar(100)
 )
GO

create table temporada
 (
  idTemporada int primary key,
  nombre varchar(100),
  constraint "Numero entre 1 y 8" check (idTemporada between 1 and 8) --  esto evita que se salgas de los valores (Pregunta 1ª)
 )
go
create table capitulo
 (
  idTemporada int not null,
  numCapitulo int  not null,
  titulo varchar(100) not null,
  valoracion  int,
  resumen varchar(2000),
  primary key (idTemporada, numCapitulo),
  constraint "Valoración entre 1 y 10" check (valoracion between 1 and 10), -- no deja que salgas de estos valores en la valoración (Pregunta 2ª)
  foreign key (idTemporada) references Temporada (idTemporada) on update cascade
 )
go


create table ActoresDelCapitulo
 (
   idTemporada int not null,
   numCapitulo int not null,
   idActor int not null,
   constraint "Ya esta el actor en el capitulo" primary key (idTemporada,numCapitulo,idActor), -- ya no duplica actor en el capitulo (Pregunta 4ª)
   foreign key (idTemporada,numCapitulo) references capitulo(idTemporada,numCapitulo) on update cascade,
   foreign key (idActor) references actor(idActor) on update cascade
 )
go

-- vista que da el total de capitulos que hay en cada temporada (3ª pregunta)

create view vwCapitulosPorTemporada (temporada,nombre,"Cantidad capitulos")
as
 select t.idTemporada,t. nombre, count(*) from temporada t
 left join capitulo c on t.idTemporada = c.idTemporada
 group by t.idTemporada, t.nombre

go

-- procedimiento al que le pasamos el nombre del actor y nos visualiza los datos de los capitulos (5ª pregunta)

create procedure spCapitulosDelActor @nombre varchar(100)
as

  select c.idTemporada,c.numCapitulo,c.titulo,c.valoracion from actor a
  inner jon ActoresDelCapitulo ac on a.idActor = ac.idActor
  inner join capitulo on c.idCapitulo = ac.idCapitulo
  where  a.nombre = @nombre
  order by c.idTemporada,c.numCapitulo


go
-- actor no puede estar en mas de 10 capitulos (6ª pregunta)

create trigger trNoMasDe10Capitulos on ActoresDelCapitulo for insert,update
as
 declare @idActor int
 set @idActor=(select idActor from inserted)
 if  ( (select count(*) from ActoresDelCapitulo where idActor =@idActor) > 10)
      begin
         Raiserror 90100 'EL actor no puede estar en más de 10 capitulos'
         rollback transaction

      end





go

