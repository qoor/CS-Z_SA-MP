/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Base of account system
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

#include "./CZ/Account/Inc/Core.inc"
#include "./CZ/Util/Inc/Ini.inc"
#include "./CZ/Inc/Intro.inc"
#include "./CZ/Inc/Timer.inc"
#include "./CZ/Inc/TextDraw.inc"
#include "./CZ/Game/Inc/Message.inc"
#include "./CZ/Account/Inc/Migration.inc"

InitModule("Account")
{
	ini_SetPivotChar(':');

	playerInfo[MAX_PLAYERS][pLevel] = 1;
	playerInfo[MAX_PLAYERS][pSkin] = -1;
	
	AddEventHandler(D_GameModeExit, "A_Core_GameModeExit");
	AddEventHandler(D_PlayerConnect, "A_Core_PlayerConnect");
	AddEventHandler(D_PlayerDisconnect, "A_Core_PlayerDisconnect");
	AddEventHandler(D_DialogResponse, "A_Core_DialogResponse");
	AddEventHandler(D_PlayerCommandText, "A_Core_PlayerCommandText");
	AddEventHandler(introPausedEvent, "A_Core_PlayerIntroPaused");
	AddEventHandler(player1sTimer, "A_Core_Player1sTimer");
	AddEventHandler(introFinishEvent, "A_Core_PlayerIntroFinish");

	AddModule("Account_Migration");
}

public A_Core_GameModeExit()
{
	if (!IsServerReboot())
	{
		contloop (new playerid : playerList)
		{
			if (IsPlayerLoggedIn(playerid))
				RequestPlayerAccountSave(playerid);
		}
	}
}

public A_Core_PlayerConnect(playerid)
{
	playerAccount[playerid] = -1;
	playerLoggedIn[playerid] = LOGIN_TYPE_NOT_LOGGED_IN;
	playerLoginTry[playerid] = 0;
	saveTime[playerid] = 0;
	luckStat[playerid] = 0;

	playerInfo[playerid] = playerInfo[MAX_PLAYERS];

	RequestPlayerAccountCheck(playerid);

	return 0;
}

public A_Core_PlayerDisconnect(playerid)
{
	if (IsPlayerLoggedIn(playerid))
		RequestPlayerAccountSave(playerid);

	return 0;
}

