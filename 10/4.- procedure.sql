-- 4.--- 

create procedure spNoEstanLlenos @fecha date
as
  select matriculaHidro , piloto.nombre from vuelo 
      inner join piloto on (piloto.idPiloto =vuelo.idpiloto)
  where fecha = @fecha 
        and  10 > (select COUNT(*) from pasaje 
                    where pasaje.idVuelo = vuelo.idVuelo)      

go
