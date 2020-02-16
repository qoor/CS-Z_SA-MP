/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Detect player is in AFK
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

#include "./CZ/Util/Inc/ESC.inc"
#include "./CZ/Inc/Timer.inc"

InitModule("ESC")
{
	AddEventHandler(D_PlayerConnect, "ESC_PlayerConnect");
	AddEventHandler(D_PlayerUpdate, "ESC_PlayerUpdate");
	AddEventHandler(player1sTimer, "ESC_Player1sTimer");
}

public ESC_PlayerConnect(playerid)
{
	playerESC[playerid] = 0;

	return 0;
}

public ESC_PlayerUpdate(playerid)
{
	if (playerESC[playerid] > 0)
		playerESC[playerid] = 0;
	
	return 1;
}

public ESC_Player1sTimer(playerid)
{
	if (playerESC[playerid] == 0)
		playerESC[playerid] = 1;
	else
		++playerESC[playerid];
	
	return 0;
}

function bool: IsPlayerESC(playerid)
{
	return (IsPlayerConnected(playerid) && playerESC[playerid] >= 2);
}

stock GetPlayerESCTime(playerid)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerESC(playerid))
		return 0;
	
	return (playerESC[playerid] - 1);
}
