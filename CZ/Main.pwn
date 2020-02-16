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

#define HOST_NAME "카스좀븨2ㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣㅣ"
#define MODE_NAME "카스 좀비 2"

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
		printf("[error] 모드에서 허용하는 최대 인원은 "#MAX_PLAYERS"명 입니다.");
		printf("[error] 서버에서 설정한 최대 인원은 %d명 입니다.", maxPlayers);
		printf("[error] 최대 인원은 모드에서 설정한 최대 인원과 같거나 작아야 합니다.");

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
	if (strcmp(command, "/admincall", true) == 0 || strcmp(command, "/어드민콜") == 0)
	{
		if (!toggleAdminCall)
			return ErrorClientMessage(playerid, "관리자에 의해 어드민콜을 사용할 수 없습니다.");
		
		printf("%s(id:%d)님께서 관리자를 호출하셨습니다.\a", GetPlayerNameEx(playerid), playerid);
		SystemClientMessage(playerid, "호출하였습니다. (남용하다 제재를 당할 수 있으니 유의)");

		return 1;
	}

	if (!IsPlayerLoggedIn(playerid))
		return ErrorClientMessage(playerid, "로그인 한 후 명령어 사용이 가능합니다.");
	
	if (strcmp(command, "/togadmincall", true) == 0 || strcmp(command, "/어드콜") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		if (toggleAdminCall)
		{
			toggleAdminCall = false;
			
			format(string, sizeof(string), "관리자 %s 님이 어드민콜을 비활성화 하였습니다.", GetPlayerNameEx(playerid));
		}
		else
		{
			toggleAdminCall = true;

			format(string, sizeof(string), "관리자 %s 님이 어드민콜을 활성화 하였습니다.", GetPlayerNameEx(playerid));
		}

		SystemClientMessageToAll(string);

		return 1;
	}

	if (strcmp(command, "/reboot", true) == 0 || strcmp(command, "/gmx", true) == 0 || strcmp(command, "/리붓") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 3))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		reboot = true;

		SendRconCommand("gmx");

		format(string, sizeof(string), "관리자 %s 님에 의해 서버를 리붓합니다.", GetPlayerNameEx(playerid));
		SystemClientMessageToAll(string);

		return 1;
	}

	if (strcmp(command, "/exit", true) == 0 || strcmp(command, "/서버종료") == 0 || strcmp(command, "/섭종료") == 0)
	{
		if (!IsPlayerAdmin(playerid))
			return ErrorClientMessage(playerid, "RCON 관리자만 사용할 수 있습니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		format(string, sizeof(string), "관리자 %s 님에 의해 서버를 종료합니다.", GetPlayerNameEx(playerid));
		SystemClientMessageToAll(string);

		SendRconCommand("exit");

		return 1;
	}
	
	return 0;
}

public Main_PlayerCommandTextFail(playerid)
{
	ErrorClientMessage(playerid, "존재하지 않는 명령어입니다. \"/help\"을(를) 통해 각종 명령어들을 볼 수 있습니다.");

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
