/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Chat system and In-Game messages
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

#include "./CZ/Game/Inc/Message.inc"

InitModule("Game_Message")
{
	AddEventHandler(D_PlayerConnect, "G_Message_PlayerConnect");
	AddEventHandler(D_PlayerText, "G_Message_PlayerText");
	AddEventHandler(D_PlayerCommandText, "G_Message_PlayerCommandText");
	AddEventHandler(D_PlayerKeyStateChange, "G_Message_PlayerKeyStateChange");
}

public G_Message_PlayerConnect(playerid)
{
	nickName[playerid] = "";
	teamChat[playerid] = false;

	return 0;
}

public G_Message_PlayerText(playerid, const text[])
{
	if (!IsPlayerLoggedIn(playerid))
	{
		// Chicken game
		if (IsPlayerChicken(playerid))
		{
			if (!IsNull(text) && strcmp(text, "���� �˼��մϴ�.") == 0)
			{
				SystemClientMessage(playerid, "����~ �̹��� ���ٰ�. �α����̳� �� �ض�.");
				ShowPlayerLoginDialog(playerid);
			}
		}

		return 0;
	}

	if (IsPlayerChicken(playerid))
	{
		if (IsNull(text) || strcmp(text, "���� �˼��մϴ�.") != 0)
		{
			SystemClientMessage(playerid, "�ϴ� \"���� �˼��մϴ�.\" ����� �ƹ� ���� ����.");
			return 0;
		}
	}
	
	new string[MAX_MESSAGE_LENGTH];

	format(string, sizeof(string), "[Lv.%d][%s]%s (%d) : {FFFFFF}%s", playerInfo[playerid][pLevel], GetTitleName(playerInfo[playerid][pTitleType]),
		(IsNull(nickName[playerid])) ? GetPlayerNameEx(playerid) : nickName[playerid], playerid, text);

	if (!teamChat[playerid])
		SendClientMessageToAll(GetPlayerColor(playerid), string);
	else
	{
		format(string, sizeof(string), "[TEAM CHAT]%s", string);
		SendClientMessageToTeam(playerid, 0xAAAAAAFF, string);
	}

	return 0;
}

public G_Message_PlayerCommandText(playerid, const command[], const params[])
{
	if (strcmp(command, "/r", true) == 0 || strcmp(command, "/�г���") == 0)
	{
		if (playerInfo[playerid][pUpgIntelligence] < 5)
			return ErrorClientMessage(playerid, "���� ������ 5 �̻��̾�� �մϴ�.");
		
		if (GetPlayerMoney(playerid) < 1000)
			return ErrorClientMessage(playerid, "�г����� �����Ϸ��� $1000�� �ʿ��մϴ�.");
		
		new string[MAX_MESSAGE_LENGTH];

		if (GetParamString(string, params, 0) == 0)
			return SystemClientMessage(playerid, "����: /r [�г���]");
		
		if (strlen(string) >= MAX_NICKNAME_LENGTH)
		{
			format(string, sizeof(string), "�г����� %d�� �̳��� ������ �� �ֽ��ϴ�.", MAX_NICKNAME_LENGTH - 1);
			return ErrorClientMessage(playerid, string);
		}

		if (charfind(string, 128) != -1 || charfind(string, 255) != -1 || strfind(string, "��", true) != -1)
			return ErrorClientMessage(playerid, "�Ϻ� Ư�����ڴ� ����� �� �����ϴ�.");

		new bracketStart = charfind(string, '{');
		new bracketEnd = charfind(string, '}');

		if (bracketStart != -1 && bracketEnd != -1 && bracketEnd - bracketStart == 7)
			return ErrorClientMessage(playerid, "�÷� �ڵ�� ������ �� �����ϴ�.");
		
		contloop (new i : playerList)
		{
			if (i != playerid && strcmp(GetPlayerNameEx(i), string, true) == 0)
				return ErrorClientMessage(playerid, "Ÿ ������ �г����� ����� �� �����ϴ�.");
		}
		
		GivePlayerMoney(playerid, -1000);
		strcpy(nickName[playerid], string);

		format(string, sizeof(string), " * �г����� [%s](��)�� �ٲټ̽��ϴ�.", string);
		return SystemClientMessage(playerid, string);
	}

	if (strcmp(command, "/team", true) == 0 || strcmp(command, "/t", true) == 0 || strcmp(command, "/��ä��") == 0 || strcmp(command, "/��ê") == 0)
	{
		if (!IsGameProgress())
			return ErrorClientMessage(playerid, "���� ������ ���������� �ʽ��ϴ�.");

		ChangePlayerTeamChatToggle(playerid);
		return 1;
	}

	return 0;
}

