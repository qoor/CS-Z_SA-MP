/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Vote system
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

#include "./CZ/Inc/Vote.inc"

InitModule("Vote")
{
	AddEventHandler(D_PlayerConnect, "Vote_PlayerConnect");
	AddEventHandler(D_PlayerCommandText, "Vote_PlayerCommandText");
	AddEventHandler(global1sTimer, "Vote_Global1sTimer");
}

public Vote_PlayerConnect(playerid)
{
	playerVoted[playerid] = false;

	return 0;
}

public Vote_PlayerCommandText(playerid, const command[], const params[])
{
	if (strcmp(command, "/vote", true) == 0 || strcmp(command, "/투표시작") == 0)
	{
		new bool: admin = (IsPlayerAdmin(playerid) || IsPlayerSubAdmin(playerid));

		if (!admin && GetPlayerMoney(playerid) < 5000)
			return ErrorClientMessage(playerid, "관리자 혹은 $5,000가 있는 유저만 사용할 수 있습니다.");
		
		if (voteTime > 0)
			return ErrorClientMessage(playerid, "이미 투표가 진행중입니다.");
		
		new time;

		if (!GetParamInt(time, params, 0))
			return ErrorClientMessage(playerid, "사용법: /투표시작 [투표 시간(초)] [투표 주제]");
		
		if (time < 1)
			return ErrorClientMessage(playerid, "투표 시간은 최소 1초 이상이어야 합니다.");
		
		new result[MAX_MESSAGE_LENGTH];
		new string[MAX_MESSAGE_LENGTH];

		if (!admin)
			GivePlayerMoney(playerid, -5000);

		MergeParams(result, params, 1);
		strcpy(voteTopic, result);

		voteTime = time;

		format(string, sizeof(string), "%s%s 님이 투표를 시작하셨습니다. \"/찬(성)\", \"/반(대))\"로 의견을 제출할 수 있습니다.", (!admin) ? ("") : ("관리자 "), GetPlayerNameEx(playerid));
		SystemClientMessageToAll(string);
		format(string, sizeof(string), "주제: %s", result);
		SystemClientMessageToAll(string);

		return 1;
	}

	if (strcmp(command, "/투표통계") == 0 || strcmp(command, "/투표현황") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		if (voteTime <= 0)
			return ErrorClientMessage(playerid, "투표가 시작되지 않았습니다.");
		
		ShowVoteResult(playerid);

		return 1;
	}

	if (strcmp(command, "/투표중단") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		if (voteTime <= 0)
			return ErrorClientMessage(playerid, "투표가 시작되지 않았습니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		voteTime = 0;

		format(string, sizeof(string), "관리자 %s 님이 투표를 도중에 중단했습니다. 투표 결과를 공개합니다.", GetPlayerNameEx(playerid));
		SystemClientMessageToAll(string);

		ShowVoteResult();
		ResetVoteResult();

		return 1;
	}

	if (strcmp(command, "/agree", true) == 0 || strcmp(command, "/찬성") == 0 || strcmp(command, "/찬") == 0)
	{
		if (voteTime <= 0)
			return ErrorClientMessage(playerid, "투표가 시작되지 않았습니다.");
		
		if (playerVoted[playerid])
			return ErrorClientMessage(playerid, "이미 투표에 참여하셨습니다.");
		
		playerVoted[playerid] = true;

		++voteAgree;

		SystemClientMessage(playerid, "투표 주제에 대해 찬성하셨습니다. 결과를 기다려 주세요.");

		return 1;
	}

	if (strcmp(command, "/disagree", true) == 0 || strcmp(command, "/반대") == 0 || strcmp(command, "/반") == 0)
	{
		if (voteTime <= 0)
			return ErrorClientMessage(playerid, "투표가 시작되지 않았습니다.");
		
		if (playerVoted[playerid])
			return ErrorClientMessage(playerid, "이미 투표에 참여하셨습니다.");
		
		playerVoted[playerid] = true;

		++voteDisagree;

		SystemClientMessage(playerid, "투표 주제에 대해 반대하셨습니다. 결과를 기다려 주세요.");

		return 1;
	}

	return 0;
}

public Vote_Global1sTimer()
{
	if (voteTime != 0)
	{
		--voteTime;

		if (voteTime == 10)
		{
			new string[MAX_MESSAGE_LENGTH];
			
			SystemClientMessageToAll("투표 시간이 10초 남았습니다. \"/찬(성)\", \"/반대\"로 의견을 제출해 주세요.");
			format(string, sizeof(string), "주제: %s", voteTopic);
			SystemClientMessageToAll(string);
		}
		else if (voteTime == 0)
		{
			SystemClientMessageToAll("투표가 끝났습니다. 투표 결과를 공개합니다.");

			ShowVoteResult();
			ResetVoteResult();
		}
	}

	return 0;
}

function ResetVoteResult()
{
	voteTopic = "";
	voteAgree = 0;
	voteDisagree = 0;

	contloop (new i : playerList)
		playerVoted[i] = false;
}

function ShowVoteResult(playerid = INVALID_PLAYER_ID)
{
	new string[MAX_MESSAGE_LENGTH];

	if (playerid == INVALID_PLAYER_ID)
		print("====================== 투표 =========================");
	
	format(string, sizeof(string), "주제: %s", voteTopic);

	if (playerid == INVALID_PLAYER_ID)
	{
		SystemClientMessageToAll(string);
		ServerLog(LOG_TYPE_VOTE, string);
	}
	else
		SendClientMessage(playerid, 0xFFFFFFFF, string);
	
	format(string, sizeof(string), "찬성 표: %d", voteAgree);
	
	if (playerid == INVALID_PLAYER_ID)
	{
		SystemClientMessageToAll(string);
		ServerLog(LOG_TYPE_VOTE, string);
	}
	else
		SendClientMessage(playerid, 0xFFFFFFFF, string);

	format(string, sizeof(string), "반대 표: %d", voteDisagree);
	
	if (playerid == INVALID_PLAYER_ID)
	{
		SystemClientMessageToAll(string);
		ServerLog(LOG_TYPE_VOTE, string);
	}
	else
		SendClientMessage(playerid, 0xFFFFFFFF, string);
	
	if (playerid == INVALID_PLAYER_ID)
		print("===================================================");
}
