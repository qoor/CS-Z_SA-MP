/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Runtime migrating file-based account to DBMS account
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

#include "./CZ/Account/Inc/Migration.inc"

InitModule("Account_Migration")
{
	AddEventHandler(D_PlayerConnect, "A_Migration_PlayerConnect");
	AddEventHandler(D_DialogResponse, "A_Migration_DialogResponse");
}

public A_Migration_PlayerConnect(playerid)
{
	CheckPlayerLegacyAccount(playerid);

	return 0;
}

public A_Migration_DialogResponse(playerid, dialogid, response, listitem, const inputtext[])
{
	if (dialogid == DIALOG_MIGRATION)
	{
		if (!response)
		{
			ErrorClientMessage(playerid, "계정을 이동하지 않으면 서버를 이용할 수 없습니다.");
			Kick(playerid);

			return 1;
		}

		if (IsNull(inputtext))
		{
			ShowPlayerMigrationDialog(playerid);

			return 1;
		}

		new encryptedPassword[MAX_PASSWORD_LENGTH];

		strcpy(encryptedPassword, inputtext);
		Encrypt(encryptedPassword);
		LoginPlayerLegacyAccount(playerid, encryptedPassword);

		return 1;
	}
	if (dialogid == DIALOG_MIGRATION + 1)
	{
		if (!response)
		{
			ErrorClientMessage(playerid, "계정을 이동하지 않으면 서버를 이용할 수 없습니다.");
			Kick(playerid);

			return 1;
		}

		new length = strlen(inputtext);

		if (length < MIN_PASSWORD_LENGTH || length > MAX_PASSWORD_LENGTH)
		{
			ErrorClientMessage(playerid, "비밀번호는 "#MIN_PASSWORD_LENGTH"자 이상 "#MAX_PASSWORD_LENGTH"자 이하로 설정해주세요.");
			ShowPlayerMigrationDialog(playerid, 1);

			return 1;
		}

		strcpy(passwordCheck[playerid], inputtext);

		ShowPlayerMigrationDialog(playerid, 2);

		return 1;
	}
	else if (dialogid == DIALOG_MIGRATION + 2)
	{
		if (!response)
		{
			ShowPlayerMigrationDialog(playerid, 1);

			return 1;
		}

		if (IsNull(inputtext) || strlen(inputtext) > MAX_PASSWORD_LENGTH)
		{
			ShowPlayerMigrationDialog(playerid, 2);

			return 1;
		}

		if (strcmp(passwordCheck[playerid], inputtext, false) != 0)
		{
			ErrorClientMessage(playerid, "비밀번호가 일치하지 않습니다. 다시 확인해주세요.");
			ShowPlayerMigrationDialog(playerid, 2);

			return 1;
		}

		passwordCheck[playerid] = "";

		RequestPlayerAccountRegister(playerid, inputtext);

		InfoClientMessage(playerid, "계정을 이동하는 중입니다. 잠시만 기다려 주세요..");

		return 1;
	}

	return 0;
}

function CheckPlayerLegacyAccount(playerid)
{
	if (!IsPlayerConnected(playerid) || IsPlayerHaveAccount(playerid))
		return 0;
	
	new string[128];

	format(string, sizeof(string), ""ACCOUNT_PATH"/%s.PWN", GetPlayerNameEx(playerid));

	legacyAccountHave[playerid] = bool: fexist(string);

	return 1;
}

function LoginPlayerLegacyAccount(playerid, const password[])
{
	if (!IsPlayerConnected(playerid) || !legacyAccountHave[playerid] || IsPlayerHaveAccount(playerid) || IsPlayerLoggedIn(playerid))
		return -1;
	
	new string[128];
	new File: file;
	new key[32], value[128];
	new luck;

	format(string, sizeof(string), ""ACCOUNT_PATH"/%s.PWN", GetPlayerNameEx(playerid));

	if (!fexist(string))
		return -1;

	file = fopen(string, io_read);

	fread(file, string);
	ini_GetKey(string, key);

	if (IsNull(key) || strcmp(key, "Password", true) != 0)
	{
		fclose(file);

		return -1;
	}

	ini_GetValue(string, value);

	if (IsNull(value))
	{
		fclose(file);

		return 0;
	}

	if (strcmp(value, password) != 0)
	{
		fclose(file);

		if ((++playerLoginTry[playerid]) >= MAX_LOGIN_TRY)
		{
			ErrorClientMessage(playerid, "비밀번호가 "#MAX_LOIGN_TRY"번 일치하지 않아 접속이 종료됩니다.");
			Kick(playerid);
		}
		else
		{
			format(string, sizeof(string), "비밀번호가 일치하지 않습니다. %d번 이상 실패 시 접속이 종료됩니다.", MAX_LOGIN_TRY - playerLoginTry[playerid]);
			ErrorClientMessage(playerid, string);
			ShowPlayerMigrationDialog(playerid);
		}

		return 0;
	}

	//strcpy(playerInfo[playerid][pPassword], value, MAX_PASSWORD_LENGTH + 1);

	while (fread(file, string))
	{
		if (IsNull(string))
			continue;
		
		ini_GetKey(string, key);

		if (IsNull(key))
			continue;
		
		if (strcmp(key, "Cash", true) == 0) playerInfo[playerid][pCash] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Kill", true) == 0) playerInfo[playerid][pKill] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Exp", true) == 0) playerInfo[playerid][pExp] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Level", true) == 0) playerInfo[playerid][pLevel] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Stat", true) == 0) playerInfo[playerid][pUpgStat] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Dec", true) == 0) playerInfo[playerid][pUpgDec] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Luck", true) == 0) luck = ini_GetValueInt(string, value);
		else if (strcmp(key, "Power", true) == 0) playerInfo[playerid][pUpgPower] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Money", true) == 0) playerInfo[playerid][pUpgMoney] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Health", true) == 0) playerInfo[playerid][pUpgHealth] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Know", true) == 0) playerInfo[playerid][pUpgIntelligence] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Sub", true) == 0) playerInfo[playerid][pSubAdmin] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Fam", true) == 0) playerInfo[playerid][pTitleType] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Death", true) == 0) playerInfo[playerid][pDeath] = ini_GetValueInt(string, value);
		else if (strcmp(key, "Skin", true) == 0) playerInfo[playerid][pSkin] = ini_GetValueInt(string, value);
		else if (strcmp(key, "MusicCastAdmin", true) == 0) playerInfo[playerid][pMusicCastAdmin] = ini_GetValueInt(string, value);
	}

	fclose(file);

	if (playerInfo[playerid][pSkin] == 0)
		playerInfo[playerid][pSkin] = -1;

	playerLoggedIn[playerid] = LOGIN_TYPE_LEGACY;

	if (luck > 0)
	{
		luckStat[playerid] = luck;
		playerInfo[playerid][pUpgStat] += luck;

		/*SavePlayerAccount(playerid);

		ShowPlayerLuckStatDialog(playerid);*/
	}

	/*old_SetPlayerScore(playerid, playerInfo[playerid][pKill]);
	UpdatePlayerMoneyText(playerid);

	TriggerEventNoSuspend(loggedInEvent, "i", playerid);*/

	ShowPlayerMigrationDialog(playerid, 1);

	/*SpawnPlayer(playerid);
	ResumePlayerIntro(playerid);*/

	return 1;
}

