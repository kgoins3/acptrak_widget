
{REDUND_ERROR} FUNCTION_BLOCK SimpleRoute (*Simply Operate a RoutedMoveVel to a new sector*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL;
		ProcessPoint : McProcessPointType;
		Destination : McSectorType;
		Acceleration : REAL;
		Velocity : REAL;
		RouteVelocity : REAL;
	END_VAR
	VAR
		Internal : Internal_typ;
	END_VAR
END_FUNCTION_BLOCK
