create table evento
 (
   idEvento int identity(1,1) primary key,
   nombre varchar(60) unique, -- evitamos tenerlo dos veces el mismo evento con el mismo nombre
   carpeta  varchar(100)  -- así decimos donde estan todas las fotos. Nos ahorramos poer el path
					      -- en cada foto. 
 )
go
create table foto
 (
  idEvento int foreign key references evento (idEvento),
  idFoto varchar(30) , -- nombre del fichero de la foto, no hace falta la ruta pues ya la tiene el evento 
  primary key ( idEvento,idFoto) -- la clave principal seran las dos
 )
go
/*
 trigger que no deje poner mas de 100 fotos en un mismo evento.
*/
create trigger trFoto on foto for update,insert
as
  declare @idE int = (select idEvento from inserted) -- en qué evento estamos insertando al foto nueva
  
  if (( select COUNT(*) from foto where idEvento=@idE ) > 100)
      begin
           raiserror 70000 ' No puede tener mas de 100 fotos para este evento'
           rollback transaction      
      end
go  

/* 
 vista que nos de por cada evento el total de fotos que hay
*/

create view vwEstadistica 
as
  select e.nombre, COUNT(f.idEvento) "Total fotos" from evento e
      left join foto f on  e.idEvento=f.idFoto 
   group by e.nombre,e.idEvento    
go

/*
 procedmiento al que le pasamos el nombre del evento y nos da la relación de todas las fotos

*/

create procedure spListaFotos @nombreEvento varchar(60)
as
  select e.carpeta+f.idfoto "Fichero de la foto" from evento e 
         inner join foto f on e.idEvento=f.idEvento
         where e.nombre=@nombreEvento
go