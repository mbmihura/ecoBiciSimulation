CREATE PROCEDURE [dbo].[LoadTripsFromCSVFile]
AS
	DELETE [dbo].[Trips]

	BULK INSERT [dbo].[Trips]
	FROM 'c:\recorrido-bicis-2012.csv'
	WITH
	(
		FIRSTROW = 1,
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n'
	)
RETURN 0