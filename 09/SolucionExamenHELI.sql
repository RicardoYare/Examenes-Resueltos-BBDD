create table piloto
 ( idPiloto int primary key,
   nombre varchar(30),
   apellidos varchar(40),
   peso int
 )
 go
 insert into piloto values ( 1,'pepe','Smith', 86)
 go
 create table modelo
  (
    idModelo int primary key,
    nombre varchar(30),
    maxPasajeros int default 5,
    maxPeso int default 500  
  )
 go
 insert into modelo values ( 1,'MBB150',5,450)
 go
 create table helicoptero
  (
    matricula varchar(12) primary key,
    idModelo int foreign key references modelo ( idModelo)
  )  
 go
 insert into helicoptero values ('N1',1)
 go
 
 create table pasajero
  ( idPasajero varchar(15) primary key,
    nombre varchar(30),
    apellidos varchar(40),
    peso int default 80
   )
 go
 insert into pasajero values ( 'F1','pepe','acosta',98)
 go
 
 create table vuelo
 (
  matricula varchar(12) foreign key references helicoptero(matricula), 
  fecha datetime default getdate() ,   
  idPiloto int foreign key references piloto(idPiloto),  
  primary key (Matricula,fecha)
 )
go
insert into vuelo (idPiloto,matricula) values (1,'N1')
go 
 
create table Billete -- relacion vuelo pasajero.
 (
  matricula varchar(12), 
  fecha datetime ,
  foreign key (matricula,fecha) references vuelo (matricula,fecha),
  idPasajero varchar(15) foreign key references pasajero (idPasajero),
  primary key (matricula,fecha,idPasajero)
 )
go

-- 1º 
  -- funcion que nos da el peso total del vuelo
  
create function fPesoTotal ( @matricula varchar(12), @fecha datetime)
  returns int
as
 begin
 declare @suma int
 set @suma=  --  suma peso de los pasajeros
  
                 (select SUM(peso) from Billete b  
                  inner join pasajero p on (p.idPasajero=b.idPasajero)
                  where b.fecha=@fecha and b.matricula=@matricula) -- para este vuelo
               
                + -- suma peso del piloto
   
                (select peso from vuelo v
                   inner join piloto p on ( v.idPiloto=p.idPiloto)
                   where v.fecha=@fecha and v.matricula=@matricula)
  return @suma                   
 end
go
-- total de personas (incluido el piloto) que van en el vuelo.
 create function fPersonas (@matricula varchar(12), @fecha datetime)
 returns int
 as
  begin
  declare @n int
  set @n=(select COUNT(*) from Billete where fecha = @fecha and matricula=@matricula)
  set @n = @n +1 -- incluir la piloto
  return @n
 end
go

create trigger trTestCapacidad on billete for insert, update
as
  declare @fecha datetime
  declare @matricula varchar(12)
  declare @sumaPeso int
  declare @maxPeso int
  
  set @matricula=(select matricula from inserted)
  set @fecha=(select fecha from inserted)
   
    
  set @sumaPeso=  dbo.fPesoTotal(@matricula,@fecha)
                   
  set @maxPeso=(select maxPeso from vuelo v
                 inner join helicoptero h on ( v.matricula=h.matricula)
                 inner join modelo m on (m.idModelo=h.idModelo) )                   
                 
  if ( @sumaPeso > @maxPeso)
      begin
          raiserror 70000 'Peso sobrepasado'
          rollback transaction
          return      
      end
  
  declare @MaxCapacidad int    
  
  set @MaxCapacidad=(select maxPasajeros from Billete b
                     inner join helicoptero h on ( b.matricula=h.matricula)
                     inner join modelo m on ( h.idModelo=m.idModelo))
                     
                     
  if ( dbo.fPersonas(@matricula,@fecha) > @MaxCapacidad)                     
    begin
        raiserror 70544 'Demasiados pasajeros (incluido el piloto)'
        rollback transaction
        return    
    end

go 
 
 -- 2º
 
 CREATE VIEW vwVuelosHoy
 as
 
 select v.matricula,cast( v.fecha as time) Hora,p.nombre,p.apellidos,
       dbo.fPersonas(v.matricula,v.fecha) "Total personas en el vuelo",
       dbo.fPesoTotal(v.matricula,v.fecha) "Peso Total"
      from  vuelo v inner join piloto p on ( v.idPiloto=p.idPiloto)   
    
   where cast(v.fecha as DATE)= cast (GETDATE() as DATE) -- los de hoy
 go
 

-- 3º
create procedure spHistoricoPajaero @nombre varchar(30), @apellidos varchar(40)
as
  select v.fecha, (pi.nombre+' '+pi.apellidos) Piloto from pasajero pa
    inner join billete b on ( pa.idPasajero = b.idPasajero)
    inner join vuelo v on ( b.fecha = v.fecha and b.matricula=v.matricula)
    inner join piloto pi on ( v.idPiloto = pi.idPiloto)

  where pa.nombre=@nombre and pa.apellidos=@apellidos
order by v.fecha
  

go 
-----------------------------MI VERSION
CREATE PROCEDURE spPasajero (@Nombre as VARCHAR, @Apellido as VARCHAR)
AS

SELECT b.matricula, b.fecha , p.idpiloto FROM Billete b

    INNER JOIN vuelo v ON b.matricula = v.matricula AND b.fecha = b.fecha
	INNER JOIN piloto p ON v.idPiloto = p.idPiloto

	INNER JOIN pasajero pj ON b.idPasajero = pj.idPasajero

	WHERE pj.nombre = @Nombre AND pj.apellidos = @Apellido
	
GO
 -- 4º  
 
 create procedure spRelacionVuelosHoy @nombre varchar(30),
						     @apellidos varchar(40),
						     @ini datetime,
						     @fin datetime
as 
  select v.matricula, COUNT(*) "Cantidad vuelos"
   from piloto p 
   inner join vuelo v on ( p.idPiloto= v.idPiloto) -- vuelos del piloto
   
   
   where p.apellidos=@apellidos and p.nombre=@nombre
     and v.fecha between @ini and @fin
   group by v.matricula  


go	
-----------MI VERSION	
CREATE PROCEDURE heliPilotados (@Nombre as VARCHAR, @Apellido as VARCHAR, @fchX DATETIME , @fchY DATETIME)

AS

  SELECT h.matricula, COUNT(h.matricula) " CANTIDA VUELOS" FROM vuelo v

     INNER JOIN helicoptero h ON v.matricula = h.matricula
	 INNER JOIN piloto p ON v.idPiloto = p.idPiloto

	 	WHERE p.nombre = @Nombre AND p.apellidos = @Apellido

		 GROUP BY h.matricula

		  HAVING v.fecha BETWEEN @fchX AND @fchY
GO				     
						    
