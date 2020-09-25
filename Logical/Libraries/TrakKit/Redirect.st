
FUNCTION_BLOCK Redirect


(*)
Redirect.st

IF Redirect.ShuttlePassed AND Redirect.ShuttleInfoValid THEN

	CASE Redirect.ShuttleInfo OF


	Redirect.DestinationSector		:= SECTOR_A;
	Redirect.DestinationPosition	:= 3.0;
	Redirect.Velocity				:= whatver;
	Redirect.Accel					:= whatever

	Redirect.Execute				:= TRUE;
ELSE
	Redirect.Execute				:= FALSE;
END_IF;
*)








END_FUNCTION_BLOCK
