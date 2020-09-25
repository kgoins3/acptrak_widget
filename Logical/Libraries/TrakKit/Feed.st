
FUNCTION_BLOCK Feed

	CASE State OF

		FEED_STATE_IDLE:

			IF Enable THEN
				InternalNumShuttles := NumShuttles;
				InternalSectorPositionStart := SectorPositionStart;
				InternalSectorPositionIncrement := SectorPositionIncrement;
				TrigEnable.ProcessPoint := PP;
				TrigEnable.Enable := 1;
				TrigInfo.ProcessPoint := PP;
				CheckShuttle.Axis := ADR(TrigInfo.TrgPointInfo.Axis);
				MoveAbs.Axis := ADR(TrigInfo.TrgPointInfo.Axis);
				MoveAbs.Sector := Sector;
				MoveAbs.Position := InternalSectorPositionStart;
				MoveAbs.Velocity := MoveAbsVelocity;
				MoveAbs.Acceleration := Acceleration;
				MoveAbs.Deceleration := Acceleration;
				MoveAbs.AdvancedParameters.StartDirection := mcDIR_POSITIVE;
				MoveAbs.AdvancedParameters.EndDirection := mcDIR_UNDEFINED;
				MoveAbs.AdvancedParameters.ShuttleOrientation := mcDIR_UNDEFINED;
				FeedTON.PT := FeedTime;
				GetShuttle.Sector := Sector;
				GetShuttle.Mode :=  mcACPTRAK_SEARCH_BACKWARD;
				ColorShuttle.Axis  := ADR(GetShuttle.Axis);
				ColorShuttle.DataAddress := ADR(InternalUserData);
				ColorShuttle.DataSize := SIZEOF(InternalUserData);
				ColorShuttle.Mode := mcACPTRAK_USERDATA_SET;
				ReadShuttleData.Axis  := ADR(TrigInfo.TrgPointInfo.Axis);
				ReadShuttleData.DataAddress := ADR(InternalUserData);
				ReadShuttleData.DataSize := SIZEOF(InternalUserData);
				ReadShuttleData.Mode := mcACPTRAK_USERDATA_GET;
				MoveVel.Axis := ADR(GetShuttle.Axis);
				MoveVel.Sector := DstSector;
				MoveVel.Position := DstSectorPosition;
				MoveVel.Velocity := Velocity;
				MoveVel.RouteVelocity := RouteVelocity;
				MoveVel.Acceleration := Acceleration;
				MoveVel.Deceleration := Acceleration;
				MoveVel.AdvancedParameters.StartDirection := DstStartDirection;// mcDIR_NEGATIVE;
				MoveVel.AdvancedParameters.EndDirection := mcDIR_UNDEFINED;
				MoveVel.AdvancedParameters.ShuttleOrientation := mcDIR_UNDEFINED;
				State := FEED_STATE_ENABLE;
			END_IF

		FEED_STATE_ENABLE:

			IF TrigEnable.Valid THEN
				State := FEED_STATE_WAIT;
			END_IF

		FEED_STATE_WAIT:

			IF ShuttleCount = 0 AND NOT Enable THEN
				TrigEnable.Enable := 0;
				State := FEED_STATE_DISABLE;
			ELSIF TrigEnable.EventCount > 0 THEN
				TrigInfo.Execute := 1;
				State := FEED_STATE_TRIG;
			END_IF

		FEED_STATE_TRIG:

			IF TrigInfo.Done THEN
				IF TrigInfo.TrgPointInfo.Event = TrigDirection THEN  // mcACPTRAK_TP_PASSED_POSITIVE THEN
					MoveVel.Velocity := Velocity;
					MoveVel.RouteVelocity := RouteVelocity;
					MoveAbs.Velocity := MoveAbsVelocity;

					CheckShuttle.Enable := 1;
					State := FEED_STATE_CHECK_SHUTTLE;
				ELSE
					TrigInfo.Execute := 0;
					State := FEED_STATE_WAIT;
				END_IF
			END_IF

		FEED_STATE_CHECK_SHUTTLE:

			IF CheckShuttle.Valid AND TrigInfo.TrgPointInfo.Axis.seqNo <> LastSeqNumber THEN // (CheckShuttle.ShuttleInfo.CurrentValues.SectorType <> mcACPTRAK_SEC_INTERNAL) THEN //
				LastSeqNumber := TrigInfo.TrgPointInfo.Axis.seqNo;
				Done:=FALSE;
				ShuttleCount := ShuttleCount + 1;
				ReadShuttleData.Execute := 1;
				IF UseAbsMove THEN
					//MoveAbs.Position := InternalSectorPositionStart;
					MoveAbs.Execute := 1;
					State := FEED_STATE_MOVE_ABS;
				ELSE
					GetShuttle.Enable := 1;
					State := FEED_STATE_GET;
				END_IF
			ELSE
				CheckShuttle.Enable := 0;
				TrigInfo.Execute := 0;
				State := FEED_STATE_WAIT;
			END_IF

		FEED_STATE_GET_SHUTTLE_DATA:
			IF ReadShuttleData.Done THEN
		//		LastShuttleNumber := InternalUserData.ShuttleNumber;
				IF UseAbsMove THEN
					MoveAbs.Execute := 1;
					State := FEED_STATE_MOVE_ABS;
				ELSE
					GetShuttle.Enable := 1;
					State := FEED_STATE_GET;
				END_IF

			ELSE
				State := FEED_STATE_WAIT;
			END_IF


		FEED_STATE_MOVE_ABS:
			ReadShuttleData.Execute := FALSE;
			IF MoveAbs.Active THEN
				IF ShuttleCount < InternalNumShuttles THEN
					MoveAbs.Execute := 0;
					CheckShuttle.Enable := 0;
					TrigInfo.Execute := 0;
					MoveAbs.Position := MoveAbs.Position - InternalSectorPositionIncrement;
					State := FEED_STATE_WAIT;
				END_IF
			ELSIF MoveAbs.Done THEN  // OR CheckShuttle.ShuttleInfo.CurrentValues.Velocity < 0.01 THEN
				MoveAbs.Execute := 0;
				CheckShuttle.Enable := 0;
				TrigInfo.Execute := 0;
				IF ShuttleCount >= InternalNumShuttles THEN
					ShuttleCount := 0;
					MoveAbs.Position := InternalSectorPositionStart;
					FeedTON.IN := 1;
					State := FEED_STATE_TIME;
				ELSE
					MoveAbs.Position := MoveAbs.Position - InternalSectorPositionIncrement;
					State := FEED_STATE_WAIT;
				END_IF
			END_IF

		FEED_STATE_TIME:
			ReadyForProduct := TRUE;
			IF FeedTON.Q THEN
				FeedTON.IN := 0;
				GetShuttle.Enable := 1;
				State := FEED_STATE_GET;
			END_IF

		FEED_STATE_GET:

			IF GetShuttle.Valid THEN
				GetShuttle.Next := 0;
				InternalUserData.Color := Color;
	//			InternalUserData.ShuttleNumber := LastShuttleNumber;
				ColorShuttle.Execute := 1;
				State := FEED_STATE_COLOR;
			END_IF

		FEED_STATE_COLOR:
			IF ColorShuttle.Done THEN
				ColorShuttle.Execute := 0;
				MoveVel.Execute := 1;
				State := FEED_STATE_SEND;
				ReadyForProduct:=FALSE;
			END_IF;
		FEED_STATE_SEND:

			IF MoveVel.Active THEN
				MoveVel.Execute := 0;
				Done:=TRUE;
				IF GetShuttle.RemainingCount = 0 THEN
					GetShuttle.Enable := 0;
					State := FEED_STATE_WAIT;
				ELSE
					GetShuttle.Next := 1;
					State := FEED_STATE_GET;
				END_IF
			END_IF

		FEED_STATE_DISABLE:

			IF NOT TrigEnable.Valid THEN
				State := FEED_STATE_IDLE;
			END_IF

	END_CASE

	TrigEnable();
	TrigInfo();
	CheckShuttle();
	MoveAbs();
	GetShuttle();
	ColorShuttle();
	MoveVel();
	FeedTON();
	ReadShuttleData();

END_FUNCTION_BLOCK
