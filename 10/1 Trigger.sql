-- 1..

 CREATE TRIGGER TRPasaje on Pasaje for insert, update
 as
    declare @idVuelo int
    
    set @idVuelo = (select idVuelo from inserted)
    
    if ( select COUNT(*) from Pasaje where idVuelo = @idVuelo) > 10
       begin
          raiserror 80000 'Hay mas de 10 pasajeros'
          rollback tran
          return       
       end
     if ( select sum(peso) from Pasaje where idVuelo = @idVuelo) > 900
       begin
          raiserror 80000 'Pesan mas de 900kg'
          rollback tran
          return       
       end       
 
 go
 
 
 go