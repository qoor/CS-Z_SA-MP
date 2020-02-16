/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Base of round system
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

#include "./CZ/Game/Inc/Core.inc"
#include "./CZ/Game/Inc/Human.inc"
#include "./CZ/Game/Inc/Zombie.inc"
#include "./CZ/Game/Inc/Message.inc"
#include "./CZ/Game/Inc/MapScr.inc"

InitModule("Game")
{
	SetMapChangeType(MAP_CHANGE_TYPE_SHUFFLE);

	AddEventHandler(D_GameModeExit, "G_Core_GameModeExit");
	AddEventHandler(D_PlayerConnect, "G_Core_PlayerConnect");
	AddEventHandler(D_PlayerDisconnect, "G_Core_PlayerDisconnect");
	AddEventHandler(D_PlayerSpawn, "G_Core_PlayerSpawn");
	AddEventHandler(D_PlayerCommandText, "G_Core_PlayerCommandText");
	AddEventHandler(D_DialogResponse, "G_Core_DialogResponse");
	AddEventHandler(D_PlayerTakeDamage, "G_Core_PlayerTakeDamage");
	AddEventHandler(D_PlayerUpdate, "G_Core_PlayerUpdate");
	AddEventHandler(introFinishEvent, "G_Core_PlayerIntroFinish");
	AddEventHandler(global1sTimer, "G_Core_Global1sTimer");
	AddEventHandler(player1sTimer, "G_Core_Player1sTimer");
	AddEventHandler(global500msTimer, "G_Core_Global500msTimer");
	AddEventHandler(mapDataFuncFoundEvent, "G_Core_MapDataFuncFound");
	AddEventHandler(gamemodeMapStartEvent, "G_Core_GamemodeMapStart");
	AddEventHandler(playerSpawnedEvent, "G_Core_PlayerSpawned");

	AddModule("Game_Damage"); // IMPORTANT: Must be first.
	AddModule("Game_Human");
	AddModule("Game_Zombie");
	AddModule("Game_Message");
	AddModule("Game_Help");
	AddModule("Game_MusicCast");
	AddModule("Game_MapScr");
	AddModule("Game_Event");

	AddEventHandler(playerKilledEvent, "G_Core_PlayerKilled");
}

public G_Core_GameModeExit()
{
	if (reboot)
		ClearDeathMessages();
}

public G_Core_PlayerConnect(playerid)
{
	new string[MAX_MESSAGE_LENGTH];

	RemovePlayerAttachedObjects(playerid);
	
	currentPlayer[playerid] = false;
	killCount[playerid] = 0;
	playerWarnings[playerid] = 0;
	deathAtWater[playerid] = false;
	santaHatDisable[playerid] = false;
	godMode[playerid] = false;
	playerDeathTick[playerid] = 0;
	grenadeEffectOff[playerid] = false;

	// Chicken game
	new bool: chicken = (strcmp(GetPlayerNameEx(playerid), "Chicken", true, 7) == 0 || IsPlayerInRangeOfIp(playerid, "123.109.*.*"));
	
	playerChicken[playerid] = chicken;
	playerChickenSpin[playerid] = 0.0;
	//

	ResetPlayerLastDeathPos(playerid);

	format(string, sizeof(string), "[접속] %s(id:%d)님께서 서버에 입장하셨습니다.", GetPlayerNameEx(playerid), playerid);
	SendClientMessageToAll(0xA9A9A9AA, string);

	SetPlayerColor(playerid, 0xFFFFFFFF);
	return 0;
}

public G_Core_PlayerDisconnect(playerid)
{
	if (skillEndTimer[playerid] != 0)
	{
		KillTimer(skillEndTimer[playerid]);

		skillEndTimer[playerid] = 0;
	}

	if (!reboot)
	{
		new string[MAX_MESSAGE_LENGTH];

		format(string, sizeof(string), "[퇴장] %s(id:%d)님께서 퇴장하셨습니다.", GetPlayerNameEx(playerid), playerid);
		SendClientMessageToAll(0xA9A9A9AA, string);
	}

	if (freezeTimer[playerid] != 0)
	{
		KillTimer(freezeTimer[playerid]);
		freezeTimer[playerid] = 0;
	}

	if (godModeTimer[playerid] != 0)
	{
		KillTimer(godModeTimer[playerid]);
		godModeTimer[playerid] = 0;
	}

	if (currentPlayer[playerid])
	{
		new gameProgress = IsGameProgress();

		--gameInfo[gPlayers];

		if (IsGameCount() || gameProgress)
		{
			if (gameInfo[gPlayers] >= 2)
			{
				if (IsPlayerHuman(playerid))
				{
					--gameInfo[gHumans];

					if (heroPlayer == playerid)
						heroPlayer = INVALID_PLAYER_ID;
				}
				else if (IsPlayerZombie(playerid) && gameProgress)
				{
					--gameInfo[gZombies];

					if (hostZombie == playerid)
						hostZombie = INVALID_PLAYER_ID;
				}
			}

			CheckGameState();
		}

		currentPlayer[playerid] = false;
	}

	return 0;
}

public G_Core_PlayerSpawn(playerid)
{
	playerDeathTick[playerid] = 0;

	ApplyAnimation(playerid, "SWAT", "swt_vnt_sht_die", 4.1, 0, 0, 0, 0, 0, 1); // Burrow animation fix
	RemovePlayerAttachedObjects(playerid);

	if (!IsGameCount() && !IsGameProgress())
	{
		if (!mapChanging)
		{
			SetPlayerPos(playerid, 1386.0767, -904.8605, 35.9753);
			SetCameraBehindPlayer(playerid);

			if (gameInfo[gPlayers] >= 2)
				SetRequestMapStart();
			else
			{
				InfoClientMessage(playerid, "게임을 시작하려면 2명 이상의 플레이어가 있어야 합니다.");
				InfoClientMessage(playerid, "다른 플레이어가 올 때 까지 기다려 주세요.");
			}
		}
	}

	return 0;
}

