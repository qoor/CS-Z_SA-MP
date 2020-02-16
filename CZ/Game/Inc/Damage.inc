/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Game/Damage.pwn
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

#if defined __GAME_DAMAGE_H__
	#endinput
#endif

#define __GAME_DAMAGE_H__

#define MAX_DAMAGED_LOG_AMOUNT 200

enum E_DAMAGED_INFO
{
	dmIssuerId,
	dmWeaponId,
	Float: dmAmount,
	dmHour,
	dmMinute,
	dmSecond
};

new playerKilledEvent;

new lastDamagedPlayer[MAX_PLAYERS];

new damagedPlayerName[MAX_PLAYERS][MAX_DAMAGED_LOG_AMOUNT][MAX_PLAYER_NAME];
new damagedPlayerCount[MAX_PLAYERS];
new damagedInfo[MAX_PLAYERS][MAX_DAMAGED_LOG_AMOUNT][E_DAMAGED_INFO];

forward GivePlayerDamage(issuerid, targetid, weaponid, Float: amount);
forward bool: IsWeaponCanDamageToArmour(weaponid);
forward InsertPlayerDamagedInfo(playerid, issuerid, weaponid, Float: amount);
forward ShowPlayerDamagedInfo(playerid, showplayerid = INVALID_PLAYER_ID);
forward ResetDamageInfo(playerid);

forward G_Damage_PlayerConnect(playerid);
forward G_Damage_PlayerDisconnect(playerid);
forward G_Damage_PlayerGiveDamage(playerid, damagedid, Float: amount, weaponid);
forward G_Damage_PlayerTakeDamage(playerid, issuerid, Float: amount, weaponid);
forward G_Damage_PlayerCommandText(playerid, const command[], const params[]);
