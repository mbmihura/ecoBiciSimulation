CREATE PROCEDURE [dbo].[LoadStationsFromCSVFile]
AS
	DELETE [dbo].[StationsDefinition]

	BULK INSERT [dbo].[StationsDefinition]
	FROM 'c:\estaciones.csv'
	WITH
	(
		FIRSTROW = 1,
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n'
	)
RETURN 0
