/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Music cast system
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

#include "./CZ/Game/Inc/MusicCast.inc"

InitModule("Game_MusicCast")
{
	LoadMusicCasts();

	AddEventHandler(D_PlayerConnect, "G_MusicCast_PlayerConnect");
	AddEventHandler(D_PlayerDisconnect, "G_MusicCast_PlayerDisconnect");
	AddEventHandler(D_PlayerCommandText, "G_MusicCast_PlayerCommandText");
	AddEventHandler(D_DialogResponse, "G_MusicCast_DialogResponse");
	AddEventHandler(introFinishEvent, "G_MusicCast_PlayerIntroFinish");
}

function LoadMusicCasts()
{
	mysql_tquery(MySQL, "SELECT * FROM musiccast LIMIT "#MAX_MUSIC_CASTS"", "OnMusicCastLoad");
}

public OnMusicCastLoad()
{
	new errno = mysql_errno(MySQL);

	if (errno)
	{
		ServerLog(LOG_TYPE_MYSQL, "��۱� ����� �ҷ��� �� �����ϴ�.", errno);
		SendRconCommand("exit");

		return;
	}

	new index;
	new rows;

	cache_get_row_count(rows);

	for (new i = 0; i < rows; ++i)
	{
		cache_get_value_name_int(i, "id", index);

		if (index >= MAX_MUSIC_CASTS)
			continue;
		
		cache_get_value_name(i, "CastName", musicCasts[index][mName], 128);
		cache_get_value_name(i, "CastURL", musicCasts[index][mURL], 128);
	}
}

public G_MusicCast_PlayerConnect(playerid)
{
	selectCast[playerid] = -1;
	listenCast[playerid] = true;

	return 0;
}

public G_MusicCast_PlayerDisconnect(playerid)
{
	if (musicCastAddPlayer == playerid)
		musicCastAddPlayer = INVALID_PLAYER_ID;
	
	StopAudioStreamForPlayer(playerid);
	
	return 0;
}

public G_MusicCast_PlayerCommandText(playerid, const command[], const params[])
{
	if (strcmp(command, "/���ǹ��") == 0 || strcmp(command, "/��۱�") == 0 || strcmp(command, "/�뷡���") == 0)
	{
		ShowPlayerMusicCastDialog(playerid);

		return 1;
	}

	if (strcmp(command, "/�뷡���") == 0 || strcmp(command, "/��۵��") == 0 || strcmp(command, "/���ǵ��") == 0 || strcmp(command, "/�뷡") == 0 || strcmp(command, "/����") == 0)
	{
		if (listenCast[playerid])
		{
			listenCast[playerid] = false;

			if (IsMusicCasting())
				StopAudioStreamForPlayer(playerid);

			SystemClientMessage(playerid, "����� �����ϴ�. ������ ����� ���� �ʽ��ϴ�.");
		}
		else
		{
			listenCast[playerid] = true;

			if (IsMusicCasting())
				PlayMusicCastForPlayer(playerid);

			SystemClientMessage(playerid, "����� �׽��ϴ�.");
		}

		return 1;
	}

	if (strcmp(command, "/��۱���") == 0 || strcmp(command, "/���Ǳ���") == 0 || strcmp(command, "/�뷡����") == 0)
	{
		if (!IsPlayerAdmin(playerid))
			return ErrorClientMessage(playerid, "RCON �����ڸ� ����� �� �ֽ��ϴ�.");
		
		new string[MAX_MESSAGE_LENGTH];

		if (!GetParamString(string, params, 0))
			return SystemClientMessage(playerid, "����: /��۱��� [�÷��̾� ��ȣ/�̸��� �κ�]");
		
		new targetid = ReturnUser(string);
		
		if (!IsPlayerConnected(targetid))
			return ErrorClientMessage(playerid, "�������� ���� �÷��̾��Դϴ�.");

		format(string, sizeof(string), "������ %s ���� %s(id:%d)�Կ���", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), targetid);
		
		if (IsPlayerMusicCastAdmin(targetid))
		{
			playerInfo[targetid][pMusicCastAdmin] = 0;

			strcat(string, "�� ��� ������ ȸ���Ͽ����ϴ�.");
		}
		else
		{
			playerInfo[targetid][pMusicCastAdmin] = 1;

			strcat(string, " ��� ������ �����Ͽ����ϴ�.");
		}
		
		SystemClientMessageToAll(string);
		SavePlayerAccount(targetid);
		
		return 1;
	}

	return 0;
}

