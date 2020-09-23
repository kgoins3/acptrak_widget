
PROGRAM _INIT 
    // size of Vis structure - this value has to be entered in B&R scene viewer (PVI -> Options -> Size)
   // SizeofVis := SIZEOF(Vis);
	SizeofVis	:= SIZEOF(userVis);
	// max number of displayed shuttles  
	NumVisShuttle := SIZEOF(Vis.Shuttle) / SIZEOF(Vis.Shuttle[0]);  
	
	
END_PROGRAM

PROGRAM _CYCLIC 
	
    FOR i:=0 TO (NumVisShuttle-1) DO 
        IF gShuttleMon.Shuttle[i].Available THEN
            // format selected monitor data to fit B&R scene viewer  
            Vis.Shuttle[i].Available    := 1;
            Vis.Shuttle[i].PositionX    := LREAL_TO_REAL(gShuttleMon.Shuttle[i].Position.X);
            Vis.Shuttle[i].PositionY    := LREAL_TO_REAL(gShuttleMon.Shuttle[i].Position.Y);
            Vis.Shuttle[i].RotationZ    := LREAL_TO_REAL(gShuttleMon.Shuttle[i].Orientation.Angle1);
            Vis.Shuttle[i].ExtentToFront    := LREAL_TO_REAL(gShuttleMon.Shuttle[i].ExtentToFront);
            Vis.Shuttle[i].ExtentToBack        := LREAL_TO_REAL(gShuttleMon.Shuttle[i].ExtentToBack);
            Vis.Shuttle[i].Width    := LREAL_TO_REAL(gShuttleMon.Shuttle[i].Width);  
            brsitoa(gShuttleMon.Shuttle[i].Index, ADR(Vis.Shuttle[i].Text));
            Vis.Shuttle[i].ColorRed := 0.5;
            Vis.Shuttle[i].ColorGreen := 0.5;
            Vis.Shuttle[i].ColorBlue := 0.5;
            //Set shuttle color via user data
            IF gShuttleMon.Shuttle[i].UserData <> 0 THEN
                pUserData ACCESS gShuttleMon.Shuttle[i].UserData;
                IF pUserData.Color = GREEN THEN
                    Vis.Shuttle[i].ColorRed := 0.0;
                    Vis.Shuttle[i].ColorGreen := 1.0;
                    Vis.Shuttle[i].ColorBlue := 0.0;
                ELSIF pUserData.Color = BLUE THEN
                    Vis.Shuttle[i].ColorRed := 0.0;
                    Vis.Shuttle[i].ColorGreen := 0.0;
                    Vis.Shuttle[i].ColorBlue := 1.0;
                ELSIF pUserData.Color = RED THEN
                    Vis.Shuttle[i].ColorRed := 1.0;
                    Vis.Shuttle[i].ColorGreen := 0.0;
                    Vis.Shuttle[i].ColorBlue := 0.0;
                ELSIF pUserData.Color = YELLOW THEN
                    Vis.Shuttle[i].ColorRed := 0.8;
                    Vis.Shuttle[i].ColorGreen := 0.8;
                    Vis.Shuttle[i].ColorBlue := 0.0;
                ELSIF pUserData.Color = ORANGE THEN
                    Vis.Shuttle[i].ColorRed := 1.0;
                    Vis.Shuttle[i].ColorGreen := 0.5;
                    Vis.Shuttle[i].ColorBlue := 0.0;
                ELSIF pUserData.Color = BLACK THEN
                    Vis.Shuttle[i].ColorRed := 0.0;
                    Vis.Shuttle[i].ColorGreen := 0.0;
                    Vis.Shuttle[i].ColorBlue := 0.0;
                ELSIF pUserData.Color = WHITE THEN
                    Vis.Shuttle[i].ColorRed := 1.0;
                    Vis.Shuttle[i].ColorGreen := 1.0;
                    Vis.Shuttle[i].ColorBlue := 1.0;
                ELSIF pUserData.Color = PINK THEN
                    Vis.Shuttle[i].ColorRed := 1.0;
                    Vis.Shuttle[i].ColorGreen := 0.0;
                    Vis.Shuttle[i].ColorBlue := 0.5;
                ELSIF pUserData.Color = PURPLE THEN
                    Vis.Shuttle[i].ColorRed := 0.5;
                    Vis.Shuttle[i].ColorGreen := 0.0;
                    Vis.Shuttle[i].ColorBlue := 1.0;
                ELSE
                    Vis.Shuttle[i].ColorRed := 0.5;
                    Vis.Shuttle[i].ColorGreen := 0.5;
                    Vis.Shuttle[i].ColorBlue := 0.5;
                END_IF
            END_IF
        ELSE
            brsmemset(ADR(Vis.Shuttle[i]), 0, SIZEOF(Vis.Shuttle[0]));
        END_IF
	END_FOR

	
	
	// mapping for some extra features in the vis / sim
	
	userVis.Vis					:= Vis;
	
	userVis.Star1_rotZ			:= -1 * LREAL_TO_REAL(Infeed.Starwheel.Axis.Position) + 225;
	//	userVis.Star2_rotZ			:= -1 * LREAL_TO_REAL(Outfeed.Starwheel.Axis.Position) + 315;
	
	//	userVis.Vis				:= Vis;
	//	
//	userVis.Star1_rotZ		:= -1 * UDINT_TO_REAL(LREAL_TO_UDINT( Starwheel.Position * 100) MOD 36000) / 100.0;
//	
//	//userVis.Star1_rotZ		:= LREAL_TO_REAL(-1*Starwheel.Position MOD 360.0);
//	
//	
	
END_PROGRAM
