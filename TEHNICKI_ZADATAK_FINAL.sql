

---------------------------------------------------------------------
-- Script that creates the sample database TSQLTEST
--
-- Supported versions of SQL Server: 2005, 2008, 2008 R2, 2012, 2014
--

USE master;

-- Drop database
IF DB_ID('TSQLTEST') IS NOT NULL 
BEGIN
ALTER DATABASE TSQLTEST 
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
DROP DATABASE TSQLTEST;
END
GO


-- If database could not be created due to open connections, abort
IF @@ERROR = 3702 
   RAISERROR('Database cannot be dropped because there are still open connections.', 127, 127) WITH NOWAIT, LOG;

-- Create database
CREATE DATABASE TSQLTEST;
GO

USE TSQLTEST;
GO




CREATE SCHEMA Sifarnici AUTHORIZATION dbo;
GO
CREATE SCHEMA Dokumenti AUTHORIZATION dbo;
GO



/******/
CREATE TABLE [Sifarnici].[PREDUZECE](
	[PreduzeceId] [SMALLINT] NOT NULL,
	[Naziv] [VARCHAR](100) NOT NULL,
 CONSTRAINT [PK_PREDUZECE] PRIMARY KEY CLUSTERED ([PreduzeceId] ASC)
)

/******/
CREATE TABLE [Sifarnici].[PREDUZECE_POSLOVNICA](
	[PreduzeceId] [SMALLINT] NOT NULL,
	[PreduzecePoslovnicaId] [SMALLINT] NOT NULL,
	[Naziv] [VARCHAR](100) NOT NULL,
	[TipPoslovnice] CHAR(1)
 CONSTRAINT [PK_PREDUZECE_POSLOVNICA] PRIMARY KEY CLUSTERED ([PreduzeceId], [PreduzecePoslovnicaId] ASC)
)

ALTER TABLE [Sifarnici].[PREDUZECE_POSLOVNICA]  WITH NOCHECK ADD  CONSTRAINT [FK_PoslovnicaDefinisanaUOrganizaciji] FOREIGN KEY([PreduzeceId])
REFERENCES [Sifarnici].[PREDUZECE] ([PreduzeceId])
GO
ALTER TABLE [Sifarnici].[PREDUZECE_POSLOVNICA] CHECK CONSTRAINT [FK_PoslovnicaDefinisanaUOrganizaciji]
GO
ALTER TABLE [Sifarnici].[PREDUZECE_POSLOVNICA]  ADD CONSTRAINT CH_VeleprodajaMaloprodaja CHECK (TipPoslovnice='V' OR TipPoslovnice='M')
GO


/****/
CREATE TABLE [Sifarnici].[POSLOVNA_GODINA](
	[PreduzeceId] [SMALLINT] NOT NULL,
	[PoslovnaGodina] [SMALLINT] NOT NULL,
 CONSTRAINT [PK_POSLOVNA_GODINA] PRIMARY KEY CLUSTERED 
([PoslovnaGodina] ASC,[PreduzeceId] ASC)
)
GO



/****/
CREATE TABLE [Sifarnici].[ARTIKAL](
	[PreduzeceId] [smallint] NOT NULL,
	[ArtikalId] [int] NOT NULL,
	[Naziv] [varchar](150) NOT NULL,
	[CijenaBezPdv] DECIMAL(12,6) NOT NULL,
	[KolicinaStanje] DECIMAL (12,6) NOT NULL,
	CONSTRAINT [PK_ARTIKAL] PRIMARY KEY CLUSTERED (PreduzeceId ASC,ArtikalId ASC)
)

ALTER TABLE [Sifarnici].[ARTIKAL]  WITH NOCHECK ADD  CONSTRAINT [FK_ArtikalDefinisanUOrganizaciji] FOREIGN KEY([PreduzeceId])
REFERENCES [Sifarnici].[PREDUZECE] ([PreduzeceId])
GO
ALTER TABLE [Sifarnici].[ARTIKAL] CHECK CONSTRAINT [FK_ArtikalDefinisanUOrganizaciji]
GO


