/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Hooking SA-MP native functions
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

#include "./CZ/Inc/Hook.inc"
#include "./CZ/Account/Inc/Core.inc"
#include "./CZ/Inc/TextDraw.inc"
#include "./CZ/Game/Inc/Core.inc"
#include "./CZ/Inc/Timer.inc"

stock Qoo_fwrite(File: file, const data[])
{
	if (IsNull(data))
		return 0;
	
	for (new i = 0, len = strlen(data); i < len; ++i)
		fputchar(file, data[i], false);
	
	return 1;
}
#if defined _ALS_fwrite
	#undef fwrite
#else
	#define _ALS_fwrite
#endif
#define fwrite Qoo_fwrite

native old_SetPlayerHealth(playerid, Float: health) = SetPlayerHealth;
stock Qoo_SetPlayerHealth(playerid, Float: health)
{
	if (!IsPlayerConnected(playerid))
		return 0;

	SetPlayerHealth(playerid, health);

	UpdatePlayerHealthText(playerid);

	return 1;
}
#if defined _ALS_SetPlayerHealth
	#undef SetPlayerHealth
#else
	#define _ALS_SetPlayerHealth
#endif
#define SetPlayerHealth Qoo_SetPlayerHealth

native old_GetPlayerMoney(playerid) = GetPlayerMoney;
stock Qoo_GetPlayerMoney(playerid)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	return (playerInfo[playerid][pCash]);
}
#if defined _ALS_GetPlayerMoney
	#undef GetPlayerMoney
#else
	#define _ALS_GetPlayerMoney
#endif
#define GetPlayerMoney Qoo_GetPlayerMoney

native old_SetPlayerMoney(playerid, money) = SetPlayerMoney;
stock Qoo_SetPlayerMoney(playerid, money)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	playerInfo[playerid][pCash] = money;

	UpdatePlayerMoneyText(playerid);

	SavePlayerAccount(playerid);

	return 1;
}
#if defined _ALS_SetPlayerMoney
	#undef SetPlayerMoney
#else
	#define _ALS_SetPlayerMoney
#endif
#define SetPlayerMoney Qoo_SetPlayerMoney

native old_GivePlayerMoney(playerid, amount) = GivePlayerMoney;
stock Qoo_GivePlayerMoney(playerid, amount)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	playerInfo[playerid][pCash] += amount;

	UpdatePlayerMoneyText(playerid);

	SavePlayerAccount(playerid);

	return 1;
}
#if defined _ALS_GivePlayerMoney
	#undef GivePlayerMoney
#else
	#define _ALS_GivePlayerMoney
#endif
#define GivePlayerMoney Qoo_GivePlayerMoney

native old_GetPlayerScore(playerid) = GetPlayerScore;
stock Qoo_GetPlayerScore(playerid)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;

	return (playerInfo[playerid][pKill]);
}
#if defined _ALS_GetPlayerScore
	#undef GetPlayerScore
#else
	#define _ALS_GetPlayerScore
#endif
#define GetPlayerScore Qoo_GetPlayerScore

native old_SetPlayerScore(playerid, score) = SetPlayerScore;
stock Qoo_SetPlayerScore(playerid, score)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	playerInfo[playerid][pKill] = score;

	SetPlayerScore(playerid, score);

	SavePlayerAccount(playerid);

	return 1;
}
#if defined _ALS_SetPlayerScore
	#undef SetPlayerScore
#else
	#define _ALS_SetPlayerScore
#endif
#define SetPlayerScore Qoo_SetPlayerScore

stock Qoo_GetWeaponName(weaponid, destination[], length = sizeof(destination))
{
	switch (weaponid)
	{
		case 0:
			strcpy(destination, "Fist", length);
		case 18:
			strcpy(destination, "Molotov Cocktail", length);
		case 44:
			strcpy(destination, "Night Vision Goggles", length);
		case 45:
			strcpy(destination, "Thermal Goggles", length);
		case 47:
			strcpy(destination, "Fake Pistol", length);
		case 49:
			strcpy(destination, "Vehicle", length);
		case 50:
			strcpy(destination, "Helicopter Blades", length);
		case 51:
			strcpy(destination, "Explosion", length);
		case 53:
			strcpy(destination, "Drowned", length);
		case 54:
			strcpy(destination, "Splat", length);
		case 200:
			strcpy(destination, "Connect", length);
		case 201:
			strcpy(destination, "Disconnect", length);
		case 255:
			strcpy(destination, "Suicide", length);
		default:
			return GetWeaponName(weaponid, destination, length);
	}

	return 1;
}
#if defined _ALS_GetWeaponName
	#undef GetWeaponName
#else
	#define _ALS_GetWeaponName
#endif
#define GetWeaponName Qoo_GetWeaponName

stock Qoo_Kick(playerid)
{
	if (!IsPlayerConnected(playerid) || playerKickTimer[playerid])
	{
		return 0;
	}

	playerKickTimer[playerid] = SetTimerEx("OnPlayerKick", GetRealTimerTime(500), false, "i", playerid);
	return 1;
}
#if defined _ALS_Kick
	#undef Kick
#else
	#define _ALS_Kick
#endif
#define Kick Qoo_Kick
