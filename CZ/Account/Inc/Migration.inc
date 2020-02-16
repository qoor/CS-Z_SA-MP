/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Account/Migration.pwn
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

#if defined __ACCOUNT_MIGRATION_H__
	#endinput
#endif
#define __ACCOUNT_MIGRATION_H__

new bool: legacyAccountHave[MAX_PLAYERS];

forward CheckPlayerLegacyAccount(playerid);
forward LoginPlayerLegacyAccount(playerid, const password[]);
forward ShowPlayerMigrationDialog(playerid, step = 0);
forward bool: IsPlayerHaveLegacyAccount(playerid);
forward RemovePlayerLegacyAccount(playerid);

forward A_Migration_PlayerConnect(playerid);
forward A_Migration_DialogResponse(playerid, dialogid, response, listitem, const inputtext[]);
