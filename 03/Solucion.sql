create trigger trNoMasDe25 on componentes_del_grupo for insert,update
as
  declare @idGRUPO datetime
  set @idGRUPO=(select idGrupo from inserted)
  if ( select COUNT(*) from COMPONENTES_DEL_GRUPO
            where idGrupo = @idGRUPO) > 25
        begin
             raiserror 60000 'NO PUEDEN HABER MAS DE 25 PERSONAS'
             rollback tran               
        end
go

create procedure spPorNacionalidades @FechaHora datetime
as
 select distinct N.Texto from 
        COMPONENTES_DEL_GRUPO G inner join NACIONALIDAD N
         on ( g.idNacionalidad = n.idNacionalidad)
   where idGrupo= @FechaHora
go

execute spPorNacionalidades '10 enero 2015 10:35'
go
create view vwHanVuelto
as 
  select v.Apellidos,v.Nombre    from COMPONENTES_DEL_GRUPO C
    inner join VISITANTE V on ( c.idVisitante=v.idVisitante)
  group by  v.Apellidos,v.Nombre ,v.idVisitante 
  having COUNT(*) >1 
    


