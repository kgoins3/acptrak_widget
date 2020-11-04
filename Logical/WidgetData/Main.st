
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	
	FOR i := 0 TO 149 DO
		animData.PosX[i]	:= LREAL_TO_REAL(gShuttleMon.Shuttle[i].Position.X);
		animData.PosY[i]	:= LREAL_TO_REAL(gShuttleMon.Shuttle[i].Position.Y);
		animData.RotZ[i]	:= LREAL_TO_REAL(gShuttleMon.Shuttle[i].Orientation.Angle1);
		animData.Avail[i]	:= BOOL_TO_SINT(gShuttleMon.Shuttle[i].Available);
		animData.ExtentBack[i]	:= LREAL_TO_REAL(gShuttleMon.Shuttle[i].ExtentToBack);
		animData.ExtentFront[i]	:= LREAL_TO_REAL(gShuttleMon.Shuttle[i].ExtentToFront);
		animData.Width[i]	:= LREAL_TO_REAL(gShuttleMon.Shuttle[i].Width);

		
		IF gShuttleMon.Shuttle[i].UserData <> 0 THEN
			pUserData ACCESS gShuttleMon.Shuttle[i].UserData;
				
			CASE pUserData.Color OF
				
				ORANGE:
					animData.ColorR[i]	:= 255;
					animData.ColorG[i]	:= 127.5;
					animData.ColorB[i]	:= 0.0;
						
				GREEN:
					animData.ColorR[i]	:= 0.0;
					animData.ColorG[i]	:= 255;
					animData.ColorB[i]	:= 0.0;
						
				RED:
					animData.ColorR[i]	:= 255;
					animData.ColorG[i]	:= 0.0;
					animData.ColorB[i]	:= 0.0;
						
				BLUE:
					animData.ColorR[i]	:= 80;
					animData.ColorG[i]	:= 80;
					animData.ColorB[i]	:= 255;
						
				WHITE:
					animData.ColorR[i]	:= 255;
					animData.ColorG[i]	:= 255;
					animData.ColorB[i]	:= 255;
						
				YELLOW:
					animData.ColorR[i]	:= 204;
					animData.ColorG[i]	:= 204;
					animData.ColorB[i]	:= 0.0;

				ELSE
					animData.ColorR[i]	:= 127.5;
					animData.ColorG[i]	:= 127.5;
					animData.ColorB[i]	:= 127.5;
			END_CASE
		END_IF
		
	END_FOR;	
	
	
END_PROGRAM
