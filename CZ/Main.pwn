/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Core of mode
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

#include "./CZ/Inc/Main.inc"

#define HOST_NAME "ī������2�ӤӤӤӤӤӤӤӤӤӤӤӤӤӤ�"
#define MODE_NAME "ī�� ���� 2"

#include "./CZ/Hook.pwn"

#include "./CZ/Util/Core.pwn"
#include "./CZ/Util/DetectJump.pwn"
#include "./CZ/Util/Dialog.pwn"
#include "./CZ/Util/ESC.pwn"
#include "./CZ/Util/Log.pwn"
#include "./CZ/Util/MapManager.pwn"
#include "./CZ/Util/ReturnUser.pwn"

#include "./CZ/DataBase.pwn"
#include "./CZ/EventMgr.pwn"
#include "./CZ/Intro.pwn"
#include "./CZ/TextDraw.pwn"
#include "./CZ/Timer.pwn"
#include "./CZ/Vote.pwn"

#include "./CZ/Game/Core.pwn"
#include "./CZ/Game/Damage.pwn"
#include "./CZ/Game/Event.pwn"
#include "./CZ/Game/Help.pwn"
#include "./CZ/Game/Human.pwn"
#include "./CZ/Game/MapScr.pwn"
#include "./CZ/Game/Message.pwn"
#include "./CZ/Game/MusicCast.pwn"
#include "./CZ/Game/Zombie.pwn"

#include "./CZ/Account/Core.pwn"
#include "./CZ/Account/Migration.pwn"

