
(* Simply Operate a RoutedMoveVel to a new sector *)
FUNCTION_BLOCK SimpleRoute
	
	CASE Internal.State OF
		0:	//	----------------------------------------------------------------------- FUB Disabled
			
			IF Enable THEN
				Internal.State		:= 10;
				
				Internal.PP.TrgEnable.ProcessPoint	:= ADR( ProcessPoint );
				Internal.PP.TrgInfo.ProcessPoint	:= ADR( ProcessPoint );
				
				Internal.PP.TrgEnable.Enable		:= TRUE;
			ELSE
				Internal.PP.RoutedMoveVel.Execute	:= FALSE;
				Internal.PP.TrgEnable.Enable		:= FALSE;
				Internal.PP.TrgInfo.Execute			:= FALSE;
			END_IF;
			
		10:	//	-----------------------------------------------------------------------
			
			IF Internal.PP.TrgEnable.Valid AND Internal.PP.TrgEnable.EventCount > 0 THEN
				Internal.PP.TrgInfo.Execute		:= TRUE;
				Internal.State					:= 20;
			END_IF;
			
		20:	//	-----------------------------------------------------------------------
		
			IF Internal.PP.TrgInfo.Done THEN
				Internal.PP.RoutedMoveVel.Axis			:= ADR( Internal.PP.TrgInfo.TrgPointInfo.Axis );
				Internal.PP.RoutedMoveVel.Sector		:= ADR( Destination );
				Internal.PP.RoutedMoveVel.Acceleration	:= Acceleration;
				Internal.PP.RoutedMoveVel.Deceleration	:= Acceleration;
				Internal.PP.RoutedMoveVel.Velocity		:= Velocity;
				Internal.PP.RoutedMoveVel.RouteVelocity	:= RouteVelocity;
				Internal.PP.RoutedMoveVel.Position		:= 0.0;
				Internal.PP.RoutedMoveVel.BufferMode	:= mcABORTING;
				
				Internal.PP.RoutedMoveVel.Execute		:= TRUE;
				
				Internal.State		:= 30;
			END_IF;
				
		30:	//	-----------------------------------------------------------------------
		
			IF Internal.PP.RoutedMoveVel.Active THEN
				Internal.PP.RoutedMoveVel.Execute		:= FALSE;
				Internal.PP.TrgInfo.Execute				:= FALSE;
				Internal.State							:= 0;
			END_IF;
				
	END_CASE;
	
	Internal.PP.RoutedMoveVel();
	Internal.PP.TrgEnable();
	Internal.PP.TrgInfo();
	
END_FUNCTION_BLOCK
