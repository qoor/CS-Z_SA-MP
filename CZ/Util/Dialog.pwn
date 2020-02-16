/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Dialog control utill
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

#include "./CZ/Util/Inc/Dialog.inc"

InitModule("Dialog")
{
	AddEventHandler(D_PlayerConnect, "Dialog_PlayerConnect");
}

public Dialog_PlayerConnect(playerid)
{
	playerDialogListValue[playerid] = playerDialogListValue[MAX_PLAYERS];
	playerDialogListCount[playerid] = -1;
	return 0;
}

function InsertPlayerDialogListValue(playerid, value)
{
	if (!IsPlayerConnected(playerid) || playerDialogListCount[playerid] >= MAX_DIALOG_LISTS)
		return;
	
	playerDialogListValue[playerid][(++playerDialogListCount[playerid])] = value;
}

function bool: GetPlayerDialogListValue(playerid, listitem, &destination)
{
	destination = 0;

	if (!IsPlayerConnected(playerid) || listitem > playerDialogListCount[playerid])
		return false;
	
	destination = playerDialogListValue[playerid][listitem];
	return true;
}

function ResetPlayerDialogList(playerid)
{
	if (!IsPlayerConnected(playerid))
		return;
	
	playerDialogListValue[playerid] = playerDialogListValue[MAX_PLAYERS];
	playerDialogListCount[playerid] = -1;
}
