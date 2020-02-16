/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Showing login intro screen
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

#include "./CZ/Inc/Intro.inc"
#include "./CZ/Account/Inc/Core.inc"
#include "./CZ/Inc/TextDraw.inc"

InitModule("Intro")
{
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);

	AddEventHandler(D_PlayerConnect, "Intro_PlayerConnect");
	AddEventHandler(D_PlayerRequestClass, "Intro_PlayerRequestClass");
	AddEventHandler(D_PlayerSpawn, "Intro_PlayerSpawn");
	AddEventHandler(player1sTimer, "Intro_Player1sTimer");
}

public Intro_PlayerConnect(playerid)
{
	introStep[playerid] = -1;
	introPaused[playerid] = 0;

	TextDrawShowForPlayer(playerid, blackScreen);

	return 0;
}

public Intro_PlayerRequestClass(playerid)
{
	SetSpawnInfo(playerid, NO_TEAM, 0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);

	return 1;
}

public Intro_PlayerSpawn(playerid)
{
	if (introStep[playerid] == -1)
	{
		StartPlayerIntro(playerid);

		return 1;
	}

	return 0;
}

public Intro_Player1sTimer(playerid)
{
	if (introPaused[playerid] == 0 && introStep[playerid] > 0)
	{
		switch ((++introStep[playerid]))
		{
		case 5:
			{
				FadeCamera(playerid, false, 0.0);
				TextDrawHideForPlayer(playerid, nexonText);

				for (new i = 0; i < 14; ++i)
					TextDrawShowForPlayer(playerid, introText[i]);

				PausePlayerIntro(playerid);
			}
		case 7:
			{
				new year, month, day;

				getdate(year, month, day);

				FadeCamera(playerid, true, 2.0);

				if (month != 12)
					PlayAudioStreamForPlayer(playerid, "http://pds25.egloos.com/pds/201501/24/38/CSOnline.mp3");
				else
					PlayAudioStreamForPlayer(playerid, "http://pds25.egloos.com/pds/201812/25/38/CSO_XMas_Intro.mp3");
				
				ClearMessage(playerid);
				SendClientMessage(playerid, 0xFFFFFFFF, "     카스좀븨2     {FF0000}제작자: {FFFFFF}Qoo     {FF0000}버전: {FFFFFF}"MODE_VERSION"");
			}
		case 13:
			{
				new version[24];
				
				GetPlayerVersion(playerid, version, sizeof(version));

				if (IsNull(version) || strcmp(version, "0.3.7-R4") != 0)
				{
					ErrorClientMessage(playerid, "설치 된 SA-MP 버전을 지원하지 않습니다.");
					ErrorClientMessage(playerid, "SA-MP 0.3.7-R4 이상의 버전으로 설치해 주세요.");
					InfoClientMessage(playerid, "다운로드 주소: https://files.sa-mp.com/sa-mp-0.3.7-R4-install.exe");
					Kick(playerid);
					return 1;
				}

				PausePlayerIntro(playerid);
			}
		case 15:
			ShowLoadingBarForPlayer(playerid, 0);
		case 17:
			ShowLoadingBarForPlayer(playerid, 1);
		case 19:
			ShowLoadingBarForPlayer(playerid, 2);
		case 20:
			ShowLoadingBarForPlayer(playerid, 3);
		case 21:
			ShowLoadingBarForPlayer(playerid, 4);
		case 22:
			HideLoadingBarForPlayer(playerid);
		case 24:
			FadeCamera(playerid, false);
		case 27:
			{
				TextDrawHideForPlayer(playerid, blackScreen);

				for (new i = 0; i < 14; ++i)
					TextDrawHideForPlayer(playerid, introText[i]);
			}
		case 29:
			{
				FadeCamera(playerid, true);
				StopAudioStreamForPlayer(playerid);
				FinishPlayerIntro(playerid);

				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
				TogglePlayerControllable(playerid, 1);
				OnPlayerSpawn(playerid);
				SetCameraBehindPlayer(playerid);
			}
		}
	}

	return 0;
}

function StartPlayerIntro(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;

	introStep[playerid] = 1;

	TogglePlayerControllable(playerid, 0);
	SetPlayerVirtualWorld(playerid, playerid + 1);
	//SetPlayerInterior(playerid, playerid + 1);
	FadeCamera(playerid, true, 0.0);

	TextDrawShowForPlayer(playerid, nexonText);

	PlayAudioStreamForPlayer(playerid, "http://pds26.egloos.com/pds/201502/28/38/Nexon.wav");
	
	ClearMessage(playerid);

	//return FinishPlayerIntro(playerid);

	return 1;
}

function PausePlayerIntro(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	introPaused[playerid] = 1;

	TriggerEventNoSuspend(introPausedEvent, "ii", playerid, introStep[playerid]);

	return 1;
}

function ResumePlayerIntro(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	introPaused[playerid] = 0;

	return 1;
}

function FinishPlayerIntro(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;

	introStep[playerid] = 0;

	TriggerEventNoSuspend(introFinishEvent, "i", playerid);

	return 1;
}

stock bool: IsPlayerFinishedIntro(playerid)
{
	return (IsPlayerConnected(playerid) && introStep[playerid] == 0);
}

function ShowLoadingBarForPlayer(playerid, step)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	if (step > 0)
		TextDrawHideForPlayer(playerid, loadingBar[step - 1]);
	
	TextDrawShowForPlayer(playerid, loadingBar[step]);

	return 1;
}

function HideLoadingBarForPlayer(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	for (new i = 0; i < 5; ++i)
		TextDrawHideForPlayer(playerid, loadingBar[i]);
	
	return 1;
}

function bool: IsPlayerIntroPaused(playerid)
{
	return (IsPlayerConnected(playerid) && introStep[playerid] > 0 && introPaused[playerid] > 0);
}
