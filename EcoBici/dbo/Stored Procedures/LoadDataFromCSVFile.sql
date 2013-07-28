CREATE PROCEDURE [dbo].[LoadDataFromCSVFile]
AS
	BULK INSERT [dbo].[Trips]
	FROM 'c:\recorrido-bicis-2012.csv'
	WITH
	(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n'
	)

RETURN 0