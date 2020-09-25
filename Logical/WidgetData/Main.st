
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	
	FOR i := 0 TO 149 DO
		animData.PosX[i]	:= LREAL_TO_REAL(gShuttleMon.Shuttle[i].Position.X);
		animData.PosY[i]	:= LREAL_TO_REAL(gShuttleMon.Shuttle[i].Position.Y);
		animData.RotZ[i]	:= LREAL_TO_REAL(gShuttleMon.Shuttle[i].Orientation.Angle1);
		animData.Avail[i]	:= BOOL_TO_SINT(gShuttleMon.Shuttle[i].Available);
	END_FOR;	
	
	
END_PROGRAM