public A_Core_DialogResponse(playerid, dialogid, response, listitem, const inputtext[])
{
	switch (dialogid)
	{
	case DIALOG_REGISTER:
		{
			if (response == 0)
			{
				Kick(playerid);

				return 1;
			}

			new length = strlen(inputtext);

			if (length < MIN_PASSWORD_LENGTH || length > MAX_PASSWORD_LENGTH)
			{
				ErrorClientMessage(playerid, "비밀번호는 최소 "#MIN_PASSWORD_LENGTH"자 이상, 최대 "#MAX_PASSWORD_LENGTH"자 이하로 설정하셔야 합니다. 다시 시도해 주세요.");
				ShowPlayerLoginDialog(playerid);

				return 1;
			}

			strcpy(passwordCheck[playerid], inputtext);
			ShowPlayerPasswordCheckDialog(playerid);

			return 1;
		}
	case DIALOG_PASSWORD_CHECK:
		{
			if (response == 0)
			{
				ShowPlayerLoginDialog(playerid);

				return 1;
			}

			if (IsNull(inputtext))
			{
				ShowPlayerPasswordCheckDialog(playerid);

				return 1;
			}

			if (strcmp(passwordCheck[playerid], inputtext) != 0)
			{
				ErrorClientMessage(playerid, "설정하려는 비밀번호와 일치하지 않습니다. 다시 입력해 주세요.");
				ShowPlayerPasswordCheckDialog(playerid);

				return 1;
			}

			RequestPlayerAccountRegister(playerid, inputtext);

			return 1;
		}
	case DIALOG_LOGIN:
		{
			if (response == 0)
			{
				Kick(playerid);

				return 1;
			}

			if (IsNull(inputtext) || strlen(inputtext) > MAX_PASSWORD_LENGTH)
			{
				ShowPlayerLoginDialog(playerid);

				return 1;
			}

			RequestPlayerAccountLogin(playerid, inputtext);

			return 1;
		}
	case DIALOG_UPGRADE_STAT:
		{
			if (response == 0)
				return 1;
			
			if (playerInfo[playerid][pUpgStat] <= 0)
				return ErrorClientMessage(playerid, "스탯 포인트가 없습니다.");
			
			new upgraded;
			
			switch (listitem)
			{
			case 1:
				{
					if (playerInfo[playerid][pUpgDec] < maxStatAmount[0])
					{
						++playerInfo[playerid][pUpgDec];
						upgraded = 1;

						SystemClientMessage(playerid, "민첩이 +1 상승 하였습니다.");
					}
					else
						SystemClientMessage(playerid, "이미 민첩 스탯을 마스터 하였습니다.");
				}
			case 2:
				{
					if (playerInfo[playerid][pUpgPower] < maxStatAmount[1])
					{
						++playerInfo[playerid][pUpgPower];
						upgraded = 1;

						SystemClientMessage(playerid, "힘이 +1 상승 하였습니다.");
					}
					else
						SystemClientMessage(playerid, "이미 민첩 스탯을 마스터 하였습니다.");
				}
			case 3:
				{
					if (playerInfo[playerid][pUpgMoney] < maxStatAmount[2])
					{
						++playerInfo[playerid][pUpgMoney];
						upgraded = 1;

						SystemClientMessage(playerid, "상술이 +1 상승 하였습니다.");
					}
					else
						SystemClientMessage(playerid, "이미 민첩 스탯을 마스터 하였습니다.");
				}
			case 4:
				{
					if (playerInfo[playerid][pUpgHealth] < maxStatAmount[3])
					{
						++playerInfo[playerid][pUpgHealth];
						upgraded = 1;

						SystemClientMessage(playerid, "체력이 +1 상승 하였습니다.");
					}
					else
						SystemClientMessage(playerid, "이미 민첩 스탯을 마스터 하였습니다.");
				}
			case 5:
				{
					if (playerInfo[playerid][pUpgIntelligence] < maxStatAmount[4])
					{
						++playerInfo[playerid][pUpgIntelligence];
						upgraded = 1;

						SystemClientMessage(playerid, "지식이 +1 상승 하였습니다.");
					}
					else
						SystemClientMessage(playerid, "이미 민첩 스탯을 마스터 하였습니다.");
				}
			default:
				ShowPlayerUpgradeStatDialog(playerid);
			}

			if (upgraded != 0)
			{
				if ((--playerInfo[playerid][pUpgStat]) > 0)
					ShowPlayerUpgradeStatDialog(playerid);
				
				SavePlayerAccount(playerid);
			}

			return 1;
		}
	case DIALOG_CHANGE_PASSWORD:
		{
			if (response == 0)
				return 1;
			
			new length = strlen(inputtext);

			if (length < MIN_PASSWORD_LENGTH || length > MAX_PASSWORD_LENGTH)
			{
				ErrorClientMessage(playerid, "비밀번호는 최소 "#MIN_PASSWORD_LENGTH"자 이상, 최대 "#MAX_PASSWORD_LENGTH"자 이하로 설정하셔야 합니다. 다시 시도해 주세요.");
				ShowPlayerChangePasswordDialog(playerid);

				return 1;
			}

			strcpy(passwordCheck[playerid], inputtext);

			ShowPlayerChangePasswordDialog(playerid, 1);

			return 1;
		}
	case DIALOG_CHANGE_PASSWORD + 1:
		{
			if (response == 0)
				return 1;

			if (IsNull(inputtext))
				return ShowPlayerChangePasswordDialog(playerid);

			if (strcmp(inputtext, passwordCheck[playerid], false) != 0)
			{
				ErrorClientMessage(playerid, "설정하려는 비밀번호와 일치하지 않습니다. 다시 입력해 주세요.");
				ShowPlayerChangePasswordDialog(playerid, 1);

				return 1;
			}

			RequestPlayerPasswordChange(playerid, inputtext);

			InfoClientMessage(playerid, "비밀번호를 변경하는 중입니다. 잠시만 기다려 주세요..");

			return 1;
		}
	case DIALOG_LUCK_STAT:
		{
			if (response != 0)
				ShowPlayerLuckStatDialog(playerid);
			
			return 1;
		}
	}

	return 0;
}

public A_Core_PlayerCommandText(playerid, const command[], const params[])
{
	if (strcmp(command, "/sav", true) == 0 || strcmp(command, "/저장") == 0)
		return SystemClientMessage(playerid, "계정은 상황에 맞게 최적화되어 자동으로 저장되므로 해당 명령어를 사용하실 필요가 없습니다.");
	
	if (strcmp(command, "/info") == 0 || strcmp(command, "/내정보") == 0)
	{
		ShowPlayerInfo(playerid);

		return 1;
	}

	if (strcmp(command, "/stat", true) == 0 || strcmp(command, "/스탯") == 0 || strcmp(command, "/스텟") == 0)
	{
		if (playerInfo[playerid][pUpgStat] == 0)
		{
			ErrorClientMessage(playerid, "스탯 포인트가 없습니다.");
			InfoClientMessage(playerid, "레벨업을 하면 스탯 포인트를 받을 수 있습니다.");
			InfoClientMessage(playerid, "계정 정보를 확인하시려면 \"/내정보\"을(를) 입력해 주세요.");

			return 1;
		}

		ShowPlayerUpgradeStatDialog(playerid);

		return 1;
	}

	if (strcmp(command, "/resetstat", true) == 0 || strcmp(command, "/statreset", true) == 0 || strcmp(command, "/스탯초기화") == 0 || strcmp(command, "/스텟초기화") == 0)
	{
		new totalStat = playerInfo[playerid][pUpgDec] + playerInfo[playerid][pUpgPower] + playerInfo[playerid][pUpgMoney] + playerInfo[playerid][pUpgHealth] + playerInfo[playerid][pUpgIntelligence];

		if (totalStat <= 0)
			return ErrorClientMessage(playerid, "초기화 할 스탯이 존재하지 않습니다.");
		
		if (GetPlayerMoney(playerid) < 150000)
			return ErrorClientMessage(playerid, "스탯 초기화를 위해서는 $150,000이 필요합니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		GivePlayerMoney(playerid, -150000);

		playerInfo[playerid][pUpgStat] += totalStat;

		playerInfo[playerid][pUpgDec] = 0;
		playerInfo[playerid][pUpgPower] = 0;
		playerInfo[playerid][pUpgMoney] = 0;
		playerInfo[playerid][pUpgHealth] = 0;
		playerInfo[playerid][pUpgIntelligence] = 0;

		SavePlayerAccount(playerid);

		format(string, sizeof(string), "스탯이 초기화되었습니다. 스탯이 기존 %d에서 %d(으)로 %d만큼 상승하였습니다.", playerInfo[playerid][pUpgStat] - totalStat, playerInfo[playerid][pUpgStat], totalStat);
		SystemClientMessage(playerid, string);

		return 1;
	}

	if (strcmp(command, "/비번변경") == 0 || strcmp(command, "/비밀번호변경") == 0)
	{
		ShowPlayerChangePasswordDialog(playerid);

		return 1;
	}

	if (strcmp(command, "/돈거래") == 0 || strcmp(command, "/돈주기") == 0)
	{
		new string[MAX_MESSAGE_LENGTH];

		if (!GetParamString(string, params, 0))
			return ErrorClientMessage(playerid, "사용법: /돈거래 [플레이어 번호/이름의 부분] [액수]");
		
		new targetid = ReturnUser(string);

		if (!IsPlayerLoggedIn(targetid))
			return ErrorClientMessage(playerid, "접속하지 않았거나 로그인하지 않은 플레이어입니다.");
		
		new amount;

		if (!GetParamInt(amount, params, 1))
			return ErrorClientMessage(playerid, "사용법: /돈거래 [플레이어 번호/이름의 부분] [액수]");
		
		if (amount <= 0 || amount > GetPlayerMoney(playerid))
		{
			format(string, sizeof(string), "유효하지 않은 액수입니다. 거래할 수 있는 금액은 $1 ~ $%d 입니다.", GetPlayerMoney(playerid));
			return ErrorClientMessage(playerid, string);
		}

		GivePlayerMoney(playerid, -amount);
		GivePlayerMoney(targetid, amount);

		format(string, sizeof(string), "%s(id:%d)님이 %s(id:%d)님에게 $%d을(를) 주었습니다.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(targetid), targetid, amount);
		ServerLog(LOG_TYPE_DEAL, string);
		SendAdminMessage(0x00FF00FF, string);

		format(string, sizeof(string), "%s(id:%d)님에게 $%d을(를) 주었습니다.", GetPlayerNameEx(targetid), targetid, amount);
		InfoClientMessage(playerid, string);

		format(string, sizeof(string), "%s(id:%d)님에게서 $%d을(를) 받았습니다.", GetPlayerNameEx(playerid), playerid, amount);
		InfoClientMessage(targetid, string);

		return 1;
	}

	if (strcmp(command, "/운영자") == 0 || strcmp(command, "/영자") == 0)
	{
		if (!IsPlayerAdmin(playerid))
			return ErrorClientMessage(playerid, "RCON 관리자만 사용할 수 있습니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		if (GetParamString(string, params, 0) == 0)
			return ErrorClientMessage(playerid, "사용법: /운(영자) [플레이어 번호/이름의 부분] [권한 레벨]");
		
		new targetid = ReturnUser(string);

		if (!IsPlayerConnected(targetid))
			return ErrorClientMessage(playerid, "접속하지 않은 플레이어입니다.");
		
		new level;

		if (!GetParamInt(level, params, 1))
			return ErrorClientMessage(playerid, "사용법: /운(영자) [플레이어 번호/이름의 부분] [권한 레벨]");
		
		if (level < 0 || level >= 4)
			return ErrorClientMessage(playerid, "권한 레벨은 0~4까지 있습니다.");
		
		playerInfo[targetid][pSubAdmin] = level;

		format(string, sizeof(string), "관리자 %s 님이 %s(id:%d)님의 관리자 레벨을 %d로 설정하였습니다.", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), targetid, level);
		SendClientMessageToAll(0xFFFFFFFF, string);

		return 1;
	}

	if (strcmp(command, "/skin", true) == 0 || strcmp(command, "/스킨구매") == 0 || strcmp(command, "/스킨변경") == 0 || strcmp(command, "/스킨") == 0)
	{
		new requireScore = (playerInfo[playerid][pSkin] == -1) ? 2500 : 100;
		new string[MAX_MESSAGE_LENGTH];

		if (GetPlayerScore(playerid) < requireScore)
		{
			format(string, sizeof(string), "스킨을 구매하려면 스코어 %d이(가) 필요합니다.", requireScore);

			if (requireScore == 2500)
				strcat(string, " 첫 구매 이후부터는 스코어 100으로 구매 가능합니다.");
			
			return ErrorClientMessage(playerid, string);
		}

		new skinid;

		if (!GetParamInt(skinid, params, 0))
			return ErrorClientMessage(playerid, "사용법: /스킨(구매) [스킨 번호]");
		
		if (IsProhibitedSkin(skinid))
			return ErrorClientMessage(playerid, "스킨 번호는 1 ~ 299까지 있으며, CJ와 롤러 스케이트 스킨은 구매가 불가능합니다.");

		playerInfo[playerid][pSkin] = skinid;

		GivePlayerScore(playerid, -requireScore);
		SavePlayerAccount(playerid);

		format(string, sizeof(string), "당신은 스코어 %d을(를) 사용하여 스킨을 %d번 스킨으로 설정하셨습니다.", requireScore, skinid);
		InfoClientMessage(playerid, string);
		
		if (requireScore == 2500)
			NewsClientMessage(playerid, "다음 구매 부터는 스코어 100(으)로 스킨 변경이 가능합니다.");
		
		return ErrorClientMessage(playerid, string);
	}

	return 0;
}

public A_Core_PlayerIntroPaused(playerid, time)
{
	if (time == 5)
	{
		if (playerAccount[playerid] >= 0)
			ResumePlayerIntro(playerid);
	}
	else if (time == 13)
	{
		// Chicken game
		if (IsPlayerChicken(playerid))
		{
			SystemClientMessage(playerid, "로그인 하려면 채팅으로 \"쿠우님 죄송합니다.\"를 정확히 입력해라.");
		}
		else
		{
			ShowPlayerLoginDialog(playerid);
		}
	}

	return 0;
}

public A_Core_Player1sTimer(playerid)
{
	if (saveTime[playerid] != 0 && IsPlayerLoggedIn(playerid))
	{
		if ((--saveTime[playerid]) == 0)
			RequestPlayerAccountSave(playerid);
	}

	return 0;
}

public A_Core_PlayerIntroFinish(playerid)
{
	TextDrawShowForPlayer(playerid, moneyText[playerid]);
}

function RequestPlayerAccountCheck(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;

	return 1;
}

public OnPlayerAccountCheck(playerid, const player[])
{
	if (!IsPlayerConnected(playerid) || strcmp(GetPlayerNameEx(playerid), player, true) != 0)
		return;
	
	new errno = mysql_errno(MySQL);

	if (errno != 0)
	{
		ServerLog(LOG_TYPE_MYSQL, "계정 조회에 오류가 발생했습니다.", errno);

		RequestPlayerAccountCheck(playerid);

		return;
	}

	new bool: haveAccount = (cache_num_rows() > 0);

	if (haveAccount)
	{
		new nameData[MAX_PLAYER_NAME];

		cache_get_value_name(0, "Name", nameData);

		if (IsNull(nameData) || strcmp(nameData, "NULL", true) == 0 || strcmp(player, nameData, true) != 0)
		{
			RequestPlayerAccountCheck(playerid);

			return;
		}
	}

	playerAccount[playerid] = haveAccount;

	if (IsPlayerIntroPaused(playerid))
		ResumePlayerIntro(playerid);
}

function RequestPlayerAccountRegister(playerid, const password[])
{
	if (!IsPlayerConnected(playerid) || IsPlayerLoggedIn(playerid))
		return 0;

	return 1;
}

public OnPlayerAccountRegister(playerid, const player[])
{
	if (!IsPlayerConnected(playerid) || strcmp(player, GetPlayerNameEx(playerid), true) != 0)
		return;
	
	new index = cache_insert_id();
	new errno = mysql_errno(MySQL);
	new bool: migration = (playerLoggedIn[playerid] == LOGIN_TYPE_LEGACY);

	if (index == 0 || errno != 0)
	{
		ServerLog(LOG_TYPE_MYSQL, "계정을 생성할 수 없습니다.", errno);

		ErrorClientMessage(playerid, "계정 생성을 실패했습니다. 다시 시도해 주세요.");

		if (!migration)
		{
			ErrorClientMessage(playerid, "계정 생성을 실패했습니다. 다시 시도해 주세요.");
			ShowPlayerLoginDialog(playerid);
		}
		else
		{
			ErrorClientMessage(playerid, "계정 이동을 실패했습니다. 다시 시도해 주세요.");
			ShowPlayerMigrationDialog(playerid);
		}

		return;
	}

	playerInfo[playerid][pAccountIndex] = index;

	RequestPlayerAccountSave(playerid, true);
}

function RequestPlayerPasswordChange(playerid, const password[])
{
	if (!IsPlayerConnected(playerid) || !IsPlayerLoggedIn(playerid))
		return 0;

	return 1;
}

public OnPlayerPasswordChange(playerid, accountIndex)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerLoggedIn(playerid) || accountIndex != playerInfo[playerid][pAccountIndex])
		return;
	
	new errno = mysql_errno(MySQL);

	if (errno != 0 || cache_affected_rows() == 0)
	{
		ServerLog(LOG_TYPE_MYSQL, "계정 비밀번호 변경에 오류가 발생했습니다.", (errno != 0) ? errno : -1);

		ErrorClientMessage(playerid, "계정 비밀번호 변경에 오류가 발생했습니다. 다시 시도해주세요.");
		ShowPlayerChangePasswordDialog(playerid);

		return;
	}
	
	SystemClientMessage(playerid, "성공적으로 비밀번호를 변경하였습니다.");
}

function RequestPlayerAccountSave(playerid, bool: register = false)
{
	if (!IsPlayerConnected(playerid) || (!register && !IsPlayerLoggedIn(playerid)))
		return 0;
	
	// WARNING!
	// If you want save string data, SHOULD use %e format of mysql_format function.
	// Ex: mysql_format(MySQL, query, sizeof(query), "%s,Example='%e'", query, example);

	return 1;
}

public OnPlayerAccountSave(playerid, accountIndex, bool: register)
{
	if (!IsPlayerConnected(playerid) || accountIndex != playerInfo[playerid][pAccountIndex] || (!register && !IsPlayerLoggedIn(playerid)))
		return;
	
	new errno = mysql_errno(MySQL);

	if (errno != 0 || cache_affected_rows() == 0)
	{
		ServerLog(LOG_TYPE_MYSQL, "계정 저장에 오류가 발생했습니다.", (errno != 0) ? errno : -1);

		RequestPlayerAccountSave(playerid, register);
		
		return;
	}
	
	if (register)
	{
		new bool: migration = (playerLoggedIn[playerid] == LOGIN_TYPE_LEGACY);

		passwordCheck[playerid] = "";
		playerAccount[playerid] = 1;

		if (!migration)
			InfoClientMessage(playerid, "계정 생성이 완료되었습니다! 가입하신 계정으로 로그인 해주세요.");
		else
			InfoClientMessage(playerid, "계정 이동이 완료되었습니다! 등록하신 비밀번호를 입력하여 로그인 해주세요.");

		RemovePlayerLegacyAccount(playerid);
		
		ShowPlayerLoginDialog(playerid);
	}
}

function RequestPlayerAccountLogin(playerid, const password[])
{
	if (!IsPlayerConnected(playerid) || !IsPlayerHaveAccount(playerid) || IsPlayerLoggedIn(playerid))
		return 0;

	return 1;
}

public OnPlayerAccountLogin(playerid, accountIndex)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerHaveAccount(playerid) || IsPlayerLoggedIn(playerid) || accountIndex != playerInfo[playerid][pAccountIndex])
		return;
	
	new errno = mysql_errno(MySQL);

	if (errno != 0 || cache_num_rows() <= 0)
	{
		ServerLog(LOG_TYPE_MYSQL, "계정 로그인에 오류가 발생했습니다.", (errno != 0) ? errno : -1);

		ErrorClientMessage(playerid, "계정 로그인에 오류가 발생했습니다. 다시 로그인 해주세요.");
		ShowPlayerLoginDialog(playerid);

		return;
	}

	if (playerInfo[playerid][pSkin] == 0)
		playerInfo[playerid][pSkin] = -1;

	playerLoggedIn[playerid] = LOGIN_TYPE_SUCCESS;

	old_SetPlayerScore(playerid, playerInfo[playerid][pKill]);
	UpdatePlayerMoneyText(playerid);

	TriggerEventNoSuspend(loggedInEvent, "i", playerid);

	ResumePlayerIntro(playerid);
}