public G_Message_PlayerKeyStateChange(playerid, newkeys)
{
	if (newkeys & KEY_ANALOG_LEFT)
	{
		ChangePlayerTeamChatToggle(playerid);
		return 1;
	}

	return 0;
}

stock InfoClientMessage(playerid, const message[])
{
	new string[MAX_MESSAGE_LENGTH] = { "[ Info ] {FFFFFF}" };

	strcat(string, message);
	return SendClientMessage(playerid, COLOR_INFO, string);
}

stock ErrorClientMessage(playerid, const message[])
{
	new string[MAX_MESSAGE_LENGTH] = { "[ Error ] {FFFFFF}" };

	strcat(string, message);
	return SendClientMessage(playerid, 0xFFFFFFFF, string);
}

stock PayClientMessage(playerid, const message[])
{
	new string[MAX_MESSAGE_LENGTH] = { "[ Pay ] {FFFFFF}" };

	strcat(string, message);
	return SendClientMessage(playerid, 0xFFFF00AA, string);
}

stock SystemClientMessage(playerid, const message[])
{
	new string[MAX_MESSAGE_LENGTH] = { "[ System ] {FFFFFF}" };

	strcat(string, message);
	return SendClientMessage(playerid, 0xFF9900AA, string);
}

stock NewsClientMessage(playerid, const message[])
{
	new string[MAX_MESSAGE_LENGTH] = { "[ News ] {FFFFFF}" };

	strcat(string, message);
	return SendClientMessage(playerid, 0xAFEEEEFF, string);
}

stock SystemClientMessageToAll(const message[])
{
	new string[MAX_MESSAGE_LENGTH] = { "[ System ] {FFFFFF}" };

	strcat(string, message);
	return SendClientMessageToAll(0xFF9900AA, string);
}

stock NewsClientMessageToAll(const message[])
{
	new string[MAX_MESSAGE_LENGTH] = { "[ News ] {FFFFFF}" };

	strcat(string, message);
	return SendClientMessageToAll(0xAFEEEEFF, string);
}

stock ClearMessageToAll(line = 20)
{
	contloop (new playerid : playerList)
		ClearMessage(playerid, line);
}

stock ClearMessage(playerid, line = 20)
{
	if (!IsPlayerConnected(playerid)/* || currentPlayer[playerid] == 0*/)
		return 0;
	
	for (new i = 0; i < line; ++i)
		SendClientMessage(playerid, 0xAAAAAAFF, " ");
	
	return 1;
}

stock SendAdminMessage(COLOR, const text[], level = 1)
{
	if (IsNull(text))
		return 0;
	
	contloop (new i : playerList)
	{
		if (IsPlayerAdmin(i) || IsPlayerSubAdmin(i, level))
			SendClientMessage(i, COLOR, text);
	}

	printf("[Admin] %s", text);

	return 1;
}

stock SendClientMessageToTeam(playerid, color, const message[])
{
	if (!IsPlayerCurrentPlayer(playerid))
		return 0;
	
	if (!IsGameProgress())
		return SendClientMessageToAll(color, message);
	
	new bool: human = IsPlayerHuman(playerid);

	contloop (new i : playerList)
	{
		if (human)
		{
			if (IsPlayerHuman(i))
				SendClientMessage(i, color, message);
		}
		else
		{
			if (IsPlayerZombie(i))
				SendClientMessage(i, color, message);
		}
	}

	return 1;
}

function ChangePlayerTeamChatToggle(playerid)
{
	if (!teamChat[playerid])
	{
		teamChat[playerid] = true;

		InfoClientMessage(playerid, "�� ä�� ���� ��ȯ�մϴ�. ä�� �� �����Ը� ���޵˴ϴ�.");
	}
	else
	{
		teamChat[playerid] = false;

		InfoClientMessage(playerid, "��ü ä�� ���� ��ȯ�մϴ�. ä�� �� ��ο��� ���޵˴ϴ�.");
	}
}
