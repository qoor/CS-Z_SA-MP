/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Account/Core.pwn
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

#if defined __ACCOUNT_H__
	#endinput
#endif

#define __ACCOUNT_H__

#define ACCOUNT_PATH "[CZ2]/Users"

#define MAX_LOGIN_TRY 5

#define MIN_PASSWORD_LENGTH 4
#define MAX_PASSWORD_LENGTH 16

#define SAVE_COOL_TIME 2

#define PASSWORD_SEED_FRONT "POLE"
#define PASSWORD_SEED_BACK "Fuck You"

enum _: eLoginTypes
{
	LOGIN_TYPE_NOT_LOGGED_IN,
	LOGIN_TYPE_LEGACY,
	LOGIN_TYPE_SUCCESS
};

new const maxStatAmount[] = {
	5,
	5,
	10,
	5,
	10
};

enum ePlayerInfo {
	pAccountIndex,
	pPassword[MAX_PASSWORD_LENGTH + 1],
	pCash,
	pKill,
	pExp,
	pLevel,
	pUpgStat,
	pUpgDec,
	pUpgPower,
	pUpgMoney,
	pUpgHealth,
	pUpgIntelligence,
	pSubAdmin,
	pTitleType,
	pDeath,
	pSkin,
	pMusicCastAdmin
};

new loggedInEvent;

new playerAccount[MAX_PLAYERS];
new playerLoggedIn[MAX_PLAYERS];
new playerLoginTry[MAX_PLAYERS];
new passwordCheck[MAX_PLAYERS][MAX_PASSWORD_LENGTH + 1];
new saveTime[MAX_PLAYERS];
new luckStat[MAX_PLAYERS];

new playerInfo[MAX_PLAYERS + 1][ePlayerInfo];

forward RequestPlayerAccountCheck(playerid);
forward RequestPlayerAccountRegister(playerid, const password[]);
forward RequestPlayerPasswordChange(playerid, const password[]);
forward RequestPlayerAccountSave(playerid, bool: register = false);
forward RequestPlayerAccountLogin(playerid, const password[]);
forward SavePlayerAccount(playerid, register = 0);
forward bool: IsPlayerHaveAccount(playerid);
forward bool: IsPlayerLoggedIn(playerid);
forward Encrypt(dest[]);
forward GetPlayerAntibody(playerid);
forward UpgradePlayerTitle(playerid);
forward AddPlayerKillCount(playerid);
forward AddPlayerDeathCount(playerid);
forward GetPlayerNextLevelExp(playerid);
forward GivePlayerScore(playerid, amount);
forward ShowPlayerUpgradeStatDialog(playerid);
forward bool: IsPlayerSubAdmin(playerid, level = 1);
forward ShowPlayerInfo(playerid);
forward ShowPlayerChangePasswordDialog(playerid, step = 0);
forward ShowPlayerLuckStatDialog(playerid);

forward OnPlayerAccountCheck(playerid, const player[]);
forward OnPlayerAccountRegister(playerid, const player[]);
forward OnPlayerAccountLogin(playerid, accountIndex);
forward OnPlayerAccountSave(playerid, accountIndex, bool: register);
forward OnPlayerPasswordChange(playerid, accountIndex);

forward A_Core_GameModeExit();
forward A_Core_PlayerConnect(playerid);
forward A_Core_PlayerDisconnect(playerid);
forward A_Core_DialogResponse(playerid, dialogid, response, listitem, const inputtext[]);
forward A_Core_PlayerCommandText(playerid, const command[], const params[]);
forward A_Core_PlayerIntroPaused(playerid, time);
forward A_Core_Player1sTimer(playerid);
forward A_Core_PlayerIntroFinish(playerid);