public G_Core_PlayerCommandText(playerid, const command[], const params[])
{
	// Chicken game
	if (IsPlayerChicken(playerid))
	{
		ErrorClientMessage(playerid, "니는 아무 명령어도 못 써.");
		return 1;
	}
	//

	/*if (strcmp(command, "/무기설정") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		new string[MAX_PLAYER_NAME];

		if (!GetParamString(string, params, 0))
			return ErrorClientMessage(playerid, "사용법: /무기설정 [플레이어 번호/이름의 부분] [index = -1]");
		
		new targetid = ReturnUser(string);

		if (!IsPlayerConnected(playerid))
			return ErrorClientMessage(playerid, "접속하지 않은 플레이어입니다.");
		
		new index;

		if (!GetParamInt(index, params, 1))
			index = -1;
		
		SetPlayerHuman(targetid, index);
		return 1;
	}*/
	/*if (strcmp(command, "/무기받기") == 0)
	{
		new weaponid;

		if (!GetParamInt(weaponid, params, 0))
			return ErrorClientMessage(playerid, "사용법: /무기받기 [무기] [총알]");
		
		if (weaponid < 0 || weaponid > 46)
			return ErrorClientMessage(playerid, "잘못된 무기 번호입니다.");
		
		new ammo;

		if (!GetParamInt(ammo, params, 1))
			return ErrorClientMessage(playerid, "사용법: /무기받기 [무기] [총알]");
		
		GivePlayerWeapon(playerid, weaponid, ammo);

		return 1;
	}*/

	/*if (strcmp(command, "/내상태") == 0)
	{
		new string[MAX_MESSAGE_LENGTH];

		ClearMessage(playerid);

		format(string, sizeof(string), "전체 인원수: %d명", gameInfo[gPlayers]);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "인간: %d명", gameInfo[gHumans]);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "좀비: %d명", gameInfo[gZombies]);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "내 상태: %s", IsPlayerHuman(playerid) ? ("인간") : IsPlayerZombie(playerid) ? ("좀비") : ("게임에 참가되지 않음"));
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "오리지널 팀: %d", GetPlayerTeam(playerid));
		SendClientMessage(playerid, -1, string);
		new Float: health;
		GetPlayerHealth(playerid, health);
		format(string, sizeof(string), "체력: %.4f", health);
		SendClientMessage(playerid, -1, string);

		return 1;
	}*/

	/*if (strcmp(command, "/좀비변경") == 0)
	{
		new type;
		
		if (!GetParamInt(type, params, 0))
			return ErrorClientMessage(playerid, "사용법: /좀비변경 [좀비 코드]");

		if (type >= ZOMBIE_TYPE_NORMAL_HOST && type < ZOMBIE_TYPE_NORMAL)
			SetPlayerHostZombie(playerid, type);
		else if (type >= ZOMBIE_TYPE_NORMAL && type <= ZOMBIE_TYPE_STINGFINGER)
			SetPlayerZombie(playerid, type);
		else
			ErrorClientMessage(playerid, "올바르지 않은 좀비 코드입니다.");

		return 1;
	}*/

	if (strcmp(command, "/칭호") == 0)
	{
		if (playerInfo[playerid][pTitleType] >= sizeof(titleList))
		{
			playerInfo[playerid][pTitleType] = sizeof(titleList) - 1;

			SavePlayerAccount(playerid);

			return ErrorClientMessage(playerid, "이미 정점에 오르셨습니다.");
		}
		
		new string[MAX_MESSAGE_LENGTH];

		if (playerInfo[playerid][pUpgIntelligence] <= playerInfo[playerid][pTitleType])
		{
			format(string, sizeof(string), "지식이 부족합니다. 칭호를 업그레이드 하기 위해서는 지식이 %d만큼 더 필요합니다.", (playerInfo[playerid][pTitleType] + 1) - playerInfo[playerid][pUpgIntelligence]);
			return ErrorClientMessage(playerid, string);
		}

		new price = (playerInfo[playerid][pTitleType] + 1) * 100000;

		if (GetPlayerMoney(playerid) < price)
		{
			format(string, sizeof(string), "칭호 비용으로 $%d가 더 필요합니다. (총 $%d)", price - GetPlayerMoney(playerid), price);
			return ErrorClientMessage(playerid, string);
		}

		UpgradePlayerTitle(playerid);
		GivePlayerMoney(playerid, -price);

		format(string, sizeof(string), "칭호가 기존 %s 에서 %s 로 변경되었습니다.", GetTitleName(playerInfo[playerid][pTitleType] - 1), GetTitleName(playerInfo[playerid][pTitleType]));
		SystemClientMessage(playerid, string);

		return 1;
	}

	if (strcmp(command, "/스카우터") == 0)
	{
		if (GetPlayerMoney(playerid) < 1000)
			return ErrorClientMessage(playerid, "$1000가 필요합니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		if (GetParamString(string, params, 0) == 0)
			return ErrorClientMessage(playerid, "사용법: /스카우터 [플레이어 번호/이름의 부분]");
		
		new targetid = ReturnUser(string);

		if (!IsPlayerConnected(targetid))
			return ErrorClientMessage(playerid, "접속하지 않은 플레이어입니다.");
		
		new targetAntibody = GetPlayerAntibody(targetid);

		GivePlayerMoney(playerid, -1000);

		if (GetPlayerAntibody(playerid) < targetAntibody)
			ErrorClientMessage(playerid, "스카우터가 측정이 불가능한 대상입니다.");
		else
		{
			format(string, sizeof(string), "%s(id:%d)님의 항체력은 %d 입니다!", GetPlayerNameEx(targetid), targetid, targetAntibody);
			SystemClientMessage(playerid, string);
		}

		return 1;
	}

	if (strcmp(command, "/mapid", true) == 0 || strcmp(command, "/mapinfo", true) == 0 || strcmp(command, "/map", true) == 0 ||
		strcmp(command, "/맵번호") == 0 || strcmp(command, "/맵정보") == 0 || strcmp(command, "/맵") == 0)
	{
		if (GetGameTime() == -1)
			return ErrorClientMessage(playerid, "현재 게임이 진행중이지 않습니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		format(string, sizeof(string), "현재 맵은 %s(id:%d) 입니다.", currentMapName, currentMap);
		SystemClientMessage(playerid, string);

		return 1;
	}

	if (strcmp(command, "/stop", true) == 0 || strcmp(command, "/게임중지") == 0 || strcmp(command, "/중지") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		if (GetGameTime() == -1)
			return ErrorClientMessage(playerid, "현재 게임이 진행중이지 않습니다.");
		
		new string[MAX_MESSAGE_LENGTH];
		
		SetRequestMapStart(1);
		
		format(string, sizeof(string), "관리자 %s 님이 라운드를 스킵하셨습니다.", GetPlayerNameEx(playerid));
		SystemClientMessageToAll(string);

		return 1;
	}

	if (strcmp(command, "/redo", true) == 0 || strcmp(command, "/재시작") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		if (GetGameTime() == -1)
			return ErrorClientMessage(playerid, "현재 게임이 진행중이지 않습니다.");
		
		new string[MAX_MESSAGE_LENGTH];
		
		format(string, sizeof(string), "관리자 %s 님이 현재 맵으로 라운드를 재시작 하셨습니다.", GetPlayerNameEx(playerid));
		SystemClientMessageToAll(string);

		redo = true;

		SetRequestMapStart(1);

		return 1;
	}

	if (strcmp(command, "/changemap", true) == 0 || strcmp(command, "/mapchange", true) == 0 || strcmp(command, "/맵변경") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		new mapid;

		if (!GetParamInt(mapid, params, 0))
			return ShowPlayerMapChangeDialog(playerid);
		
		if (!IsValidMap(mapid))
		{
			new minMap, maxMap;
			new string[MAX_MESSAGE_LENGTH];

			GetMinMaxMapID(minMap, maxMap);

			ErrorClientMessage(playerid, "올바르지 않은 맵 번호입니다.");
			format(string, sizeof(string), "현재 서버에 %d ~ %d까지의 맵이 있습니다.", minMap, maxMap);
			InfoClientMessage(playerid, string);

			return 1;
		}

		if (currentMap == mapid)
			return ErrorClientMessage(playerid, "이미 해당 맵으로 라운드가 진행중입니다. 라운드 재시작을 해야 할 경우 \"/redo\"을(를) 사용해 주세요.");
		
		ChangeMapFromPlayer(playerid, mapid);

		return 1;
	}

	if (strcmp(command, "/mapchangetype", true) == 0 || strcmp(command, "/맵체인지타입") == 0 || strcmp(command, "/맵체인지방식") == 0 ||
		strcmp(command, "/맵첸타입") == 0 || strcmp(command, "/맵첸방식") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		new type;

		if (!GetParamInt(type, params, 0))
			return ErrorClientMessage(playerid, "사용법: /맵체인지타입 [0: 오름차순, 1: 내림차순, 2: 랜덤, 3: 셔플(기본값)");
		
		if (type < MAP_CHANGE_TYPE_ASC || type > MAP_CHANGE_TYPE_SHUFFLE)
			return ErrorClientMessage(playerid, "올바르지 않은 맵 체인지 타입입니다.");
		
		new string[MAX_MESSAGE_LENGTH];
		
		SetMapChangeType(type);

		format(string, sizeof(string), "관리자 %s 님이 맵 체인지 방식을 %s(으)로 변경하였습니다.", GetPlayerNameEx(playerid),
			(type == MAP_CHANGE_TYPE_ASC) ? ("오름차순") : (type == MAP_CHANGE_TYPE_DESC) ? ("내림차순") : (type == MAP_CHANGE_TYPE_RANDOM) ? ("랜덤") : ("셔플"));
		SystemClientMessageToAll(string);

		return 1;
	}

	if (strcmp(command, "/kill", true) == 0 || strcmp(command, "/자살") == 0)
	{
		if (IsGameCount())
			return ErrorClientMessage(playerid, "카운트가 진행 될 땐 자살을 할 수 없습니다.");
		
		if (pipeBombTargeted[playerid] != INVALID_PLAYER_ID)
			return ErrorClientMessage(playerid, "Pipe Bomb에 휘말린 상태에서는 자살을 할 수 없습니다.");
		
		if (GetPlayerState(playerid) != PLAYER_STATE_WASTED)
		{
			KillPlayer(playerid);
		}

		return 1;
	}

	if (strcmp(command, "/report", true) == 0 || strcmp(command, "/신고") == 0)
	{
		new string[MAX_MESSAGE_LENGTH];

		if (GetParamString(string, params, 0) == 0)
			return ErrorClientMessage(playerid, "사용법: /신고 [플레이어 번호/이름의 부분] [신고할 내용]");
		
		new targetid = ReturnUser(string);

		if (!IsPlayerConnected(targetid))
			return ErrorClientMessage(playerid, "존재하지 않는 플레이어입니다.");

		new result [MAX_MESSAGE_LENGTH];

		MergeParams(result, params, 1);

		if (IsNull(result))
			return ErrorClientMessage(playerid, "사용법: /신고 [플레이어 번호/이름의 부분] [신고할 내용]");
		
		format(string, sizeof(string), "%s(%d) → %s(%d) {FF0000}[이유: %s]", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(targetid), targetid, result);
		SendAdminMessage(0xFFFFFFFF, string);

		SystemClientMessage(playerid, "신고 내용이 정상적으로 접수되었습니다.");

		return 1;
	}

	if (strcmp(command, "/warning", true) == 0 || strcmp(command, "/warn", true) == 0 || strcmp(command, "/경고") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		if (GetParamString(string, params, 0) == 0)
			return ErrorClientMessage(playerid, "사용법: /경고 [플레이어 번호/이름의 부분] [경고 사유]");
		
		new targetid = ReturnUser(string);

		if (!IsPlayerConnected(targetid))
			return ErrorClientMessage(playerid, "접속하지 않은 플레이어입니다.");
		
		new result[MAX_MESSAGE_LENGTH];

		MergeParams(result, params, 1);

		if (IsNull(result))
			return ErrorClientMessage(playerid, "사용법: /경고 [플레이어 번호/이름의 부분] [경고 사유]");
		
		++playerWarnings[targetid];

		format(string, sizeof(string), "%s(id:%d)님이 관리자 %s 님에 의해 경고를 받았습니다. {FF0000}[사유: %s] [%d/"#MAX_PLAYER_WARNINGS"]", GetPlayerNameEx(targetid), targetid, GetPlayerNameEx(playerid),
			result, playerWarnings[targetid]);
		SendClientMessageToAll(0xFFFFFFFF, string);

		if (playerWarnings[targetid] >= MAX_PLAYER_WARNINGS)
		{
			format(string, sizeof(string), "%s(id:%d)님이 경고 3회를 받아 접속이 종료됩니다.", GetPlayerNameEx(targetid), targetid);
			SendClientMessageToAll(0xFFFFFFFF, string);

			Kick(targetid);
		}
		
		return 1;
	}

	if (strcmp(command, "/경고차감") == 0 || strcmp(command, "/차감") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		if (GetParamString(string, params, 0) == 0)
			return ErrorClientMessage(playerid, "사용법: /(경고)차감 [플레이어 번호/이름의 부분] [차감 사유]");
		
		new targetid = ReturnUser(string);

		if (!IsPlayerConnected(targetid))
			return ErrorClientMessage(playerid, "접속하지 않은 플레이어입니다.");
		
		if (playerWarnings[targetid] <= 0)
			return ErrorClientMessage(playerid, "차감 받을 수 있는 경고가 없습니다.");
		
		new result[MAX_MESSAGE_LENGTH];

		MergeParams(result, params, 1);

		if (IsNull(result))
			return ErrorClientMessage(playerid, "사용법: /(경고)차감 [플레이어 번호/이름의 부분] [차감 사유]");
		
		--playerWarnings[targetid];

		format(string, sizeof(string), "%s(id:%d)님이 관리자 %s 님에 의해 경고가 차감되었습니다. {FF0000}[사유: %s] [%d/"#MAX_PLAYER_WARNINGS"]", GetPlayerNameEx(targetid), targetid,
			GetPlayerNameEx(playerid), result, playerWarnings[targetid]);
		SendClientMessageToAll(0xFFFFFFFF, string);
		
		return 1;
	}

	if (strcmp(command, "/건의사항") == 0 || strcmp(command, "/건의") == 0)
	{
		new result[128];

		if (!MergeParams(result, params, 0))
			return ErrorClientMessage(playerid, "사용법: /건의(사항) [건의 할 내용]");

		new string[MAX_MESSAGE_LENGTH];

		format(string, sizeof(string), "%s님의 건의: {FFFFFF}%s", GetPlayerNameEx(playerid), result);
		SendAdminMessage(0x00FFFFFF, string);
		format(string, sizeof(string), "%s: %s", GetPlayerNameEx(playerid), result);
		ServerLog(LOG_TYPE_SUGGESTION, string);

		SystemClientMessage(playerid, "건의 사항이 관리자에게 전달되었습니다.");

		return 1;
	}

	if (strcmp(command, "/모자") == 0 || strcmp(command, "/산타모자") == 0 || strcmp(command, "/산타모") == 0)
	{
		new month, temp;

		getdate(temp, month, temp);

		if (month != 12)
			return ErrorClientMessage(playerid, "크리스마스 시즌 기간이 아닙니다.");
		
		if (!santaHatDisable[playerid])
		{
			santaHatDisable[playerid] = true;

			if (IsPlayerAttachedObjectSlotUsed(playerid, 3))
				RemovePlayerAttachedObject(playerid, 3);
			
			SystemClientMessage(playerid, "산타 모자를 벗었습니다.");
		}
		else
		{
			santaHatDisable[playerid] = false;

			SetPlayerAttachedObject(playerid, 3, 19065, 2, 0.120000, 0.040000, -0.003500, 0.0, 100.0, 100.0, 1.4, 1.4, 1.4);
			SystemClientMessage(playerid, "산타 모자를 썼습니다.");
		}

		return 1;
	}

	if (strcmp(command, "/소생") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return SystemClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		new targetid;

		if (!GetParamInt(targetid, params, 0))
			return SystemClientMessage(playerid, "사용법: /소생 [플레이어 번호/이름의 부분] [사유]");
		
		if (!IsPlayerCurrentPlayer(targetid))
			return ErrorClientMessage(playerid, "접속하지 않았거나 로그인을 하지 않은 플레이어입니다.");
		if (IsPlayerHuman(targetid) || (!IsPlayerHuman(targetid) && !IsPlayerZombie(targetid)))
			return ErrorClientMessage(playerid, "소생할 수 없는 플레이어입니다.");
		
		new result[64];

		if (!MergeParams(result, params, 1))
			return SystemClientMessage(playerid, "사용법: /소생 [플레이어 번호/이름의 부분] [사유]");

		new string[MAX_MESSAGE_LENGTH];

		if (hostZombie == targetid)
			hostZombie = INVALID_PLAYER_ID;
		
		SetPlayerHuman(targetid);

		format(string, sizeof(string), "관리자 %s 님이 %s(id:%d)님을 소생시켰습니다. [사유: %s]", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), targetid, result);
		return SystemClientMessageToAll(string);
	}

	if (strcmp(command, "/동의") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		if (!GetParamString(string, params, 0))
		{
			SystemClientMessage(playerid, "사용법: /동의 [항목]");
			SystemClientMessage(playerid, " 항복");

			return 1;
		}

		if (strcmp(string, "항복") == 0)
		{
			if (!IsZombieWantSurrender())
				return ErrorClientMessage(playerid, "숙주 좀비가 항복 요청을 하지 않았거나 게임이 진행중이지 않습니다.");
			
			SetZombieWantSurrender(false);
			OnGameRoundFinish(GAMEOVER_TYPE_HUMAN_WIN);

			format(string, sizeof(string), "숙주 좀비 %s(id:%d)(이)가 항복했습니다.", GetPlayerNameEx(hostZombie), hostZombie);
			NewsClientMessageToAll(string);
		}
		else
			ErrorClientMessage(playerid, "알 수 없는 항목입니다.");
		
		return 1;
	}

	if (strcmp(command, "/거절") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		new string[MAX_MESSAGE_LENGTH];

		if (!GetParamString(string, params, 0))
		{
			SystemClientMessage(playerid, "사용법: /거절 [항목]");
			SystemClientMessage(playerid, " 항복");

			return 1;
		}

		if (strcmp(string, "항복") == 0)
		{
			if (!IsZombieWantSurrender())
				return ErrorClientMessage(playerid, "숙주 좀비가 없거나 항복 요청을 하지 않았거나 게임이 진행중이지 않습니다.");
			
			SetZombieWantSurrender(false);

			format(string, sizeof(string), "관리자 %s(id:%d)님이 숙주 좀비 %s(id:%d)의 항복 요청을 거절했습니다.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(hostZombie), hostZombie);
			SendAdminMessage(0xFF0000FF, string);

			SystemClientMessage(hostZombie, "관리자가 항복 요청을 거절했습니다.");
		}
		else
			ErrorClientMessage(playerid, "알 수 없는 항목입니다.");
		
		return 1;
	}

	// Chicken game
	if (strcmp(command, "/치킨") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
		{
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		}

		new string[MAX_MESSAGE_LENGTH];

		if (!GetParamString(string, params, 0))
		{
			SystemClientMessage(playerid, "사용법: /치킨 [플레이어 번호/이름의 부분]");
			return 1;
		}

		new targetid = ReturnUser(string);

		if (!IsPlayerConnected(targetid) || !IsPlayerLoggedIn(targetid))
		{
			ErrorClientMessage(playerid, "접속하지 않았거나 로그인 하지 않은 플레이어입니다.");
			return 1;
		}

		if (IsPlayerChicken(targetid))
		{
			playerChicken[targetid] = false;

			format(string, sizeof(string), "당신은 %s(id:%d)님을 치킨 게임에서 풀려나게 했습니다.", GetPlayerNameEx(targetid), targetid);
			InfoClientMessage(playerid, string);
			SystemClientMessage(targetid, "당신은 치킨 게임에서 풀려났습니다.");
		}
		else
		{
			playerChicken[targetid] = true;

			format(string, sizeof(string), "당신은 %s(id:%d) 이 새끼를 치킨 게임으로 초대합니다.", GetPlayerNameEx(targetid), targetid);
			InfoClientMessage(playerid, string);
			SystemClientMessage(targetid, "치킨아 내 눈을 피해갈 수 있을거 같아?");
		}

		return 1;
	}
	//

	return 0;
}

public G_Core_PlayerDeath(playerid)
{
	TogglePlayerGodMode(playerid, false);
	return 0;
}

public G_Core_DialogResponse(playerid, dialogid, response, listitem)
{
	if (dialogid == DIALOG_CHANGE_MAP)
	{
		if (response == 0 || (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2)))
			return 1;
		
		new mapId;

		if (!GetPlayerDialogListValue(playerid, listitem, mapId) || !ChangeMapFromPlayer(playerid, mapId))
			ShowPlayerMapChangeDialog(playerid);
		
		return 1;
	}

	return 0;
}

public G_Core_PlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
	if (weaponid == 51 && issuerid != playerid && grenadeEffectOff[playerid])
	{
		new Float: vx, Float: vy, Float: vz;

		GetPlayerVelocity(playerid, vx, vy, vz);
		SetPlayerVelocity(playerid, vx, vy, vz);
	}

	return 0;
}

