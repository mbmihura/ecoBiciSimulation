CREATE TYPE [dbo].[ByclesInitialAmountPerStations] AS TABLE 
(
	[idEstacion] INT NOT NULL,
	[NombreEstacion] varchar(50),
	[CantidadInicialBicicletas] INT
)