function SavePlayerAccount(playerid, register = 0)
{
	if (!IsPlayerConnected(playerid) || (register == 0 && !IsPlayerLoggedIn(playerid)))
		return 0;
	
	if (!register)
	{
		if (saveTime[playerid] != 0)
			saveTime[playerid] = SAVE_COOL_TIME;
	}
	else
		RequestPlayerAccountSave(playerid, true);

	return 1;
}

function bool: IsPlayerHaveAccount(playerid)
{
	return (IsPlayerConnected(playerid) && playerAccount[playerid] > 0);
}

function bool: IsPlayerLoggedIn(playerid)
{
	return (IsPlayerConnected(playerid) && playerAccount[playerid] > 0 && playerLoggedIn[playerid] > 1);
}

function ShowPlayerLoginDialog(playerid)
{
	if (!IsPlayerConnected(playerid) || playerAccount[playerid] == -1 || IsPlayerLoggedIn(playerid))
		return 0;

	if (!IsPlayerHaveAccount(playerid))
	{
		if (!IsPlayerHaveLegacyAccount(playerid))
		{
			ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{FF9900}카스 좀비 : {FFFFFF}계정 생성",
				"{FF9900}카스 좀비{FFFFFF} 서버에 오신걸 환영합니다.\n{FF9900}계정{FFFFFF}이 존재하지 않으니 {FF9900}비밀번호{FFFFFF}를 입력후 {FF9900}확인 버튼{FFFFFF}을 누르시기 바랍니다.\n\
				비밀번호는 {FF9900}"#MIN_PASSWORD_LENGTH"자 이상 "#MAX_PASSWORD_LENGTH"자 이하{FFFFFF}로 설정해주세요.",
				"확인", "종료");
		}
		else
			ShowPlayerMigrationDialog(playerid); // Pass to Migration module
	}
	else
	{
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{FF9900}카스 좀비 : {FFFFFF}계정 로그인",
			"{FFFFFF}이미 만드신 {FF9900}계정{FFFFFF}이 존재합니다.\n{FF9900}비밀번호{FFFFFF}를 입력후 {FF9900}게정 로그인 버튼{FFFFFF}을 누르시기 바랍니다.",
			"로그인", "종료");
	}

	return 1;
}

