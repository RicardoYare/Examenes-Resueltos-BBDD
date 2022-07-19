--3 .--

create procedure spVuelosEntreFechas
    @MatriculaHidro varchar(15), 
    @desde date,
    @hasta date
 as
   select idVuelo,fecha from Vuelo 
        where MatriculaHidro = @MatriculaHidro
         and fecha between @desde and @hasta  
 go