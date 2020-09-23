
PROGRAM _INIT
		
	//	----------------------------------------------------------------------- infeed axis configuration parameters
	
	InfeedAxisPars.Acceleration		:= 90.0;
	InfeedAxisPars.Deceleration		:= 90.0;
	InfeedAxisPars.Velocity			:= 90.0;
	
	InfeedAxisPars.Direction		:= mcDIR_POSITIVE;
	InfeedAxisPars.Homing.Mode		:= mcHOMING_DIRECT;
	InfeedAxisPars.Position			:= 0.0;
	
	Infeed.Starwheel.Axis.MpLink		:= ADR( gAxis_1 );
	Infeed.Starwheel.Axis.Parameters	:= ADR( InfeedAxisPars );
	Infeed.Starwheel.Axis.Enable		:= TRUE;

	//	----------------------------------------------------------------------- Infeed starwheel Pars
	
	Infeed.Par.SectorTangentPos		:= 1.71;			// sector position of the tangent point
	Infeed.Par.R1					:= 0.14224;			// radius of curvature of the tangent point
	Infeed.Par.R2					:= 0.3202758;		// radius of curvature of the track system at the tangent point
	Infeed.Par.Rp					:= 0.025;			// radius of the product
	Infeed.Par.deltaT				:= t#10ms;			// starwheel encoder signal delay - for predictive compensation
	Infeed.Par.PocketCount			:= 6;				// number of pockets on this starwheel
	Infeed.Par.ReleaseVelocity		:= 1.8;				// release velocity to next station
	Infeed.Par.PositionSyncPP		:= 0.45;			// position 

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
	ShSpawn.DstSector			:= ADR( Sector_Infeed );
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
				Infeed.Starwheel.Axis.Power			:= TRUE;
			END_IF;
			
			IF AsmPowerOn.Done AND Infeed.Starwheel.Axis.PowerOn THEN
				Infeed.Starwheel.Axis.Home			:= TRUE;
				gTrak.Status.State					:= 1;
			END_IF;
			
		1://	----------------------------------------------------------------------- Powering on / start Starwheel.Axis homing
			
			IF Infeed.Starwheel.Axis.IsHomed THEN
				Infeed.Starwheel.Axis.Home			:= FALSE;
				Infeed.Starwheel.Axis.MoveVelocity	:= TRUE;
			END_IF;
			
			IF Infeed.Starwheel.Axis.InVelocity THEN	// outfeed set to half velocity, same accel, so infeed will reach speed last
				ShSpawn.Enable				:= TRUE;
				gTrak.Status.State 			:= 2;
			END_IF;
			
		2://	----------------------------------------------------------------------- Homed, powered, begin sync code	
			
			IF ShSpawn.SpawnValid THEN
				ShSpawn.AcknSpawn			:= TRUE;
			END_IF;
			
			IF ShSpawn.Done THEN
				ShSpawn.Enable				:= FALSE;
			END_IF;
			
			// Starwheel code
			act_Sect_Star1;
			
			// hacky speed ramp-up
			IF gTrak.Par.PPM < 500 THEN
				gTrak.Par.PPM				:= gTrak.Par.PPM + ( 0.002 );
			END_IF;
			
			InfeedAxisPars.Velocity			:= gTrak.Par.PPM / USINT_TO_REAL(Infeed.Par.PocketCount) * 6.0;	// convert PPM command to degrees per second
			Infeed.Starwheel.Axis.Update	:= NOT(Infeed.Starwheel.Axis.Update);
		
	END_CASE;
	
	// Track-related fubs
	AsmPowerOn();
	AsmReadStatus();
	ShSpawn();
	
	// mpAxisBasic fub
	Infeed.Starwheel.Axis();
	 
END_PROGRAM
