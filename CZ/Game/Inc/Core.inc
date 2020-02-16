/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Game/Core.pwn
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

#if defined __GAME_CORE_H__
	#endinput
#endif

#define __GAME_CORE_H__

#define GAME_COUNT_TIME 20
#define GAME_TIME 400
#define RESPAWN_GOD_MODE_TIME 3000

#define MAX_SPAWN_POINTS 10

/*#define HUMAN_TEAM 1
#define ZOMBIE_TEAM 2*/

#define GAMEOVER_TYPE_PLAYERSHORTAGE 0
#define GAMEOVER_TYPE_HUMAN_WIN 1
#define GAMEOVER_TYPE_ZOMBIE_WIN 2

#define SKILL_OBJECT_TYPE_TANK 1

#define MAX_NICKNAME_LENGTH 32
#define MAX_PLAYER_WARNINGS 3
#define MAX_GOD_MODE_TIME (60 * 1000)

new const titleList[][7] = {
	"No",
	"Mono",
	"Duo",
	"Triple",
	"Quadra",
	"Penta",
	"Hexa",
	"Hepta",
	"Octa",
	"Nona",
	"Deca"
};

new const koreanWeaponNames[][19] = {
	"주먹",
	"너클",
	"골프채",
	"경관봉",
	"단검",
	"야구 방망이",
	"삽",
	"당구큐",
	"카타나",
	"전기톱",
	"보라색 딜도",
	"딜도",
	"바이브레이터",
	"은색 바이브레이터",
	"꽃다발",
	"지팡이",
	"수류탄",
	"연막탄",
	"화염병",
	"오류",
	"오류",
	"오류",
	"콜트 45",
	"콜트 (소음기)",
	"데저트 이글",
	"샷건",
	"손 오브 샷건",
	"컴뱃 샷건",
	"마이크로 SMG (UZI)",
	"MP5",
	"AK-47",
	"M4",
	"Tec-9",
	"컨트리 소총",
	"스나이퍼 소총",
	"RPG",
	"열 추적 RPG",
	"화염 방사기",
	"미니건",
	"가방 폭탄",
	"폭탄 스위치",
	"스프레이 캔",
	"소화기",
	"카메라",
	"나이트 비전 고글",
	"서멀 비전 고글",
	"낙하산"
};

enum eGameInfo {
	gPlayers,
	gGameStartTime,
	gGameTime,
	gLastGameTime,
	gGameCount,
	gSpawnPointCount,
	Float: gSpawnPointX[MAX_SPAWN_POINTS],
	Float: gSpawnPointY[MAX_SPAWN_POINTS],
	Float: gSpawnPointZ[MAX_SPAWN_POINTS],
	gHumans,
	gZombies,
	gWorldMinute,
	gWorldHour
};

new gameRoundFinishEvent;
new gameCountEvent;
new gameCountEndEvent;
new playerSpawnedEvent;

new bool: mapChanging;
new startDelayTimer;
new bool: redo;

new gameInfo[eGameInfo];

new objectType[MAX_OBJECTS];

new oldGameTimeText[32];

new currentPlayer[MAX_PLAYERS];
new killCount[MAX_PLAYERS];
new freezeTimer[MAX_PLAYERS];
new playerWarnings[MAX_PLAYERS];
new bool: deathAtWater[MAX_PLAYERS];
new bool: santaHatDisable[MAX_PLAYERS];
new bool: godMode[MAX_PLAYERS];
new godModeTimer[MAX_PLAYERS];
new playerDeathTick[MAX_PLAYERS];
new skillEndTimer[MAX_PLAYERS];
// Chicken game
new bool: playerChicken[MAX_PLAYERS];
new Float: playerChickenSpin[MAX_PLAYERS];
//

new Float: lastDeathPosX[MAX_PLAYERS];
new Float: lastDeathPosY[MAX_PLAYERS];
new Float: lastDeathPosZ[MAX_PLAYERS];
new Float: lastDeathPosA[MAX_PLAYERS];

forward SetRequestMapStart(fastStart = 0);
forward bool: IsGameProgress();
forward bool: IsGameCount();
forward GetGameTime();
forward GetGameCount();
forward CreateSpawnPoint(Float: x, Float: y, Float: z);
forward RemovePlayerAttachedObjects(playerid);
forward GetRandomSpawnPos(&Float: x, &Float: y, &Float: z);
forward RandomPlayer();
forward GetFrontAttackPosition(playerid, &Float: x, &Float: y, &Float: z, Float: front = 0.25);
forward Float: Get2DDistanceFromPoint(Float: x1, Float: y1, Float: x2, Float: y2);
forward CreateSkillObject(type, modelid, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz);
forward bool: IsPlayerCurrentPlayer(playerid);
forward GetTitleName(index);
forward GetKoreanWeaponName(weaponid);
forward ResetPlayerLastDeathPos(playerid);
forward bool: GetPlayerLastDeathPos(playerid, &Float: x, &Float: y, &Float: z, &Float: a);
forward bool: IsPlayerGamePlayer(playerid);
forward SetPlayerSpawnPos(playerid);
forward bool: IsProhibitedSkin(skinid);
forward ChangeMapFromPlayer(playerid, mapid);
forward TogglePlayerGodMode(playerid, bool: enable, time = RESPAWN_GOD_MODE_TIME);
forward bool: IsPlayerGodModeEnabled(playerid);
forward KillPlayer(playerid);
forward ClearDeathMessages();
forward bool: IsPlayerChicken(playerid);

forward OnRequestMapStart();
forward OnGameRoundFinish(type);
forward OnPlayerRequestUnfreeze(playerid);
forward OnPlayerSpawned(playerid);
forward OnPlayerGodModeTimeEnd(playerid);
forward OnPlayerRespawnKill(playerid, Float: amount);

forward G_Core_GameModeExit();
forward G_Core_PlayerConnect(playerid);
forward G_Core_PlayerDisconnect(playerid);
forward G_Core_PlayerSpawn(playerid);
forward G_Core_PlayerCommandText(playerid, const command[], const params[]);
forward G_Core_DialogResponse(playerid, dialogid, response, listitem);
forward G_Core_PlayerTakeDamage(playerid, issuerid, Float: amount, weaponid);
forward G_Core_PlayerUpdate(playerid);
forward G_Core_PlayerDeath(playerid);
forward G_Core_PlayerIntroFinish(playerid);
forward G_Core_Global1sTimer();
forward G_Core_Player1sTimer(playerid);
forward G_Core_Global500msTimer();
forward G_Core_MapDataFuncFound(const tag[], const func[], const value[]);
forward G_Core_GamemodeMapStart();
forward G_Core_PlayerSpawned(playerid);
forward G_Core_PlayerKilled(playerid, killerid, reason);
