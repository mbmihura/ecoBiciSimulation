CREATE FUNCTION [dbo].[ED] 
(
	@IdSDE	INT
)
RETURNS INT
AS
BEGIN	
	DECLARE @Temp TABLE (Id INT IDENTITY, IdEstacionDestino INT)
	DECLARE
		 @cant_estaciones numeric(18) 
		,@retorno	int
		
	INSERT INTO @Temp 
		(IdEstacionDestino)
	SELECT EstacionDestino
	FROM [dbo].[Trips]
	WHERE EstacionOrigen = @IdSDE
	
	SELECT @cant_estaciones = Count(*) 
	FROM @Temp	
	
	SELECT @retorno = IdEstacionDestino
	FROM @Temp
	WHERE Id = Cast(
		((SELECT RandomNumber FROM [dbo].[RandomV])*@cant_estaciones) AS INT
	)

	RETURN @retorno
END