public G_MusicCast_DialogResponse(playerid, dialogid, response, listitem, const inputtext[])
{
	if (dialogid < DIALOG_MUSIC_CAST || dialogid > DIALOG_MUSIC_CAST + 6)
		return 0;
	
	switch (dialogid)
	{
	case DIALOG_MUSIC_CAST:
		{
			if (response == 0)
				return 1;
			
			switch (listitem)
			{
			case 0:
				ShowPlayerMusicCastDialog(playerid, 1);
			case 1:
				{
					if (!IsMusicCasting())
						return ErrorClientMessage(playerid, "����� ���������� �ʽ��ϴ�.");
					
					new string[MAX_MESSAGE_LENGTH];
					
					musicCastIndex = -1;
					musicCastManualURL = "";

					contloop (new i : playerList)
					{
						if (IsPlayerCurrentPlayer(i) && listenCast[i])
							StopAudioStreamForPlayer(i);
					}

					format(string, sizeof(string), "������ %s ���� ����� �����ϼ̽��ϴ�.", GetPlayerNameEx(playerid));
					SystemClientMessageToAll(string);
				}
			case 2:
				{
					if (IsPlayerConnected(musicCastAddPlayer))
					{
						ErrorClientMessage(playerid, "�ٸ� �����ڰ� ����� �߰��ϰ� �ֽ��ϴ�.");
						return ShowPlayerMusicCastDialog(playerid);
					}

					musicCastAddPlayer = playerid;

					ShowPlayerMusicCastDialog(playerid, 2);
				}
			case 3:
				ShowPlayerMusicCastDialog(playerid);
			default:
				{
					selectCast[playerid] = listitem - 4;

					ShowPlayerMusicCastDialog(playerid, 4);
				}
			}

			return 1;
		}
	case DIALOG_MUSIC_CAST + 1:
		{
			if (response == 0)
				return ShowPlayerMusicCastDialog(playerid);
			
			if (IsNull(inputtext))
				return ShowPlayerMusicCastDialog(playerid, 1);
			
			if (!IsValidMusicURL(inputtext))
			{
				ErrorClientMessage(playerid, "�ùٸ��� ���� URL�Դϴ�. �ٽ� �Է��� �ּ���.");
				return ShowPlayerMusicCastDialog(playerid, 1);
			}

			new bool: admin;

			if (IsPlayerAdmin(playerid) || IsPlayerSubAdmin(playerid) || IsPlayerMusicCastAdmin(playerid))
				admin = true;
			else if (GetPlayerMoney(playerid) < MUSIC_CAST_PRICE)
				return ErrorClientMessage(playerid, "����� �ϱ� ���ؼ��� $"#MUSIC_CAST_PRICE" (��)�� �ʿ��մϴ�.");

			new string[MAX_MESSAGE_LENGTH];

			musicCastIndex = -1;
			strcpy(musicCastManualURL, inputtext);

			contloop (new i : playerList)
			{
				if (IsPlayerCurrentPlayer(i) && listenCast[i])
				{
					StopAudioStreamForPlayer(i);
					PlayAudioStreamForPlayer(i, musicCastManualURL);
				}
			}

			if (!admin)
				GivePlayerMoney(playerid, -MUSIC_CAST_PRICE);
			else
				string = "������ ";

			format(string, sizeof(string), "%s%s ���� ����� �����ϼ̽��ϴ�.", string, GetPlayerNameEx(playerid));
			SystemClientMessageToAll(string);

			return 1;
		}
	case DIALOG_MUSIC_CAST + 2:
		{
			if (response == 0)
			{
				if (musicCastAddPlayer == playerid)
					musicCastAddPlayer = INVALID_PLAYER_ID;
				
				return ShowPlayerMusicCastDialog(playerid);
			}
			
			if (IsNull(inputtext))
				return ShowPlayerMusicCastDialog(playerid, 2);
			
			strcpy(musicCastAddName, inputtext);

			ShowPlayerMusicCastDialog(playerid, 3);

			return 1;
		}
	case DIALOG_MUSIC_CAST + 3:
		{
			if (response == 0)
			{
				musicCastAddPlayer = INVALID_PLAYER_ID;

				return ShowPlayerMusicCastDialog(playerid, 2);
			}

			if (IsNull(inputtext))
				return ShowPlayerMusicCastDialog(playerid, 3);
			
			if (!IsValidMusicURL(inputtext))
			{
				ErrorClientMessage(playerid, "�ùٸ��� ���� URL�Դϴ�. �ٽ� �Է��� �ּ���.");
				return ShowPlayerMusicCastDialog(playerid, 3);
			}
			
			musicCastAddPlayer = INVALID_PLAYER_ID;
			
			if (!AddMusicCast(playerid, musicCastAddName, inputtext))
				ErrorClientMessage(playerid, "���̻� ����� �߰��� �� �����ϴ�.");

			return 1;
		}
	case DIALOG_MUSIC_CAST + 4:
		{
			if (response == 0)
			{
				selectCast[playerid] = -1;

				return ShowPlayerMusicCastDialog(playerid);
			}

			new index = selectCast[playerid];

			if (IsNull(musicCasts[index][mName]))
			{
				selectCast[playerid] = -1;

				ErrorClientMessage(playerid, "�ٽ� �õ��� �ּ���.");
				return ShowPlayerMusicCastDialog(playerid);
			}

			if (listitem == 0)
			{
				if (IsNull(musicCasts[index][mName]))
				{
					ShowPlayerMusicCastDialog(playerid);

					return ErrorClientMessage(playerid, "�ٽ� �õ��� �ּ���.");
				}

				new string[MAX_MESSAGE_LENGTH];

				musicCastIndex = index;
				musicCastManualURL = "";

				strcpy(string, musicCasts[index][mURL]);

				contloop (new i : playerList)
				{
					if (IsPlayerCurrentPlayer(i) && listenCast[i])
					{
						StopAudioStreamForPlayer(i);
						PlayAudioStreamForPlayer(i, string);
					}
				}

				format(string, sizeof(string), "������ %s ���� ����� �����ϼ̽��ϴ�.", GetPlayerNameEx(playerid));
				SystemClientMessageToAll(string);
				format(string, sizeof(string), "��� �̸�: %s", musicCasts[index][mName]);
				SystemClientMessageToAll(string);
			}
			else if (listitem == 1)
				ShowPlayerMusicCastDialog(playerid, 5);
			else if (listitem == 2)
				ShowPlayerMusicCastDialog(playerid, 6);
			else if (listitem == 3)
			{
				if (!RemoveMusicCast(playerid, index))
				{
					ErrorClientMessage(playerid, "����� ������ �� �����ϴ�. �ٽ� �õ����ּ���.");
					return ShowPlayerMusicCastDialog(playerid);
				}
			}
			return 1;
		}
	case DIALOG_MUSIC_CAST + 5:
		{
			if (response == 0)
				return ShowPlayerMusicCastDialog(playerid, 4);
			
			if (IsNull(inputtext))
				return ShowPlayerMusicCastDialog(playerid, 5);
			
			new index = selectCast[playerid];

			if (IsNull(musicCasts[index][mName]))
			{
				selectCast[playerid] = -1;

				ErrorClientMessage(playerid, "�ٽ� �õ��� �ּ���.");
				return ShowPlayerMusicCastDialog(playerid);
			}

			new query[256];

			strcpy(musicCasts[index][mName], inputtext, 128);

			mysql_format(MySQL, query, sizeof(query), "UPDATE musiccast SET CastName = '%e' WHERE id = %d", inputtext, index);
			mysql_tquery(MySQL, query);

			SystemClientMessage(playerid, "��� �̸��� ���������� �����߽��ϴ�.");
			ShowPlayerMusicCastDialog(playerid, 4);

			return 1;
		}
	case DIALOG_MUSIC_CAST + 6:
		{
			if (response == 0)
				return ShowPlayerMusicCastDialog(playerid, 4);
			
			if (IsNull(inputtext))
				return ShowPlayerMusicCastDialog(playerid, 6);
			
			new index = selectCast[playerid];

			if (IsNull(musicCasts[index][mName]))
			{
				selectCast[playerid] = -1;

				ErrorClientMessage(playerid, "�ٽ� �õ��� �ּ���.");
				return ShowPlayerMusicCastDialog(playerid);
			}

			new query[256];

			strcpy(musicCasts[index][mURL], inputtext, 128);

			mysql_format(MySQL, query, sizeof(query), "UPDATE musiccast SET CastURL = '%e' WHERE id = %d", inputtext, index);
			mysql_tquery(MySQL, query);

			SystemClientMessage(playerid, "��� URL�� ���������� �����߽��ϴ�.");
			ShowPlayerMusicCastDialog(playerid, 4);

			return 1;
		}
	}

	return 0;
}

public G_MusicCast_PlayerIntroFinish(playerid)
{
	PlayMusicCastForPlayer(playerid);
}

function ShowPlayerMusicCastDialog(playerid, step = 0)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;
	
	switch (step)
	{
	case 0:
		{
			new string[4096] = { "{F29661}URL ���� �Է�" };

			if (IsPlayerAdmin(playerid) || IsPlayerSubAdmin(playerid) || IsPlayerMusicCastAdmin(playerid))
			{
				strcat(string, "\n{F15F5F}����\n{6799FF}��� �߰�\n \n");

				for (new i = 0; i < MAX_MUSIC_CASTS; ++i)
				{
					if (IsNull(musicCasts[i][mName]))
						break;
					
					format(string, sizeof(string), "%s%s\n", string, musicCasts[i][mName]);
				}
			}

			ShowPlayerDialog(playerid, DIALOG_MUSIC_CAST, DIALOG_STYLE_LIST, "��� �ý���", string, "����", "���");
		}
	case 1:
		ShowPlayerDialog(playerid, DIALOG_MUSIC_CAST + 1, DIALOG_STYLE_INPUT, "��� URL ���� �Է�", "����Ͻ� �����̳� ������ URL�� �Է��� �ּ���.\nhttp(s):// ���ξ �ݵ�� ���� �մϴ�.", "���", "����");
	case 2:
		ShowPlayerDialog(playerid, DIALOG_MUSIC_CAST + 2, DIALOG_STYLE_INPUT, "��� �߰�", "�߰��Ͻ� ����� �̸��� �Է��� �ּ���.", "����", "����");
	case 3:
		ShowPlayerDialog(playerid, DIALOG_MUSIC_CAST + 3, DIALOG_STYLE_INPUT, "��� �߰�", "�߰��Ͻ� ����� URL�� �Է��� �ּ���.\nhttp(s):// ���ξ �ݵ�� ���� �մϴ�.", "�Ϸ�", "����");
	case 4:
		{
			if (selectCast[playerid] == -1)
				ShowPlayerMusicCastDialog(playerid);
			else
				ShowPlayerDialog(playerid, DIALOG_MUSIC_CAST + 4, DIALOG_STYLE_LIST, musicCasts[selectCast[playerid]][mName], "����\n�̸� ����\nURL ����\n����", "����", "����");
		}
	case 5:
		ShowPlayerDialog(playerid, DIALOG_MUSIC_CAST + 5, DIALOG_STYLE_INPUT, "��� �̸� ����", "�����Ϸ��� ��� �̸��� �Է��� �ּ���.", "Ȯ��", "����");
	case 6:
		ShowPlayerDialog(playerid, DIALOG_MUSIC_CAST + 6, DIALOG_STYLE_INPUT, "��� URL ����", "�����Ϸ��� ��� URL�� �Է��� �ּ���.", "Ȯ��", "����");
	}
	
	return 1;
}

