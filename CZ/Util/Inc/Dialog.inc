/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Util/Dialog.pwn
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

#if defined __DIALOG_H__
	#endinput
#endif

#define __DIALOG_H__

#define MAX_DIALOG_LISTS 500

enum _: E_DIALOG_LIST (+= 10) {
	DIALOG_NONE = 10,
	DIALOG_REGISTER,
	DIALOG_PASSWORD_CHECK,
	DIALOG_LOGIN,
	DIALOG_CHANGE_PASSWORD,
	DIALOG_WEAPON_SHOP,
	DIALOG_UPGRADE_STAT,
	DIALOG_HELP,
	DIALOG_LUCK_STAT,
	DIALOG_MUSIC_CAST,
	DIALOG_CHANGE_MAP,
	DIALOG_MIGRATION
};

new playerDialogListValue[MAX_PLAYERS + 1][MAX_DIALOG_LISTS];
new playerDialogListCount[MAX_PLAYERS];

forward Dialog_PlayerConnect(playerid);

forward InsertPlayerDialogListValue(playerid, value);
forward bool: GetPlayerDialogListValue(playerid, listitem, &destination);
forward ResetPlayerDialogList(playerid);