/****/
CREATE TABLE [Sifarnici].[USLUGA](
	[PreduzeceId] [smallint] NOT NULL,
	[UslugaId] [int] NOT NULL,
	[Naziv] [varchar](150) NOT NULL,
	[CijenaBezPdv] DECIMAL(12,6) NOT NULL,
	CONSTRAINT [PK_USLUGA] PRIMARY KEY CLUSTERED (PreduzeceId ASC,UslugaId ASC)
)

ALTER TABLE [Sifarnici].[USLUGA]  WITH NOCHECK ADD  CONSTRAINT [FK_UslugaDefinisanUPreduzecu] FOREIGN KEY([PreduzeceId])
REFERENCES [Sifarnici].[PREDUZECE] ([PreduzeceId])
GO
ALTER TABLE [Sifarnici].[USLUGA] CHECK CONSTRAINT [FK_UslugaDefinisanUPreduzecu]
GO


/****/
CREATE TABLE [Sifarnici].[RADNIK](
	[PreduzeceId] [SMALLINT] NOT NULL,
	[RadnikId] [INT] NOT NULL,
	[Ime] [VARCHAR](40) NOT NULL,
	[Prezime] [VARCHAR](40) NOT NULL,
	[JMB] [CHAR](13) NOT NULL,
 CONSTRAINT [PK_RADNIK] PRIMARY KEY CLUSTERED ([PreduzeceId] ASC,[RadnikId] ASC),
 CONSTRAINT [JedinstveniJMB] UNIQUE NONCLUSTERED ([PreduzeceId] ASC,[JMB] ASC)
) 

GO
ALTER TABLE [Sifarnici].[RADNIK]  WITH NOCHECK ADD  CONSTRAINT [FK_RadnikPripadaOrganizaciji] FOREIGN KEY([PreduzeceId])
REFERENCES [Sifarnici].[PREDUZECE] ([PreduzeceId])
GO
ALTER TABLE [Sifarnici].[RADNIK] CHECK CONSTRAINT [FK_RadnikPripadaOrganizaciji]
GO



/****/
CREATE TABLE [Sifarnici].[KUPAC](
	[PreduzeceId] [smallint] NOT NULL,
	[KupacId] [int] NOT NULL,
	[Naziv] [varchar](150) NOT NULL,
	[Jib] [char](13) NULL,
	[Ib] [char](13) NULL,
	[MaticniBroj] [varchar](13) NULL,
	[FizickoLice] [bit] NOT NULL,
	[PdvObveznik] [bit] NOT NULL,
 CONSTRAINT [PK_PARTNER] PRIMARY KEY CLUSTERED ([PreduzeceId] ASC,[KupacId] ASC)
) 
GO

ALTER TABLE [Sifarnici].[KUPAC]  WITH NOCHECK ADD  CONSTRAINT [FK_PartnerOrganizacije] FOREIGN KEY([PreduzeceId])
REFERENCES [Sifarnici].[PREDUZECE] ([PreduzeceId])
GO
ALTER TABLE [Sifarnici].[KUPAC] CHECK CONSTRAINT [FK_PartnerOrganizacije]
GO


/****/
CREATE TABLE Dokumenti.[RACUN] (
	[PreduzeceId] [smallint] NOT NULL,
	[PreduzecePoslovnicaId] [smallint] NOT NULL,
	[PoslovnaGodina] [smallint] NOT NULL,
	[RacunId] [int] NOT NULL,
	[Datum] [date] NOT NULL,
	[KupacId] [int] NOT NULL,
	[Osnovica] [decimal](12, 2) NOT NULL,
	[Pdv] [decimal](12, 2) NOT NULL,
	[Ukupno] [decimal](12, 2) NOT NULL,
	[RadnikId] [int] NOT NULL,
	[Status] [char](1) NOT NULL,
	[DatumKnjizenja] [date] NULL,
	[Napomena] [varchar](2000) NULL,
 CONSTRAINT [PK_RACUN] PRIMARY KEY CLUSTERED 
([PreduzeceId] ASC,[PreduzecePoslovnicaId] ASC,[PoslovnaGodina] ASC,[RacunId] ASC)
)
GO

