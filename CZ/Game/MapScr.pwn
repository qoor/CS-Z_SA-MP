/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Custom scripts of specified maps 
 * 
 * MIT License
 * 
 * Copyright (c) 2020 Qoo
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
*/

#include "./CZ/Game/Inc/MapScr.inc"

InitModule("Game_MapScr")
{
	AddEventHandler(gamemodeMapStartEvent, "G_MapScr_GamemodeMapStart");
}

public G_MapScr_GamemodeMapStart()
{
	for (new i = 0; i < liftObjects; ++i)
	{
		if (liftObject[i][loTime] == 0)
			continue;

		liftObject[i][loObject] = 0;
		
		liftObject[i][loStartX] = 0.0;
		liftObject[i][loStartY] = 0.0;
		liftObject[i][loStartZ] = 0.0;

		liftObject[i][loStartRotX] = 0.0;
		liftObject[i][loStartRotY] = 0.0;
		liftObject[i][loStartRotZ] = 0.0;

		liftObject[i][loStartSpeed] = 0.0;
		liftObject[i][loEndSpeed] = 0.0;

		liftObject[i][loEndX] = 0.0;
		liftObject[i][loEndY] = 0.0;
		liftObject[i][loEndZ] = 0.0;

		liftObject[i][loEndRotX] = 0.0;
		liftObject[i][loEndRotY] = 0.0;
		liftObject[i][loEndRotZ] = 0.0;

		liftObject[i][loTime] = 0;

		if (liftObject[i][loTimer] != 0)
		{
			KillTimer(liftObject[i][loTimer]);

			liftObject[i][loTimer] = 0;
		}
	}

	liftObjects = 0;

	new mapName[MAX_MAP_NAME];

	GetMapName(currentMap, mapName);
	
	if (!IsNull(mapName) && strcmp(mapName, "The Eiffel Tower", true) == 0)
	{
		CreateLiftObject(974, 948.7885, 2439.6833, 9.8745, 90.2408, 0.0, 0.0, 948.7885, 2439.6833, 42.3915, 5.0, 10.0, 90.2408, 0.0, 0.0, 10000);
		CreateLiftObject(974, 957.2825, 2432.8066, 42.4322, 90.2408, 0.0, 0.0, 957.2704, 2432.7641, 81.2929, 5.0, 10.0, 90.2408, 0.0, 0.0, 15000);
		CreateLiftObject(974, 957.1609, 2442.0993, 81.1611, 90.2408, 0.0, 0.0, 956.3643, 2442.0812, 198.7663, 5.0, 10.0, 90.2408, 0.0, 0.0, 30000);
	}
}

public OnLiftObjectArrived(index, step)
{
	if (index < 0 || index >= MAX_LIFT_OBJECTS || IsValidObject(liftObject[index][loObject]) == 0)
		return;
	
	if (step == 0)
	{
		MoveObject(liftObject[index][loObject], liftObject[index][loEndX], liftObject[index][loEndY], liftObject[index][loEndZ], liftObject[index][loEndSpeed],
			liftObject[index][loEndRotX], liftObject[index][loEndRotY], liftObject[index][loEndRotZ]);
	}
	else
	{
		MoveObject(liftObject[index][loObject], liftObject[index][loStartX], liftObject[index][loStartY], liftObject[index][loStartZ], liftObject[index][loStartSpeed],
			liftObject[index][loStartRotX], liftObject[index][loStartRotY], liftObject[index][loStartRotZ]);
	}

	liftObject[index][loTimer] = SetTimerEx("OnLiftObjectArrived", GetRealTimerTime(liftObject[index][loTime]), 0, "ii", index, !step);
}

function CreateLiftObject(modelid, Float: startX, Float: startY, Float: startZ, Float: startRotX, Float: startRotY, Float: startRotZ, Float: endX, Float: endY, Float: endZ,\
	Float: startSpeed, Float: endSpeed, Float: endRotX, Float: endRotY, Float: endRotZ, time)
{
	new index = liftObjects;

	if (index >= MAX_LIFT_OBJECTS)
		return 0;
	
	liftObject[index][loObject] = CreateMapObject(modelid, startX, startY, startZ, startRotX, startRotY, startRotZ);
	
	liftObject[index][loStartX] = startX;
	liftObject[index][loStartY] = startY;
	liftObject[index][loStartZ] = startZ;

	liftObject[index][loStartRotX] = startRotX;
	liftObject[index][loStartRotY] = startRotY;
	liftObject[index][loStartRotZ] = startRotZ;

	liftObject[index][loStartSpeed] = startSpeed;
	liftObject[index][loEndSpeed] = endSpeed;

	liftObject[index][loEndX] = endX;
	liftObject[index][loEndY] = endY;
	liftObject[index][loEndZ] = endZ;

	liftObject[index][loEndRotX] = endRotX;
	liftObject[index][loEndRotY] = endRotY;
	liftObject[index][loEndRotZ] = endRotZ;

	liftObject[index][loTime] = time;
	
	OnLiftObjectArrived(index, 0);

	++liftObjects;

	return 1;
}

function GivePlayerParachute(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	new mapName[MAX_MAP_NAME];

	GetMapName(currentMap, mapName);

	if (IsNull(mapName))
		return 0;

	if (strcmp(mapName, "The Sink Hole", true) == 0 || strcmp(mapName, "Free Fall", true) == 0)
	{
		GivePlayerWeapon(playerid, WEAPON_PARACHUTE, 1);
		SetPlayerArmedWeapon(playerid, WEAPON_PARACHUTE);
	}
	
	return 1;
}

stock bool: IsMapDisallowWaterDeath(mapid)
{
	new mapName[MAX_MAP_NAME];

	GetMapName(mapid, mapName);

	return (!IsNull(mapName) &&
			(strcmp(mapName, "Area 69 Underground", true) == 0 ||
			strcmp(mapName, "Underwater Laboratory", true) == 0));
}
