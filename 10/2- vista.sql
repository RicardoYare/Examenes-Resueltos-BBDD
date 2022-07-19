-- 2. ---

create view vwPasajerosHoy
as
   select nombre, peso from pasaje 
      inner join pasajero on (pasaje.idPasajero= pasajero.idpasajero)
      inner join vuelo on (pasaje.idvuelo=vuelo.idvuelo)
      where fecha = cast(GETDATE() as DATE) 
 go