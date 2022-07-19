/*
Created: 17/06/2015
Modified: 17/06/2015
Model: excursiones
Database: MS SQL Server 2008
*/

create database excursiones
go

use excursiones
go

-- Create tables section -------------------------------------------------

-- Table Hoteles

CREATE TABLE [Hoteles]
(
 [CodHotel] Int NOT NULL,
 [Hotel] Varchar(50) NOT NULL
)
go

-- Add keys for table Hoteles

ALTER TABLE [Hoteles] ADD CONSTRAINT [Key1] PRIMARY KEY ([CodHotel])
go

-- Table Clientes

CREATE TABLE [Clientes]
(
 [CodCliente] Int NOT NULL,
 [Nombre] Varchar(20) NOT NULL,
 [PrimerApellido] Varchar(20) NOT NULL,
 [SegundoApellido] Varchar(20) NOT NULL,
 [CodHotel] Int  NOT NULL
)
go

-- Create indexes for table Clientes

CREATE INDEX [IX_Relationship1] ON [Clientes] ([CodHotel])
go

-- Add keys for table Clientes

ALTER TABLE [Clientes] ADD CONSTRAINT [Key2] PRIMARY KEY ([CodCliente])
go

-- Table Vehiculos

CREATE TABLE [Vehiculos]
(
 [Matricula] Char(7) NOT NULL,
 [Descripcion] Varchar(20) NOT NULL
)
go

-- Add keys for table Vehiculos

ALTER TABLE [Vehiculos] ADD CONSTRAINT [Key3] PRIMARY KEY ([Matricula])
go

-- Table Conductores

CREATE TABLE [Conductores]
(
 [CodConductor] Int NOT NULL,
 [Nombre] Varchar(20) NOT NULL,
 [Apellidos] Varchar(40) NOT NULL
)
go

-- Add keys for table Conductores

ALTER TABLE [Conductores] ADD CONSTRAINT [Key4] PRIMARY KEY ([CodConductor])
go

-- Table Transportes

CREATE TABLE [Transportes]
(
 [Fecha] Date NOT NULL,
 [Matricula] Char(7) NOT NULL,
 [CodConductor] Int NOT NULL
)
go

-- Create indexes for table Transportes

CREATE INDEX [IX_Relationship3] ON [Transportes] ([CodConductor])
go

-- Add keys for table Transportes

ALTER TABLE [Transportes] ADD CONSTRAINT [Key5] PRIMARY KEY ([Fecha],[Matricula])
go

-- Table Excursiones

CREATE TABLE [Excursiones]
(
 [CodCliente] Int NOT NULL,
 [Fecha] Date NOT NULL,
 [Matricula] Char(7) NOT NULL
)
go

-- Add keys for table Excursiones

ALTER TABLE [Excursiones] ADD CONSTRAINT [Key6] PRIMARY KEY ([CodCliente],[Fecha],[Matricula])
go

-- Create relationships section ------------------------------------------------- 

ALTER TABLE [Clientes] ADD CONSTRAINT [se alojan] FOREIGN KEY ([CodHotel]) REFERENCES [Hoteles] ([CodHotel]) ON UPDATE CASCADE
go

ALTER TABLE [Transportes] ADD CONSTRAINT [transportados] FOREIGN KEY ([Matricula]) REFERENCES [Vehiculos] ([Matricula]) ON UPDATE CASCADE
go

ALTER TABLE [Transportes] ADD CONSTRAINT [llevado por] FOREIGN KEY ([CodConductor]) REFERENCES [Conductores] ([CodConductor]) ON UPDATE CASCADE
go

ALTER TABLE [Excursiones] ADD CONSTRAINT [acuden] FOREIGN KEY ([CodCliente]) REFERENCES [Clientes] ([CodCliente]) ON UPDATE CASCADE
go

ALTER TABLE [Excursiones] ADD CONSTRAINT [transportados en] FOREIGN KEY ([Fecha], [Matricula]) REFERENCES [Transportes] ([Fecha], [Matricula])ON UPDATE CASCADE
go



