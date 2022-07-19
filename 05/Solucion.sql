/* 1- Saber cual es la tripulación de un barco en una fecha determinada. Procedimiento almacenado.*/

create procedure spTripulacionBarco @fecha date, @idBarco int
as

    select  t.nombre,t.apellido1,t.apellido2 from EXCURSION EX 
    inner join TRIPULACION_DE_BARCO TB on ( ex.idExcursion= tb.idExcursion)
    inner join TRIPULANTE T on ( tb.idTripulante=t.idTripulante)
    where ex.fecha = @fecha and ex.idBarco = @idBarco -- de la fecha y barco indicado.


go

/* 2- El sistema no dejará sobrepasar la capacidad del barco, tanto en tripulación como en turistas */

create trigger trTestSobrecargaTRIPULANTES on  TRIPULACION_DE_BARCO for insert, update 
as
    --  TEST NO SOBREPASAR TRIPULANTES DEL BARCO
    
   declare @n int
   declare @idBarco int
   declare @idExcursion int
   
   set @idExcursion=(select idExcursion from inserted) -- tenemos la excursión
   set @n = (select COUNT(*) from TRIPULACION_DE_BARCO where idExcursion=@idExcursion) -- contamos cuantos tripulantes tentemos ya en el barco=esta excursion.
   set @idBarco =(select idBarco from excursion where idExcursion=@idExcursion) -- tenemos el barco.
   
   if ( @n> (select maxTripulacion from BARCO where idBarco=@idBarco))  -- si sobrepasamos la capacidad maxima del barco...
     begin
         raiserror 60000 'Capacidad de tripulantes sobrepasada para este barco'
         rollback transaction     
     end   
go


CREATE trigger trTestSobrecargaTURISTAS on  TURISTAS_DE_LA_EXCURSION for insert, update 
as
    --  TEST NO SOBREPASAR TURISTAS(pasajeros) DEL BARCO
    
   declare @n int
   declare @idBarco int
   declare @idExcursion int
   
   set @idExcursion=(select idExcursion from inserted) -- tenemos la excursión
   set @n = (select COUNT(*) from TURISTAS_DE_LA_EXCURSION where idExcursion=@idExcursion) -- contamos cuantos turistas tentemos ya en el barco=esta excursion.
   set @idBarco =(select idBarco from excursion where idExcursion=@idExcursion) -- tenemos el barco.
   
   if ( @n> (select maxPasajeros from BARCO where idBarco=@idBarco))  -- si sobrepasamos la capacidad maxima de pasajeros del barco...
     begin
         raiserror 60001 'Capacidad de pasajeros/turistas sobrepasada para este barco'
         rollback transaction     
     end   
go

/* 3- Dado un tipo de excursión y una fecha, queremos saber la relación de barcos que 
realizan esa excursión con indicación del numero de pasajeros y cantidad de tripulantes 
que van en el barco. Procedimiento almacenado*/

create procedure spRelacionTipoFecha @fecha date, @idTipo int
as
  select idBarco, -- barco
      (select COUNT(*) from TRIPULACION_DE_BARCO tp where tp.idExcursion=ex.idExcursion) "Tripulantes", -- cantidad de tripulantes
      (select COUNT(*) from TURISTAS_DE_LA_EXCURSION te where te.idExcursion=ex.idExcursion) "Turistas" -- cantidad de turistas/pasajeros  
  
  from EXCURSION ex
  
  where ex.idTipo=@idTipo  and ex.fecha=@fecha


go

/* 4- Relación de excursiones en las que quedan plazas libres hoy. Hacer mediante una vista */

create view vwPlazasLibres 
as
  select ex.idExcursion,t.nombre from EXCURSION ex
   inner join TIPO_EXCURSION t on ( t.idTipo=ex.idTipo) --para poner el nombre del tipo de excursion.
   inner join BARCO b on ( b.idBarco=ex.idBarco) -- para calcular el maximo de pasajeros.    
   
  where ex.fecha= cast(getdate() as DATE) -- la fecha de hoy (sin la parte que es hora), por eso el cast
     and  -- y que la cantidad de turistas que hay apuntados sea menor que la capacidad del barco.
      (select COUNT(*) from TURISTAS_DE_LA_EXCURSION te where te.idExcursion=ex.idExcursion) < b.maxPasajeros           
go

/* 5.- Un turista no puede hacer dos excursiones al mismo tiempo.*/

create trigger trSoloUnaExcursionPorDia on TURISTAS_DE_LA_EXCURSION for insert,update
as  
  declare @idTurista int
  declare @idExcursion int
  declare @fecha date
  declare @n int
  
  set @idTurista=(select idTurista from inserted)
  set @idExcursion=(select idExcursion from inserted)
  
  set @fecha = (select fecha from EXCURSION where idExcursion=@idExcursion) -- tengo la fecha en la que intento poner a este turista.
  
  -- ahora hay que ver que no tenga ninguna excursion para ese dia.
  
  set @n=(select COUNT(*) from TURISTAS_DE_LA_EXCURSION te
            inner join EXCURSION ex on (te.idExcursion=ex.idExcursion)
         where  ex.fecha=@fecha and te.idturista=@idTurista ) --  contar las excursiones en las que aparece el turista.
  
    if (@n >1) -- "1", no un cero, puesto que la excursion que estoy intentando grabar ya aparece como grabada en la tabla al hacer el select desde el trigger.
     begin
        raiserror 60010 'Ya tiene otra excursion para este día'
        rollback transaction
     end   
go 