function ShowPlayerPasswordCheckDialog(playerid)
{
	if (!IsPlayerConnected(playerid) || IsPlayerHaveAccount(playerid) || IsPlayerLoggedIn(playerid))
		return 0;
	
	ShowPlayerDialog(playerid, DIALOG_PASSWORD_CHECK, DIALOG_STYLE_PASSWORD, "{FF9900}카스 좀비 : {FFFFFF}계정 생성",
			"{FFFFFF}입력하신 {FF9900}비밀번호{FFFFFF}를 다시 한번 입력 후 {FF9900}계정 등록 버튼{FFFFFF}을 누르시길 바랍니다.",
			"등록", "이전");

	return 1;
}

function Encrypt(dest[])
{
	for (new i = 0, len = strlen(dest); i < len; ++i)
	{
		dest[i] += (3 ^ i) * (i % 15);

		if (dest[i] > 0xFF)
			dest[i] -= 64;
	}
}

function GetPlayerAntibody(playerid)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	return ((playerInfo[playerid][pKill] - playerInfo[playerid][pDeath]) * 10);
}

function UpgradePlayerTitle(playerid)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	++playerInfo[playerid][pTitleType];

	SavePlayerAccount(playerid);

	return 1;
}

function AddPlayerKillCount(playerid)
{
	GivePlayerScore(playerid, 1);
	
	if ((++playerInfo[playerid][pExp]) >= GetPlayerNextLevelExp(playerid))
	{
		new string[MAX_MESSAGE_LENGTH];

		playerInfo[playerid][pExp] = 0;
		++playerInfo[playerid][pLevel];
		++playerInfo[playerid][pUpgStat];

		format(string, sizeof(string), "[ Big News ] %s (%d){FFFFFF}님께서 {FF0000}Lv. %d {FFFFFF}로 레벨업 되었습니다.", GetPlayerNameEx(playerid), playerid, playerInfo[playerid][pLevel]);
		SendClientMessageToAll(0xFF0000FF, string);

		SystemClientMessage(playerid, "레벨이 상승하였습니다!");
		InfoClientMessage(playerid, "\"/스탯\" 명령어를 통해 능력치를 상승시킬 수 있습니다!");
	}

	SavePlayerAccount(playerid);

	return 1;
}