public G_Core_PlayerUpdate(playerid)
{
	// Chicken game
	if (IsPlayerChicken(playerid))
	{
		if (IsPlayerLoggedIn(playerid))
		{
			if ((playerChickenSpin[playerid] += 10.0) > 180.0)
			{
				playerChickenSpin[playerid] = -180.0;
			}

			SetPlayerFacingAngle(playerid, playerChickenSpin[playerid]);
		}
	}
	//

	return 1;
}

public G_Core_PlayerIntroFinish(playerid)
{
	if (IsPlayerConnected(playerid))
	{
		++gameInfo[gPlayers];

		currentPlayer[playerid] = true;

		SetPlayerTime(playerid, 6, 0);
		TextDrawShowForPlayer(playerid, gameTimeText);
		TextDrawShowForPlayer(playerid, healthText[playerid]);
		ClearMessage(playerid);
	}
}

public G_Core_Global1sTimer()
{
	if (GetGameTime() != -1)
	{
		if ((++gameInfo[gWorldMinute]) >= 60)
		{
			gameInfo[gWorldMinute] = 0;

			if ((++gameInfo[gWorldHour]) > 24)
				gameInfo[gWorldHour] = 0;
		}
	}

	return 0;
}

public G_Core_Player1sTimer(playerid)
{
	if (IsPlayerCurrentPlayer(playerid) && GetGameTime() != -1)
	{
		new hour, minute;

		GetPlayerTime(playerid, hour, minute);

		if (hour != gameInfo[gWorldHour] || minute != gameInfo[gWorldMinute])
			SetPlayerTime(playerid, gameInfo[gWorldHour], gameInfo[gWorldMinute]);

		if (!IsMapDisallowWaterDeath(currentMap))
		{
			new animlib[32], animname[32];

			GetAnimationName(GetPlayerAnimationIndex(playerid), animlib, sizeof(animlib), animname, sizeof(animname));

			if (!IsNull(animlib) && strcmp(animlib, "SWIM") == 0)
			{
				deathAtWater[playerid] = true;

				KillPlayer(playerid);
			}
		}

		if (playerDeathTick[playerid] != 0 && GetTickCount() - playerDeathTick[playerid] >= 8000)
			OnPlayerSpawn(playerid);
		
		if (IsPlayerChicken(playerid))
		{
			if (GetPlayerDrunkLevel(playerid) < 4500)
			{
				SetPlayerDrunkLevel(playerid, 5000);
			}
		}
	}
	
	return 0;
}

