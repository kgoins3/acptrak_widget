
PROGRAM _INIT

	//	----------------------------------------------------------------------- Init trak assembly
	
	AsmPowerOn.Assembly			:= ADR( gAssembly_1 );
	AsmReadStatus.Assembly		:= ADR( gAssembly_1 );
	AsmReadStatus.Enable		:= TRUE;
	
	//	----------------------------------------------------------------------- Init virtual shuttles
	
	ShSpawn.StartPP				:= ADR( PP_Spawn_In );
	ShSpawn.EndPP				:= ADR( PP_Spawn_Out );
	
	ShSpawn.Acceleration		:= 10.0;
	ShSpawn.Velocity			:= 1.0;
	ShSpawn.RouteVelocity		:= 1.0;
	
	ShSpawn.Sector				:= ADR( Sector_Spawn );
	ShSpawn.DstSector			:= ADR( Sector_Mid );
	ShSpawn.DstSectorPosition	:= 0.0;
	
	ShSpawn.NumShuttleBatch				:= 1;
	ShSpawn.NumShuttleTotal				:= 30;
	ShSpawn.SectorPositionStart			:= 0.0875;
	ShSpawn.SectorPositionIncrement		:= 0;	// single-batch spawn, no increment needed1
	
	//	----------------------------------------------------------------------- gTrak Pars
	
	gTrak.Par.Acceleration		:= 30.0;
	gTrak.Par.Velocity			:= 2.0;
	gTrak.Par.PPM				:= 30;
	
END_PROGRAM

PROGRAM _CYCLIC	
	
	CASE gTrak.Status.State OF
		0://	----------------------------------------------------------------------- Powered OFF
			
			IF gTrak.Cmd.PowerOn THEN
				AsmPowerOn.Execute					:= TRUE;
			END_IF;
			
			IF AsmPowerOn.Done THEN
				ShSpawn.Enable						:= TRUE;
				gTrak.Status.State					:= 1;
			END_IF;
			
		1://	----------------------------------------------------------------------- Powering on / start Starwheel.Axis homing
			
			IF ShSpawn.SpawnValid THEN
				ShSpawn.AcknSpawn			:= TRUE;
			END_IF;
			
			IF ShSpawn.Done THEN
				ShSpawn.Enable				:= FALSE;
			END_IF;
			
			IF oneshot THEN
				VarA			:= 13;
				VarB			:= 9;
				VarC			:= 7;
				Rand16			:= 13;
				
				oneshot			:= FALSE;
			END_IF;
	
			Rand16		:= Rand16 XOR SHL(Rand16,VarA);
			Rand16		:= Rand16 XOR SHR(Rand16,VarB);
			Rand16		:= Rand16 XOR SHL(Rand16,VarC);	
		
			midRoute.Enable			:= TRUE;
			midRoute.ProcessPoint	:= PP_MidRoute;
			midRoute.Acceleration	:= gTrak.Par.Acceleration;
			midRoute.Velocity		:= gTrak.Par.Velocity;
			midRoute.RouteVelocity	:= gTrak.Par.Velocity;		
			
			IF Rand16 > 32767 THEN
				midRoute.Destination	:= Sector_Bottom; // randomly pick between bot and top?
			ELSE
				midRoute.Destination	:= Sector_Top;
			END_IF;				
				
			botRoute.Enable			:= TRUE;
			botRoute.ProcessPoint	:= PP_BotRoute;
			botRoute.Acceleration	:= gTrak.Par.Acceleration;
			botRoute.Velocity		:= gTrak.Par.Velocity;
			botRoute.RouteVelocity	:= gTrak.Par.Velocity;
			botRoute.Destination	:= Sector_Mid;
		
			topRoute.Enable			:= TRUE;
			topRoute.ProcessPoint	:= PP_TopRoute;
			topRoute.Acceleration	:= gTrak.Par.Acceleration;
			topRoute.Velocity		:= gTrak.Par.Velocity;
			topRoute.RouteVelocity	:= gTrak.Par.Velocity;
			topRoute.Destination	:= Sector_Top;
		
		
	END_CASE;
	
	// Track-related fubs
	AsmPowerOn();
	AsmReadStatus();
	ShSpawn();
	
	midRoute();
	botRoute();
	topRoute();
	 
END_PROGRAM
