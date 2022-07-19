drop table menu
go
drop table comida
go
drop table receta
go
drop table ingrediente
go
drop table plato
go
drop procedure spNumeroCalorias
go
drop  view vwPlatoCalorias
go

SET NOCOUNT ON 
CREATE TABLE INGREDIENTE
   ( id int identity primary key,
     nombre varchar(100),
     unidadMedida varchar(4), 
     caloriasUnidad int default 0
   )
go
insert into INGREDIENTE values ('Azucar','gr',10)
insert into INGREDIENTE values ('Leche','ml', 3)
insert into INGREDIENTE values ('Harina','gr',6)
insert into INGREDIENTE values ('Huevo','un',32)
insert into INGREDIENTE values ('Sal','gr',0)
insert into INGREDIENTE values ('Mantequilla','gr',7)
insert into INGREDIENTE values ('Arroz','gr',7)
insert into INGREDIENTE values ('Aceite','ml',9)


go
create table PLATO
  ( id int identity primary key,
    nombre varchar(100)
  )
go
insert into PLATO values ('Arroz con leche')
insert into PLATO values ('Natilla')
insert into PLATO values ('Huevos fritos')
insert into PLATO values ('Arroz a la cubana')
go
create table RECETA
  ( idplato int not null,
    idIngrediente int not null,
    cantidad int not null default 1,
    primary key (idplato,idIngrediente),
    foreign key (idplato) references plato (id) on update cascade,
    foreign key (idIngrediente) references ingrediente (id) 
					on update cascade
  )
go 
   
insert into RECETA  values ( 1,1,70)
insert into RECETA  values ( 1,2,13)
insert into RECETA  values ( 1,3,1)
insert into RECETA  values ( 1,4,10)
insert into RECETA  values ( 2,1,12)
insert into RECETA  values ( 3,1,13)
insert into RECETA  values ( 2,2,4)
go

create view vwPlatoCalorias (idPlato,Nombre,Calorias)
 as

select  p.id,p.nombre,

   ( select SUM( RECETA.cantidad * I.caloriasUnidad) from RECETA 
     inner join INGREDIENTE I on ( RECETA.idIngrediente=i.id) 
     where RECETA.idplato = P.id) 

 from PLATO P

go
--select * from vwPlatoCalorias

create procedure spNumeroCalorias @nombrePlato varchar(100)
as 
  
  select CALORIAS from vwPlatoCalorias where nombre = @nombrePlato 
go

--execute spNumeroCalorias 'Natilla'

create table COMIDA
  (  idComida char(1) primary key,
     denominacion varchar(10)
   )
go
insert into COMIDA values ( '1','Desayuno')
insert into COMIDA values ( '2','Almuerzo')
insert into COMIDA values ( '3','Cena')
go
create table MENU
  ( NumDia tinyint not null , -- 1= lunes, 2=martes... 7=domingo..
    idComida char(1) not null,
    idPlato  int not null, 
    primary key (NumDia,IdComida,idPlato),
    foreign key (idComida) references comida (idComida) 
			on update cascade,
	foreign key (idPlato) references Plato (id) 
	        on update cascade
  )
go
create trigger trTestCalorias on menu for insert,update
as
 begin
    declare @diaSemana tinyint
    declare @comida  char(1)
    declare @nCalorias int 
    
    -- que estoy insertando...
    
    set @diaSemana=(select NumDia from INSERTED) 
    set @Comida = (select idComida from INSERTED)
    
    set @nCalorias = 
        ( select sum (calorias) from MENU 
          inner join vwPlatoCalorias VW on (menu.idplato = VW.idPlato)
          where menu.numDia = @diaSemana and menu.idComida=@comida)
          
 if @comida = '1' -- desayuno
       begin
          if @nCalorias > 700 
             begin
                raiserror 90700 'Desayuno con mas de 700 calorias'
                rollback transaction
                return     
             end        
       end
     
if @comida = '2' -- Almuerzo
       begin
          if @nCalorias > 1000
             begin
                raiserror 91000 'Almuerzo con mas de 1000 calorias'
                rollback transaction
                return     
             end        
       end 
       
 -- '3' ya solo puede ser cena
 
  if @nCalorias > 650
             begin
                raiserror 90650 'Cena con mas de 650 calorias'
                rollback transaction
                return     
             end        
              
 end
 
 
    
    
  