function AddPlayerDeathCount(playerid)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	++playerInfo[playerid][pDeath];

	SavePlayerAccount(playerid);

	return 1;
}

function GetPlayerNextLevelExp(playerid)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	return (playerInfo[playerid][pLevel] * 5 * (playerInfo[playerid][pLevel] + 1));
}

function GivePlayerScore(playerid, amount)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	playerInfo[playerid][pKill] += amount;

	old_SetPlayerScore(playerid, playerInfo[playerid][pKill]);
	SavePlayerAccount(playerid);

	return 1;
}

function ShowPlayerUpgradeStatDialog(playerid)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	new string[1024];

	format(string, sizeof(string), "당신의 스탯 포인트: %d\n", playerInfo[playerid][pUpgStat]);
	format(string, sizeof(string), "%s{FFFF00}민첩 +1 {FF0000}[%d/%d]\n", string, playerInfo[playerid][pUpgDec], maxStatAmount[0]);
	format(string, sizeof(string), "%s{FFFF00}힘 +1 {FF0000}[%d/%d]\n", string, playerInfo[playerid][pUpgPower], maxStatAmount[1]);
	format(string, sizeof(string), "%s{FFFF00}상술 +1 {FF0000}[%d/%d]\n", string, playerInfo[playerid][pUpgMoney], maxStatAmount[2]);
	format(string, sizeof(string), "%s{FFFF00}체력 +1 {FF0000}[%d/%d]\n", string, playerInfo[playerid][pUpgHealth], maxStatAmount[3]);
	format(string, sizeof(string), "%s{FFFF00}지식 +1 {FF0000}[%d/%d]\n", string, playerInfo[playerid][pUpgIntelligence], maxStatAmount[4]);

	ShowPlayerDialog(playerid, DIALOG_UPGRADE_STAT, DIALOG_STYLE_LIST, "스탯 업그레이드", string, "업그레이드", "취소");

	return 1;
}

