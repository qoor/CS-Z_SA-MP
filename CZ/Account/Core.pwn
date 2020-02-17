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
				ErrorClientMessage(playerid, "��й�ȣ�� �ּ� "#MIN_PASSWORD_LENGTH"�� �̻�, �ִ� "#MAX_PASSWORD_LENGTH"�� ���Ϸ� �����ϼž� �մϴ�. �ٽ� �õ��� �ּ���.");
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
				ErrorClientMessage(playerid, "�����Ϸ��� ��й�ȣ�� ��ġ���� �ʽ��ϴ�. �ٽ� �Է��� �ּ���.");
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
				return ErrorClientMessage(playerid, "���� ����Ʈ�� �����ϴ�.");
			
			new upgraded;
			
			switch (listitem)
			{
			case 1:
				{
					if (playerInfo[playerid][pUpgDec] < maxStatAmount[0])
					{
						++playerInfo[playerid][pUpgDec];
						upgraded = 1;

						SystemClientMessage(playerid, "��ø�� +1 ��� �Ͽ����ϴ�.");
					}
					else
						SystemClientMessage(playerid, "�̹� ��ø ������ ������ �Ͽ����ϴ�.");
				}
			case 2:
				{
					if (playerInfo[playerid][pUpgPower] < maxStatAmount[1])
					{
						++playerInfo[playerid][pUpgPower];
						upgraded = 1;

						SystemClientMessage(playerid, "���� +1 ��� �Ͽ����ϴ�.");
					}
					else
						SystemClientMessage(playerid, "�̹� ��ø ������ ������ �Ͽ����ϴ�.");
				}
			case 3:
				{
					if (playerInfo[playerid][pUpgMoney] < maxStatAmount[2])
					{
						++playerInfo[playerid][pUpgMoney];
						upgraded = 1;

						SystemClientMessage(playerid, "����� +1 ��� �Ͽ����ϴ�.");
					}
					else
						SystemClientMessage(playerid, "�̹� ��ø ������ ������ �Ͽ����ϴ�.");
				}
			case 4:
				{
					if (playerInfo[playerid][pUpgHealth] < maxStatAmount[3])
					{
						++playerInfo[playerid][pUpgHealth];
						upgraded = 1;

						SystemClientMessage(playerid, "ü���� +1 ��� �Ͽ����ϴ�.");
					}
					else
						SystemClientMessage(playerid, "�̹� ��ø ������ ������ �Ͽ����ϴ�.");
				}
			case 5:
				{
					if (playerInfo[playerid][pUpgIntelligence] < maxStatAmount[4])
					{
						++playerInfo[playerid][pUpgIntelligence];
						upgraded = 1;

						SystemClientMessage(playerid, "������ +1 ��� �Ͽ����ϴ�.");
					}
					else
						SystemClientMessage(playerid, "�̹� ��ø ������ ������ �Ͽ����ϴ�.");
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
				ErrorClientMessage(playerid, "��й�ȣ�� �ּ� "#MIN_PASSWORD_LENGTH"�� �̻�, �ִ� "#MAX_PASSWORD_LENGTH"�� ���Ϸ� �����ϼž� �մϴ�. �ٽ� �õ��� �ּ���.");
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
				ErrorClientMessage(playerid, "�����Ϸ��� ��й�ȣ�� ��ġ���� �ʽ��ϴ�. �ٽ� �Է��� �ּ���.");
				ShowPlayerChangePasswordDialog(playerid, 1);

				return 1;
			}

			RequestPlayerPasswordChange(playerid, inputtext);

			InfoClientMessage(playerid, "��й�ȣ�� �����ϴ� ���Դϴ�. ��ø� ��ٷ� �ּ���..");

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
	if (strcmp(command, "/sav", true) == 0 || strcmp(command, "/����") == 0)
		return SystemClientMessage(playerid, "������ ��Ȳ�� �°� ����ȭ�Ǿ� �ڵ����� ����ǹǷ� �ش� ��ɾ ����Ͻ� �ʿ䰡 �����ϴ�.");
	
	if (strcmp(command, "/info") == 0 || strcmp(command, "/������") == 0)
	{
		ShowPlayerInfo(playerid);

		return 1;
	}

	if (strcmp(command, "/stat", true) == 0 || strcmp(command, "/����") == 0 || strcmp(command, "/����") == 0)
	{
		if (playerInfo[playerid][pUpgStat] == 0)
		{
			ErrorClientMessage(playerid, "���� ����Ʈ�� �����ϴ�.");
			InfoClientMessage(playerid, "�������� �ϸ� ���� ����Ʈ�� ���� �� �ֽ��ϴ�.");
			InfoClientMessage(playerid, "���� ������ Ȯ���Ͻ÷��� \"/������\"��(��) �Է��� �ּ���.");

			return 1;
		}

		ShowPlayerUpgradeStatDialog(playerid);

		return 1;
	}

	if (strcmp(command, "/resetstat", true) == 0 || strcmp(command, "/statreset", true) == 0 || strcmp(command, "/�����ʱ�ȭ") == 0 || strcmp(command, "/�����ʱ�ȭ") == 0)
	{
		new totalStat = playerInfo[playerid][pUpgDec] + playerInfo[playerid][pUpgPower] + playerInfo[playerid][pUpgMoney] + playerInfo[playerid][pUpgHealth] + playerInfo[playerid][pUpgIntelligence];

		if (totalStat <= 0)
			return ErrorClientMessage(playerid, "�ʱ�ȭ �� ������ �������� �ʽ��ϴ�.");
		
		if (GetPlayerMoney(playerid) < 150000)
			return ErrorClientMessage(playerid, "���� �ʱ�ȭ�� ���ؼ��� $150,000�� �ʿ��մϴ�.");
		
		new string[MAX_MESSAGE_LENGTH];

		GivePlayerMoney(playerid, -150000);

		playerInfo[playerid][pUpgStat] += totalStat;

		playerInfo[playerid][pUpgDec] = 0;
		playerInfo[playerid][pUpgPower] = 0;
		playerInfo[playerid][pUpgMoney] = 0;
		playerInfo[playerid][pUpgHealth] = 0;
		playerInfo[playerid][pUpgIntelligence] = 0;

		SavePlayerAccount(playerid);

		format(string, sizeof(string), "������ �ʱ�ȭ�Ǿ����ϴ�. ������ ���� %d���� %d(��)�� %d��ŭ ����Ͽ����ϴ�.", playerInfo[playerid][pUpgStat] - totalStat, playerInfo[playerid][pUpgStat], totalStat);
		SystemClientMessage(playerid, string);

		return 1;
	}

	if (strcmp(command, "/�������") == 0 || strcmp(command, "/��й�ȣ����") == 0)
	{
		ShowPlayerChangePasswordDialog(playerid);

		return 1;
	}

	if (strcmp(command, "/���ŷ�") == 0 || strcmp(command, "/���ֱ�") == 0)
	{
		new string[MAX_MESSAGE_LENGTH];

		if (!GetParamString(string, params, 0))
			return ErrorClientMessage(playerid, "����: /���ŷ� [�÷��̾� ��ȣ/�̸��� �κ�] [�׼�]");
		
		new targetid = ReturnUser(string);

		if (!IsPlayerLoggedIn(targetid))
			return ErrorClientMessage(playerid, "�������� �ʾҰų� �α������� ���� �÷��̾��Դϴ�.");
		
		new amount;

		if (!GetParamInt(amount, params, 1))
			return ErrorClientMessage(playerid, "����: /���ŷ� [�÷��̾� ��ȣ/�̸��� �κ�] [�׼�]");
		
		if (amount <= 0 || amount > GetPlayerMoney(playerid))
		{
			format(string, sizeof(string), "��ȿ���� ���� �׼��Դϴ�. �ŷ��� �� �ִ� �ݾ��� $1 ~ $%d �Դϴ�.", GetPlayerMoney(playerid));
			return ErrorClientMessage(playerid, string);
		}

		GivePlayerMoney(playerid, -amount);
		GivePlayerMoney(targetid, amount);

		format(string, sizeof(string), "%s(id:%d)���� %s(id:%d)�Կ��� $%d��(��) �־����ϴ�.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(targetid), targetid, amount);
		ServerLog(LOG_TYPE_DEAL, string);
		SendAdminMessage(0x00FF00FF, string);

		format(string, sizeof(string), "%s(id:%d)�Կ��� $%d��(��) �־����ϴ�.", GetPlayerNameEx(targetid), targetid, amount);
		InfoClientMessage(playerid, string);

		format(string, sizeof(string), "%s(id:%d)�Կ��Լ� $%d��(��) �޾ҽ��ϴ�.", GetPlayerNameEx(playerid), playerid, amount);
		InfoClientMessage(targetid, string);

		return 1;
	}

	if (strcmp(command, "/���") == 0 || strcmp(command, "/����") == 0)
	{
		if (!IsPlayerAdmin(playerid))
			return ErrorClientMessage(playerid, "RCON �����ڸ� ����� �� �ֽ��ϴ�.");
		
		new string[MAX_MESSAGE_LENGTH];

		if (GetParamString(string, params, 0) == 0)
			return ErrorClientMessage(playerid, "����: /��(����) [�÷��̾� ��ȣ/�̸��� �κ�] [���� ����]");
		
		new targetid = ReturnUser(string);

		if (!IsPlayerConnected(targetid))
			return ErrorClientMessage(playerid, "�������� ���� �÷��̾��Դϴ�.");
		
		new level;

		if (!GetParamInt(level, params, 1))
			return ErrorClientMessage(playerid, "����: /��(����) [�÷��̾� ��ȣ/�̸��� �κ�] [���� ����]");
		
		if (level < 0 || level >= 4)
			return ErrorClientMessage(playerid, "���� ������ 0~4���� �ֽ��ϴ�.");
		
		playerInfo[targetid][pSubAdmin] = level;

		format(string, sizeof(string), "������ %s ���� %s(id:%d)���� ������ ������ %d�� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), targetid, level);
		SendClientMessageToAll(0xFFFFFFFF, string);

		return 1;
	}

	if (strcmp(command, "/skin", true) == 0 || strcmp(command, "/��Ų����") == 0 || strcmp(command, "/��Ų����") == 0 || strcmp(command, "/��Ų") == 0)
	{
		new requireScore = (playerInfo[playerid][pSkin] == -1) ? 2500 : 100;
		new string[MAX_MESSAGE_LENGTH];

		if (GetPlayerScore(playerid) < requireScore)
		{
			format(string, sizeof(string), "��Ų�� �����Ϸ��� ���ھ� %d��(��) �ʿ��մϴ�.", requireScore);

			if (requireScore == 2500)
				strcat(string, " ù ���� ���ĺ��ʹ� ���ھ� 100���� ���� �����մϴ�.");
			
			return ErrorClientMessage(playerid, string);
		}

		new skinid;

		if (!GetParamInt(skinid, params, 0))
			return ErrorClientMessage(playerid, "����: /��Ų(����) [��Ų ��ȣ]");
		
		if (IsProhibitedSkin(skinid))
			return ErrorClientMessage(playerid, "��Ų ��ȣ�� 1 ~ 299���� ������, CJ�� �ѷ� ������Ʈ ��Ų�� ���Ű� �Ұ����մϴ�.");

		playerInfo[playerid][pSkin] = skinid;

		GivePlayerScore(playerid, -requireScore);
		SavePlayerAccount(playerid);

		format(string, sizeof(string), "����� ���ھ� %d��(��) ����Ͽ� ��Ų�� %d�� ��Ų���� �����ϼ̽��ϴ�.", requireScore, skinid);
		InfoClientMessage(playerid, string);
		
		if (requireScore == 2500)
			NewsClientMessage(playerid, "���� ���� ���ʹ� ���ھ� 100(��)�� ��Ų ������ �����մϴ�.");
		
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
			SystemClientMessage(playerid, "�α��� �Ϸ��� ä������ \"���� �˼��մϴ�.\"�� ��Ȯ�� �Է��ض�.");
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
		ServerLog(LOG_TYPE_MYSQL, "���� ��ȸ�� ������ �߻��߽��ϴ�.", errno);

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
		ServerLog(LOG_TYPE_MYSQL, "������ ������ �� �����ϴ�.", errno);

		ErrorClientMessage(playerid, "���� ������ �����߽��ϴ�. �ٽ� �õ��� �ּ���.");

		if (!migration)
		{
			ErrorClientMessage(playerid, "���� ������ �����߽��ϴ�. �ٽ� �õ��� �ּ���.");
			ShowPlayerLoginDialog(playerid);
		}
		else
		{
			ErrorClientMessage(playerid, "���� �̵��� �����߽��ϴ�. �ٽ� �õ��� �ּ���.");
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
		ServerLog(LOG_TYPE_MYSQL, "���� ��й�ȣ ���濡 ������ �߻��߽��ϴ�.", (errno != 0) ? errno : -1);

		ErrorClientMessage(playerid, "���� ��й�ȣ ���濡 ������ �߻��߽��ϴ�. �ٽ� �õ����ּ���.");
		ShowPlayerChangePasswordDialog(playerid);

		return;
	}
	
	SystemClientMessage(playerid, "���������� ��й�ȣ�� �����Ͽ����ϴ�.");
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
		ServerLog(LOG_TYPE_MYSQL, "���� ���忡 ������ �߻��߽��ϴ�.", (errno != 0) ? errno : -1);

		RequestPlayerAccountSave(playerid, register);
		
		return;
	}
	
	if (register)
	{
		new bool: migration = (playerLoggedIn[playerid] == LOGIN_TYPE_LEGACY);

		passwordCheck[playerid] = "";
		playerAccount[playerid] = 1;

		if (!migration)
			InfoClientMessage(playerid, "���� ������ �Ϸ�Ǿ����ϴ�! �����Ͻ� �������� �α��� ���ּ���.");
		else
			InfoClientMessage(playerid, "���� �̵��� �Ϸ�Ǿ����ϴ�! ����Ͻ� ��й�ȣ�� �Է��Ͽ� �α��� ���ּ���.");

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
		ServerLog(LOG_TYPE_MYSQL, "���� �α��ο� ������ �߻��߽��ϴ�.", (errno != 0) ? errno : -1);

		ErrorClientMessage(playerid, "���� �α��ο� ������ �߻��߽��ϴ�. �ٽ� �α��� ���ּ���.");
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
			ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{FF9900}ī�� ���� : {FFFFFF}���� ����",
				"{FF9900}ī�� ����{FFFFFF} ������ ���Ű� ȯ���մϴ�.\n{FF9900}����{FFFFFF}�� �������� ������ {FF9900}��й�ȣ{FFFFFF}�� �Է��� {FF9900}Ȯ�� ��ư{FFFFFF}�� �����ñ� �ٶ��ϴ�.\n\
				��й�ȣ�� {FF9900}"#MIN_PASSWORD_LENGTH"�� �̻� "#MAX_PASSWORD_LENGTH"�� ����{FFFFFF}�� �������ּ���.",
				"Ȯ��", "����");
		}
		else
			ShowPlayerMigrationDialog(playerid); // Pass to Migration module
	}
	else
	{
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{FF9900}ī�� ���� : {FFFFFF}���� �α���",
			"{FFFFFF}�̹� ����� {FF9900}����{FFFFFF}�� �����մϴ�.\n{FF9900}��й�ȣ{FFFFFF}�� �Է��� {FF9900}���� �α��� ��ư{FFFFFF}�� �����ñ� �ٶ��ϴ�.",
			"�α���", "����");
	}

	return 1;
}

function ShowPlayerPasswordCheckDialog(playerid)
{
	if (!IsPlayerConnected(playerid) || IsPlayerHaveAccount(playerid) || IsPlayerLoggedIn(playerid))
		return 0;
	
	ShowPlayerDialog(playerid, DIALOG_PASSWORD_CHECK, DIALOG_STYLE_PASSWORD, "{FF9900}ī�� ���� : {FFFFFF}���� ����",
			"{FFFFFF}�Է��Ͻ� {FF9900}��й�ȣ{FFFFFF}�� �ٽ� �ѹ� �Է� �� {FF9900}���� ��� ��ư{FFFFFF}�� �����ñ� �ٶ��ϴ�.",
			"���", "����");

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

		format(string, sizeof(string), "[ Big News ] %s (%d){FFFFFF}�Բ��� {FF0000}Lv. %d {FFFFFF}�� ������ �Ǿ����ϴ�.", GetPlayerNameEx(playerid), playerid, playerInfo[playerid][pLevel]);
		SendClientMessageToAll(0xFF0000FF, string);

		SystemClientMessage(playerid, "������ ����Ͽ����ϴ�!");
		InfoClientMessage(playerid, "\"/����\" ��ɾ ���� �ɷ�ġ�� ��½�ų �� �ֽ��ϴ�!");
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

	format(string, sizeof(string), "����� ���� ����Ʈ: %d\n", playerInfo[playerid][pUpgStat]);
	format(string, sizeof(string), "%s{FFFF00}��ø +1 {FF0000}[%d/%d]\n", string, playerInfo[playerid][pUpgDec], maxStatAmount[0]);
	format(string, sizeof(string), "%s{FFFF00}�� +1 {FF0000}[%d/%d]\n", string, playerInfo[playerid][pUpgPower], maxStatAmount[1]);
	format(string, sizeof(string), "%s{FFFF00}��� +1 {FF0000}[%d/%d]\n", string, playerInfo[playerid][pUpgMoney], maxStatAmount[2]);
	format(string, sizeof(string), "%s{FFFF00}ü�� +1 {FF0000}[%d/%d]\n", string, playerInfo[playerid][pUpgHealth], maxStatAmount[3]);
	format(string, sizeof(string), "%s{FFFF00}���� +1 {FF0000}[%d/%d]\n", string, playerInfo[playerid][pUpgIntelligence], maxStatAmount[4]);

	ShowPlayerDialog(playerid, DIALOG_UPGRADE_STAT, DIALOG_STYLE_LIST, "���� ���׷��̵�", string, "���׷��̵�", "���");

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

	format(string, sizeof(string), "{FF0000}%s {FFFF00}���� ����\n\
		{FF0000}Lv.%d\n\
		{FFFF00}��ø : {FF0000}%d \n\
		{FFFF00}�� : {FF0000}%d\n\
		{FFFF00}��� : {FF0000}%d\n\
		{FFFF00}ü�� : {FF0000}%d\n\
		{FFFF00}���� : {FF0000}%d",
		GetPlayerNameEx(playerid), playerInfo[playerid][pLevel], playerInfo[playerid][pUpgDec], playerInfo[playerid][pUpgPower], playerInfo[playerid][pUpgMoney], playerInfo[playerid][pUpgHealth],
		playerInfo[playerid][pUpgIntelligence]
	);
	ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, "������", string, "Ȯ��", "");

	return 1;
}

