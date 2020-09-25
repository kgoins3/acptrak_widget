
FUNCTION_BLOCK ShuttleSpawn
	VAR_INPUT
		Enable : BOOL;
		StartPP : UDINT; (*Process point at start to block any incoming shuttle*)
		EndPP : UDINT; (*Process point at end to check shuttles have left*)
		Sector : UDINT; (*Sector to create shuttles on*)
		SectorPositionStart : LREAL; (*Position to start creating shuttles*)
		SectorPositionIncrement : LREAL; (*Increment to create shuttles*)
		DstSector : DINT; (*Destination Sector*)
		DstSectorPosition : LREAL; (*Destination sector position*)
		Velocity : REAL; (*Velocity of move*)
		RouteVelocity : REAL;
		Acceleration : {REDUND_UNREPLICABLE} REAL; (*Acceleration of move*)
		NumShuttleBatch : USINT; (*Number of shuttles in a batch*)
		NumShuttleTotal : USINT; (*Total shuttles to spawn*)
		SetShuttleData : MC_BR_ShCopyUserData_AcpTrak;
		AcknSpawn : BOOL;
	END_VAR
	VAR_OUTPUT
		SpawnValid : BOOL;
		SpawnedAxis : McAxisType;
		Done : BOOL;
	END_VAR
	VAR
		InternalSectorPositionStart : LREAL;
		InternalSectorPositionIncrement : LREAL;
		InternalNumShuttleBatch : USINT;
		InternalNumShuttleTotal : USINT;
		ExitShuttleNum : USINT; (*Number of shuttles that have left*)
		BatchCreated : USINT; (*Number of shuttles created in the batch*)
		TotalCreated : USINT; (*Number of shuttles created total*)
		State : SpawnState;
		TrigEnable : MC_BR_TrgPointEnable_AcpTrak;
		TrigInfo : MC_BR_TrgPointGetInfo_AcpTrak;
		Barrier : MC_BR_BarrierCommand_AcpTrak;
		AddShuttle : MC_BR_SecAddShuttle_AcpTrak;
		GetShuttle : MC_BR_SecGetShuttle_AcpTrak;
		MoveVel : MC_BR_RoutedMoveVel_AcpTrak;
		InternalUserData : typShuttleUserData;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ShuttleDelete
END_FUNCTION_BLOCK

FUNCTION_BLOCK Redirect
END_FUNCTION_BLOCK