public G_Core_Global500msTimer()
{
	new gameTime = GetGameTime();

	if (gameTime != -1 && gameTime != gameInfo[gLastGameTime])
	{
		new string[32];
		new count = GetGameCount();
		new ramainingTime = gameInfo[gGameTime] - gameTime;

		format(string, sizeof(string), "Timeleft ~w~: %d (%d)", ramainingTime, gameInfo[gHumans]);

		if (IsNull(oldGameTimeText) || strcmp(string, oldGameTimeText) != 0)
		{
			TextDrawSetString(gameTimeText, string);
			
			oldGameTimeText = string;
		}

		if (count > 0)
			TriggerEventNoSuspend(gameCountEvent, "i", count);

		if (IsGameProgress())
		{
			if (ramainingTime == GAME_TIME)
				TriggerEventNoSuspend(gameCountEndEvent, "");
			
			if (!mapChanging && gameTime >= gameInfo[gGameTime])
				OnGameRoundFinish((gameInfo[gHumans] > 0) ? GAMEOVER_TYPE_HUMAN_WIN : GAMEOVER_TYPE_PLAYERSHORTAGE);
		}

		gameInfo[gLastGameTime] = gameTime;
	}

	return 0;
}

public G_Core_MapDataFuncFound(const tag[], const func[], const value[])
{
	new parameter[3][16];

	if (strcmp(tag, "spawnpoint", true) == 0)
	{
		split(value, parameter, ',');
		CreateSpawnPoint(floatstr(parameter[0]), floatstr(parameter[1]), floatstr(parameter[2]));
	}
}

