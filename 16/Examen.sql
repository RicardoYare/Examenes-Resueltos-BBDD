CREATE DATABASE TOPROCK
USE TOPROCK

CREATE TABLE Grupo (
 idGrupo varchar(10) not Null PRIMARY KEY ,
 fecha dateTime NOT NULL 
)
go


CREATE TABLE Entrada (
	idEntrada varchar(10)not Null primary key,
	Nombre varchar(20) not Null,
	Apellido varchar(20)not Null		
)
go

insert into Entrada values('11e', '05-05-2015', '22F')



CREATE TABLE Horario (
	fecha dateTime not null PRIMARY KEY ,
	pr_Diurno int,
	pr_Nocturno int,
	pr_Festivos int
)
go
insert into Entrada values('11e', '05-05-2015', '22F')

create table Precio(

	precioCOBRADO int not Null PRIMARY KEY ,
	fecha dateTime FOREIGN KEY (fecha)
	REFERENCES Horario(fecha) not NULL
	
)

--------------------------------------------------------

--1.- Vista relacion Grupos hoy indicando personas apuntadas
create view VW_RelaconGrupos

as
	select e.idGrupo, COUNT(*)  "cantidad",e.Nombre, e.Apellido from Entrada e
	inner join Horario h on(e.fecha= h.fecha)
go


------------------------------------------------------
--2 Grupo no fuera de horarios permitidos 10 máñana a  9 noche

create trgger tr_Horarios on Grupo for insert,update
  as
    declare @horario dateTime
    declare @texto varchar(20)
    if ( select @horario from inserted) > dateTime(@horario)
      begin
         set @texto='El horario no esta permitido'+
                   (select @horario from inserted)
         raiserror 50000 @texto
         rollback transaction
      end 
 go 
 ------------------------------------------------------
--3 No dejar a mas de 50 personas
create trigger tr_NoMasPersonas on Grupo for insert,update
  as
    declare @horario dateTime
    declare @texto varchar(30)
		if ( select COUNT(*) from inserted) > 50
			begin
			set @texto='El cupo es superior al permitido'
			raiserror 50000 @texto
			rollback transaction
      end 
 go 
----------------------------------------------------------
--4 Dinero recaudado en ese dia
create procedure pr_Recaudado 
	@fecha dateTime
as
		DECLARE @precio int
		SET @precio= (SELECT SUM(p.precioCOBRADO) precioTotal  from Precio p
		where fecha=@fecha )
	 go 


EXECUTE pr_Recaudado '10-1-2010'	





