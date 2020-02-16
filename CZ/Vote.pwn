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
	if (strcmp(command, "/vote", true) == 0 || strcmp(command, "/��ǥ����") == 0)
	{
		new bool: admin = (IsPlayerAdmin(playerid) || IsPlayerSubAdmin(playerid));

		if (!admin && GetPlayerMoney(playerid) < 5000)
			return ErrorClientMessage(playerid, "������ Ȥ�� $5,000�� �ִ� ������ ����� �� �ֽ��ϴ�.");
		
		if (voteTime > 0)
			return ErrorClientMessage(playerid, "�̹� ��ǥ�� �������Դϴ�.");
		
		new time;

		if (!GetParamInt(time, params, 0))
			return ErrorClientMessage(playerid, "����: /��ǥ���� [��ǥ �ð�(��)] [��ǥ ����]");
		
		if (time < 1)
			return ErrorClientMessage(playerid, "��ǥ �ð��� �ּ� 1�� �̻��̾�� �մϴ�.");
		
		new result[MAX_MESSAGE_LENGTH];
		new string[MAX_MESSAGE_LENGTH];

		if (!admin)
			GivePlayerMoney(playerid, -5000);

		MergeParams(result, params, 1);
		strcpy(voteTopic, result);

		voteTime = time;

		format(string, sizeof(string), "%s%s ���� ��ǥ�� �����ϼ̽��ϴ�. \"/��(��)\", \"/��(��))\"�� �ǰ��� ������ �� �ֽ��ϴ�.", (!admin) ? ("") : ("������ "), GetPlayerNameEx(playerid));
		SystemClientMessageToAll(string);
		format(string, sizeof(string), "����: %s", result);
		SystemClientMessageToAll(string);

		return 1;
	}

	if (strcmp(command, "/��ǥ���") == 0 || strcmp(command, "/��ǥ��Ȳ") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid))
			return ErrorClientMessage(playerid, "�����ڸ� ����� �� �ֽ��ϴ�.");
		
		if (voteTime <= 0)
			return ErrorClientMessage(playerid, "��ǥ�� ���۵��� �ʾҽ��ϴ�.");
		
		ShowVoteResult(playerid);

		return 1;
	}

	if (strcmp(command, "/��ǥ�ߴ�") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid))
			return ErrorClientMessage(playerid, "�����ڸ� ����� �� �ֽ��ϴ�.");
		
		if (voteTime <= 0)
			return ErrorClientMessage(playerid, "��ǥ�� ���۵��� �ʾҽ��ϴ�.");
		
		new string[MAX_MESSAGE_LENGTH];

		voteTime = 0;

		format(string, sizeof(string), "������ %s ���� ��ǥ�� ���߿� �ߴ��߽��ϴ�. ��ǥ ����� �����մϴ�.", GetPlayerNameEx(playerid));
		SystemClientMessageToAll(string);

		ShowVoteResult();
		ResetVoteResult();

		return 1;
	}

	if (strcmp(command, "/agree", true) == 0 || strcmp(command, "/����") == 0 || strcmp(command, "/��") == 0)
	{
		if (voteTime <= 0)
			return ErrorClientMessage(playerid, "��ǥ�� ���۵��� �ʾҽ��ϴ�.");
		
		if (playerVoted[playerid])
			return ErrorClientMessage(playerid, "�̹� ��ǥ�� �����ϼ̽��ϴ�.");
		
		playerVoted[playerid] = true;

		++voteAgree;

		SystemClientMessage(playerid, "��ǥ ������ ���� �����ϼ̽��ϴ�. ����� ��ٷ� �ּ���.");

		return 1;
	}

	if (strcmp(command, "/disagree", true) == 0 || strcmp(command, "/�ݴ�") == 0 || strcmp(command, "/��") == 0)
	{
		if (voteTime <= 0)
			return ErrorClientMessage(playerid, "��ǥ�� ���۵��� �ʾҽ��ϴ�.");
		
		if (playerVoted[playerid])
			return ErrorClientMessage(playerid, "�̹� ��ǥ�� �����ϼ̽��ϴ�.");
		
		playerVoted[playerid] = true;

		++voteDisagree;

		SystemClientMessage(playerid, "��ǥ ������ ���� �ݴ��ϼ̽��ϴ�. ����� ��ٷ� �ּ���.");

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
			
			SystemClientMessageToAll("��ǥ �ð��� 10�� ���ҽ��ϴ�. \"/��(��)\", \"/�ݴ�\"�� �ǰ��� ������ �ּ���.");
			format(string, sizeof(string), "����: %s", voteTopic);
			SystemClientMessageToAll(string);
		}
		else if (voteTime == 0)
		{
			SystemClientMessageToAll("��ǥ�� �������ϴ�. ��ǥ ����� �����մϴ�.");

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
		print("====================== ��ǥ =========================");
	
	format(string, sizeof(string), "����: %s", voteTopic);

	if (playerid == INVALID_PLAYER_ID)
	{
		SystemClientMessageToAll(string);
		ServerLog(LOG_TYPE_VOTE, string);
	}
	else
		SendClientMessage(playerid, 0xFFFFFFFF, string);
	
	format(string, sizeof(string), "���� ǥ: %d", voteAgree);
	
	if (playerid == INVALID_PLAYER_ID)
	{
		SystemClientMessageToAll(string);
		ServerLog(LOG_TYPE_VOTE, string);
	}
	else
		SendClientMessage(playerid, 0xFFFFFFFF, string);

	format(string, sizeof(string), "�ݴ� ǥ: %d", voteDisagree);
	
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
