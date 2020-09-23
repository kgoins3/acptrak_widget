
ACTION act_Sect_Star1:
		
	//	======================================================================= Calculate track position cutoffs for starwheel rotational periods
	
	// Could set this to calculate only once as an optimization	
	FOR index := 0 TO (SIZEOF( Infeed.Starwheel.Period ) / SIZEOF( Infeed.Starwheel.Period[0] ) - 1) DO		
		Infeed.Starwheel.Period[index].TrakMax	:= (((index * -2 + 1) * PI ) * Infeed.Par.R1 ) + Infeed.Par.SectorTangentPos;
		Infeed.Starwheel.Period[index].TrakMin	:= (((index * -2 - 1) * PI ) * Infeed.Par.R1 ) + Infeed.Par.SectorTangentPos;
		
		IF Infeed.Par.PositionSyncPP > Infeed.Starwheel.Period[index].TrakMin AND Infeed.Par.PositionSyncPP < Infeed.Starwheel.Period[index].TrakMax THEN
			// Essentially, how many revolutions early are shuttles syncronizing to the starwheel
			Infeed.Par.PeriodCount				:= INT_TO_USINT(index + 1);	
		END_IF;
	END_FOR;
	
	//	======================================================================= Continuous position calculation
	
	// Remember calculated positions from last cycle to check for trakpos values crossing over the sync position
	Infeed.Starwheel.Period[Infeed.Par.PeriodCount-1].PocketLastCycle		:= Infeed.Starwheel.Period[Infeed.Par.PeriodCount-1].Pocket;

	FOR indexPeriod := 0 TO Infeed.Par.PeriodCount - 1 DO
		FOR indexPocket := 0 TO Infeed.Par.PocketCount - 1  DO
			// Calculate pocket offsets from Starwheel positions
			Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].Offset		:= 360.0 - indexPocket * ( 360.0 / Infeed.Par.PocketCount );
			
			// Predictive phasing offset based on starwheel velocity and deltaT ... time_to_real returns value as milliseconds
			Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].PosDeg		:= LREAL_TO_REAL(Infeed.Starwheel.Axis.Position) + Infeed.Starwheel.Axis.Velocity * TIME_TO_REAL(Infeed.Par.deltaT) / 1000.0;
			
			// Calculate pocket positions in degrees based on offsets & starwheel position
			Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].PosDeg		:= fmod(Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].PosDeg + 
																					Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].Offset, 360.0) - 180.0;
			// Offset additionally for additional revolutions of the slave
			Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].PosDeg		:= Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].PosDeg - (indexPeriod * 360.0);
			
			// Convert position to radians
			Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].PosRad		:= Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].PosDeg * ( 2 * PI ) / ( 360.0 );
			
			// Camming equation v1.2 - see documentation for description
			//Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].TrakPos	:= StarCamEq(Infeed.Par.R1,Infeed.Par.R2,Infeed.Par.Rp,Infeed.Par.Wm,Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].PosRad);
			Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].TrakPos	:= Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].PosRad * Infeed.Par.R1;
			
			// Offset into the track sector
			Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].TrakPos	:= Infeed.Starwheel.Period[indexPeriod].Pocket[indexPocket].TrakPos + Infeed.Par.SectorTangentPos;			
		END_FOR;		
	END_FOR;
	
	//	======================================================================= Process Point Barrier functionality
	
	// IF any of the trak positions roll over AND the current ticket count is 0, then add a ticket.
	// Also keep track of which pocket crossed over last as the next pocket select
		
	CASE Infeed.SyncPP.BarrierState OF
		0:	//	----------------------------------------------------------------------- Check for calculated track position rollover
			
			FOR index := 0 TO Infeed.Par.PocketCount - 1 DO
				IF Infeed.Starwheel.Period[Infeed.Par.PeriodCount-1].Pocket[index].TrakPos > Infeed.Par.PositionSyncPP + 0.050 AND
					Infeed.Starwheel.Period[Infeed.Par.PeriodCount-1].PocketLastCycle[index].TrakPos < Infeed.Par.PositionSyncPP + 0.050 THEN
					Infeed.SyncPP.periodSelect			:= Infeed.Par.PeriodCount - 1;
					Infeed.SyncPP.pocketSelect			:= INT_TO_USINT(index);
					Infeed.SyncPP.BarrierState	:= 1;
				END_IF;				
			END_FOR;					
			
		1:	//	----------------------------------------------------------------------- Check ticket count
			
			Infeed.SyncPP.BarrierReadInfo.ProcessPoint	:= ADR( PP_Infeed_Sync );
			Infeed.SyncPP.BarrierReadInfo.Enable		:= TRUE;
			
			// Add a ticket only if the current ticket count is 0
			IF Infeed.SyncPP.BarrierReadInfo.Valid AND Infeed.SyncPP.BarrierReadInfo.BarrierInfo.RemainingTickets = 0 THEN
				Infeed.SyncPP.BarrierState					:= 2;
			ELSIF Infeed.SyncPP.BarrierReadInfo.Valid AND Infeed.SyncPP.BarrierReadInfo.BarrierInfo.RemainingTickets > 0 THEN
				Infeed.SyncPP.BarrierState					:= 0;
			ELSE
				// Wait for BarrierReadInfo to return valid results
			END_IF;
			
		2:	//	----------------------------------------------------------------------- Add single ticket
			
			Infeed.SyncPP.BarrierCmd.ProcessPoint					:= ADR( PP_Infeed_Sync );
			Infeed.SyncPP.BarrierCmd.Command						:= mcACPTRAK_BARRIER_ADD_TICKETS;
			Infeed.SyncPP.BarrierCmd.AdvancedParameters.TicketCount	:= 1;
			Infeed.SyncPP.BarrierCmd.Execute						:= TRUE;
			
			IF Infeed.SyncPP.BarrierCmd.Done THEN
				Infeed.SyncPP.BarrierCmd.Execute					:= FALSE;
				Infeed.SyncPP.BarrierState							:= 0;
			END_IF;
	END_CASE;
	
	Infeed.SyncPP.BarrierReadInfo();
	Infeed.SyncPP.BarrierCmd();	
	
	// If the currently selected next (period,pocket) pair rolls over, then sync to the same pocket 1 period ahead
	IF Infeed.Starwheel.Period[Infeed.SyncPP.periodSelect].Pocket[Infeed.SyncPP.pocketSelect].TrakPos < Infeed.Par.PositionSyncPP THEN
		Infeed.SyncPP.periodSelect		:= Infeed.SyncPP.periodSelect - 1;		
	END_IF;
		
	//	======================================================================= Process Point Sync
	
	CASE Infeed.SyncPP.State OF
		0://	----------------------------------------------------------------------- disabled
			
			Infeed.SyncPP.TrgEnable.ProcessPoint		:= ADR( PP_Infeed_Sync );
			Infeed.SyncPP.TrgInfo.ProcessPoint			:= ADR( PP_Infeed_Sync );
			Infeed.SyncPP.TrgEnable.Enable				:= FALSE;
			
			IF AsmReadStatus.AssemblyReady THEN
				Infeed.SyncPP.TrgEnable.Enable			:= TRUE;
				Infeed.SyncPP.State						:= 1;
			END_IF;
			
		1://	----------------------------------------------------------------------- wait for shuttle event trigger
			
			IF Infeed.SyncPP.TrgEnable.Valid AND Infeed.SyncPP.TrgEnable.EventCount > 0 THEN
				Infeed.SyncPP.TrgInfo.Execute			:= TRUE;
				Infeed.SyncPP.Counter					:= Infeed.SyncPP.Counter + 1;
				Infeed.SyncPP.State						:= 2;
			END_IF;
			
		2://	----------------------------------------------------------------------- get event info
			
			IF Infeed.SyncPP.TrgInfo.Done AND Infeed.SyncPP.TrgInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				
				Infeed.SyncPP.UserDataBuffer.SyncObjectID	:= Infeed.indexOpenSyncObj;				
				Infeed.SyncPP.State							:= 3;
				
			END_IF;
				
		3://	----------------------------------------------------------------------- set shuttle user data
			
			Infeed.SyncPP.ShUserData.Axis			:= ADR( Infeed.SyncPP.TrgInfo.TrgPointInfo.Axis );
			Infeed.SyncPP.ShUserData.DataAddress	:= ADR( Infeed.SyncPP.UserDataBuffer );
			Infeed.SyncPP.ShUserData.DataSize		:= SIZEOF( Infeed.SyncPP.UserDataBuffer );
			Infeed.SyncPP.ShUserData.Mode			:= mcACPTRAK_USERDATA_SET;
			Infeed.SyncPP.ShUserData.Execute		:= TRUE;
			
			IF Infeed.SyncPP.ShUserData.Done THEN
				Infeed.SyncPP.ShUserData.Execute	:= FALSE;
				Infeed.SyncPP.State					:= 4;
			END_IF;
			
		4://	----------------------------------------------------------------------- Write info the sync object for this shuttle
			
			Infeed.SyncObj[Infeed.SyncPP.UserDataBuffer.SyncObjectID].InSync		:= TRUE;
			Infeed.SyncObj[Infeed.SyncPP.UserDataBuffer.SyncObjectID].PeriodSelect	:= Infeed.SyncPP.periodSelect;
			Infeed.SyncObj[Infeed.SyncPP.UserDataBuffer.SyncObjectID].PocketSelect	:= Infeed.SyncPP.pocketSelect;
			Infeed.SyncObj[Infeed.SyncPP.UserDataBuffer.SyncObjectID].ThisShuttle	:= Infeed.SyncPP.TrgInfo.TrgPointInfo.Axis;
			
			IF Infeed.indexOpenSyncObj = NUM_SYNC_OBJS THEN
				Infeed.indexOpenSyncObj				:= 0;
			ELSE
				Infeed.indexOpenSyncObj				:= Infeed.indexOpenSyncObj + 1;
			END_IF;
			
			Infeed.SyncPP.State						:= 5;
			
		5://	----------------------------------------------------------------------- reset trig info
		
			Infeed.SyncPP.TrgInfo.Execute			:= FALSE;
			Infeed.SyncPP.State						:= 1;
			
	END_CASE;
	
	Infeed.SyncPP.ShUserData();
	Infeed.SyncPP.TrgEnable();
	Infeed.SyncPP.TrgInfo();
	
	//	======================================================================= ProcessPoint Release
	
	CASE Infeed.ReleasePP.State OF
		0://	----------------------------------------------------------------------- init and wait for poweron
		
			Infeed.ReleasePP.TrgEnable.ProcessPoint		:= ADR( PP_Infeed_Release );
			Infeed.ReleasePP.TrgInfo.ProcessPoint		:= ADR( PP_Infeed_Release );
			Infeed.ReleasePP.TrgEnable.Enable			:= FALSE;
			
			IF AsmReadStatus.AssemblyReady THEN
				Infeed.ReleasePP.TrgEnable.Enable		:= TRUE;
				Infeed.ReleasePP.State					:= 1;
			END_IF;
			
		1://	----------------------------------------------------------------------- wait for shuttle event trigger
			
			IF Infeed.ReleasePP.TrgEnable.Valid AND Infeed.ReleasePP.TrgEnable.EventCount > 0 THEN
				Infeed.ReleasePP.TrgInfo.Execute		:= TRUE;
				Infeed.ReleasePP.Counter				:= Infeed.ReleasePP.Counter + 1;
				Infeed.ReleasePP.State					:= 2;
			END_IF;
			
		2://	----------------------------------------------------------------------- read shuttle info
			
			IF Infeed.ReleasePP.TrgInfo.Done AND Infeed.ReleasePP.TrgInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				Infeed.ReleasePP.ShUserData.Axis		:= ADR( Infeed.ReleasePP.TrgInfo.TrgPointInfo.Axis );
				Infeed.ReleasePP.ShUserData.DataAddress	:= ADR( Infeed.ReleasePP.UserDataBuffer );
				Infeed.ReleasePP.ShUserData.DataSize	:= SIZEOF( Infeed.ReleasePP.UserDataBuffer );
				Infeed.ReleasePP.ShUserData.Mode		:= mcACPTRAK_USERDATA_GET;
				Infeed.ReleasePP.ShUserData.Execute		:= TRUE;
			END_IF;
			
			IF Infeed.ReleasePP.ShUserData.Done THEN
				Infeed.SyncObj[Infeed.ReleasePP.UserDataBuffer.SyncObjectID].InSync		:= FALSE;
				Infeed.ReleasePP.ShUserData.Execute		:= FALSE;
				Infeed.ReleasePP.State					:= 3;
			END_IF;
			
		3://	----------------------------------------------------------------------- Send Routed command to the next destination
			
			Infeed.ReleasePP.RoutedMoveVel.Axis			:= ADR( Infeed.ReleasePP.TrgInfo.TrgPointInfo.Axis );
			Infeed.ReleasePP.RoutedMoveVel.BufferMode	:= mcABORTING;
			Infeed.ReleasePP.RoutedMoveVel.Acceleration	:= gTrak.Par.Acceleration;
			Infeed.ReleasePP.RoutedMoveVel.Deceleration	:= gTrak.Par.Acceleration;
			Infeed.ReleasePP.RoutedMoveVel.Velocity		:= gTrak.Par.Velocity;
			Infeed.ReleasePP.RoutedMoveVel.RouteVelocity:= gTrak.Par.Velocity;
			Infeed.ReleasePP.RoutedMoveVel.Sector		:= ADR( Sector_Infeed );
			Infeed.ReleasePP.RoutedMoveVel.Position		:= 0.0;
			
			Infeed.ReleasePP.RoutedMoveVel.AdvancedParameters.StartDirection	:= mcDIR_POSITIVE;
			
			Infeed.ReleasePP.RoutedMoveVel.Execute		:= TRUE;
			
			Infeed.ReleasePP.State						:= 4;
			
		4://	----------------------------------------------------------------------- Check for movement
			
			IF Infeed.ReleasePP.RoutedMoveVel.Active THEN
				Infeed.ReleasePP.RoutedMoveVel.Execute	:= FALSE;
				Infeed.ReleasePP.State					:= 5;
			END_IF;
			
		5://	----------------------------------------------------------------------- Reset trig info
		
			Infeed.ReleasePP.TrgInfo.Execute			:= FALSE;
			Infeed.ReleasePP.State						:= 1;		
		
	END_CASE;
	
	Infeed.ReleasePP.TrgEnable();
	Infeed.ReleasePP.TrgInfo();
	Infeed.ReleasePP.ShUserData();
	Infeed.ReleasePP.RoutedMoveVel();
	
	//	======================================================================= Sync Object Logic
	
	FOR index := 0 TO NUM_SYNC_OBJS DO
		
		IF Infeed.SyncObj[index].InSync THEN
			
			Infeed.SyncObj[index].MoveCyclic.Axis				:= ADR( Infeed.SyncObj[index].ThisShuttle );
			Infeed.SyncObj[index].MoveCyclic.InterpolationMode	:= mcIPLM_DEFAULT;
			
			Infeed.SyncObj[index].MoveCyclic.AdvancedParameters.Acceleration		:= gTrak.Par.Acceleration;
			Infeed.SyncObj[index].MoveCyclic.AdvancedParameters.Deceleration		:= gTrak.Par.Acceleration;
			Infeed.SyncObj[index].MoveCyclic.AdvancedParameters.Velocity			:= gTrak.Par.Velocity;
			
			// If the current setpoint is behind the setpoint from last cycle, the position has rolled over and the syncobj should decrement Master periods
			IF Infeed.Starwheel.Period[Infeed.SyncObj[index].PeriodSelect].Pocket[Infeed.SyncObj[index].PocketSelect].TrakPos < Infeed.SyncObj[index].LastCycleSetpoint THEN
				Infeed.SyncObj[index].PeriodSelect				:= Infeed.SyncObj[index].PeriodSelect - 1;
			END_IF;
				
			Infeed.SyncObj[index].MoveCyclic.CyclicPosition		:= Infeed.Starwheel.Period[Infeed.SyncObj[index].PeriodSelect].Pocket[Infeed.SyncObj[index].PocketSelect].TrakPos;
			
			Infeed.SyncObj[index].LastCycleSetpoint				:= Infeed.Starwheel.Period[Infeed.SyncObj[index].PeriodSelect].Pocket[Infeed.SyncObj[index].PocketSelect].TrakPos;			
					
			Infeed.SyncObj[index].MoveCyclic.Enable				:= TRUE;
			
		ELSE
			Infeed.SyncObj[index].MoveCyclic.Enable					:= FALSE;
			Infeed.SyncObj[index].MoveCyclic.CyclicPosition			:= 0;
			Infeed.SyncObj[index].LastCycleSetpoint					:= 0;			
		END_IF;
		
		Infeed.SyncObj[index].MoveCyclic();
		
	END_FOR;	
	
END_ACTION
