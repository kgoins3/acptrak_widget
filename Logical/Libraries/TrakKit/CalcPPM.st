
FUNCTION_BLOCK CalculatePPM

	CASE State OF

		0:

			IF Enable THEN
				TrigEnable.ProcessPoint := PP;
				TrigEnable.Enable := TRUE;
				TrigInfo.ProcessPoint := PP;
				CheckShuttle.Axis := ADR(TrigInfo.TrgPointInfo.Axis);
				DTGetTime_0.enable := TRUE;
				State := 1;
				//ShuttlesPassed:=1;
			END_IF

		1:
			//TotalShuttlesPassed := 0;
			IF TrigEnable.Valid THEN
				State := 2;
			END_IF

		2:

			IF NOT Enable THEN
				TrigEnable.Enable := FALSE;
			ELSIF TrigEnable.EventCount > 0 THEN
				IF NumberOfShuttlesToAvg > 10000 THEN
					NumberOfShuttlesToAvg:=10000;
				END_IF
				TrigInfo.Execute := TRUE;
				State := 3;
			END_IF

		3:

			IF TrigInfo.Done THEN
				IF TrigInfo.TrgPointInfo.Event = TrigDirection THEN
					CheckShuttle.Enable := TRUE;
					State := 4;
				ELSE
					TrigInfo.Execute := 0;
					State := 2;
				END_IF
			END_IF

		4:

			IF CheckShuttle.Valid AND TrigInfo.TrgPointInfo.Axis.seqNo <> LastSeqNumber THEN
				LastSeqNumber := TrigInfo.TrgPointInfo.Axis.seqNo;

				IF TotalShuttlesPassed = 0 THEN
					TimeStart[0] := DTGetTime_0.DT1;
				ELSE
					ShuttlesPassed := ShuttlesPassed + 1;
					IF ShuttlesPassed > NumberOfShuttlesToAvg THEN
						ShuttlesPassed := 1;
					END_IF;
					IF TotalShuttlesPassed <= NumberOfShuttlesToAvg THEN
						TimeStart[ShuttlesPassed]:=DTGetTime_0.DT1;
						TimeDelta := DiffDT(DTGetTime_0.DT1, TimeStart[0]);
						PPM := 60.0 * INT_TO_LREAL(ShuttlesPassed) / UDINT_TO_LREAL(TimeDelta);
						//LastTimeDeltaIndex:=1;
					ELSE
						//						LastTimeDeltaIndex:=LastTimeDeltaIndex+1;
						//						IF LastTimeDeltaIndex > NumberOfShuttlesToAvg THEN
						//							LastTimeDeltaIndex:=1;
						//						END_IF;
						TimeDelta := DiffDT(DTGetTime_0.DT1, TimeStart[ShuttlesPassed]);
						TimeStart[ShuttlesPassed]:=DTGetTime_0.DT1;
						PPM := 60.0 * NumberOfShuttlesToAvg / UDINT_TO_LREAL(TimeDelta);
					END_IF
				END_IF
				TotalShuttlesPassed := TotalShuttlesPassed +1;

			END_IF
			CheckShuttle.Enable := 0;
			TrigInfo.Execute := 0;
			State := 2;

	END_CASE

	TrigEnable();
	TrigInfo();
	CheckShuttle();
	DTGetTime_0();

END_FUNCTION_BLOCK
