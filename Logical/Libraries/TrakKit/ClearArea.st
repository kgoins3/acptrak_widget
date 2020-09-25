


FUNCTION_BLOCK ClearArea

	CASE BlockState OF

		CLEAR_BLOCK_STATE_IDLE:

			IF Enable THEN
				Barrier.ProcessPoint := StartPP;
				Barrier.AdvancedParameters.TicketCount := NumShuttles;
				Barrier.Command := mcACPTRAK_BARRIER_ADD_TICKETS;
				Barrier.Execute := 1;
				BlockState := CLEAR_BLOCK_STATE_INIT;
			END_IF

		CLEAR_BLOCK_STATE_INIT:

			IF Barrier.Done THEN
				Barrier.Execute := 0;
				BlockState := CLEAR_BLOCK_STATE_WAIT;
			END_IF


		CLEAR_BLOCK_STATE_WAIT:

			IF NOT Enable THEN
				Barrier.AdvancedParameters.TicketCount := 0;
				Barrier.Command := mcACPTRAK_BARRIER_OPEN;
				Barrier.Execute := 1;
				BlockState := CLEAR_BLOCK_STATE_OFF;
			ELSIF USINT_TO_DINT(ExitShuttleNum) >= Barrier.AdvancedParameters.TicketCount THEN
				ExitShuttleNum := 0;
				Barrier.Execute := 1;
				BlockState := CLEAR_BLOCK_STATE_RESET;
			END_IF

		CLEAR_BLOCK_STATE_RESET:

			IF Barrier.Done THEN
				Barrier.Execute := 0;
				BlockState := CLEAR_BLOCK_STATE_WAIT;
			END_IF

		CLEAR_BLOCK_STATE_OFF:

			IF Barrier.Done THEN
				ExitShuttleNum := 0;
				Barrier.Execute := 0;
				BlockState := CLEAR_BLOCK_STATE_IDLE;
			END_IF

	END_CASE

	CASE PPState OF

		CLEAR_PP_STATE_IDLE:

			IF Enable THEN
				TrigEnable.ProcessPoint := EndPP;
				TrigEnable.Enable := 1;
				TrigInfo.ProcessPoint := EndPP;
				PPState := CLEAR_PP_STATE_ENABLE;
			END_IF

		CLEAR_PP_STATE_ENABLE:

			IF TrigEnable.Valid THEN
				PPState := CLEAR_PP_STATE_WAIT;
			END_IF

		CLEAR_PP_STATE_WAIT:

			IF NOT Enable THEN
				TrigEnable.Enable := 0;
				PPState := CLEAR_PP_STATE_OFF;
			ELSIF TrigEnable.EventCount > 0  THEN
				TrigInfo.Execute := 1;
				PPState := CLEAR_PP_STATE_GET_INFO;
			END_IF

		CLEAR_PP_STATE_GET_INFO:

			IF TrigInfo.Done THEN
				ExitShuttleNum := ExitShuttleNum + 1;
				TrigInfo.Execute := 0;
				PPState := CLEAR_PP_STATE_WAIT;
			END_IF

		CLEAR_PP_STATE_OFF:

			IF NOT TrigEnable.Valid THEN
				ExitShuttleNum := 0;
				PPState := CLEAR_PP_STATE_IDLE;
			END_IF

	END_CASE

	TrigEnable();
	TrigInfo();
	Barrier();
END_FUNCTION_BLOCK
