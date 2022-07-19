create database ExamenPostales
go
use ExamenPostales
go
create table vista
 ( idVista int primary key,
   texto varchar(30)
  )
go

create table cia -- complia
  (
    idCia int primary key,
    nombre varchar(30) not null unique 
  )  
 go
create table fabricante 
 ( 
   idFabricante int primary key,
   nombre varchar(50) not null unique
 )
go
create table modelo
 (
  idModelo int primary key,
  nombre varchar(50),
  idFrabricante int foreign key references fabricante(idFabricante)
        on update cascade
 
 )
go

create table postal
 ( idPostal int identity primary key,
   fecha date not null,
   volando bit default 1, -- 0 = no, 1=si  
   idmodelo int not null foreign key references modelo (idModelo)
     on update cascade,
   idvista int not null foreign key references vista (idVista)
     on update cascade,
   idCia int not null foreign key references Cia (idCia)
     on update cascade
  )
go
-- 1º
create unique index ak_postal on postal ( idmodelo,idCia)
go
-- 2º
/*
Procedimiento almacenado al que pasamos
la compañía aérea y nos da la relación de
postales que tenemos de ella, ordenada por fecha de adquisición. La mas nueva al
principio de la lista. Se debe indicar modelo de avión, tipo de vista, si esta volando o
en tierra y fecha de adquisición. (2ptos)
*/
create procedure spPostalesCIA @idCia int
as
 select p.fecha,
     case p.volando
       when 1 then 'Si'
       else ' ' -- no vuela
     end "Volando"  
     ,v.texto "Vista", 
    f.nombre "Fabricante", m.nombre "Modelo" 
      from postal p 
    inner join vista v on p.idvista=v.idVista
    inner join modelo m on m.idModelo=p.idmodelo
    inner join fabricante f on f.idFabricante=m.idFrabricante
    
    where p.idCia=@idCia -- de la compañia pedida
    order by fecha desc 
go

-- 3.- 
/*
El sistema no nos puede dejar tener más de 20 postales de un mismo modelo de
avión (3ptos)
*/
go
create trigger trNoMasDe20  on postal for insert,update
as
  declare @idModelo int
  set @idModelo = (select idmodelo from inserted)
  
  if (( select COUNT(*) from postal where idmodelo = @idModelo)>20 )
     begin
         rollback transaction
         raiserror 80000 'No puede tener más de 20 postales del mismo modelo' 
   
     end
go 

--4.
/*Una vista que que nos de la relación de
postales (indicando todos sus datos) de
aviones que estén volando. (2 ptos)
*/
create view vwAvionesVolando
as
 select p.idpostal,c.nombre "Compañia",
    p.fecha,v.texto "Vista", 
    f.nombre "Fabricante", m.nombre "Modelo" 
      from postal p 
    inner join vista v on p.idvista=v.idVista
    inner join modelo m on m.idModelo=p.idmodelo
    inner join fabricante f on f.idFabricante=m.idFrabricante
    inner join cia c on c.idCia=p.idCia
    
    where p.volando=1 -- esta volando.
go
    
--5.
/*
. Un procedimiento almacenado que nos de
cual es el modelo de avión del que tenemos
más postales. (2 Ptos)
*/
create procedure spMasPostales    
as
   declare @maximo int
   
   set @maximo=( select top 1 COUNT(*) from postal p
                  group by p.idmodelo
                  order by 1 desc)  
                  
   select  m.nombre "Modelo"   from postal p
   inner join modelo m on p.idmodelo=m.idModelo         
   group by p.idmodelo,m.idModelo
   having COUNT(*) = @maximo  
   


go
    