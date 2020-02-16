/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Game/Zombie.pwn
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

#if defined __GAME_ZOMBIE_H__
	#endinput
#endif

#define __GAME_ZOMBIE_H__

#define BASE_ZOMBIE_DAMAGE 25.0

#define MAX_SKILL_OBJECTS 25
#define MAX_ZOMBIE_SKILLS 2
#define MAX_STINGFINGER_TARGET_PLAYERS 4

#define ZOMBIE_SKILL_COOL_TIME 30

#define STINGFINGER_ATTACK_RANGE 5.0
//#define STINGFINGER_ATTACK_DAMAGE 80.0
#define STINGFINGER_JUMP_TIME 5000
#define STINGFINGER_JUMP_VELOCITY 5.0

enum _: eZombieTypes
{
	ZOMBIE_TYPE_HUMAN = -1,

	ZOMBIE_TYPE_NORMAL_HOST = 1,
	ZOMBIE_TYPE_HAMMER_HOST = 2,
	ZOMBIE_TYPE_WITCH_HOST,
	ZOMBIE_TYPE_TANK_HOST,
	ZOMBIE_TYPE_STINGFINGER_HOST,
	// Chicken game
	ZOMBIE_TYPE_CHICKEN_HOST,

	ZOMBIE_TYPE_NORMAL = ZOMBIE_TYPE_STINGFINGER_HOST + 1,
	//ZOMBIE_TYPE_BURROW = ZOMBIE_TYPE_STINGFINGER_HOST + 2,
	ZOMBIE_TYPE_JOCKEY = ZOMBIE_TYPE_STINGFINGER_HOST + 2,
	ZOMBIE_TYPE_SWAM,
	ZOMBIE_TYPE_FARMSPAWNER,
	ZOMBIE_TYPE_BOOMER,
	ZOMBIE_TYPE_HUNTER,
	ZOMBIE_TYPE_CHARGER,
	ZOMBIE_TYPE_SPITTER,
	ZOMBIE_TYPE_SMOKER,
	ZOMBIE_TYPE_STINGFINGER,
	// Chicken game
	ZOMBIE_TYPE_CHICKEN
};

new const hostZombieProbabilities[] = { // 일반 타입을 제외한 확률 기재. (퍼센티지 기준)
	6,
	2,
	2,
	1,
	0, // Chicken game
};

new const guestZombieProbabilities[] = { // 일반 타입을 제외한 확률 기재. (퍼센티지 기준)
	//9, // ZOMBIE_TYPE_BURROW
	2,
	3,
	3,
	3,
	3,
	3,
	1,
	1,
	2,
	0 // Chicken game
};

new Float: smokerPosX[MAX_PLAYERS];
new Float: smokerPosY[MAX_PLAYERS];
new Float: smokerPosZ[MAX_PLAYERS];

new hostZombie = INVALID_PLAYER_ID;
new bool: requestZombieSurrender;

new swamEndTimer;
new bool: swamEnabled;
new Float: swamPosX;
new Float: swamPosY;
new Float: swamPosZ;
new swamObject = INVALID_OBJECT_ID;

new zombieType[MAX_PLAYERS];
new zombieSkillCoolTime[MAX_PLAYERS][MAX_ZOMBIE_SKILLS];
new skillObject[MAX_PLAYERS][MAX_SKILL_OBJECTS];
new skillStep[MAX_PLAYERS];
new chargerGrabType[MAX_PLAYERS];
new smokerAttack[MAX_PLAYERS];
new bool: stingFingerJump[MAX_PLAYERS];
new bool: hunterJumpUsed[MAX_PLAYERS];

forward SpawnPlayerOfZombie(playerid);
forward SetPlayerHostZombie(playerid, type = -1, bool: first = false);
forward SetPlayerZombie(playerid, type = -1);
forward SelectHostZombie(targetid = INVALID_PLAYER_ID);
forward RandomZombiePlayer(hostCheck);
forward CheckZombieCount(targetid);
forward bool: IsPlayerZombie(playerid);
forward AttackZombiePlayer(playerid);
forward AttackStingFingerZombiePlayer(playerid);
forward PlayerInfectPlayer(playerid, targetid, weaponid);
forward UsePlayerZombieSkill(playerid, targetid = INVALID_PLAYER_ID, type = 0);
forward bool: IsPlayerFKeySkillZombie(playerid);
forward bool: IsPlayerHiddenZombie(playerid);
forward CreateSwamFromPlayer(playerid);
forward ResetSmokerSkill(playerid);
forward RemovePlayerSkillObjects(playerid);
forward bool: IsPlayerInSwam(playerid);
forward bool: IsZombieWantSurrender();
forward SetZombieWantSurrender(bool: want);

forward G_Zombie_PlayerConnect(playerid);
forward G_Zombie_PlayerDisconnect(playerid);
forward G_Zombie_PlayerSpawn(playerid);
forward G_Zombie_PlayerKeyStateChange(playerid, newkeys);
forward G_Zombie_ObjectMoved(objectid);
forward G_Zombie_PlayerTakeDamage(playerid, issuerid, Float: amount, weaponid);
forward G_Zombie_PlayerUpdate(playerid);
forward G_Zombie_PlayerCommandText(playerid, const command[]);
forward G_Zombie_PlayerDeath(playerid);
forward G_Zombie_GamemodeMapStart();
forward G_Zombie_Player1sTimer(playerid);
forward G_Zombie_GameRoundFinish(type);
forward G_Zombie_GameCount(count);
forward G_Zombie_GameCountEnd();
forward G_Zombie_PlayerJump(playerid);
forward G_Zombie_PlayerKilled(playerid, killerid, reason);

forward OnRequestSwamEnd();
forward OnPlayerRequestChargerGrabEnd(playerid);
forward OnSmokerGrabPlayer(playerid, targetid);
forward OnPlayerStingFingerJumpEnd(playerid);
forward OnPlayerStingFingerAttackEnd(playerid);
