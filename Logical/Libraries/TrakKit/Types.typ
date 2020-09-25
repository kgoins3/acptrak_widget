
TYPE
	enumUserColor : 
		(
		GRAY,
		BLUE,
		RED,
		GREEN,
		YELLOW,
		ORANGE,
		WHITE,
		BLACK,
		PINK,
		PURPLE
		);
	typShuttleUserData : 	STRUCT 
		Color : enumUserColor;
		SyncObjectID : UINT;
		InSync : BOOL;
	END_STRUCT;
	ClearBlockState : 
		(
		CLEAR_BLOCK_STATE_IDLE,
		CLEAR_BLOCK_STATE_INIT,
		CLEAR_BLOCK_STATE_WAIT,
		CLEAR_BLOCK_STATE_RESET,
		CLEAR_BLOCK_STATE_OFF
		);
	ClearPPState : 
		(
		CLEAR_PP_STATE_IDLE,
		CLEAR_PP_STATE_ENABLE,
		CLEAR_PP_STATE_WAIT,
		CLEAR_PP_STATE_GET_INFO,
		CLEAR_PP_STATE_OFF
		);
	SpawnState : 
		(
		SPAWN_STATE_IDLE,
		SPAWN_STATE_BLOCK,
		SPAWN_STATE_CREATE,
		SPAWN_STATE_REPORT,
		SPAWN_STATE_CREATE_NEXT,
		SPAWN_STATE_GET,
		SPAWN_STATE_SET_USER_DATA,
		SPAWN_STATE_SEND,
		SPAWN_STATE_WAIT,
		SPAWN_STATE_TRIG,
		SPAWN_STATE_UNBLOCK,
		SPAWN_STATE_DONE
		);
	FeedState : 
		(
		FEED_STATE_IDLE,
		FEED_STATE_ENABLE,
		FEED_STATE_WAIT,
		FEED_STATE_TRIG,
		FEED_STATE_CHECK_SHUTTLE,
		FEED_STATE_GET_SHUTTLE_DATA,
		FEED_STATE_MOVE_ABS,
		FEED_STATE_TIME,
		FEED_STATE_GET,
		FEED_STATE_COLOR,
		FEED_STATE_SEND,
		FEED_STATE_DISABLE
		);
	TwoUpState1 : 
		(
		TWOUP_STATE1_IDLE,
		TWOUP_STATE1_ENABLE,
		TWOUP_STATE1_WAIT,
		TWOUP_STATE1_TRIG,
		TWOUP_STATE1_CHECK_SHUTTLE,
		TWOUP_STATE1_MOVE_ABS,
		TWOUP_STATE1_TIME,
		TWOUP_STATE1_DISABLE
		);
	TwoUpState2 : 
		(
		TWOUP_STATE2_IDLE,
		TWOUP_STATE2_WAIT,
		TWOUP_STATE2_GET1,
		TWOUP_STATE2_MOVE_ABS,
		TWOUP_STATE2_TIME,
		TWOUP_STATE2_GET2,
		TWOUP_STATE2_COLOR,
		TWOUP_STATE2_SEND
		);
END_TYPE