
TYPE
	SyncObj_typ : 	STRUCT 
		MoveCyclic : MC_BR_ElasticMoveCycPos_AcpTrak;
		InSync : BOOL;
		PocketSelect : USINT;
		ThisShuttle : McAxisType;
		PeriodSelect : USINT;
		LastCycleSetpoint : LREAL;
	END_STRUCT;
	UserData_typ : 	STRUCT 
		SyncObjectID : UINT;
		Color : enumUserColor;
	END_STRUCT;
	TrakCmd_typ : 	STRUCT 
		PowerOn : BOOL;
	END_STRUCT;
	TrakPar_typ : 	STRUCT 
		Acceleration : REAL;
		Velocity : REAL;
		PPM : REAL;
	END_STRUCT;
	TrakStatus_typ : 	STRUCT 
		State : USINT;
	END_STRUCT;
	Trak_typ : 	STRUCT 
		Cmd : TrakCmd_typ;
		Par : TrakPar_typ;
		Status : TrakStatus_typ;
	END_STRUCT;
	Reference_typ : 	STRUCT 
		PosRad : REAL;
		PosDeg : REAL;
	END_STRUCT;
	Period_typ : 	STRUCT 
		Pocket : ARRAY[0..MAX_NUM_POCKETS]OF Pockets_typ;
		PocketLastCycle : ARRAY[0..MAX_NUM_POCKETS]OF Pockets_typ;
		TrakMax : REAL;
		TrakMin : REAL;
	END_STRUCT;
	Starwheel_typ : 	STRUCT 
		Axis : MpAxisBasic;
		Period : ARRAY[0..MAX_NUM_PERIODS]OF Period_typ;
	END_STRUCT;
	Pockets_typ : 	STRUCT 
		Offset : REAL;
		PosDeg : REAL;
		PosRad : REAL;
		TrakPos : LREAL;
	END_STRUCT;
	ProcessPoint_typ : 	STRUCT 
		RoutedMoveVel : MC_BR_RoutedMoveVel_AcpTrak;
		TrgEnable : MC_BR_TrgPointEnable_AcpTrak;
		TrgInfo : MC_BR_TrgPointGetInfo_AcpTrak;
		ShUserData : MC_BR_ShCopyUserData_AcpTrak;
		UserDataBuffer : UserData_typ;
		Counter : UDINT;
		State : USINT;
		BarrierCmd : MC_BR_BarrierCommand_AcpTrak;
		BarrierReadInfo : MC_BR_BarrierReadInfo_AcpTrak;
		BarrierState : USINT;
		periodSelect : USINT;
		pocketSelect : USINT;
	END_STRUCT;
	StarSectorPar_typ : 	STRUCT 
		R1 : REAL;
		R2 : REAL;
		deltaT : TIME;
		SectorTangentPos : REAL;
		PocketCount : USINT;
		Wm : REAL;
		ReleaseVelocity : REAL;
		PositionSyncPP : REAL;
		Rp : REAL;
		PeriodCount : USINT;
		PositionRelPP : REAL;
	END_STRUCT;
	StarwheelSectorLogic_typ : 	STRUCT 
		Starwheel : Starwheel_typ;
		SyncPP : ProcessPoint_typ;
		ReleasePP : ProcessPoint_typ;
		SyncObj : ARRAY[0..NUM_SYNC_OBJS]OF SyncObj_typ;
		indexOpenSyncObj : USINT;
		Par : StarSectorPar_typ;
	END_STRUCT;
END_TYPE
