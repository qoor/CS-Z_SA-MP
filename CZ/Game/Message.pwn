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
			if (!IsNull(text) && strcmp(text, "쿠우님 죄송합니다.") == 0)
			{
				SystemClientMessage(playerid, "오냐~ 이번은 봐줄게. 로그인이나 쳐 해라.");
				ShowPlayerLoginDialog(playerid);
			}
		}

		return 0;
	}

	if (IsPlayerChicken(playerid))
	{
		if (IsNull(text) || strcmp(text, "쿠우님 죄송합니다.") != 0)
		{
			SystemClientMessage(playerid, "니는 \"쿠우님 죄송합니다.\" 빼고는 아무 말도 못해.");
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
	if (strcmp(command, "/r", true) == 0 || strcmp(command, "/닉네임") == 0)
	{
		if (playerInfo[playerid][pUpgIntelligence] < 5)
			return ErrorClientMessage(playerid, "지식 스탯이 5 이상이어야 합니다.");
		
		if (GetPlayerMoney(playerid) < 1000)
			return ErrorClientMessage(playerid, "닉네임을 변경하려면 $1000가 필요합니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		if (GetParamString(string, params, 0) == 0)
			return SystemClientMessage(playerid, "사용법: /r [닉네임]");
		
		if (strlen(string) >= MAX_NICKNAME_LENGTH)
		{
			format(string, sizeof(string), "닉네임은 %d자 이내로 설정할 수 있습니다.", MAX_NICKNAME_LENGTH - 1);
			return ErrorClientMessage(playerid, string);
		}

		if (charfind(string, 128) != -1 || charfind(string, 255) != -1 || strfind(string, "　", true) != -1)
			return ErrorClientMessage(playerid, "일부 특수문자는 사용할 수 없습니다.");

		new bracketStart = charfind(string, '{');
		new bracketEnd = charfind(string, '}');

		if (bracketStart != -1 && bracketEnd != -1 && bracketEnd - bracketStart == 7)
			return ErrorClientMessage(playerid, "컬러 코드는 삽입할 수 없습니다.");
		
		contloop (new i : playerList)
		{
			if (i != playerid && strcmp(GetPlayerNameEx(i), string, true) == 0)
				return ErrorClientMessage(playerid, "타 유저의 닉네임은 사용할 수 없습니다.");
		}
		
		GivePlayerMoney(playerid, -1000);
		strcpy(nickName[playerid], string);

		format(string, sizeof(string), " * 닉네임을 [%s](으)로 바꾸셨습니다.", string);
		return SystemClientMessage(playerid, string);
	}

	if (strcmp(command, "/team", true) == 0 || strcmp(command, "/t", true) == 0 || strcmp(command, "/팀채팅") == 0 || strcmp(command, "/팀챗") == 0)
	{
		if (!IsGameProgress())
			return ErrorClientMessage(playerid, "현재 게임이 진행중이지 않습니다.");

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

		InfoClientMessage(playerid, "팀 채팅 모드로 전환합니다. 채팅 시 팀에게만 전달됩니다.");
	}
	else
	{
		teamChat[playerid] = false;

		InfoClientMessage(playerid, "전체 채팅 모드로 전환합니다. 채팅 시 모두에게 전달됩니다.");
	}
}
