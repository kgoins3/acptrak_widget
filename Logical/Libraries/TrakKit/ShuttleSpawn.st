
FUNCTION_BLOCK ShuttleSpawn

	CASE State OF

		SPAWN_STATE_IDLE:

			IF Enable THEN
				InternalSectorPositionStart := SectorPositionStart;
				InternalSectorPositionIncrement := SectorPositionIncrement;
				InternalNumShuttleTotal := NumShuttleTotal;
				InternalNumShuttleBatch := NumShuttleBatch;
				//				InternalUserData.ShuttleNumber := 0;
				//				InternalUserData.Color := BLUE;
			//	InternalUserData.FirstShuttle := 1;
				TrigEnable.ProcessPoint := EndPP;
				TrigEnable.Enable := 1;
				TrigInfo.ProcessPoint := EndPP;
				Barrier.ProcessPoint := StartPP;
				Barrier.Command := mcACPTRAK_BARRIER_CLOSE;
				Barrier.Execute := 1;
				AddShuttle.Sector := Sector;
				AddShuttle.AdvancedParameters.Velocity := Velocity;
				AddShuttle.Position := InternalSectorPositionStart;
				GetShuttle.Sector := Sector;
				GetShuttle.Mode := mcACPTRAK_SEARCH_FORWARD;
//  added F.Forthuber
				SpawnValid := FALSE;
//  end
				SetShuttleData.Axis  := ADR(GetShuttle.Axis);
				SetShuttleData.DataAddress := ADR(InternalUserData);
				SetShuttleData.DataSize := SIZEOF(InternalUserData);
				SetShuttleData.Mode := mcACPTRAK_USERDATA_SET;
				MoveVel.Axis := ADR(GetShuttle.Axis);
				MoveVel.Sector := DstSector;
				MoveVel.Position := DstSectorPosition;
				MoveVel.Velocity := Velocity;
				MoveVel.RouteVelocity := RouteVelocity;
				MoveVel.Acceleration := Acceleration;
				MoveVel.Deceleration := Acceleration;
				MoveVel.AdvancedParameters.StartDirection := mcDIR_POSITIVE;
				MoveVel.AdvancedParameters.EndDirection := mcDIR_POSITIVE;
				MoveVel.AdvancedParameters.ShuttleOrientation := mcDIR_UNDEFINED;
				State := SPAWN_STATE_BLOCK;
			END_IF

		SPAWN_STATE_BLOCK:

			IF TrigEnable.Valid AND Barrier.Done THEN
				Barrier.Execute := 0;
				AddShuttle.Execute := 1;
				Done:=FALSE;
				State := SPAWN_STATE_CREATE;
			END_IF

		SPAWN_STATE_CREATE:

			IF AddShuttle.Done THEN
//  added F.Forthuber
				SpawnedAxis := AddShuttle.Axis;
				SpawnValid:=TRUE;
				State := SPAWN_STATE_REPORT;
			END_IF
			
		SPAWN_STATE_REPORT:
			
			IF AcknSpawn THEN
				SpawnValid:=FALSE;
//  end
				BatchCreated := BatchCreated + 1;
				TotalCreated := TotalCreated + 1;
				AddShuttle.Execute := 0;
				IF (BatchCreated >= InternalNumShuttleBatch) OR (TotalCreated >= InternalNumShuttleTotal) THEN
					BatchCreated := 0;
					GetShuttle.Enable := 1;
					State := SPAWN_STATE_GET;
				ELSE
					State := SPAWN_STATE_CREATE_NEXT;
				END_IF
			END_IF

		SPAWN_STATE_CREATE_NEXT:

			AddShuttle.Position := AddShuttle.Position + InternalSectorPositionIncrement;
			AddShuttle.Execute := 1;
			State := SPAWN_STATE_CREATE;

		SPAWN_STATE_GET:

			IF GetShuttle.Valid THEN
				GetShuttle.Next := 0;
				//InternalUserData.ShuttleNumber := InternalUserData.ShuttleNumber + 1;
				SetShuttleData.Execute := 1;
				State := SPAWN_STATE_SET_USER_DATA;
			END_IF

		SPAWN_STATE_SET_USER_DATA:
			IF SetShuttleData.Done THEN
				SetShuttleData.Execute := 0;
				MoveVel.Execute := 1;
				State := SPAWN_STATE_SEND;
			END_IF;

		SPAWN_STATE_SEND:

			IF MoveVel.Active THEN
	//			InternalUserData.FirstShuttle := 0;
				MoveVel.Execute := 0;
				IF GetShuttle.RemainingCount = 0 THEN
					GetShuttle.Enable := 0;
					State := SPAWN_STATE_WAIT;
				ELSE
					GetShuttle.Next := 1;
					State := SPAWN_STATE_GET;
				END_IF
			END_IF


		SPAWN_STATE_WAIT:

			IF NOT Enable  THEN
				TotalCreated := 0;
				ExitShuttleNum := 0;
				TrigEnable.Enable := 0;
				Barrier.Command := mcACPTRAK_BARRIER_OPEN;
				Barrier.Execute := 1;
				State := SPAWN_STATE_UNBLOCK;
			ELSIF TotalCreated >= InternalNumShuttleTotal THEN
				TotalCreated := 0;
				TrigEnable.Enable := 0;
				Barrier.Command := mcACPTRAK_BARRIER_OPEN;
				Barrier.Execute := 1;
				State := SPAWN_STATE_UNBLOCK;
			ELSIF ExitShuttleNum >= InternalNumShuttleBatch THEN
				ExitShuttleNum := 0;
				AddShuttle.Position := InternalSectorPositionStart;
				AddShuttle.Execute := 1;
				State := SPAWN_STATE_CREATE;
			ELSIF TrigEnable.EventCount > 0 THEN
				TrigInfo.Execute := 1;
				State := SPAWN_STATE_TRIG;
			END_IF

		SPAWN_STATE_TRIG:

			IF TrigInfo.Done THEN
				TrigInfo.Execute := 0;
				ExitShuttleNum := ExitShuttleNum + 1;
				State := SPAWN_STATE_WAIT;
			END_IF

		SPAWN_STATE_UNBLOCK:

			IF Barrier.Done AND NOT TrigEnable.Valid THEN
				Barrier.Execute := 0;
				State := SPAWN_STATE_DONE;
			END_IF

		SPAWN_STATE_DONE:
			
			Done := TRUE;

			IF NOT Enable THEN
				Done := FALSE;
				State := SPAWN_STATE_IDLE;
			END_IF

	END_CASE

	TrigEnable();
	TrigInfo();
	Barrier();
	AddShuttle();
	GetShuttle();
	SetShuttleData();
	MoveVel();

END_FUNCTION_BLOCK
