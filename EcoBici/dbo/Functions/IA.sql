CREATE FUNCTION [dbo].[IA] 
(
	@IdEstacion INT
)
RETURNS INT
AS
BEGIN	
	DECLARE 
		 @Temp TABLE (Id INT IDENTITY, IntervaloMinutos	INT)
	DECLARE 
		 @fecha_salida			DATETIME 
		,@fecha_salida_anterior	DATETIME
		,@minutos				INT
		,@cant_intervalos		NUMERIC(18)
		,@retorno				INT
		 
	DECLARE Estaciones_c CURSOR
	FOR SELECT EstacionOrigen
		FROM [dbo].[Trips]
		WHERE EstacionOrigen = @IdEstacion
		ORDER BY FechaInicio
	
	OPEN Estaciones_c
	FETCH Estaciones_c INTO @fecha_salida
		
	SET @fecha_salida_anterior = '2010-01-01'					
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			IF DATEDIFF(DAY,@fecha_salida_anterior,@fecha_salida) = 0 
				BEGIN
					SET @minutos = DATEDIFF(MINUTE,@fecha_salida_anterior,@fecha_salida)
					INSERT INTO @Temp
						(IntervaloMinutos)
					VALUES (@minutos)
				END	
			SET @fecha_salida_anterior = @fecha_salida		 
			FETCH  Estaciones_c INTO @fecha_salida
		END 		 		 
	
	SELECT @cant_intervalos = count(*)
	FROM @Temp	
	
	SELECT @retorno = IntervaloMinutos
	FROM @Temp
	WHERE Id = cast(
		((SELECT RandomNumber FROM [dbo].[RandomV])*@cant_intervalos) AS INT
	)

	RETURN @retorno
END