public G_Core_GamemodeMapStart()
{
	new string[MAX_MESSAGE_LENGTH];

	SetWeather(10);
	ClearDeathMessages();
	
	gameInfo[gGameTime] = GAME_TIME + GAME_COUNT_TIME;
	gameInfo[gWorldMinute] = 0;
	gameInfo[gWorldHour] = 0;
	gameInfo[gZombies] = 0;
	gameInfo[gHumans] = 0;

	format(string, sizeof(string), "Map Name: %s", currentMapName);

	contloop (new playerid : playerList)
	{
		killCount[playerid] = 0;
		zombieType[playerid] = 0;
		deathAtWater[playerid] = false;

		ResetPlayerLastDeathPos(playerid);

		if (!IsPlayerCurrentPlayer(playerid))
			continue;
		
		TogglePlayerControllable(playerid, 1);
		ClearAnimations(playerid, 1);

		CheckHumanCount(playerid);
		zombieType[playerid] = -1;

		SystemClientMessage(playerid, string);

		if (GetPlayerState(playerid) != PLAYER_STATE_WASTED)
			SpawnPlayer(playerid);
	}

	gameInfo[gGameStartTime] = GetTickCount();

	contloop (new playerid : playerList)
	{
		SetPlayerTeam(playerid, NO_TEAM);
		SetPlayerTeam(playerid, DEFAULT_TEAM);
	}
}