function ShowPlayerMigrationDialog(playerid, step = 0)
{
	if (!IsPlayerConnected(playerid) || (step > 0 && playerLoggedIn[playerid] != LOGIN_TYPE_LEGACY))
		return;
	
	if (step == 0)
	{
		ShowPlayerDialog(playerid, DIALOG_MIGRATION, DIALOG_STYLE_PASSWORD, "{FF9900}카스 좀비 : {FFFFFF}계정 이동",
			"{FF9900}파일 시스템 기반 {FFFFFF}계정 시스템에서 {FF9900}MariaDB 데이터베이스 기반 {FFFFFF}계정 시스템으로 개편되었습니다.\n\
			{FF9900}기존 계정의 비밀번호{FFFFFF}를 입력하여 로그인 해주세요.", "로그인", "종료");
	}
	else if (step == 1)
	{
		ShowPlayerDialog(playerid, DIALOG_MIGRATION + 1, DIALOG_STYLE_PASSWORD, "{FF9900}카스 좀비 : {FFFFFF}계정 이동", "{FF9900}새로 사용하실 비밀번호{FFFFFF}를 입력해주세요.\n\
			비밀번호는 {FF9900}"#MIN_PASSWORD_LENGTH"자 이상 "#MAX_PASSWORD_LENGTH"자 이하{FFFFFF}로 설정해주세요.", "다음", "종료");
	}
	else if (step == 2)
	{
		ShowPlayerDialog(playerid, DIALOG_MIGRATION + 2, DIALOG_STYLE_PASSWORD, "{FF9900}카스 좀비 : {FFFFFF}계정 이동",
			"{FFFFFF}입력하신 비밀번호를 {FF9900}다시 한 번 {FFFFFF}입력해주세요.", "완료", "이전");
	}
}

function bool: IsPlayerHaveLegacyAccount(playerid)
{
	return (IsPlayerConnected(playerid) && legacyAccountHave[playerid]);
}

function RemovePlayerLegacyAccount(playerid)
{
	if (!IsPlayerConnected(playerid) || !legacyAccountHave[playerid])
		return 0;

	new path[128];

	format(path, sizeof(path), ""ACCOUNT_PATH"/%s.PWN", GetPlayerNameEx(playerid));
	fremove(path);

	legacyAccountHave[playerid] = false;

	return 1;
}