InitModule("Main")
{
	AntiDeAMX();

	new maxPlayers = GetServerVarAsInt("maxplayers");

	if (maxPlayers > MAX_PLAYERS)
	{
		printf("[error] ��忡�� ����ϴ� �ִ� �ο��� "#MAX_PLAYERS"�� �Դϴ�.");
		printf("[error] �������� ������ �ִ� �ο��� %d�� �Դϴ�.", maxPlayers);
		printf("[error] �ִ� �ο��� ��忡�� ������ �ִ� �ο��� ���ų� �۾ƾ� �մϴ�.");

		SendRconCommand("exit");

		return;
	}

	AllowInteriorWeapons(1);
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();

	AddEventHandler(D_PlayerConnect, "Main_PlayerConnect");
	AddEventHandler(D_PlayerCommandText, "Main_PlayerCommandText");
	AddEventHandler(D_PlayerCommandTextFail, "Main_PlayerCommandTextFail");

	AddModule("EventMgr");
	AddModule("DataBase");
	AddModule("Timer");
	AddModule("TextDraw");

	AddModule("Util");

	AddModule("Intro");
	AddModule("Account");
	AddModule("Vote");
	AddModule("Game");

	AddEventHandler(D_PlayerDisconnect, "Main_PlayerDisconnect");
	AddEventHandler(D_GameModeExit, "Main_GameModeExit");

	OnGameModeLoadFinish();
}

public Main_GameModeExit()
{
	if (MySQL)
		mysql_close(MySQL);
}

public OnGameModeLoadFinish()
{
	SetGameModeText(MODE_NAME);
	SendRconCommand("hostname "HOST_NAME"");
	SendRconCommand("mapname "MODE_VERSION"");
	
	print("========================================================");
	print("         "HOST_NAME"");
	print("                     Made by Qoo");
	print("                Version: "MODE_VERSION"");
	print("Thanks to Junggle, Fasa, Keroro, RangE, Claire_Redfield, EVOLUTION");
	print("    Copyright (c) 2018, 2019 Qoo. All rights reserved.");
	print("========================================================");
}

public OnPlayerKick(playerid)
{
	Kick(playerid);
}

public Main_PlayerConnect(playerid)
{
	GetPlayerName(playerid, playerName[playerid], MAX_PLAYER_NAME);

	return 0;
}

public Main_PlayerDisconnect(playerid)
{
	playerName[playerid] = "";

	if (playerKickTimer[playerid])
	{
		KillTimer(playerKickTimer[playerid]);
		playerKickTimer[playerid] = 0;
	}

	return 0;
}

public Main_PlayerCommandText(playerid, const command[])
{
	if (strcmp(command, "/admincall", true) == 0 || strcmp(command, "/������") == 0)
	{
		if (!toggleAdminCall)
			return ErrorClientMessage(playerid, "�����ڿ� ���� �������� ����� �� �����ϴ�.");
		
		printf("%s(id:%d)�Բ��� �����ڸ� ȣ���ϼ̽��ϴ�.\a", GetPlayerNameEx(playerid), playerid);
		SystemClientMessage(playerid, "ȣ���Ͽ����ϴ�. (�����ϴ� ���縦 ���� �� ������ ����)");

		return 1;
	}

	if (!IsPlayerLoggedIn(playerid))
		return ErrorClientMessage(playerid, "�α��� �� �� ��ɾ� ����� �����մϴ�.");
	
	if (strcmp(command, "/togadmincall", true) == 0 || strcmp(command, "/�����") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return ErrorClientMessage(playerid, "�����ڸ� ����� �� �ֽ��ϴ�.");
		
		new string[MAX_MESSAGE_LENGTH];

		if (toggleAdminCall)
		{
			toggleAdminCall = false;
			
			format(string, sizeof(string), "������ %s ���� �������� ��Ȱ��ȭ �Ͽ����ϴ�.", GetPlayerNameEx(playerid));
		}
		else
		{
			toggleAdminCall = true;

			format(string, sizeof(string), "������ %s ���� �������� Ȱ��ȭ �Ͽ����ϴ�.", GetPlayerNameEx(playerid));
		}

		SystemClientMessageToAll(string);

		return 1;
	}

	if (strcmp(command, "/reboot", true) == 0 || strcmp(command, "/gmx", true) == 0 || strcmp(command, "/����") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 3))
			return ErrorClientMessage(playerid, "�����ڸ� ����� �� �ֽ��ϴ�.");
		
		new string[MAX_MESSAGE_LENGTH];

		reboot = true;

		SendRconCommand("gmx");

		format(string, sizeof(string), "������ %s �Կ� ���� ������ �����մϴ�.", GetPlayerNameEx(playerid));
		SystemClientMessageToAll(string);

		return 1;
	}

	if (strcmp(command, "/exit", true) == 0 || strcmp(command, "/��������") == 0 || strcmp(command, "/������") == 0)
	{
		if (!IsPlayerAdmin(playerid))
			return ErrorClientMessage(playerid, "RCON �����ڸ� ����� �� �ֽ��ϴ�.");
		
		new string[MAX_MESSAGE_LENGTH];

		format(string, sizeof(string), "������ %s �Կ� ���� ������ �����մϴ�.", GetPlayerNameEx(playerid));
		SystemClientMessageToAll(string);

		SendRconCommand("exit");

		return 1;
	}
	
	return 0;
}

public Main_PlayerCommandTextFail(playerid)
{
	ErrorClientMessage(playerid, "�������� �ʴ� ��ɾ��Դϴ�. \"/help\"��(��) ���� ���� ��ɾ���� �� �� �ֽ��ϴ�.");

	return 1;
}

function GetPlayerNameEx(playerid)
{
	if (!IsPlayerConnected(playerid))
	{
		new name[MAX_PLAYER_NAME];

		return name;
	}

	return playerName[playerid];
}

function bool: IsServerReboot()
{
	return (reboot == true);
}

function AntiDeAMX()
{
	new buffer[][] = {
		"Made by",
		"Qoo"
	};

	#pragma unused buffer
}

function IsPlayerInRangeOfIp(playerid, const ipRange[], rangeSize = sizeof(ipRange))
{
	new breakPoint = rangeSize;
	new playerIp[16];

	GetPlayerIp(playerid, playerIp, sizeof(playerIp));

	for (new i = 0; i < rangeSize; ++i)
	{
		if (i + 1 < rangeSize - 1 && ipRange[i] == '.' && ipRange[i + 1] == '*')
		{
			breakPoint = i;
			break;
		}
	}

	for (new i = 0; i < breakPoint; ++i)
	{
		if (playerIp[i] != ipRange[i])
		{
			return 0;
		}
	}

	return 1;
}