FUNCTION_BLOCK Feed
	VAR_INPUT
		Enable : BOOL;
		PP : UDINT;
		NumShuttles : USINT;
		Sector : UDINT;
		UseAbsMove : BOOL;
		UseVelMoveTrigger : BOOL;
		VelMovTrigger : BOOL;
		SectorPositionStart : LREAL;
		TrigDirection : McAcpTrakTrgPointEventEnum;
		MoveAbsVelocity : REAL;
		SectorPositionIncrement : LREAL;
		DstSector : UDINT;
		DstSectorPosition : LREAL;
		DstStartDirection : McDirectionEnum;
		Color : enumUserColor;
		Velocity : REAL;
		RouteVelocity : REAL;
		Acceleration : REAL;
		FeedTime : TIME;
	END_VAR
	VAR_OUTPUT
		Done : BOOL;
		ReadyForProduct : BOOL;
	END_VAR
	VAR
		InternalNumShuttles : USINT;
		InternalSectorPositionStart : LREAL;
		InternalSectorPositionIncrement : LREAL;
		InternalUserData : typShuttleUserData;
		LastSeqNumber : UDINT;
		LastShuttleNumber : USINT;
		ShuttleCount : USINT;
		State : FeedState;
		TrigEnable : MC_BR_TrgPointEnable_AcpTrak;
		TrigInfo : MC_BR_TrgPointGetInfo_AcpTrak;
		CheckShuttle : MC_BR_ShReadInfo_AcpTrak;
		MoveAbs : MC_BR_RoutedMoveAbs_AcpTrak;
		GetShuttle : MC_BR_SecGetShuttle_AcpTrak;
		ColorShuttle : MC_BR_ShCopyUserData_AcpTrak;
		MoveVel : MC_BR_RoutedMoveVel_AcpTrak;
		FeedTON : TON;
		ReadShuttleData : MC_BR_ShCopyUserData_AcpTrak;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ClearArea
	VAR_INPUT
		Enable : BOOL;
		StartPP : UDINT;
		EndPP : UDINT;
		NumShuttles : USINT; (*Number of shuttles to allow*)
		newParam : BOOL;
	END_VAR
	VAR
		ExitShuttleNum : USINT; (*Number of shuttles that have left*)
		BlockState : ClearBlockState;
		PPState : ClearPPState;
		TrigEnable : MC_BR_TrgPointEnable_AcpTrak;
		TrigInfo : MC_BR_TrgPointGetInfo_AcpTrak;
		Barrier : MC_BR_BarrierCommand_AcpTrak;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK CalculatePPM
	VAR_INPUT
		Enable : BOOL;
		PP : UDINT;
		NumberOfShuttlesToAvg : LREAL; (*Max 10000*)
		TrigDirection : McAcpTrakTrgPointEventEnum;
	END_VAR
	VAR_OUTPUT
		PPM : LREAL;
	END_VAR
	VAR
		FinishedLoadout : BOOL;
		LastSeqNumber : UDINT;
		ShuttlesPassed : INT;
		TotalShuttlesPassed : UDINT;
		TimeTotal : UDINT;
		TimeStart : ARRAY[0..10000] OF DATE_AND_TIME;
		TimeDelta : UDINT;
		State : UINT;
		TrigEnable : MC_BR_TrgPointEnable_AcpTrak;
		TrigInfo : MC_BR_TrgPointGetInfo_AcpTrak;
		CheckShuttle : MC_BR_ShReadInfo_AcpTrak;
		DTGetTime_0 : DTGetTime;
		LastTimeDeltaIndex : UINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK TwoUp
	VAR_INPUT
		Enable : BOOL;
		PP : UDINT;
		NumShuttles : USINT;
		Sector : ARRAY[0..1] OF UDINT;
		SectorPositionStart : ARRAY[0..1] OF LREAL;
		SectorPositionIncrement : ARRAY[0..1] OF LREAL;
		DstSector : UDINT;
		DstSectorPosition : LREAL;
		Color : enumUserColor;
		Velocity : REAL;
		Acceleration : REAL;
		FeedTime : ARRAY[0..1] OF TIME;
	END_VAR
	VAR
		InternalNumShuttles : USINT;
		InternalPosArray : ARRAY[0..8] OF LREAL;
		InternalSectorPositionStart : ARRAY[0..1] OF LREAL;
		InternalSectorPositionIncrement : ARRAY[0..1] OF LREAL;
		InternalUserData : typShuttleUserData;
		ShuttleCount : USINT;
		State1 : TwoUpState1;
		State2 : TwoUpState2;
		TrigEnable : MC_BR_TrgPointEnable_AcpTrak;
		TrigInfo : MC_BR_TrgPointGetInfo_AcpTrak;
		CheckShuttle : MC_BR_ShReadInfo_AcpTrak;
		MoveAbs : ARRAY[0..1] OF MC_BR_RoutedMoveAbs_AcpTrak;
		GetShuttle : ARRAY[0..1] OF MC_BR_SecGetShuttle_AcpTrak;
		MoveVel : MC_BR_RoutedMoveVel_AcpTrak;
		ColorShuttle : MC_BR_ShCopyUserData_AcpTrak;
		FeedTON : ARRAY[0..1] OF TON;
		Increment : BOOL; (*Increment from first to second segment*)
	END_VAR
END_FUNCTION_BLOCK
