/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * In-Game events
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

#include "./CZ/Game/Inc/Event.inc"

InitModule("Game_Event")
{
	AddEventHandler(D_PlayerCommandText, "G_Event_PlayerCommandText");
	AddEventHandler(gamemodeMapStartEvent, "G_Event_GamemodeMapStart");
}

public G_Event_PlayerCommandText(playerid, const command[], const params[])
{
	if (strcmp(command, "/이벤트") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		new event[64];

		if (!GetParamString(event, params, 0) || IsNull(params))
		{
			ErrorClientMessage(playerid, "사용법: /이벤트 [이벤트]");
			SendClientMessage(playerid, 0xFFFFFFFF, "============= 이벤트 목록 =============");
			SendClientMessage(playerid, 0xAAAAAAFF, " 날씨 좀비확률동일");

			return 1;
		}

		new eventid;

		if (strcmp(event, "날씨") == 0)
		{
			eventid = EVENT_WEATHER;

			if (!gameEventToggle[EVENT_WEATHER])
				ExecuteGameEvent(EVENT_WEATHER);
			else
				SetWeather(10);
		}
		else if (strcmp(event, "좀비확률동일") == 0)
			eventid = EVENT_ZOMBIE_PROBABILITY_SAME;
		else
			return ErrorClientMessage(playerid, "존재하지 않는 이벤트입니다.");
		
		new string[MAX_MESSAGE_LENGTH];
		
		gameEventToggle[eventid] = !gameEventToggle[eventid];

		format(string, sizeof(string), "관리자 %s 님이 %s 이벤트를 %s습니다.", GetPlayerNameEx(playerid), event, (gameEventToggle[eventid]) ? ("켰") : ("껐"));
		SystemClientMessageToAll(string);

		return 1;
	}

	return 0;
}

public G_Event_GamemodeMapStart()
{
	if (gameEventToggle[EVENT_WEATHER])
		ExecuteGameEvent(EVENT_WEATHER);
}

stock ExecuteGameEvent(eventid)
{
	if (eventid == EVENT_WEATHER)
	{
		random(51);
		random(51);

		SetWeather(random(51));
	}
}

stock bool: IsValidGameEvent(eventid)
{
	return (eventid > EVENT_NOT_USE && eventid < EVENT_INVALID);
}

stock bool: IsGameEventEnabled(eventid)
{
	return (IsValidGameEvent(eventid) && gameEventToggle[eventid]);
}
