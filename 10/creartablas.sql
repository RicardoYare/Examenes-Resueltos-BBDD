
-- Table PASAJERO

CREATE TABLE [PASAJERO]
(
 idPasajero Int IDENTITY NOT NULL primary key,
 Nombre Varchar(50) NULL
)
go

-- Table HIDROAVION

CREATE TABLE HIDROAVION
(
 MatriculaHidro Varchar(15) NOT NULL primary key,
 Observaciones Varchar(30) NULL
)

-- Table PILOTO
go
CREATE TABLE PILOTO
(
 idPiloto Int NOT NULL primary key,
 Nombre Varchar(50) NOT NULL
)
go


-- Table VUELO

CREATE TABLE VUELO
(
 idVuelo Int IDENTITY NOT NULL primary key,
 MatriculaHidro Varchar(15) NOT NULL foreign key references HIDROAVION(matriculaHidro)
                     on update cascade,
 idPiloto Int NOT NULL foreign key references Piloto (idPiloto)
				     on update cascade,
 Fecha Date NOT NULL
)
go

create unique index akAvionSoloVuelaUnaVez on vuelo (matriculahidro,fecha)
go



-- Table PASAJE

CREATE TABLE PASAJE
(
 idVuelo Int NOT NULL foreign key references vuelo(idVuelo) 
                on update cascade,
 idPasajero Int NOT NULL foreign key references Pasajero(idPasajero)
				on update cascade,
 peso Int not NULL,
 primary key ( idVuelo,idPasajero)
  
)
go