function bool: IsPlayerSubAdmin(playerid, level = 1)
{
	return (IsPlayerLoggedIn(playerid) && playerInfo[playerid][pSubAdmin] >= level);
}

function ShowPlayerInfo(playerid)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	new string[256];

	format(string, sizeof(string), "{FF0000}%s {FFFF00}님의 정보\n\
		{FF0000}Lv.%d\n\
		{FFFF00}민첩 : {FF0000}%d \n\
		{FFFF00}힘 : {FF0000}%d\n\
		{FFFF00}상술 : {FF0000}%d\n\
		{FFFF00}체력 : {FF0000}%d\n\
		{FFFF00}지식 : {FF0000}%d",
		GetPlayerNameEx(playerid), playerInfo[playerid][pLevel], playerInfo[playerid][pUpgDec], playerInfo[playerid][pUpgPower], playerInfo[playerid][pUpgMoney], playerInfo[playerid][pUpgHealth],
		playerInfo[playerid][pUpgIntelligence]
	);
	ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, "내정보", string, "확인", "");

	return 1;
}

function ShowPlayerChangePasswordDialog(playerid, step = 0)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	if (step == 0)
		ShowPlayerDialog(playerid, DIALOG_CHANGE_PASSWORD, DIALOG_STYLE_PASSWORD, "비밀번호 변경",
			"{FFFFFF}변경하실 비밀번호를 입력해 주세요.\n비밀번호는 최소 "#MIN_PASSWORD_LENGTH"이상, 최대 "#MAX_PASSWORD_LENGTH"이하로 설정해야 합니다.", "확인", "취소");
	else
		ShowPlayerDialog(playerid, DIALOG_CHANGE_PASSWORD + 1, DIALOG_STYLE_PASSWORD, "비밀번호 확인",
			"{FFFFFF}입력하신 비밀번호를 다시 입력해 주세요.", "변경", "이전");
	
	return 1;
}

function ShowPlayerLuckStatDialog(playerid)
{
	if (!IsPlayerConnected(playerid) || luckStat[playerid] == 0)
		return 0;
	
	new string[256];

	format(string, sizeof(string), "운 스탯은 더이상 존재하지 않습니다. 기존 운 스탯 %d만큼 스탯 포인트가 적립되었습니다.", luckStat[playerid]);
	ShowPlayerDialog(playerid, DIALOG_LUCK_STAT, DIALOG_STYLE_MSGBOX, "스탯 안내", string, "다시보기", "확인");

	return 1;
}
