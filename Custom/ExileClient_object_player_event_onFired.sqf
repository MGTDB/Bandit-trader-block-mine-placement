private["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_object", "_intersection", "_firstInsection", "_name"];
_unit = _this select 0;
_weapon = _this select 1;
_muzzle = _this select 2;
_mode =	_this select 3;
_ammo = _this select 4;
_magazine =	_this select 5;
_projectile = _this select 6;
if (ExilePlayerInSafezone) then
{
    if (local _projectile) then
    {
        deleteVehicle _projectile;
        _name = getText (configFile >> "CfgMagazines" >> _magazine >> "displayName");
        switch (_weapon) do
        {
            case "Put":
            {
                [_unit, _magazine] call ExileClient_util_playerCargo_add;
                ["ErrorTitleAndText", ["Information:",format["You cannot place %1s here, you have been refunded",_name]]] call ExileClient_gui_toaster_addTemplateToast;
            };
            case "Throw":
            {
                [_unit, _magazine] call ExileClient_util_playerCargo_add;
                ["ErrorTitleAndText", ["Information:",format["You cannot throw %1s here, you have been refunded",_name]]] call ExileClient_gui_toaster_addTemplateToast;
            };
        };
    };
}
else
{
	switch (_weapon) do
	{
		case "Exile_Melee_Axe":
		{
			player playActionNow "GestureExileAxeSwing01";
			0 call ExileClient_object_tree_chop;
		};
		case "Exile_Melee_Shovel":
		{
			player playActionNow "GestureExileSledgeHammerSwing01";
		};
		case "Exile_Melee_SledgeHammer":
		{
			player playActionNow "GestureExileSledgeHammerSwing01";
			0 call ExileClient_object_shippingContainer_smash;
		};
		case "Put":
		{
			if (_magazine in ["DemoCharge_Remote_Mag", "SatchelCharge_Remote_Mag"]) then
			{
				_object = cursorTarget;
				if ((_object isKindOf "LandVehicle") || (_object isKindOf "Air") || (_object isKindOf "Boat") || (_object isKindOf "Man") || (_object isKindOf "Exile_Construction_Abstract_Static")) then
				{
					_intersection = lineIntersectsSurfaces 
					[
						AGLToASL positionCameraToWorld [0, 0, 0],  
						AGLToASL positionCameraToWorld [0, 0, 5],  
						player, 
						objNull, 
						true, 
						1, 
						"VIEW", 
						"GEOM" 
					];
					if (count _intersection > 0) then 
					{
						_firstInsection = _intersection select 0;
						if !(simulationEnabled _object) then 
						{
							if (local _object) then 
							{
								_object enableSimulation true;
							}
							else 
							{
								["enableSimulationRequest", [netId _object]] call ExileClient_system_network_send;
							};
						};
						_projectile setPosASL [0, 0, 0]; 
						_projectile attachTo [_object, _object worldToModel (ASLtoAGL (_firstInsection select 0)) ];
						_projectile setVectorUp (_firstInsection select 1);
					};
				};
			};
			//Block placing of mines in black market traders (need to input coordinates)
			if (((((getPos player) distance2D [5555,5555,0]) < 130)) || ((((getPos player) distance2D [6666,6666,0]) < 130)) || ((((getPos player) distance2D [7777,7777,0]) < 130))) then//edit the 3 coords and distance for bm traders
	        {
	            if (local _projectile) then
	            {
	                deleteVehicle _projectile;//delete mine
	                [_unit, _magazine] call ExileClient_util_playerCargo_add;//refund them the mine
	                _weaponName = getText (configFile >> "CfgMagazines" >> _magazine >> "displayName");//get mine name
	                ["ErrorTitleAndText", ["Black Market",format["You cannot place a %1 here",_weaponName]]] call ExileClient_gui_toaster_addTemplateToast;//alert the player
	            };
	        };
		};
		case "Throw":
		{
		};
		default 
		{
			ExileClientPlayerIsInCombat = true;
			ExileClientPlayerLastCombatAt = diag_tickTime;
			true call ExileClient_gui_hud_toggleCombatIcon;
			if !(isNull _projectile) then 
			{
				if (cameraView isEqualTo "GUNNER") then 
				{
					if (isNumber (configFile >> "CfgMagazines" >> _magazine >> "exileBulletCam")) then 
					{
						call ExileClient_system_bulletCam_destroy;
						ExileClientBulletCameraThread = _projectile spawn ExileClient_system_bulletCam_thread;
					};
				};
			};
		};
	};
};
true