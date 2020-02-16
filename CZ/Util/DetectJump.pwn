/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Detect player character jump status
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

#include "./CZ/Util/Inc/DetectJump.inc"

InitModule("DetectJump")
{
	AddEventHandler(D_PlayerConnect, "DetectJump_PlayerConnect");
	AddEventHandler(D_PlayerSpawn, "DetectJump_PlayerSpawn");
	AddEventHandler(D_PlayerUpdate, "DetectJump_PlayerUpdate");
}

public DetectJump_PlayerConnect(playerid)
{
	playerJumping[playerid] = false;

	return 0;
}

public DetectJump_PlayerSpawn(playerid)
{
	playerJumping[playerid] = false;

	return 0;
}

public DetectJump_PlayerUpdate(playerid)
{
	new animationIndex = GetPlayerAnimationIndex(playerid);

	if (!playerJumping[playerid])
	{
		if (animationIndex == 1197 || animationIndex == 1198)
		{
			playerJumping[playerid] = true;

			TriggerEventWithBreak(playerJumpEvent, 1, "i", playerid);
		}
	}
	else
	{
		if (animationIndex == 1129 || animationIndex == 1133 || animationIndex == 1196 || animationIndex == 1208 || animationIndex == 1066 || animationIndex == 1063)
			playerJumping[playerid] = false;
	}

	return 1;
}

stock bool: IsPlayerJumping(playerid)
{
	return (IsPlayerConnected(playerid) && playerJumping[playerid]);
}
