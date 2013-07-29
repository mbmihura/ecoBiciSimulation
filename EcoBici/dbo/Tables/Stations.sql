CREATE TABLE [dbo].[Stations]
(
	[Id] INT PRIMARY KEY NOT NULL,
	[Nombre] nvarchar,
	[TiempoProxSalida] DATETIME DEFAULT NULL,
	[SumatoriaTiempoSinBicicletas] INT DEFAULT 0 NOT NULL,
	[InicioTiempoSinBicicleta] DATETIME NULL,
	[PorcTiempoSinBicicletas] NUMERIC(2,2) NULL
)


