
TYPE
	Internal_typ : 	STRUCT 
		State : UINT;
		PP : PP_typ;
	END_STRUCT;
	PP_typ : 	STRUCT 
		RoutedMoveVel : MC_BR_RoutedMoveVel_AcpTrak;
		TrgInfo : MC_BR_TrgPointGetInfo_AcpTrak;
		TrgEnable : MC_BR_TrgPointEnable_AcpTrak;
	END_STRUCT;
END_TYPE
