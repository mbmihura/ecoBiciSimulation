CREATE PROCEDURE [dbo].[RunSimulation]
	@CantInicialBicicletasPorStacion [BicyclesInitialAmountPerStations] READONLY
AS
BEGIN
	DECLARE @PRB NUMERIC(2,2)
	DECLARE @time DATETIME
	DECLARE @tf DATETIME
	DECLARE @IA INT
	DECLARE @minTPLL DATETIME
	DECLARE @idBiciMinTPLL INT
	DECLARE @minTPSE DATETIME
	DECLARE @idEstacionMinTPSE INT
	DECLARE @idBycicle INT
	DECLARE @ED INT
	DECLARE @TV INT

	DECLARE @STSB INT -- Sumatoria Tiempo Sin Bicicletas Por Estacion
	DECLARE @ITSB DATETIME -- Inicio Tiempo Sin Bicicletas Por Estacion

	SET @PRB = 0.06 -- Porcetage de bicicletas que llegan rotas a una estacion.
	SET @time = '2012-07-21 08:00:00' -- Horario de inicio.
	SET @tf = '2013-07-21 20:00:00' -- Horario de fin.

	DELETE [dbo].[Stations]

	INSERT
		INTO [dbo].[Stations](Id,Nombre)
		SELECT idEstacion, NombreEstacion
		FROM @CantInicialBicicletasPorStacion

	-- Si la estacion inicia sin bicicletas, registrar valor inicial de @time como su InicioTiempoSinBicicleta.
	UPDATE [dbo].[Stations]
	SET InicioTiempoSinBicicleta = @time
	WHERE EXISTS(Select * 
				 FROM @CantInicialBicicletasPorStacion input 
				 WHERE 
					input.idEstacion = Id AND
					CantidadInicialBicicletas = 0
				)
	

	WHILE (@time < @tf OR EXISTS(SELECT * FROM [dbo].[Bicycles] WHERE TiempoLLegada IS NOT NULL))
	BEGIN
		SELECT TOP 1 @minTPLL = [TiempoLLegada], @idBiciMinTPLL = [Id] FROM [dbo].[Bicycles] ORDER BY TiempoLLegada asc
		SELECT TOP 1 @minTPSE = [TiempoProxSalida], @idEstacionMinTPSE = [Id] FROM [dbo].[Stations] ORDER BY TiempoProxSalida asc

		IF(@minTPSE < @minTPLL) -- Si coincide el tiempo, procesar llegadas antes que salidas.
		-- Evento: Salida desde una estacion.
		BEGIN
			SET @time = @minTPSE
			SELECT @IA = [dbo].[IA](@idEstacionMinTPSE)
			
			UPDATE [DBO].[Stations]
			SET TiempoProxSalida = DATEADD(MINUTE, @IA,@time) 
			WHERE Id = @idEstacionMinTPSE

			DECLARE @CantBicisLibres INT
			SELECT @CantBicisLibres = Count(id) FROM [dbo].[Bicycles] WHERE TiempoLLegada IS NULL AND EstacionLLegada = @idEstacionMinTPSE
			IF @CantBicisLibres > 0
			BEGIN
				SELECT @ED = [dbo].[ED](@idEstacionMinTPSE)
				SELECT @TV = [dbo].[TV](@idEstacionMinTPSE, @ED)
				
				UPDATE [dbo].[Bicycles]
				SET 
					TiempoLLegada = DATEADD(MINUTE, @TV, @time),
					EstacionLLegada = @ED
				WHERE Id = @idBycicle

				IF @CantBicisLibres < 2
				BEGIN
				-- Estacion sin bicicletas
					UPDATE [dbo].[Stations]
					SET InicioTiempoSinBicicleta = @time
					WHERE Id = @idEstacionMinTPSE
				END
			END
		END
		ELSE
		-- Evento: Llegada de bici a una estacion.
		BEGIN
			-- Avanzar el tiempo hasta el evento
			SET @Time = @minTPLL

			DECLARE @EstacionDondeLlega INT
			SELECT @EstacionDondeLlega = EstacionLLegada FROM [dbo].[Bicycles] WHERE Id = @idBiciMinTPLL
			
			-- No hay bicicletas libres en la estacion
			IF NOT EXISTS(SELECT * FROM [dbo].[Bicycles] WHERE TiempoLLegada IS NULL AND EstacionLLegada = @EstacionDondeLlega)
			BEGIN
				-- Actulizar sumatior tiempo que estuvo sin bicis la estacion.

				SELECT 
					@STSB = SumatoriaTiempoSinBicicletas, -- Sumatoria Tiempo Sin Bicicletas Por Estacion
					@ITSB = InicioTiempoSinBicicleta      -- Inicio Tiempo Sin Bicicletas Por Estacion
				FROM [dbo].[Stations] WHERE Id = @EstacionDondeLlega
				
				UPDATE [dbo].[Stations]
				SET SumatoriaTiempoSinBicicletas = @STSB + DATEDIFF(MINUTE, @ITSB, @time)
				WHERE id = @EstacionDondeLlega
			END

			-- Procesar evento: bicicleta pasa a estar desocupada.
			UPDATE [dbo].[Bicycles]
			SET TiempoLLegada = NULL
			WHERE Id = @idBiciMinTPLL

			-- Determinar si la bicicles llega rota se rompe o queda disponible paraser retirada desde esa estacion.
			IF (RAND() < @PRB)
			BEGIN
				UPDATE [dbo].[Bicycles]
				SET EstacionLLegada = NULL
				WHERE Id = @idBiciMinTPLL
			END
		END		
	END

	UPDATE [dbo].[Stations]
	SET PorcTiempoSinBicicletas = (SELECT s2.SumatoriaTiempoSinBicicletas FROM [dbo].[Stations] s2 where s2.Id = id)
	WHERE id = @EstacionDondeLlega



	-- Calcular resultados:
	-- PTSBE: Porcentaje de tiempo sin bicicletas disponibles por estacion.
	declare C_Stations cursor
	for	select Id, SumatoriaTiempoSinBicicletas, PorcTiempoSinBicicletas from [dbo].[Stations]

				/*ahora declaramos las variables con las que vamos a recorrer el cursor:*/

				declare @nombres varchar(25)
				declare @apellidos varchar(25)

				/*Abrimos el cursor para iniciar el recorrido del mismo*/
				open cursor_prueba

				/*Se mueve al siguiente registro dentro del cursor y los asignamos a las variables antes declaradas*/
				--fetch next from cursor_prueba 
				--into @nombres, apellidos

				/*Retorna el estatus del último registro recorrido en el cursor, cuando es igual a 0 encontró registro pendientes de recorrer*/
				while @@fetch_status = 0
				begin

				print 'El Nombre de la persona es: ' + @nombres + ' y sus apellidos: ' + @apellidos

				/*Se mueve al siguiente registro dentro del cursor*/
				--fetch next from cursor_prueba
				--into @nombres, apellidos

				end 

				/* Cuando concluimos con el recorrido del cursor, este debe ser cerrado y luego destruído mediante las siguientes sentencias:*/ 
				close cursor_prueba --Cierra el cursor.
				deallocate cursor_prueba --Lo libera de la memoria y lo destruye.

    -- Promedio de tiempo en el que las estaciones no tuvieron bicicletas.

	-- Tiempo máximo en el que no se encontraron sin bicicletas por estacion.

	-- Mayor decrecimiento de bicicletas disponibles por estacion.

	-- Primer momento sin bicicletas disponibles por estacion.


	-- Mostrar resultados
	PRINT N'Resultado1: '
    + RTRIM(CAST(GETDATE() AS nvarchar(30)))
    + N'.';

	--INSERT [dbo].[Results]
	--SET


END