function AddMusicCast(playerid, const name[], const url[])
{
	new i;
	new query[512];

	for (i = 0; i < MAX_MUSIC_CASTS; ++i)
	{
		if (IsNull(musicCasts[i][mName]))
		{
			mysql_format(MySQL, query, sizeof(query), "INSERT INTO musiccast (id, CastName, CastURL) VALUES (%d, '%e', '%e')", i, name, url);
			mysql_tquery(MySQL, query, "OnMusicCastAdd", "iiss", playerid, i, name, url);

			break;
		}
	}

	return (i != MAX_MUSIC_CASTS);
}

public OnMusicCastAdd(playerid, index, const name[], const url[])
{
	new errno = mysql_errno(MySQL);

	if (errno)
	{
		ServerLog(LOG_TYPE_MYSQL, "����� �߰��� �� �����ϴ�.", errno);

		ErrorClientMessage(playerid, "����� �߰��� �� �����ϴ�. �ٽ� �õ����ּ���.");
		ShowPlayerMusicCastDialog(playerid);

		return;
	}
	strcpy(musicCasts[index][mName], name, 128);
	strcpy(musicCasts[index][mURL], url, 128);

	if (IsPlayerConnected(playerid))
	{
		SystemClientMessage(playerid, "����� ���������� �߰��߽��ϴ�.");
		ShowPlayerMusicCastDialog(playerid);
	}
}

