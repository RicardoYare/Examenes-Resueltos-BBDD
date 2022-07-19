CREATE DATABASE ESTABLO
go
use establo

create table pelicula
  (
    idPelicula int primary key,
    titulo varchar(100)
)

create table establo
 (
  idEstablo int primary key,
  nombre varchar(50),
  capacidad int -- capacidad de caballos en el establo
)
go
create table caballo
  (
   idCaballo int primary key,
   nombre varchar(30),
   idEstablo int foreign key references establo(idEstablo)
      on update cascade, -- Si el caballo esta en el establo sera distinto de null
   idPelicula int foreign key references pelicula (idPelicula)  
     on update cascade -- si el caballo esta alquilado a un apelicula
				-- sera distinto de nulo. Si esta en un establo (no alquilo) el valor sera nulo.
      
  )
go

-- 2- Vista que me de la cantidad de caballos que tengo en cada establo.
create view vwCaballosPorEstablo
as
  select e.idEstablo, e.nombre, COUNT(*) "Cantidad caballos" from establo e 
  left join caballo c on e.idEstablo=c.idEstablo -- left para que salga a cero los que no tienen caballos
  group by e.idEstablo,e.nombre    
go

--3- El sistema no puede dejar que en un establo tengamos más caballos que la capacidad del mismo.

create trigger trNoOverBooking on caballo for insert, update
as
  declare @idEstablo int = (select idEstablo from inserted)
  if ( @idEstablo is null) -- Si se esta poniendo un caballo en un establo el valor sería NOT NULL
								-- Si es  null es que se va a una pelicula y entonces no hariamos nada.
     begin
            return  -- no afecta a ningun establo --> nos vamos               
     end						
     		
   declare @capacidad int=(select capacidad from establo where idEstablo=@idEstablo)     
   
   -- ahora vemos si nos hemos pasado de la capacidad para ese establo
   
   if ( select COUNT(*) from caballo where idEstablo=@idEstablo) > @capacidad
     begin  -- si nos pasamos de la capacidad
        rollback transaction
        raiserror 90000 'Ha sobrepasado la capacidad del establo'    
     end
go

 /* 4-  Procedimiento almacenado al que le indicamos
el nombre del establo y nos da la relación de
caballos que se encuentran en estos momentos en él.*/

create procedure spRelacionCaballos @nombreEstablo varchar(50)
as
  declare @idEstablo int =(select idEstablo from establo
                            where nombre=@nombreEstablo)
  if (@idEstablo is null)
     begin
         raiserror 80900 'No existe el establo'
         return     
     end
   -- Ya tenemos el id del establo y vamos a sacar la lista de caballos.
   
   select idCaballo, nombre from caballo where idEstablo=@idEstablo   
go
/* 5.
Procedimiento almacenado al que le pasamos
el nombre del caballo y nos dice dode esta. Si
esta en un establo, nos da el nombre del
establo. Si por el contrario esta alquilado a una
pelicula, nos dice el nombre de la pelicula*/

create procedure spDondeEstaMiCaballo @nombreCaballo varchar(30)
as
  declare @idCaballo int=(select idCaballo from caballo 
                           where nombre=@nombreCaballo)
  if (@idCaballo is null)
      begin
          raiserror 90500 'Caballo no existe'
          return      
      end
  declare @idEstablo int=(select idEstablo from caballo where idCaballo=@idCaballo)
  
  if (@idEstablo is not null) -- esta en un establo
    begin
       select 'Esta en el establo' "Situacion",idEstablo,nombre from establo
                         where idEstablo=@idCaballo
       return -- nos vamos  
    end
   -- debe estar en una pelicula
    
   declare @idPelicula int=(select idPelicula from caballo 
                              where idCaballo=@idCaballo)
   if (@idPelicula is not null)
     begin                           
         select 'Esta en la pelicula' "Situacion" ,idPelicula,titulo
                from pelicula where idPelicula=@idPelicula                        
         return
      end      
   Select 'CABALLO ROBADO'   
      


go