public G_Core_PlayerSpawned(playerid)
{
	GivePlayerParachute(playerid);
	
	if (santaHatDisable[playerid])
		return;
	
	new year, month, day;
	
	getdate(year, month, day);

	if (month == 12)
		SetPlayerAttachedObject(playerid, 3, 19065, 2, 0.120000, 0.040000, -0.003500, 0.0, 100.0, 100.0, 1.4, 1.4, 1.4);
}

public OnRequestMapStart()
{
	startDelayTimer = 0;
	mapChanging = false;

	if (redo)
	{
		redo = false;
		
		SetNextMap(currentMap);
	}

	StartNextMap();
}

public OnGameRoundFinish(type)
{
	gameInfo[gGameStartTime] = 0;
	gameInfo[gLastGameTime] = 0;
	gameInfo[gGameTime] = 0;

	if (!reboot)
	{
		if (type == GAMEOVER_TYPE_PLAYERSHORTAGE)
		{
			TextDrawSetString(gameTimeText, "Time Left : READY (!)");

			NewsClientMessageToAll("게임 참가자가 2명 미만이 되어 게임이 종료됩니다.");
			NewsClientMessageToAll("다른 플레이어가 올 때 까지 기다려 주세요.");
		}
		else
		{
			TriggerEventNoSuspend(gameRoundFinishEvent, "i", type);

			if (gameInfo[gPlayers] >= 2)
				SetRequestMapStart();
		}
	}
}

public OnPlayerRequestUnfreeze(playerid)
{
	freezeTimer[playerid] = 0;

	if (IsPlayerConnected(playerid))
	{
		TogglePlayerControllable(playerid, 1);
		SetPlayerChatBubble(playerid, "", 0xFFFFFFFF, 1.0, 1000);
	}
}

public OnPlayerSpawned(playerid)
{
	TriggerEventNoSuspend(playerSpawnedEvent, "i", playerid);
}

public OnPlayerGodModeTimeEnd(playerid)
{
	if (!IsPlayerConnected(playerid))
		return;

	godMode[playerid] = false;
	godModeTimer[playerid] = 0;

	SetPlayerChatBubble(playerid, " ", 0xFFFFFF00, 1.0, 100);
}

