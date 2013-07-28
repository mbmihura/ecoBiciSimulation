CREATE FUNCTION [dbo].[TV]
(
	@IdOrigen	INT,
	@IdDestino	INT
)
RETURNS INT
AS
BEGIN	
	DECLARE 
		 @Temp TABLE (Id INT IDENTITY, TiempoDeViaje INT)
	DECLARE 
		 @cant_tiempos			NUMERIC(18)
		,@retorno				INT
	
	INSERT INTO @Temp
		(TiempoDeViaje)	
	SELECT TiempoUso
	FROM [dbo].[Trips]
	WHERE 
		EstacionOrigen = @IdOrigen AND
		EstacionDestino = @IdDestino

	SELECT @cant_tiempos = count(*)
	FROM @Temp	
	
	SELECT @retorno = TiempoDeViaje
	FROM @Temp
	WHERE Id = cast(
		((SELECT RandomNumber FROM [dbo].[RandomV])*@cant_tiempos) AS INT
	)

	RETURN @retorno
END
