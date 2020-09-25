
FUNCTION_BLOCK TwoUp

	CASE State1 OF

		TWOUP_STATE1_IDLE:

			IF Enable THEN
				InternalNumShuttles := NumShuttles;

				InternalPosArray[0] := 0.80;
				InternalPosArray[1] := 0.72;
				InternalPosArray[2] := 0.64;
				InternalPosArray[3] := 0.56;
				InternalPosArray[4] := 0.32;
				InternalPosArray[5] := 0.24;
				InternalPosArray[6] := 0.16;
				InternalPosArray[7] := 0.08;

				InternalSectorPositionStart[0] := SectorPositionStart[0];
				InternalSectorPositionIncrement[0] := SectorPositionIncrement[0];
				TrigEnable.ProcessPoint := PP;
				TrigEnable.Enable := 1;
				TrigInfo.ProcessPoint := PP;
				CheckShuttle.Axis := ADR(TrigInfo.TrgPointInfo.Axis);
				MoveAbs[0].Axis := ADR(TrigInfo.TrgPointInfo.Axis);
				MoveAbs[0].Sector := Sector[0];

				MoveAbs[0].Position := (*InternalPosArray[1];//*)InternalSectorPositionStart[0];

				MoveAbs[0].Velocity := Velocity;
				MoveAbs[0].Acceleration := Acceleration;
				MoveAbs[0].Deceleration := Acceleration;
				MoveAbs[0].AdvancedParameters.StartDirection := mcDIR_POSITIVE;
				MoveAbs[0].AdvancedParameters.EndDirection := mcDIR_UNDEFINED;
				MoveAbs[0].AdvancedParameters.ShuttleOrientation := mcDIR_UNDEFINED;
				FeedTON[0].PT := FeedTime[0];
				State1 := TWOUP_STATE1_ENABLE;
			END_IF



		TWOUP_STATE1_ENABLE:

			IF TrigEnable.Valid THEN
				State1 := TWOUP_STATE1_WAIT;
			END_IF

		TWOUP_STATE1_WAIT:

			IF ShuttleCount = 0 AND NOT Enable THEN
				TrigEnable.Enable := 0;
				State1 := TWOUP_STATE1_DISABLE;
			ELSIF TrigEnable.EventCount > 0 THEN
				TrigInfo.Execute := 1;
				State1 := TWOUP_STATE1_TRIG;
			END_IF

		TWOUP_STATE1_TRIG:

			IF TrigInfo.Done THEN
				CheckShuttle.Enable := 1;
				State1 := TWOUP_STATE1_CHECK_SHUTTLE;
			END_IF

		TWOUP_STATE1_CHECK_SHUTTLE:

			IF CheckShuttle.Valid AND (CheckShuttle.ShuttleInfo.CurrentValues.SectorType <> mcACPTRAK_SEC_INTERNAL) THEN
				ShuttleCount := ShuttleCount + 1;
				MoveAbs[0].Execute := 1;
				State1 := TWOUP_STATE1_MOVE_ABS;
			ELSE
				CheckShuttle.Enable := 0;
				TrigInfo.Execute := 0;
				State1 := TWOUP_STATE1_WAIT;
			END_IF

		TWOUP_STATE1_MOVE_ABS:

			IF MoveAbs[0].Active THEN
				IF ShuttleCount < InternalNumShuttles THEN
					MoveAbs[0].Execute := 0;
					CheckShuttle.Enable := 0;
					TrigInfo.Execute := 0;
					MoveAbs[0].Position := (*InternalPosArray[ShuttleCount];//*)MoveAbs[0].Position - InternalSectorPositionIncrement[0];
					State1 := TWOUP_STATE1_WAIT;
				END_IF
			ELSIF MoveAbs[0].Done THEN
				MoveAbs[0].Execute := 0;
				CheckShuttle.Enable := 0;
				TrigInfo.Execute := 0;
				IF ShuttleCount >= InternalNumShuttles THEN
					ShuttleCount := 0;
					MoveAbs[0].Position := (*InternalPosArray[1];//*)InternalSectorPositionStart[0];
					FeedTON[0].IN := 1;
					State1 := TWOUP_STATE1_TIME;
				ELSE
					MoveAbs[0].Position := (*InternalPosArray[ShuttleCount];//*)MoveAbs[0].Position - InternalSectorPositionIncrement[0];
					State1 := TWOUP_STATE1_WAIT;
				END_IF
			END_IF

		TWOUP_STATE1_TIME:

			IF FeedTON[0].Q THEN
				FeedTON[0].IN := 0;
				Increment := 1;
				State1 := TWOUP_STATE1_WAIT;
			END_IF

		TWOUP_STATE1_DISABLE:

			IF NOT TrigEnable.Valid THEN
				State1 := TWOUP_STATE1_IDLE;
			END_IF

	END_CASE

	CASE State2 OF

		TWOUP_STATE2_IDLE:

			IF Enable THEN
				Increment := 0;
				InternalSectorPositionStart[1] := SectorPositionStart[1];
				InternalSectorPositionIncrement[1] := SectorPositionIncrement[1];
				InternalUserData.Color := Color;
				GetShuttle[0].Sector := Sector[0];
				GetShuttle[0].Mode :=  mcACPTRAK_SEARCH_BACKWARD;
				MoveAbs[1].Axis := ADR(GetShuttle[0].Axis);
				MoveAbs[1].Sector := Sector[1];
				MoveAbs[1].Position := InternalSectorPositionStart[1];
				MoveAbs[1].Velocity := Velocity;
				MoveAbs[1].Acceleration := Acceleration;
				MoveAbs[1].Deceleration := Acceleration;
				MoveAbs[1].AdvancedParameters.StartDirection := mcDIR_POSITIVE;
				MoveAbs[1].AdvancedParameters.EndDirection := mcDIR_UNDEFINED;
				MoveAbs[1].AdvancedParameters.ShuttleOrientation := mcDIR_UNDEFINED;
				FeedTON[1].PT := FeedTime[1];
				GetShuttle[1].Sector := Sector[1];
				GetShuttle[1].Mode :=  mcACPTRAK_SEARCH_FORWARD;
				ColorShuttle.Axis  := ADR(GetShuttle[1].Axis);
				ColorShuttle.DataAddress := ADR(InternalUserData);
				ColorShuttle.DataSize := SIZEOF(InternalUserData);
				ColorShuttle.Mode := mcACPTRAK_USERDATA_SET;
				MoveVel.Axis := ADR(GetShuttle[1].Axis);
				MoveVel.Sector := DstSector;
				MoveVel.Position := DstSectorPosition;
				MoveVel.Velocity := Velocity;
				MoveVel.RouteVelocity := Velocity;
				MoveVel.Acceleration := Acceleration;
				MoveVel.Deceleration := Acceleration;
				MoveVel.AdvancedParameters.StartDirection := mcDIR_POSITIVE;
				MoveVel.AdvancedParameters.EndDirection := mcDIR_UNDEFINED;
				MoveVel.AdvancedParameters.ShuttleOrientation := mcDIR_UNDEFINED;
				State2 := TWOUP_STATE2_WAIT;
			END_IF

		TWOUP_STATE2_WAIT:

			IF NOT Enable THEN
				State2 := TWOUP_STATE2_IDLE;
			ELSIF Increment THEN
				Increment := 0;
				GetShuttle[0].Enable := 1;
				//                GetShuttle[1].Enable := 1;
				State2 := (*TWOUP_STATE2_GET2;//*)TWOUP_STATE2_GET1;
			END_IF

		TWOUP_STATE2_GET1:

			IF GetShuttle[0].Valid THEN
				GetShuttle[0].Next := 0;
				MoveAbs[1].Execute := 1;
				State2 := TWOUP_STATE2_MOVE_ABS;
			END_IF

		TWOUP_STATE2_MOVE_ABS:

			IF MoveAbs[1].Active THEN
				IF GetShuttle[0].RemainingCount <> 0 THEN
					MoveAbs[1].Execute := 0;
					MoveAbs[1].Position := MoveAbs[1].Position - InternalSectorPositionIncrement[1];
					GetShuttle[0].Next := 1;
					State2 := TWOUP_STATE2_GET1;
				END_IF
			ELSIF MoveAbs[1].Done THEN
				MoveAbs[1].Execute := 0;
				GetShuttle[0].Enable := 0;
				MoveAbs[1].Position := InternalSectorPositionStart[1];
				FeedTON[1].IN := 1;
				State2 := TWOUP_STATE2_TIME;
			END_IF

		TWOUP_STATE2_TIME:

			IF FeedTON[1].Q THEN
				FeedTON[1].IN := 0;
				GetShuttle[1].Enable := 1;
				State2 := TWOUP_STATE2_GET2;
			END_IF

		TWOUP_STATE2_GET2:

			IF GetShuttle[1].Valid THEN
				GetShuttle[1].Next := 0;
				ColorShuttle.Execute := 1;
				State2 := TWOUP_STATE2_COLOR;
			END_IF

		TWOUP_STATE2_COLOR:
			IF ColorShuttle.Done THEN
				ColorShuttle.Execute := 0;
				MoveVel.Execute := 1;
				State2 := TWOUP_STATE2_SEND;
			END_IF;
		TWOUP_STATE2_SEND:

			IF MoveVel.Active THEN
				MoveVel.Execute := 0;
				IF GetShuttle[1].RemainingCount = 0 THEN
					GetShuttle[1].Enable := 0;
					State2 := TWOUP_STATE2_WAIT;
				ELSE
					GetShuttle[1].Next := 1;
					State2 := TWOUP_STATE2_GET2;
				END_IF
			END_IF

	END_CASE

	TrigEnable();
	TrigInfo();
	CheckShuttle();
	MoveAbs[0]();
	MoveAbs[1]();
	FeedTON[0]();
	FeedTON[1]();
	GetShuttle[0]();
	GetShuttle[1]();
	ColorShuttle();
	MoveVel();

END_FUNCTION_BLOCK