ALTER TABLE [Dokumenti].RACUN WITH NOCHECK ADD  CONSTRAINT [FK_RacunDefinisanUOrganizaciji] FOREIGN KEY([PreduzeceId],[PreduzecePoslovnicaId])
REFERENCES [Sifarnici].PREDUZECE_POSLOVNICA ([PreduzeceId],PreduzecePoslovnicaId)
GO
ALTER TABLE [Dokumenti].RACUN CHECK CONSTRAINT [FK_RacunDefinisanUOrganizaciji]
GO


ALTER TABLE [Dokumenti].[RACUN] WITH NOCHECK ADD  CONSTRAINT [FK_RacunIzPoslovneGodine] FOREIGN KEY([PoslovnaGodina], [PreduzeceId])
REFERENCES [Sifarnici].[POSLOVNA_GODINA] ([PoslovnaGodina], [PreduzeceId])
GO
ALTER TABLE [Dokumenti].[RACUN] CHECK CONSTRAINT [FK_RacunIzPoslovneGodine]
GO

ALTER TABLE [Dokumenti].[RACUN]  WITH NOCHECK ADD  CONSTRAINT [FK_KupacZaKogaJeRacun] FOREIGN KEY([PreduzeceId], [KupacId])
REFERENCES [Sifarnici].[KUPAC] ([PreduzeceId], [KupacId])
GO
ALTER TABLE [Dokumenti].[RACUN] CHECK CONSTRAINT [FK_KupacZaKogaJeRacun]
GO


ALTER TABLE [Dokumenti].[RACUN]  WITH NOCHECK ADD  CONSTRAINT [FK_RadnikFakturisao] FOREIGN KEY([PreduzeceId], [RadnikId])
REFERENCES [Sifarnici].[RADNIK] ([PreduzeceId], [RadnikId])
GO
ALTER TABLE [Dokumenti].[RACUN] CHECK CONSTRAINT [FK_RadnikFakturisao]
GO

ALTER TABLE Dokumenti.RACUN ADD CONSTRAINT CH_Status CHECK (Status='E' OR Status='P')
GO


/*****/


CREATE TABLE [Dokumenti].[RACUN_STAVKA] (
	[PreduzeceId] [SMALLINT] NOT NULL,
	[PreduzecePoslovnicaId] [smallint] NOT NULL,
	[PoslovnaGodina] [SMALLINT] NOT NULL,
	[RacunId] [INT] NOT NULL,
	[RacunStavkaId] [SMALLINT] NOT NULL,
	[ArtikalId] [INT] NULL,
	[UslugaId] [INT] NULL,
	[Kolicina] [DECIMAL](14, 6) NOT NULL,
	[Cijena] [DECIMAL](16, 6) NOT NULL,
	[PdvStopa] [DECIMAL](16, 2) NOT NULL,
	[Pdv] [DECIMAL](16, 6) NOT NULL,
	[Osnovica] [DECIMAL](16, 2) NOT NULL,
 CONSTRAINT [PK_IZLAZNA_FAKTURA_ROBA] PRIMARY KEY CLUSTERED 
([PreduzeceId] ASC,PreduzecePoslovnicaId ASC,[PoslovnaGodina] ASC, [RacunId] ASC,[RacunStavkaId] ASC)
)
GO


ALTER TABLE [Dokumenti].[RACUN_STAVKA]  WITH NOCHECK ADD  CONSTRAINT [FK_ArtikalPoStavciRacuna] FOREIGN KEY([PreduzeceId], [ArtikalId])
REFERENCES [Sifarnici].[ARTIKAL] ([PreduzeceId], [ArtikalId])
GO
ALTER TABLE [Dokumenti].[RACUN_STAVKA] CHECK CONSTRAINT [FK_ArtikalPoStavciRacuna]
GO

ALTER TABLE [Dokumenti].[RACUN_STAVKA]  WITH NOCHECK ADD  CONSTRAINT [FK_UslugaPoStavciRacuna] FOREIGN KEY([PreduzeceId], [UslugaId])
REFERENCES [Sifarnici].[USLUGA] ([PreduzeceId], [UslugaId])
GO
ALTER TABLE [Dokumenti].[RACUN_STAVKA] CHECK CONSTRAINT [FK_UslugaPoStavciRacuna]
GO


