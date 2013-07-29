CREATE TABLE [dbo].[Results]
(
	[Id] INT NOT NULL PRIMARY KEY,
	[SimulationTime] DATETIME,
	[PorcTiempoEstacionSinBicicletas] NUMERIC(2,2),
	[PromTiempoEstacionesNoTieneBicicletas] NUMERIC(2,2),
	[TiempoMaxEstaciónNoTuvoBicicletas] INT,
	[LapsoMayorDecrecimientoBicicletasEnEstacion] INT,
	[PrimerMomentoEstacionEstuvoSinBicicletas] datetime
)
