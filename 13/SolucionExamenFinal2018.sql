create database MUNHECOS
go
use munhecos

/*

  crear tablas
*/
create table color
  ( idColor int primary key,
    nombre varchar(30) UNIQUE
   )
go
insert into color values (1,'rojo');
insert into color values (2,'amarillo');
insert into color values (3,'azul');
go
create table fabricante
  ( idFabricante int primary key,
    nombre varchar(30)
   )
go
insert into fabricante values (1,'Famosa') 
insert into fabricante values (3,'Pongo')
insert into fabricante values (2,'Meca')
go

create table material
 ( idMaterial int primary key,
    nombre varchar(30)
   )    
go
insert into material values ( 1,'Plastico');
insert into material values ( 2,'Madera');
insert into material values ( 3,'Papel');
insert into material values ( 4,'Peluche');

go
create table munheco
 (
    idMunheco int  primary key,
    nombre varchar(40) not null,
    idFabricante int references fabricante (idFabricante) on update cascade,
    idMaterial int references material(idMaterial) on update cascade,
    tamanho int
 )   
go
insert into munheco values ( 1,'pongo',1,1,15)
insert into munheco values ( 2,'puchi',2,3,15)
insert into munheco values ( 3,'mimi',1,2,10)
go

create table munhecoColor 
  (
    idMunheco int references munheco (idMunheco) on update cascade,
    idColor int references color(idColor) on update cascade,
    stock int default 0 ,
    primary key (idMunheco,idColor),
    constraint "No hay cantidad suficiente" check (stock >= 0) /* no se deja poner valores negativos*/
  )
go
insert into munhecoColor values ( 1,1,10)
insert into munhecoColor values ( 1,2,12)
insert into munhecoColor values ( 2,3,15)
go

create table ventas
  (
    idVenta int identity(1,1) primary key,
    fechaHora smalldatetime default getDate(),
    idMunheco int not null,
    idColor int not null,
    cantidad int not null,
    foreign key (idMunheco,idColor) references munhecoColor(idMunheco,idColor) on update cascade    
  )
go  

/* trigger para actualizar una nueva venta*/
create trigger trNuevaVenta on ventas for insert
as
  declare @idMunheco int=(select idMunheco from inserted)
  declare @idColor int=(select idColor from inserted)
  declare @cantidad int =(select cantidad from inserted)
  
  update munhecoColor set stock = stock - @cantidad where idColor=@idColor and idMunheco=@idMunheco
go
/*
vista que la cantidad de ventas por cada muñeco

*/
create view vwVentasPorMunheco (idMunheco,nombre,"Cantidad Vendida")
as
select m.idMunheco ,m.nombre ,"cantidad vendida"=
             case 
                 when SUM(cantidad)  is null then 0
                 else SUM(cantidad) 
            end  
 from munheco m
 left join ventas v on m.idMunheco=v.idMunheco
 group by m.idMunheco,m.nombre
go

/*
 procedimento que pasamos  nombre de color y nos da la relacion de muñecos que tenemos de ese color

*/

create procedure spMunhecoDelColor @txtColor varchar(30)
as
  declare @idColor int =(select idColor from color where nombre=@txtColor)
  
  select m.idMunheco, m.nombre , stock from munheco m
  inner join munhecoColor mc on mc.idMunheco=m.idMunheco
  where mc.idColor=@idColor
  
  
go
execute spMunhecoDelColor 'rojo'
go