ALTER TABLE [Dokumenti].[RACUN_STAVKA]  WITH NOCHECK ADD  CONSTRAINT [FK_RobaRacuna] FOREIGN KEY([PreduzeceId],[PreduzecePoslovnicaId], [PoslovnaGodina], [RacunId])
REFERENCES [Dokumenti].[RACUN] ([PreduzeceId],[PreduzecePoslovnicaId], [PoslovnaGodina], [RacunId])
GO

ALTER TABLE [Dokumenti].[RACUN_STAVKA] CHECK CONSTRAINT [FK_RobaRacuna]
GO


ALTER TABLE [Dokumenti].[RACUN_STAVKA]  WITH CHECK ADD  CONSTRAINT [CK_UslugaArtikal] CHECK  ((NOT [ArtikalId] IS NULL) OR (NOT [UslugaId] IS NULL))
GO

ALTER TABLE [Dokumenti].[RACUN_STAVKA] CHECK CONSTRAINT [CK_UslugaArtikal]
GO



/*INSERT*/
INSERT INTO Sifarnici.PREDUZECE
VALUES
( 1, 'Preduzece DOO' )
INSERT INTO Sifarnici.PREDUZECE_POSLOVNICA
VALUES
( 1, 1, '01 Poslovnica veleprodaja', 'V' ), 
( 1, 2, '02 Poslovnica maloprodaja', 'M' )
INSERT INTO Sifarnici.POSLOVNA_GODINA
VALUES
( 1, 2022 ), 
( 1, 2023 )
INSERT INTO Sifarnici.ARTIKAL
VALUES
( 1, 1, 'Artikal1', 10.000000, 20.000000 ), 
( 1, 2, 'Artikal2', 20.000000, 50.000000 ), 
( 1, 3, 'Artikal3', 5.000000, 50.000000 )
INSERT INTO Sifarnici.USLUGA
VALUES
( 1, 1, 'Usluga1', 10.000000 ), 
( 1, 2, 'Usluga2', 20.000000 ), 
( 1, 3, 'Usluga3', 3.000000 )
INSERT INTO Sifarnici.KUPAC
VALUES
( 1, 1, 'Kupac1', '', '', '', 0, 1 ), 
( 1, 2, 'Kupac2', '', '', '', 0, 1 ), 
( 1, 3, 'Kupac3', '', '', '', 0, 0 )
INSERT INTO Sifarnici.RADNIK
VALUES
( 1, 1, 'Petar', 'Petrovic', '1234567894562' ), 
( 1, 2, 'Marko', 'Markovic', '6547896215486' )
INSERT INTO Dokumenti.RACUN
VALUES
( 1, 1, 2023, 1, N'2023-04-13T00:00:00', 1, 200.00, 34.00, 234.00, 1, 'E', NULL, '' ), 
( 1, 1, 2023, 2, N'2023-04-13T00:00:00', 2, 0.00, 0.00, 0.00, 2, 'E', NULL, '' ), 
( 1, 1, 2023, 3, N'2023-04-13T00:00:00', 3, 0.00, 0.00, 0.00, 1, 'E', NULL, '' ), 
( 1, 2, 2023, 1, N'2023-04-13T00:00:00', 3, 0.00, 0.00, 0.00, 2, 'E', NULL, '' ), 
( 1, 2, 2023, 2, N'2023-04-13T00:00:00', 3, 0.00, 0.00, 0.00, 1, 'E', NULL, '' )
INSERT INTO Dokumenti.RACUN_STAVKA
VALUES
( 1, 1, 2023, 1, 1, 1, NULL, 10.000000, 10.000000, 17.00, 17.000000, 100.00 ), 
( 1, 1, 2023, 1, 3, NULL, 1, 10.000000, 10.000000, 17.00, 17.000000, 100.00 ),
( 1, 2, 2023, 2, 1, 1, NULL, 10.000000, 10.000000, 17.00, 17.000000, 100.00 ), 
( 1, 2, 2023, 2, 3, NULL, 1, 10.000000, 10.000000, 17.00, 17.000000, 100.00 )