public OnPlayerRespawnKill(playerid, Float: amount)
{
	/*SystemClientMessage(playerid, "리스폰 킬을 시도하셔서 사살됩니다.");
	KillPlayer(playerid);*/

	GivePlayerDamage(INVALID_PLAYER_ID, playerid, WEAPON_DROWN, amount);
	SystemClientMessage(playerid, "리스폰 킬을 시도할 시 본인의 체력도 같이 감소합니다.");
}

public G_Core_PlayerKilled(playerid, killerid, reason)
{
	SendDeathMessage(lastDamagedPlayer[playerid], playerid, reason);
	return 1;
}

function SetRequestMapStart(fastStart = 0)
{
	if (gameInfo[gPlayers] <= 1)
		return 0;
	
	gameInfo[gGameStartTime] = 0;
	gameInfo[gLastGameTime] = 0;
	gameInfo[gGameTime] = 0;

	for (new i = 0, len = gameInfo[gSpawnPointCount]; i < len; ++i)
	{
		gameInfo[gSpawnPointX][i] = 0.0;
		gameInfo[gSpawnPointY][i] = 0.0;
		gameInfo[gSpawnPointZ][i] = 0.0;
	}

	gameInfo[gSpawnPointCount] = 0;
	mapChanging = true;

	if (startDelayTimer != 0)
	{
		KillTimer(startDelayTimer);

		startDelayTimer = 0;
	}

	if (fastStart == 0)
		startDelayTimer = SetTimer("OnRequestMapStart", GetRealTimerTime(5000), 0);
	else
		OnRequestMapStart();

	return 1;
}

function bool: IsGameProgress()
{
	new time = GetGameTime();

	return (time != -1 && gameInfo[gGameTime] - time <= GAME_TIME);
}

function bool: IsGameCount()
{
	new time = GetGameTime();

	return (time != -1 && gameInfo[gGameTime] - time > GAME_TIME);
}

function GetGameTime()
{
	if (gameInfo[gGameStartTime] == 0)
		return -1;
	
	return ((GetTickCount() - gameInfo[gGameStartTime]) / 1000);
}

function GetGameCount()
{
	new time = GetGameTime();

	if (time == -1 || time > GAME_COUNT_TIME)
		return -1;
	
	return (GAME_COUNT_TIME - time);
}

function CreateSpawnPoint(Float: x, Float: y, Float: z)
{
	new index = gameInfo[gSpawnPointCount];

	if (index >= MAX_SPAWN_POINTS)
		return 0;
	
	gameInfo[gSpawnPointX][index] = x;
	gameInfo[gSpawnPointY][index] = y;
	gameInfo[gSpawnPointZ][index] = z;

	++gameInfo[gSpawnPointCount];

	return 1;
}

function RemovePlayerAttachedObjects(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	for (new i = 0; i < 10; ++i)
		RemovePlayerAttachedObject(playerid, i);

	return 1;
}

function GetRandomSpawnPos(&Float: x, &Float: y, &Float: z)
{
	new index = random(gameInfo[gSpawnPointCount]);

	x = gameInfo[gSpawnPointX][index];
	y = gameInfo[gSpawnPointY][index];
	z = gameInfo[gSpawnPointZ][index];
}

stock RandomPlayer()
{
	new playerid = INVALID_PLAYER_ID;

	if (gameInfo[gPlayers] > 0)
	{
		new checkedPlayer[MAX_PLAYERS];
		new checked;

		do {
			playerid = random(MAX_PLAYERS);

			if (checkedPlayer[playerid] == 0)
			{
				checkedPlayer[playerid] = 1;

				if ((++checked) > MAX_PLAYERS)
					break;
			}
		} while (!IsPlayerConnected(playerid) || !currentPlayer[playerid]);
	}

	return playerid;
}

function GetFrontAttackPosition(playerid, &Float: x, &Float: y, &Float: z, Float: front = 0.25)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	new Float: a;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);

	x += (front * floatsin(-a, degrees));
	y += (front * floatcos(-a, degrees));

	return 1;
}

function Float: Get2DDistanceFromPoint(Float: x1, Float: y1, Float: x2, Float: y2)
{
	return (((x1 - x2) * (x1 - x2)) + ((y1 - y2) * (y1 - y2)));
}

function SetPlayerFreezeWithTime(playerid, time = 5000)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	TogglePlayerControllable(playerid, 0);
	SetPlayerChatBubble(playerid, "얼어붙음", 0xFFFFFFFF, 35.0, time + 2000);

	if (freezeTimer[playerid] != 0)
		KillTimer(freezeTimer[playerid]);
	
	freezeTimer[playerid] = SetTimerEx("OnPlayerRequestUnfreeze", GetRealTimerTime(time), 0, "i", playerid);

	return 1;
}

function CreateSkillObject(type, modelid, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz)
{
	new objectid = CreateMapObject(modelid, x, y, z, rx, ry, rz);

	if (objectid != INVALID_OBJECT_ID)
		objectType[objectid] = type;

	return objectid;
}

function bool: IsPlayerCurrentPlayer(playerid)
{
	return (IsPlayerConnected(playerid) && currentPlayer[playerid]);
}

function GetTitleName(index)
{
	new output[sizeof(titleList[])];

	if (index >= 0 && index < sizeof(titleList))
		output = titleList[index];
	
	return output;
}

function GetKoreanWeaponName(weaponid)
{
	new output[sizeof(koreanWeaponNames[])];

	if (weaponid >= 0 && weaponid < sizeof(koreanWeaponNames))
		output = koreanWeaponNames[weaponid];
	
	return output;
}

function ResetPlayerLastDeathPos(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	lastDeathPosX[playerid] = 0.0;
	lastDeathPosY[playerid] = 0.0;
	lastDeathPosZ[playerid] = 0.0;
	lastDeathPosA[playerid] = 0.0;

	return 1;
}

