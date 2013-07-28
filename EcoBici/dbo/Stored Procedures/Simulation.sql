CREATE PROCEDURE [dbo].[Simulation]
	@CantInicialBicicletasPorStacion [ByclesInitialAmountPerStations] READONLY
AS
BEGIN
	DECLARE @PRB NUMERIC(2,2)
	DECLARE @time DATETIME
	DECLARE @tf DATETIME
	DECLARE @IA INT
	DECLARE @minTPLL DATETIME
	DECLARE @idMinTPLL INT
	DECLARE @minTPSE DATETIME
	DECLARE @idMinTPSE INT
	DECLARE @idBycicle INT
	DECLARE @ED INT
	DECLARE @TV INT

	SET @PRB = 0.06 -- Porcetage de bicicletas que llegan rotas a una estacion.



	WHILE (@time < @tf OR EXISTS(SELECT * FROM [dbo].[Bicycles] WHERE TiempoLLegada IS NOT NULL))
	BEGIN
		SELECT TOP 1 @minTPLL = [TiempoLLegada], @idMinTPLL = [Id] FROM [dbo].[Bicycles]
		SELECT TOP 1 @minTPSE = [TiempoProxSalida], @idMinTPSE = [Id] FROM [dbo].[Stations]

		IF(@minTPSE > @minTPLL) -- Si coincide el tiempo, procesar llegadas antes que salidas.
		BEGIN
			-- Evento: Salida desde una estacion.
			SET @time = @minTPSE
			SELECT @IA = [dbo].[IA](@idMinTPSE)
			
			UPDATE [DBO].[Stations]
			SET TiempoProxSalida = DATEADD(MINUTE, @IA,@time) 
			WHERE Id = @idMinTPSE

			SELECT @idBycicle = Id FROM [dbo].[Bicycles] WHERE TiempoLLegada IS NULL AND EstacionLLegada = @idMinTPSE
			IF @idBycicle IS NULL
			BEGIN
				SELECT @ED = [dbo].[ED](@idMinTPSE)
				SELECT @TV = [dbo].[TV](@idMinTPSE, @ED)
				
				UPDATE [dbo].[Bicycles]
				SET 
					TiempoLLegada = DATEADD(MINUTE, @TV, @time),
					EstacionLLegada = @ED
				WHERE Id = @idBycicle
			END
		END
		ELSE
		BEGIN
			SET @Time = @minTPLL

			UPDATE [dbo].[Bicycles]
			SET TiempoLLegada = NULL
			WHERE Id = @idMinTPLL

			-- Bicicles que se rompen
			IF (RAND() < @PRB)
			BEGIN
				UPDATE [dbo].[Bicycles]
				SET EstacionLLegada = NULL
				WHERE Id = @idMinTPLL
			END
		END		
	END
	-- Calcular resultados


	-- Mostrar resultados
	PRINT N'Resultado1: '
    + RTRIM(CAST(GETDATE() AS nvarchar(30)))
    + N'.';

	--INSERT [dbo].[Results]
	--SET


END