function RemoveMusicCast(playerid, index)
{
	if (index < 0 || index >= MAX_MUSIC_CASTS)
		return 0;
	
	new query[128];

	format(query, sizeof(query), "DELETE FROM musiccast WHERE id = %d", index);
	mysql_tquery(MySQL, query, "OnMusicCastRemove", "iii", playerid, index, 0);

	return 1;
}

public OnMusicCastRemove(playerid, index, step)
{
	if (step < 2)
	{
		new errno = mysql_errno(MySQL);

		if (errno)
		{
			ServerLog(LOG_TYPE_MYSQL, "����� ������ �� �����ϴ�.", errno);

			ErrorClientMessage(playerid, "����� ������ �� �����ϴ�. �ٽ� �õ����ּ���.");
			ShowPlayerMusicCastDialog(playerid);

			return;
		}
	}

	new end = MAX_MUSIC_CASTS - 1;

	if (step == 0)
	{
		if (index < end)
		{
			new query[64];

			format(query, sizeof(query), "UPDATE musiccast SET id = id - 1 WHERE id > %d", index);
			mysql_tquery(MySQL, query, "OnMusicCastRemove", "iii", playerid, index, 1);
		}
		else
			OnMusicCastRemove(playerid, index, 2);
	}
	else
	{
		new i;

		for (i = index; i < end; ++i)
		{
			if (IsNull(musicCasts[i + 1][mName]))
				break;
			
			strcpy(musicCasts[i][mName], musicCasts[i + 1][mName], 128);
			strcpy(musicCasts[i][mName], musicCasts[i + 1][mName], 128);
		}

		strcpy(musicCasts[i][mName], "", 128);
		strcpy(musicCasts[i][mURL], "", 128);

		SystemClientMessage(playerid, "����� ���������� �����Ǿ����ϴ�.");
		ShowPlayerMusicCastDialog(playerid);
	}
}

function PlayMusicCastForPlayer(playerid)
{
	if (!IsPlayerCurrentPlayer(playerid))
		return 0;
	
	if ((musicCastIndex < 0 || musicCastIndex >= MAX_MUSIC_CASTS || IsNull(musicCasts[musicCastIndex][mName]) || IsNull(musicCasts[musicCastIndex][mURL])) && IsNull(musicCastManualURL))
		return 0;
	
	StopAudioStreamForPlayer(playerid);
	
	if (musicCastIndex >= 0)
		PlayAudioStreamForPlayer(playerid, musicCasts[musicCastIndex][mURL]);
	else
		PlayAudioStreamForPlayer(playerid, musicCastManualURL);

	return 1;
}

function bool: IsValidMusicURL(const url[])
{
	return (!IsNull(url) && (strcmp(url, "http://", true, 7) == 0 || strcmp(url, "https://", true, 8) == 0 || strcmp(url, "ftp://", true, 6) == 0));
}

function bool: IsMusicCasting()
{
	return (musicCastIndex != -1 || !IsNull(musicCastManualURL));
}

function bool: IsPlayerMusicCastAdmin(playerid)
{
	return (IsPlayerConnected(playerid) && playerInfo[playerid][pMusicCastAdmin] > 0);
}