function ShowPlayerChangePasswordDialog(playerid, step = 0)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	if (step == 0)
		ShowPlayerDialog(playerid, DIALOG_CHANGE_PASSWORD, DIALOG_STYLE_PASSWORD, "��й�ȣ ����",
			"{FFFFFF}�����Ͻ� ��й�ȣ�� �Է��� �ּ���.\n��й�ȣ�� �ּ� "#MIN_PASSWORD_LENGTH"�̻�, �ִ� "#MAX_PASSWORD_LENGTH"���Ϸ� �����ؾ� �մϴ�.", "Ȯ��", "���");
	else
		ShowPlayerDialog(playerid, DIALOG_CHANGE_PASSWORD + 1, DIALOG_STYLE_PASSWORD, "��й�ȣ Ȯ��",
			"{FFFFFF}�Է��Ͻ� ��й�ȣ�� �ٽ� �Է��� �ּ���.", "����", "����");
	
	return 1;
}

function ShowPlayerLuckStatDialog(playerid)
{
	if (!IsPlayerConnected(playerid) || luckStat[playerid] == 0)
		return 0;
	
	new string[256];

	format(string, sizeof(string), "�� ������ ���̻� �������� �ʽ��ϴ�. ���� �� ���� %d��ŭ ���� ����Ʈ�� �����Ǿ����ϴ�.", luckStat[playerid]);
	ShowPlayerDialog(playerid, DIALOG_LUCK_STAT, DIALOG_STYLE_MSGBOX, "���� �ȳ�", string, "�ٽú���", "Ȯ��");

	return 1;
}