function bool: GetPlayerLastDeathPos(playerid, &Float: x, &Float: y, &Float: z, &Float: a)
{
	if (!IsPlayerCurrentPlayer(playerid) || (lastDeathPosX[playerid] == 0.0 && lastDeathPosY[playerid] == 0.0 && lastDeathPosZ[playerid] == 0.0))
		return false;
	
	x = lastDeathPosX[playerid];
	y = lastDeathPosY[playerid];
	z = lastDeathPosZ[playerid];
	a = lastDeathPosA[playerid];

	return true;
}

function bool: IsPlayerGamePlayer(playerid)
{
	return (IsPlayerCurrentPlayer(playerid) && (IsPlayerHuman(playerid) || IsPlayerZombie(playerid)));
}

function SetPlayerSpawnPos(playerid)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerCurrentPlayer(playerid) || (!IsGameCount() && !IsGameProgress()))
		return 0;
	
	new Float: x, Float: y, Float: z, Float: a;

	// 인간에서 죽은 후 스폰될 시 좀비화가 되기 전 이므로 인간으로 인식 됨.
	if (!deathAtWater[playerid] && (IsGameCount() || IsPlayerHuman(playerid)) && GetPlayerLastDeathPos(playerid, x, y, z, a))
	{
		SetPlayerPos(playerid, x, y, z);
		SetPlayerFacingAngle(playerid, a);

		ResetPlayerLastDeathPos(playerid);
	}
	else
	{
		GetRandomSpawnPos(x, y, z);
		SetPlayerPos(playerid, x, y, z);
		SetPlayerFacingAngle(playerid, float(random(360)));

		TogglePlayerGodMode(playerid, true);
	}

	deathAtWater[playerid] = false;

	return 1;
}

function bool: IsProhibitedSkin(skinid)
{
	return (skinid == 0 || skinid == 74 || skinid == 92 || skinid == 99);
}

function ShowPlayerMapChangeDialog(playerid)
{
	if (!IsPlayerConnected(playerid) || (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2)))
		return 0;
	
	new string[4096];
	new mapName[MAX_MAP_NAME];
	new minMapID = MAX_MAPS;
	new maxMapID = -1;

	ResetPlayerDialogList(playerid);
	GetMinMaxMapID(minMapID, maxMapID);

	for (new i = minMapID; i <= maxMapID; ++i)
	{
		if (!GetMapName(i, mapName))
			continue;
		
		format(string, sizeof(string), "%s%s\n", string, mapName);
		InsertPlayerDialogListValue(playerid, i);
	}

	ShowPlayerDialog(playerid, DIALOG_CHANGE_MAP, DIALOG_STYLE_LIST, "맵 변경", string, "변경", "취소");

	return 1;
}

function ChangeMapFromPlayer(playerid, mapid)
{
	if (!IsPlayerConnected(playerid) || (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2)))
		return 0;

	if (!IsValidMap(mapid))
		return 0;

	new string[MAX_MESSAGE_LENGTH];

	GetMapName(mapid, string);
	format(string, sizeof(string), "관리자 %s 님이 %s(id:%d) 맵을 요청하였습니다. 라운드가 새로 시작됩니다.", GetPlayerNameEx(playerid), string, mapid);
	SystemClientMessageToAll(string);

	SetNextMap(mapid);
	SetRequestMapStart(1);

	return 1;
}

function TogglePlayerGodMode(playerid, bool: enable, time = RESPAWN_GOD_MODE_TIME)
{
	if (!IsPlayerCurrentPlayer(playerid))
		return 0;

	if (enable == godMode[playerid])
		return 1;

	if (godModeTimer[playerid] != 0)
	{
		KillTimer(godModeTimer[playerid]);
		godModeTimer[playerid] = 0;
	}
	
	if (enable)
	{
		if (time > 0)
		{
			if (time < MAX_GOD_MODE_TIME)
				godModeTimer[playerid] = SetTimerEx("OnPlayerGodModeTimeEnd", GetRealTimerTime(time), 0, "i", playerid);
			else
				return 0;
		}

		godMode[playerid] = true;

		SetPlayerChatBubble(playerid, "리스폰 무적 상태", 0xE5D85CFF, 100.0, time + 5000);
	}
	else
	{
		godMode[playerid] = false;

		SetPlayerChatBubble(playerid, " ", 0xFFFFFF00, 1.0, 100);
	}
	
	return 1;
}

function bool: IsPlayerGodModeEnabled(playerid)
{
	return (IsPlayerCurrentPlayer(playerid) && godMode[playerid]);
}

function KillPlayer(playerid)
{
	if (!IsPlayerConnected(playerid))
		return;
	
	new Float: health;

	GetPlayerHealth(playerid, health);

	if (health <= 0.0)
	{
		return;
	}
	
	GivePlayerDamage(INVALID_PLAYER_ID, playerid, 255, health);
}

function CheckGameState()
{
	if (!IsGameCount() && !IsGameProgress())
		return;
	
	if (gameInfo[gPlayers] < 2)
		OnGameRoundFinish(GAMEOVER_TYPE_PLAYERSHORTAGE);
	else if (gameInfo[gHumans] <= 0)
	{
		if (IsGameProgress() && gameInfo[gZombies] > 0)
			OnGameRoundFinish(GAMEOVER_TYPE_ZOMBIE_WIN);
		else
			OnGameRoundFinish(GAMEOVER_TYPE_PLAYERSHORTAGE);
	}
}

function ClearDeathMessages()
{
	SendDeathMessage(9999, 9999, 200);
	SendDeathMessage(9999, 9999, 200);
	SendDeathMessage(9999, 9999, 200);
	SendDeathMessage(9999, 9999, 200);
	SendDeathMessage(9999, 9999, 200);
}

// Chicken game
function bool: IsPlayerChicken(playerid)
{
	return playerChicken[playerid];
}
