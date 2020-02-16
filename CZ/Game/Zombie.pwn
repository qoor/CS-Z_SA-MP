/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * System for zombie survivor
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

#include "./CZ/Game/Inc/Zombie.inc"

// 좀비 리치: 1.5

InitModule("Game_Zombie")
{
	assert(ZOMBIE_TYPE_NORMAL_HOST + sizeof(hostZombieProbabilities) >= ZOMBIE_TYPE_STINGFINGER_HOST &&
		ZOMBIE_TYPE_NORMAL + sizeof(guestZombieProbabilities) >= ZOMBIE_TYPE_STINGFINGER);

	AddEventHandler(D_PlayerConnect, "G_Zombie_PlayerConnect");
	AddEventHandler(D_PlayerDisconnect, "G_Zombie_PlayerDisconnect");
	AddEventHandler(D_PlayerSpawn, "G_Zombie_PlayerSpawn");
	AddEventHandler(D_PlayerKeyStateChange, "G_Zombie_PlayerKeyStateChange");
	AddEventHandler(D_ObjectMoved, "G_Zombie_ObjectMoved");
	AddEventHandler(D_PlayerUpdate, "G_Zombie_PlayerUpdate");
	AddEventHandler(D_PlayerCommandText, "G_Zombie_PlayerCommandText");
	AddEventHandler(D_PlayerDeath, "G_Zombie_PlayerDeath");
	AddEventHandler(D_PlayerTakeDamage, "G_Zombie_PlayerTakeDamage");
	AddEventHandler(gamemodeMapStartEvent, "G_Zombie_GamemodeMapStart");
	AddEventHandler(player1sTimer, "G_Zombie_Player1sTimer");
	AddEventHandler(gameRoundFinishEvent, "G_Zombie_GameRoundFinish");
	AddEventHandler(gameCountEvent, "G_Zombie_GameCount");
	AddEventHandler(gameCountEndEvent, "G_Zombie_GameCountEnd");
	AddEventHandler(playerJumpEvent, "G_Zombie_PlayerJump");
	AddEventHandler(playerKilledEvent, "G_Zombie_PlayerKilled");
}

public G_Zombie_PlayerConnect(playerid)
{
	zombieType[playerid] = 0;
	chargerGrabType[playerid] = 0;
	smokerAttack[playerid] = 0;
	stingFingerJump[playerid] = false;
	hunterJumpUsed[playerid] = false;

	for (new i = 0; i < MAX_SKILL_OBJECTS; ++i)
		skillObject[playerid][i] = INVALID_OBJECT_ID;
	
	for (new i = 0; i < MAX_ZOMBIE_SKILLS; ++i)
		zombieSkillCoolTime[playerid][i] = 0;

	return 0;
}

public G_Zombie_PlayerDisconnect(playerid)
{
	new grabType = chargerGrabType[playerid];

	if (grabType != 0)
	{
		if (grabType == 1)
			OnPlayerRequestChargerGrabEnd(playerid);
		else
			chargerGrabType[playerid] = 0;
	}

	if (smokerAttack[playerid] == 1)
		ResetSmokerSkill(playerid);
	else if (smokerAttack[playerid] > 1)
	{
		new issuerid = smokerAttack[playerid] - 2;

		if (IsPlayerConnected(issuerid) && smokerAttack[issuerid] == 1)
			ResetSmokerSkill(issuerid);
	}

	RemovePlayerSkillObjects(playerid);

	return 0;
}

public G_Zombie_PlayerSpawn(playerid)
{
	if (IsGameProgress())
		SpawnPlayerOfZombie(playerid);
	
	return 0;
}

public G_Zombie_PlayerKeyStateChange(playerid, newkeys)
{
	if (IsAttackKeyPressed(newkeys) && IsPlayerZombie(playerid))
		AttackZombiePlayer(playerid);
	
	if (IsPlayerZombie(playerid))
	{
		if (newkeys & KEY_SECONDARY_ATTACK)
		{
			/*if (zombieType[playerid] == ZOMBIE_TYPE_BURROW)
			{
				ApplyAnimation(playerid, "SWAT", "swt_vnt_sht_die", 4.1, 0, 1, 1, 1, 1, 1);

				return 1;
			}
			else */if (IsPlayerFKeySkillZombie(playerid))
			{
				if (zombieSkillCoolTime[playerid][0] <= 0)
					UsePlayerZombieSkill(playerid);
				else
					SystemClientMessage(playerid, "마나가 부족합니다.");
				
				return 1;
			}
			else if (zombieType[playerid] == ZOMBIE_TYPE_HUNTER)
			{
				if (!hunterJumpUsed[playerid])
				{
					hunterJumpUsed[playerid] = true;

					SystemClientMessage(playerid, "점프력 향상 모드로 설정되었습니다.");
				}
				else
				{
					hunterJumpUsed[playerid] = false;

					SystemClientMessage(playerid, "기본 점프 모드로 설정되었습니다.");
				}
			}
		}

		if (newkeys & KEY_JUMP)
		{
			if (zombieType[playerid] == ZOMBIE_TYPE_HUNTER && hunterJumpUsed[playerid])
			{
				new Float: vx, Float: vy, Float: vz;

				GetPlayerVelocity(playerid, vx, vy, vz);
				SetPlayerVelocity(playerid, vx, vy, vz + 5.0);

				return 1;
			}
		}

		if (newkeys & KEY_YES)
		{
			if (zombieType[playerid] == ZOMBIE_TYPE_STINGFINGER_HOST || zombieType[playerid] == ZOMBIE_TYPE_STINGFINGER)
			{
				if (zombieSkillCoolTime[playerid][1] <= 0)
					UsePlayerZombieSkill(playerid, .type = 1);
				else
					SystemClientMessage(playerid, "마나가 부족합니다.");
			}
		}
	}

	return 0;
}

public G_Zombie_ObjectMoved(objectid)
{
	if (objectType[objectid] == SKILL_OBJECT_TYPE_TANK)
	{
		new Float: x, Float: y, Float: z;

		GetObjectPos(objectid, x, y, z);
		DestroyObject(objectid);
		CreateExplosion(x, y, z, 11, 12.0);
		CreateExplosion(x, y, z, 11, 12.0);

		objectType[objectid] = 0;
	}

	return 0;
}

public G_Zombie_PlayerUpdate(playerid)
{
	if (zombieType[playerid] == ZOMBIE_TYPE_CHARGER && chargerGrabType[playerid] == 1)
	{
		new Float: x, Float: y, Float: z;

		GetPlayerPos(playerid, x, y, z);
		
		contloop (new targetid : playerList)
		{
			if (!IsPlayerHuman(targetid))
				continue;
			
			if (chargerGrabType[targetid] == 0 && IsPlayerInRangeOfPoint(targetid, 2.0, x, y, z))
				chargerGrabType[targetid] = 2 + playerid;
			
			if (chargerGrabType[targetid] == 2 + playerid)
				SetPlayerPos(targetid, x, y, z);
		}
	}

	if (smokerAttack[playerid] >= 2)
	{
		new issuerid = smokerAttack[playerid] - 2;

		if (!IsPlayerConnected(issuerid) || zombieType[issuerid] != ZOMBIE_TYPE_SMOKER || smokerAttack[issuerid] == 0)
		{
			if (IsPlayerConnected(issuerid))
				ResetSmokerSkill(issuerid);
			else
			{
				TogglePlayerControllable(playerid, 1);

				smokerAttack[playerid] = 0;
			}
		}
		else
		{
			new step;

			step = skillStep[issuerid];

			if (step <= 0)
				ResetSmokerSkill(issuerid);
			else
			{
				new Float: px = smokerPosX[issuerid], Float: py = smokerPosY[issuerid], Float: pz = smokerPosZ[issuerid];
				new Float: tx = smokerPosX[playerid], Float: ty = smokerPosY[playerid], Float: tz = smokerPosZ[playerid];

				--skillStep[issuerid];

				SetPlayerPos(playerid, px + ((tx - px) * step) / 50, py + ((ty - py) * step) / 50, pz + ((tz - pz) * step) / 50);
				SetPlayerPos(issuerid, px, py, pz);

				if (step > 0 && (step % 2) == 0)
				{
					new objIndex = (MAX_SKILL_OBJECTS - 1) - ((step / 2) - 1);

					DestroyObject(skillObject[issuerid][objIndex]);

					skillObject[issuerid][objIndex] = INVALID_OBJECT_ID;
				}
			}
		}
	}

	return 1;
}

public G_Zombie_PlayerCommandText(playerid, const command[])
{
	if (strcmp(command, "/항복") == 0)
	{
		if (!IsGameProgress())
			return ErrorClientMessage(playerid, "게임이 진행중이지 않습니다.");
		
		if (!IsPlayerZombie(playerid) || hostZombie != playerid)
			return ErrorClientMessage(playerid, "숙주 좀비만 사용할 수 있습니다.");
		
		new string[MAX_MESSAGE_LENGTH];
		
		SetZombieWantSurrender(true);

		format(string, sizeof(string), "숙주 좀비 %s(id:%d)님이 항복을 요청하였습니다. (/동의 항복) 또는 (/거절 항복)", GetPlayerNameEx(playerid), playerid);
		SendAdminMessage(0xFF0000FF, string);

		SystemClientMessage(playerid, "관리자들에게 항복 수락 요청을 보냈습니다.");
		
		return 1;
	}

	if (strcmp(command, "/좀숙주") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		if (GetGameTime() == -1)
			return ErrorClientMessage(playerid, "게임이 진행중이지 않습니다.");
		
		if (IsPlayerConnected(hostZombie))
			return ErrorClientMessage(playerid, "이미 숙주 좀비가 있습니다.");

		new targetid = RandomZombiePlayer(1);

		if (!IsPlayerConnected(targetid))
			return ErrorClientMessage(playerid, "좀비가 없습니다.");
		
		new string[MAX_MESSAGE_LENGTH];
		
		SelectHostZombie(targetid);

		format(string, sizeof(string), "관리자 %s 님이 랜덤으로 숙주 좀비를 선택했습니다.", GetPlayerNameEx(playerid));
		SystemClientMessageToAll(string);

		return 1;
	}

	if (strcmp(command, "/인숙주") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid, 2))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		if (GetGameTime() == -1)
			return ErrorClientMessage(playerid, "게임이 진행중이지 않습니다.");
		
		if (IsPlayerConnected(hostZombie))
			return ErrorClientMessage(playerid, "이미 숙주 좀비가 있습니다.");

		new targetid = RandomHumanPlayer(1);

		if (!IsPlayerConnected(targetid))
			return ErrorClientMessage(playerid, "영웅을 제외한 일반 생존자가 없습니다.");
		
		new string[MAX_MESSAGE_LENGTH];
		
		SelectHostZombie(targetid);

		format(string, sizeof(string), "관리자 %s 님이 랜덤으로 숙주 좀비를 선택했습니다.", GetPlayerNameEx(playerid));
		SystemClientMessageToAll(string);

		return 1;
	}

	return 0;
}

public G_Zombie_GamemodeMapStart()
{
	new i;

	hostZombie = INVALID_PLAYER_ID;
	requestZombieSurrender = false;

	gameInfo[gZombies] = 0;

	swamEnabled = false;
	swamObject = INVALID_OBJECT_ID;

	contloop (new playerid : playerList)
	{
		for (i = 0; i < MAX_SKILL_OBJECTS; ++i)
			skillObject[playerid][i] = INVALID_OBJECT_ID;
		
		skillStep[playerid] = 0;
		smokerAttack[playerid] = 0;
		chargerGrabType[playerid] = 0;
		stingFingerJump[playerid] = false;

		for (i = 0; i < MAX_ZOMBIE_SKILLS; ++i)
			zombieSkillCoolTime[playerid][i] = 0;
	}
}

public G_Zombie_PlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
	if (!IsPlayerZombie(issuerid))
		return 0;
	
	if (IsPlayerHuman(playerid))
	{
		new bool: damageIgnored;
		new bool: damageSoundIgnored;

		if (weaponid == 0)
		{
			if (zombieType[issuerid] == ZOMBIE_TYPE_WITCH_HOST)
			{
				damageIgnored = true;

				PlayerInfectPlayer(issuerid, playerid, weaponid);
			}
			else
			{
				// Chicken game
				if (IsPlayerChicken(issuerid))
				{
					amount = 0.0;
				}
				else
				{
					amount = BASE_ZOMBIE_DAMAGE;
				}
			}
		}
		else
		{
			if (weaponid == WEAPON_RIFLE && (zombieType[issuerid] == ZOMBIE_TYPE_SPITTER || zombieType[issuerid] == ZOMBIE_TYPE_SMOKER))
				UsePlayerZombieSkill(issuerid, playerid);
			else if (weaponid == 1 && (zombieType[issuerid] == ZOMBIE_TYPE_STINGFINGER_HOST || zombieType[issuerid] == ZOMBIE_TYPE_STINGFINGER))
			{
				new string[MAX_MESSAGE_LENGTH];

				format(string, sizeof(string), "%s(id:%d)님이 촉수에 맞았습니다.", GetPlayerNameEx(playerid), playerid);
				SystemClientMessage(issuerid, string);

				SystemClientMessage(playerid, "스팅핑거의 촉수에 맞았습니다.");

			#if !defined STINGFINGER_ATTACK_DAMAGE
				damageIgnored = true;

				PlayerInfectPlayer(issuerid, playerid, weaponid);
			#endif
			}
			else
			{
				damageIgnored = true;
				damageSoundIgnored = true;
			}
		}

		if (!damageIgnored)
		{
			new Float: health;

			GetPlayerHealth(playerid, health);

			if (health - amount <= 0.0)
			{
				PlayerInfectPlayer(issuerid, playerid, weaponid);
			}
			else
			{
				GivePlayerDamage(issuerid, playerid, weaponid, amount + playerInfo[issuerid][pUpgPower]);
			}
		}
		
		if (!damageSoundIgnored)
		{
			PlayerPlaySound(issuerid, 1057, 0.0, 0.0, 0.0);
			PlayerPlaySound(playerid, 17802, 0.0, 0.0, 0.0);
		}
	}
	
	return 1;
}

public G_Zombie_PlayerDeath(playerid)
{
	stingFingerJump[playerid] = false;

	if (IsPlayerZombie(playerid) && zombieType[playerid] == ZOMBIE_TYPE_BOOMER)
		UsePlayerZombieSkill(playerid);
	
	return 0;
}

public G_Zombie_Player1sTimer(playerid)
{
	for (new i = 0; i < MAX_ZOMBIE_SKILLS; ++i)
	{
		if (zombieSkillCoolTime[playerid][i] != 0)
		{
			--zombieSkillCoolTime[playerid][i];

			if (zombieSkillCoolTime[playerid][i] == 0)
			{
				if (zombieType[playerid] == ZOMBIE_TYPE_STINGFINGER_HOST || zombieType[playerid] == ZOMBIE_TYPE_STINGFINGER)
				{
					if (i == 0)
						SystemClientMessage(playerid, "촉수 스킬 마나가 다 찼습니다.");
					else
						SystemClientMessage(playerid, "점프 향상 스킬 마나가 다 찼습니다.");
				}
				else
					SystemClientMessage(playerid, "마나가 다 찼습니다.");

				if (i == 0 && (zombieType[playerid] == ZOMBIE_TYPE_SPITTER || zombieType[playerid] == ZOMBIE_TYPE_SMOKER))
				{
					ResetPlayerWeapons(playerid);
					GivePlayerWeapon(playerid, WEAPON_RIFLE, 1);
				}
			}
		}
		else if (i == 0)
		{
			if ((zombieType[playerid] == ZOMBIE_TYPE_SPITTER || zombieType[playerid] == ZOMBIE_TYPE_SMOKER) && !IsPlayerESC(playerid))
			{
				new weaponid, ammo;

				GetPlayerWeaponData(playerid, 6, weaponid, ammo);

				if (weaponid != WEAPON_RIFLE || ammo <= 0)
				{
					ResetPlayerWeapons(playerid);

					zombieSkillCoolTime[playerid][0] = ZOMBIE_SKILL_COOL_TIME;
				}
			}
		}
	}

	return 0;
}

public G_Zombie_PlayerKilled(playerid, killerid, reason)
{
	if (IsPlayerZombie(killerid) && IsPlayerHuman(playerid))
	{
		PlayerInfectPlayer(killerid, playerid, reason);
		return 0; // Ignore kill
	}

	return 1;
}

public G_Zombie_GameRoundFinish(type)
{
	if (type == GAMEOVER_TYPE_ZOMBIE_WIN)
	{
		contloop (new playerid : playerList)
		{
			if (!IsPlayerCurrentPlayer(playerid))
				continue;
			
			ClearMessage(playerid);
			NewsClientMessage(playerid, "모든 생존자가 감염되었습니다!");
			NewsClientMessage(playerid, "좀비의 승리입니다!");
			
			TogglePlayerControllable(playerid, 0);

			GameTextForPlayer(playerid, "~y~Zombie ~n~~w~Win", 5000, 0);
		}

		if (IsPlayerConnected(hostZombie))
		{
			GivePlayerScore(hostZombie, 5);
			GivePlayerMoney(hostZombie, 5000);

			PayClientMessage(hostZombie, "생존자를 전부 감염시켜 $5,000와 스코어 5를 얻었습니다.");
		}
	}
}

public G_Zombie_GameCount(count)
{
	if (count <= 5)
	{
		new string[32];

		format(string, sizeof(string), "~y~Infect..~n~~w~%d", count);
		GameTextForAll(string, 1000, 3);
	}
}

public G_Zombie_GameCountEnd()
{
	SelectHostZombie();
}

public G_Zombie_PlayerJump(playerid)
{
	if (!IsPlayerConnected(playerid))
		return;
	
	if ((zombieType[playerid] == ZOMBIE_TYPE_STINGFINGER_HOST || zombieType[playerid] == ZOMBIE_TYPE_STINGFINGER) && stingFingerJump[playerid])
	{
		new Float: vx, Float: vy, Float: vz;

		GetPlayerVelocity(playerid, vx, vy, vz);
		SetPlayerVelocity(playerid, vx, vy, vz + STINGFINGER_JUMP_VELOCITY);
	}
}

public OnRequestSwamEnd()
{
	swamEndTimer = 0;

	if (swamEnabled)
	{
		swamEnabled = false;

		if (IsValidObject(swamObject))
		{
			DestroyObject(swamObject);

			swamObject = INVALID_OBJECT_ID;
		}
	}
}

public OnPlayerRequestChargerGrabEnd(playerid)
{
	skillEndTimer[playerid] = 0;

	if (IsPlayerConnected(playerid))
		chargerGrabType[playerid] = 0;

	contloop (new targetid : playerList)
	{
		if (targetid != playerid && chargerGrabType[targetid] == 2 + playerid)
			chargerGrabType[targetid] = 0;
	}
}

public OnPlayerStingFingerJumpEnd(playerid)
{
	if (!IsPlayerConnected(playerid))
		return;
	
	skillEndTimer[playerid] = 0;
	
	if (stingFingerJump[playerid])
	{
		stingFingerJump[playerid] = false;

		InfoClientMessage(playerid, "점프력이 원래대로 돌아옵니다.");
	}
}

public OnPlayerStingFingerAttackEnd(playerid)
{
	if (!IsPlayerConnected(playerid) || (zombieType[playerid] != ZOMBIE_TYPE_STINGFINGER_HOST && zombieType[playerid] != ZOMBIE_TYPE_STINGFINGER))
		return;
	
	skillEndTimer[playerid] = 0;
	
	RemovePlayerAttachedObject(playerid, 3);
	RemovePlayerAttachedObject(playerid, 4);
}

function SpawnPlayerOfZombie(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;

	ClearAnimations(playerid, 1);
	SetPlayerSpawnPos(playerid);
	SetCameraBehindPlayer(playerid);
	
	if (hostZombie == playerid)
		SetPlayerHostZombie(playerid);
	else
		SetPlayerZombie(playerid);
	
	OnPlayerSpawned(playerid);

	return 1;
}

function SetPlayerHostZombie(playerid, type = -1, bool: first = false)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	new rand;

	if (IsGameCount() || IsGameProgress())
		CheckZombieCount(playerid);
	
	if (heroPlayer == playerid)
		heroPlayer = INVALID_PLAYER_ID;
	
	for (new i = 0; i < MAX_ZOMBIE_SKILLS; ++i)
		zombieSkillCoolTime[playerid][i] = 0;
	
	ResetPlayerWeapons(playerid);
	ClearAnimations(playerid, 1);
	SetPlayerColor(playerid, 0xFFFF00AA);

	if (!IsPlayerChicken(playerid))
	{
		if (IsGameEventEnabled(EVENT_ZOMBIE_PROBABILITY_SAME))
		{
			type = ZOMBIE_TYPE_NORMAL_HOST + random(sizeof(hostZombieProbabilities) + 1);
		}
		else if (type == -1)
		{
			new newType;

			do {
				newType = ZOMBIE_TYPE_HUMAN;
				rand = random(50) + 1;

				if (rand > 0)
				{
					new probabilityCount;

					newType = ZOMBIE_TYPE_NORMAL_HOST;

					for (new i = 0; i < sizeof(hostZombieProbabilities); ++i)
					{
						if ((probabilityCount += hostZombieProbabilities[i]) >= rand)
						{
							newType += i + 1;
							break;
						}
					}
				}
			} while (newType == ZOMBIE_TYPE_HAMMER_HOST && first);

			type = newType;
		}
	}
	else
	{
		type = ZOMBIE_TYPE_CHICKEN_HOST;
	}

	switch (type)
	{
	case ZOMBIE_TYPE_NORMAL_HOST:
		{
			SetPlayerSkin(playerid, 0);
			SetPlayerHealth(playerid, 300.0);
			
			InfoClientMessage(playerid, "당신은 숙주 좀비이므로 모든 생존자를 감염시켜야 합니다.");
		}
	case ZOMBIE_TYPE_HAMMER_HOST:
		{
			SetPlayerSkin(playerid, 5);
			SetPlayerHealth(playerid, 300.0);

			InfoClientMessage(playerid, "당신은 특수 숙주 좀비 해머입니다.");
			InfoClientMessage(playerid, "모든 특수총의 효과를 받지 않습니다.");
		}
	case ZOMBIE_TYPE_WITCH_HOST:
		{
			SetPlayerSkin(playerid, 145);
			SetPlayerHealth(playerid, 500.0);

			InfoClientMessage(playerid, "당신은 특수 숙주 좀비 윗치입니다.");
			InfoClientMessage(playerid, "생존자를 한방에 죽일 수 있습니다.");
		}
	case ZOMBIE_TYPE_TANK_HOST:
		{
			SetPlayerSkin(playerid, 149);
			SetPlayerHealth(playerid, 300.0);

			InfoClientMessage(playerid, "원작자 아이디어 : Claire_Redfield");
			InfoClientMessage(playerid, "당신은 특수 숙주 좀비 탱크입니다.");
			InfoClientMessage(playerid, "F 키로 돌을 날릴 수 있습니다.");
		}
	case ZOMBIE_TYPE_STINGFINGER_HOST:
		{
			SetPlayerSkin(playerid, 12);
			SetPlayerHealth(playerid, 300.0);
			SetPlayerAttachedObject(playerid, 0, 19163, 2, 0.0519, 0.0149, 0.0000, 0.0000, 88.4000, -178.7000, 1.1879, 1.2990, 1.3440);
			SetPlayerAttachedObject(playerid, 1, 19472, 2, -0.0279, 0.1599, 0.0020, 85.6999, 87.4000, 0.0000, 1.3459, 1.1499, 1.2089);
			SetPlayerAttachedObject(playerid, 2, 1008, 1, 0.1819, -0.0760, 0.0000, 96.3000, 0.2999, -177.5001, 0.6460, 0.6320, 0.5490);

			InfoClientMessage(playerid, "당신은 특수 숙주 좀비 스팅핑거입니다.");
			InfoClientMessage(playerid, "F 키로 팔의 촉수를 늘려 멀리 있는 생존자를 잡을 수 있습니다.");
			InfoClientMessage(playerid, "Y 키로 5초간 점프력이 향상됩니다.");
		}
		// Chicken game
	case ZOMBIE_TYPE_CHICKEN_HOST:
		{
			SetPlayerSkin(playerid, 167);
			SetPlayerHealth(playerid, 300.0);
			
			InfoClientMessage(playerid, "니는 특수 숙주 좀비 치킨이다.");
			InfoClientMessage(playerid, "앞을 보고 걸어다닐 수 없고 계속 빙글빙글 돈다.");
			InfoClientMessage(playerid, "어떤 무기에 대미지를 입든 특수무기 효과 중 하나를 당한다.");
			InfoClientMessage(playerid, "\"쿠우님 죄송합니다.\" 이외에는 아무런 말을 할 수 없다.");
			InfoClientMessage(playerid, "인간에게 공격하면 대미지가 0이다.");
		}
	}

	zombieType[playerid] = type;

	return 1;
}

function SetPlayerZombie(playerid, type = -1)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	new rand;

	if (IsGameCount() || IsGameProgress())
		CheckZombieCount(playerid);
	
	if (heroPlayer == playerid)
		heroPlayer = INVALID_PLAYER_ID;
	
	for (new i = 0; i < MAX_ZOMBIE_SKILLS; ++i)
		zombieSkillCoolTime[playerid][i] = 0;

	ResetPlayerWeapons(playerid);
	ClearAnimations(playerid, 1);
	SetPlayerColor(playerid, 0xFF0000AA);
	SetPlayerHealth(playerid, 100.0);

	if (!IsPlayerChicken(playerid))
	{
		if (!IsGameEventEnabled(EVENT_ZOMBIE_PROBABILITY_SAME))
		{
			rand = random(100) + 1;
		}
		else
		{
			type = ZOMBIE_TYPE_NORMAL + random(sizeof(guestZombieProbabilities) + 1);
		}

		if (type == -1 && rand > 0)
		{
			new probabilityCount;

			type = ZOMBIE_TYPE_NORMAL;

			for (new i = 0; i < sizeof(guestZombieProbabilities); ++i)
			{
				if ((probabilityCount += guestZombieProbabilities[i]) >= rand)
				{
					type += i + 1;
					break;
				}
			}
		}
	}
	else
	{
		type = ZOMBIE_TYPE_CHICKEN;
	}

	switch (type)
	{
	case ZOMBIE_TYPE_NORMAL:
		{
			SetPlayerSkin(playerid, 0);
			InfoClientMessage(playerid, "당신은 좀비이므로 모든 생존자를 감염시켜야 합니다.");
		}
	/*case ZOMBIE_TYPE_BURROW:
		{
			SetPlayerSkin(playerid, 28);
			InfoClientMessage(playerid, "당신은 특수 좀비 버로우입니다.");
			InfoClientMessage(playerid, "F 키로 자신의 몸을 땅아래로 숨길 수 있습니다.");
		}*/
	case ZOMBIE_TYPE_JOCKEY:
		{
			SetPlayerSkin(playerid, 160);
			SetPlayerHealth(playerid, 100.0);

			InfoClientMessage(playerid, "당신은 특수 좀비 자키입니다.");
			InfoClientMessage(playerid, "F 키로 생존자를 마비시킬 수 있습니다.");
		}
	case ZOMBIE_TYPE_SWAM:
		{
			SetPlayerSkin(playerid, 136);
			SetPlayerHealth(playerid, 100.0);

			InfoClientMessage(playerid, "당신은 특수 좀비 스웜입니다.");
			InfoClientMessage(playerid, "F 키로 다크 스윔을 발동해 좀비들을 보호하십시오.");
		}
	case ZOMBIE_TYPE_FARMSPAWNER:
		{
			SetPlayerSkin(playerid, 35);
			SetPlayerHealth(playerid, 100.0);

			InfoClientMessage(playerid, "원작자 아이디어 : Hms1son_HN");
			InfoClientMessage(playerid, "당신은 특수 좀비 팜 스포너입니다.");
			InfoClientMessage(playerid, "F 키로 짚단을 설치할 수 있습니다.");
		}
	case ZOMBIE_TYPE_BOOMER:
		{
			SetPlayerSkin(playerid, 31);
			SetPlayerHealth(playerid, 100.0);

			InfoClientMessage(playerid, "당신은 특수 좀비 부머입니다.");
			InfoClientMessage(playerid, "F 키로 폭발을 일으킬 수 있습니다.");
		}
	case ZOMBIE_TYPE_HUNTER:
		{
			hunterJumpUsed[playerid] = true;
			
			SetPlayerSkin(playerid, 230);
			SetPlayerHealth(playerid, 100.0);

			InfoClientMessage(playerid, "당신은 특수 좀비 헌터입니다.");
			InfoClientMessage(playerid, "Shift 키로 허공을 날 수 있습니다.");
			InfoClientMessage(playerid, "F키로 점프 모드를 변환할 수 있습니다.");
		}
	case ZOMBIE_TYPE_CHARGER:
		{
			SetPlayerSkin(playerid, 213);
			SetPlayerHealth(playerid, 200.0);
			SetPlayerAttachedObject(playerid, 0, 2906, 6, 0.2738, 0.1129, 0.0697, 188.8418, 16.1643, 287.9833, -4.3860, 1.0000, -2.8934);

			InfoClientMessage(playerid, "원작자 아이디어 : Claire_Redfield");
			InfoClientMessage(playerid, "당신은 특수 좀비 차저입니다.");
			InfoClientMessage(playerid, "F 키로 돌진하여 생존자를 잡을 수 있습니다.");
		}
	case ZOMBIE_TYPE_SPITTER:
		{
			GivePlayerWeapon(playerid, WEAPON_RIFLE, 1);
			SetPlayerSkin(playerid, 201);
			SetPlayerHealth(playerid, 100.0);
			SetPlayerAttachedObject(playerid, 0, 2907, 6, 0.2432, 0.0, 0.0867, 221.0684, 0.0, 81.4490, 0.8312, 1.0, 1.0);

			InfoClientMessage(playerid, "원작자 아이디어 : Claire_Redfield");
			InfoClientMessage(playerid, "당신은 특수 좀비 스피터입니다.");
			InfoClientMessage(playerid, "당신의 침(Country Rifle)을 생존자에게 맞춰 불태울 수 있습니다.");
		}
	case ZOMBIE_TYPE_SMOKER:
		{
			GivePlayerWeapon(playerid, WEAPON_RIFLE, 1);
			SetPlayerSkin(playerid, 79);
			SetPlayerHealth(playerid, 100.0);
			SetPlayerAttachedObject(playerid, 0, 2907, 6, 0.2432, 0.0, 0.0867, 221.0684, 0.0, 81.4490, 0.8312, 1.0, 1.0);

			InfoClientMessage(playerid, "원작자 아이디어 : Claire_Redfield");
			InfoClientMessage(playerid, "당신은 특수 좀비 스모커입니다.");
			InfoClientMessage(playerid, "당신의 혀(Country Rifle)를 생존자에게 맞춰 끌어올 수 있습니다.");
		}
	case ZOMBIE_TYPE_STINGFINGER:
		{
			SetPlayerSkin(playerid, 216);
			SetPlayerHealth(playerid, 100.0);
			SetPlayerAttachedObject(playerid, 0, 19163, 2, 0.0519, 0.0149, 0.0000, 0.0000, 88.4000, -178.7000, 1.1879, 1.2990, 1.3440);
			SetPlayerAttachedObject(playerid, 1, 19472, 2, -0.0279, 0.1599, 0.0020, 85.6999, 87.4000, 0.0000, 1.3459, 1.1499, 1.2089);
			SetPlayerAttachedObject(playerid, 2, 1008, 1, 0.1819, -0.0760, 0.0000, 96.3000, 0.2999, -177.5001, 0.6460, 0.6320, 0.5490);

			InfoClientMessage(playerid, "당신은 특수 좀비 스팅핑거입니다.");
			InfoClientMessage(playerid, "F 키로 팔의 촉수를 늘려 멀리 있는 생존자를 잡을 수 있습니다.");
			InfoClientMessage(playerid, "Y 키로 5초간 점프력이 향상됩니다.");
		}
		// Chicken game
	case ZOMBIE_TYPE_CHICKEN:
		{
			SetPlayerSkin(playerid, 167);
			SetPlayerHealth(playerid, 100.0);
			
			InfoClientMessage(playerid, "니는 특수 좀비 치킨이다.");
			InfoClientMessage(playerid, "앞을 보고 걸어다닐 수 없고 계속 빙글빙글 돈다.");
			InfoClientMessage(playerid, "어떤 무기에 대미지를 입든 특수무기 효과 중 하나를 당한다.");
			InfoClientMessage(playerid, "\"쿠우님 죄송합니다.\" 이외에는 아무런 말을 할 수 없다.");
			InfoClientMessage(playerid, "인간에게 공격하면 대미지가 0이다.");
		}
	}

	zombieType[playerid] = type;

	return 1;
}

function SelectHostZombie(targetid = INVALID_PLAYER_ID)
{
	if (IsPlayerConnected(hostZombie))
		return 0;
	
	if (targetid == INVALID_PLAYER_ID)
	{
		if (gameInfo[gZombies] <= 0)
			targetid = RandomHumanPlayer(1);
		else
			targetid = RandomZombiePlayer(0);
	}
	
	if (!IsPlayerConnected(targetid))
		return 0;
	
	new string[145];

	format(string, sizeof(string), "[감염] 생존자 %s 님께서 숙주 좀비가 되었습니다.", GetPlayerNameEx(targetid));
	SendClientMessageToAll(0xFF0000FF, string);

	hostZombie = targetid;
	SetPlayerHostZombie(targetid, .first = true);
	return 1;
}

stock RandomZombiePlayer(hostCheck)
{
	new playerid = INVALID_PLAYER_ID;

	if (gameInfo[gPlayers] >= 0)
	{
		new checkedPlayer[MAX_PLAYERS];
		new checked;

		do {
			playerid = random(MAX_PLAYERS);

			if (checkedPlayer[playerid] == 0)
			{
				checkedPlayer[playerid] = 1;

				++checked;
			}
		} while (checked < MAX_PLAYERS && (!IsPlayerCurrentPlayer(playerid) || !IsPlayerZombie(playerid) || (hostCheck != 0 && hostZombie == playerid)));
	}

	return playerid;
}

function CheckZombieCount(targetid)
{
	if (!IsPlayerConnected(targetid))
		return 0;

	if (zombieType[targetid] == 0 || IsPlayerHuman(targetid))
	{
		++gameInfo[gZombies];

		if (IsPlayerHuman(targetid))
		{
			--gameInfo[gHumans];
			
			CheckGameState();
		}
	}

	return 1;
}

function bool: IsPlayerZombie(playerid)
{
	return (IsPlayerCurrentPlayer(playerid) && zombieType[playerid] > 0);
}

function AttackZombiePlayer(playerid)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerZombie(playerid))
		return 0;
	
	new Float: px, Float: py, Float: pz;
	new Float: tx, Float: ty, Float: tz;

	GetFrontAttackPosition(playerid, px, py, pz);

	contloop (new targetid : playerList)
	{
		if (IsPlayerHuman(targetid) && IsPlayerInRangeOfPoint(targetid, 1.5, px, py, pz))
		{
			GetPlayerPos(targetid, tx, ty, tz);
			
			if (Get2DDistanceFromPoint(px, py, tx, ty) <= 0.5)
				OnPlayerTakeDamage(targetid, playerid, BASE_ZOMBIE_DAMAGE, 0, 0);
		}
	}

	return 1;
}

function AttackStingFingerZombiePlayer(playerid)
{
	if (!IsPlayerConnected(playerid) || (zombieType[playerid] != ZOMBIE_TYPE_STINGFINGER_HOST && zombieType[playerid] != ZOMBIE_TYPE_STINGFINGER))
		return 0;
	
	new Float: px, Float: py, Float: pz;
	new Float: camFrontVecX, Float: camFrontVecY, Float: camFrontVecZ;
	new Float: targetDistances[MAX_STINGFINGER_TARGET_PLAYERS] = { Float: 99999.0, ... };
	new Float: distance;
	new targetPlayers[MAX_STINGFINGER_TARGET_PLAYERS];
	new targetCount;
	new targetid;

	GetPlayerPos(playerid, px, py, pz);
	GetPlayerCameraFrontVector(playerid, camFrontVecX, camFrontVecY, camFrontVecZ);

	px += STINGFINGER_ATTACK_RANGE * camFrontVecX;
	py += STINGFINGER_ATTACK_RANGE * camFrontVecY;
	pz += STINGFINGER_ATTACK_RANGE * camFrontVecZ;

	contloop (targetid : playerList)
	{
		if (!IsPlayerHuman(targetid))
		{
			continue;
		}

		distance = GetPlayerDistanceFromPoint(targetid, px, py, pz);

		if (distance > STINGFINGER_ATTACK_RANGE)
		{
			continue;
		}

		for (new j = 0; j < MAX_STINGFINGER_TARGET_PLAYERS; ++j)
		{
			if (targetPlayers[j] != 0 && targetDistances[j] <= distance)
			{
				continue;
			}

			if (targetPlayers[j] == 0)
			{
				++targetCount;
			}

			targetPlayers[j] = targetid + 1;
			targetDistances[j] = distance;
			break;
		}

		if (targetCount >= MAX_STINGFINGER_TARGET_PLAYERS)
		{
			break;
		}
	}

	for (new i = 0; i < targetCount; ++i)
	{
		targetid = targetPlayers[i] - 1;

		if (IsPlayerConnected(targetid))
		{
		#if !defined STINGFINGER_ATTACK_DAMAGE
			OnPlayerTakeDamage(targetid, playerid, BASE_ZOMBIE_DAMAGE, 1, 0);
		#else
			OnPlayerTakeDamage(targetid, playerid, STINGFINGER_ATTACK_DAMAGE, 1, 0);
		#endif
		}
	}

	return 1;
}

function PlayerInfectPlayer(playerid, targetid, weaponid)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid) || !IsPlayerZombie(playerid) || !IsPlayerHuman(targetid))
		return 0;
	
	new string[MAX_MESSAGE_LENGTH];

	++killCount[playerid];

	SendDeathMessage(playerid, targetid, weaponid);

	AddPlayerKillCount(playerid);
	AddPlayerDeathCount(targetid);
	GivePlayerMoney(playerid, KILL_REWARD(playerid));

	ResetPlayerWeapons(targetid);
	RemovePlayerAttachedObjects(targetid);
	SetPlayerZombie(targetid);

	OnPlayerSpawned(targetid);

	format(string, sizeof(string), "~y~> SHOT <~n~~w~x %d", killCount[playerid]);
	GameTextForPlayer(playerid, string, 3000, 3);

	format(string, sizeof(string), "[감염] 생존자 %s 님께서 감염되었습니다.", GetPlayerNameEx(targetid));
	SendClientMessageToAll(0xFF0000FF, string);

	return 1;
}

function UsePlayerZombieSkill(playerid, targetid = INVALID_PLAYER_ID, type = 0)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerZombie(playerid) || !IsPlayerHiddenZombie(playerid))
		return 0;
	
	switch (zombieType[playerid])
	{
	case ZOMBIE_TYPE_TANK_HOST:
		{
			new Float: px, Float: py, Float: pz, Float: pa;
			new Float: tx, Float: ty, Float: tz;
			new Float: checkAngle;
			new Float: distance = 50.0;

			GetPlayerPos(playerid, px, py, pz);
			GetPlayerFacingAngle(playerid, pa);

			skillObject[playerid][0] = CreateSkillObject(SKILL_OBJECT_TYPE_TANK, 3931, px, py, pz, 0.0, 0.0, pa);

			if (skillObject[playerid][0] != INVALID_OBJECT_ID)
			{
				contloop (targetid : playerList)
				{
					if (!IsPlayerHuman(targetid) || IsPlayerInRangeOfPoint(targetid, 50.0, px, py, pz) == 0)
						continue;
					
					GetPlayerPos(targetid, tx, ty, tz);

					checkAngle = 180.0 - atan2(px - tx, py - ty);
					
					if (floatabs(checkAngle - pa) < 5.0)
					{
						distance = GetPlayerDistanceFromPoint(targetid, px, py, pz);

						break;
					}
				}

				MoveObject(skillObject[playerid][0], px + (distance * floatsin(-pa, degrees)), py + (distance * floatcos(-pa, degrees)), pz, 100.0, 0.0, 0.0, 0.0);
			}
		}
	case ZOMBIE_TYPE_JOCKEY:
		{
			new Float: x, Float: y, Float: z;
			//new Float: minDistance = 5.1;
			//new Float: distance;

			GetPlayerPos(playerid, x, y, z);

			contloop (new i : playerList)
			{
				if (IsPlayerZombie(i))
					continue;
				
				/*distance = GetPlayerDistanceFromPoint(targetid, x, y, z);

				if (distance < minDistance)
				{
					minDistance = distance;
					targetid = i;
				}*/

				if (IsPlayerInRangeOfPoint(i, 5.0, x, y, z))
					SetPlayerFreezeWithTime(i);
			}

			/*if (IsPlayerConnected(targetid))
				SetPlayerFreezeWithTime(targetid, 5000);*/
		}
	case ZOMBIE_TYPE_SWAM:
		CreateSwamFromPlayer(playerid);
	case ZOMBIE_TYPE_FARMSPAWNER:
		{
			new Float: x, Float: y, Float: z;

			GetPlayerPos(playerid, x, y, z);
			CreateMapObject(3374, x, y, z, 0.0, 0.0, 0.0);
		}
	case ZOMBIE_TYPE_BOOMER:
		CreateBoomerExplosion(playerid);
	case ZOMBIE_TYPE_HUNTER:
		{}
	case ZOMBIE_TYPE_CHARGER:
		{
			new Float: vx, Float: vy, Float: vz;

			chargerGrabType[playerid] = 1;
			skillEndTimer[playerid] = SetTimerEx("OnPlayerRequestChargerGrabEnd", GetRealTimerTime(3000), 0, "i", playerid);

			GetPlayerVelocity(playerid, vx, vy, vz);
			SetPlayerVelocity(playerid, vx * 30.0, vy * 30.0, 1.5);
		}
	case ZOMBIE_TYPE_SPITTER:
		{
			new Float: x, Float: y, Float: z;

			ResetPlayerWeapons(playerid);

			GetPlayerPos(targetid, x, y, z);
			CreateExplosion(x, y, z + 1.7, 1, 0.1);
		}
	case ZOMBIE_TYPE_SMOKER:
		{
			new Float: px, Float: py, Float: pz;
			new Float: tx, Float: ty, Float: tz;
			new Float: pa;

			skillStep[playerid] = 50;
			smokerAttack[playerid] = 1;
			smokerAttack[targetid] = playerid + 2;

			ResetPlayerWeapons(playerid);

			GetPlayerPos(playerid, px, py, pz);
			GetPlayerFacingAngle(playerid, pa);
			GetPlayerPos(targetid, tx, ty, tz);

			TogglePlayerControllable(targetid, 0);

			for (new i = 1; i <= MAX_SKILL_OBJECTS; ++i)
				skillObject[playerid][i - 1] = CreateObject(2907, tx + (((px - tx) / MAX_SKILL_OBJECTS) * i), ty + (((py - ty) / MAX_SKILL_OBJECTS) * i), tz + (((pz - tz) / MAX_SKILL_OBJECTS) * i),
					0.0, 0.0, pa);
			
			smokerPosX[playerid] = px;
			smokerPosY[playerid] = py;
			smokerPosZ[playerid] = pz;

			smokerPosX[targetid] = tx;
			smokerPosY[targetid] = ty;
			smokerPosZ[targetid] = tz;

			SendClientMessage(targetid, 0xFFFFFFFF, "스모커에게 잡히셨습니다.");
		}
	case ZOMBIE_TYPE_STINGFINGER_HOST, ZOMBIE_TYPE_STINGFINGER:
		{
			if (type == 0)
			{
				SetPlayerAttachedObject(playerid, 3, 2906, 1, 0.1949, 1.1179, 0.0980, 0.0000, -88.0000, 0.0000, 1.0000, 4.0219, 1.0000);
				SetPlayerAttachedObject(playerid, 4, 2906, 1, 0.1949, 1.1179, -0.0980, 0.0000, 88.0000, 0.0000, 1.0000, 4.0219, 1.0000);

				AttackStingFingerZombiePlayer(playerid);

				zombieSkillCoolTime[playerid][0] = ZOMBIE_SKILL_COOL_TIME;
				skillEndTimer[playerid] = SetTimerEx("OnPlayerStingFingerAttackEnd", GetRealTimerTime(1000), 0, "i", playerid);
			}
			else
			{
				stingFingerJump[playerid] = true;
				zombieSkillCoolTime[playerid][1] = ZOMBIE_SKILL_COOL_TIME;

				InfoClientMessage(playerid, "점프력이 향상되었습니다.");

				skillEndTimer[playerid] = SetTimerEx("OnPlayerStingFingerJumpEnd", GetRealTimerTime(STINGFINGER_JUMP_TIME), 0, "i", playerid);
			}

			return 1;
		}
	}

	zombieSkillCoolTime[playerid][0] = ZOMBIE_SKILL_COOL_TIME;

	return 1;
}

function bool: IsPlayerFKeySkillZombie(playerid)
{
	if (!IsPlayerCurrentPlayer(playerid) || !IsPlayerZombie(playerid))
		return false;
	
	new type = zombieType[playerid];

	return (type == ZOMBIE_TYPE_TANK_HOST || type == ZOMBIE_TYPE_STINGFINGER_HOST || (type >= ZOMBIE_TYPE_JOCKEY && type <= ZOMBIE_TYPE_BOOMER)
		|| type == ZOMBIE_TYPE_CHARGER || type == ZOMBIE_TYPE_STINGFINGER);
}

function bool: IsPlayerHiddenZombie(playerid)
{
	/*return (!IsPlayerConnected(playerid) || currentPlayer[playerid] == 0 || !IsPlayerZombie(playerid) || zombieType[playerid] == ZOMBIE_TYPE_NORMAL_HOST ||
		zombieType[playerid] == ZOMBIE_TYPE_NORMAL);*/
	
	return (IsPlayerCurrentPlayer(playerid) && zombieType[playerid] != ZOMBIE_TYPE_NORMAL_HOST && zombieType[playerid] != ZOMBIE_TYPE_NORMAL);
}

function CreateBoomerExplosion(playerid)
{
	if (!IsPlayerCurrentPlayer(playerid) || zombieType[playerid] != ZOMBIE_TYPE_BOOMER)
		return 0;
	
	new Float: x, Float: y, Float: z;

	GetPlayerPos(playerid, x, y, z);
	CreateExplosion(x + 2.0, y, z, 2, 10.0);
	KillPlayer(playerid);

	return 1;
}

function CreateSwamFromPlayer(playerid)
{
	if (!IsPlayerConnected(playerid) || zombieType[playerid] != ZOMBIE_TYPE_SWAM)
		return 0;
	
	new Float: x, Float: y, Float: z;

	GetPlayerPos(playerid, x, y, z);

	swamEnabled = true;
	swamPosX = x;
	swamPosY = y;
	swamPosZ = z;

	if (IsValidObject(swamObject))
		DestroyObject(swamObject);
	
	swamObject = CreateMapObject(18728, x, y, z - 3.0, 0.0, 0.0, 0.0);

	if (swamEndTimer != 0)
		KillTimer(swamEndTimer);
	
	swamEndTimer = SetTimer("OnRequestSwamEnd", GetRealTimerTime(15000), 0);

	return 1;
}

function ResetSmokerSkill(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	contloop (new targetid : playerList)
	{
		if (smokerAttack[targetid] == playerid + 2)
		{
			smokerAttack[targetid] = 0;

			TogglePlayerControllable(targetid, 1);
		}
	}

	smokerAttack[playerid] = 0;

	RemovePlayerSkillObjects(playerid);

	return 1;
}

function RemovePlayerSkillObjects(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	for (new i = 0; i < MAX_SKILL_OBJECTS; ++i)
	{
		if (IsValidObject(skillObject[playerid][i]))
		{
			DestroyObject(skillObject[playerid][i]);

			skillObject[playerid][i] = INVALID_OBJECT_ID;
		}
	}

	return 1;
}

function bool: IsPlayerInSwam(playerid)
{
	return (IsPlayerConnected(playerid) && swamEnabled && IsPlayerInRangeOfPoint(playerid, 10.0, swamPosX, swamPosY, swamPosZ));
}

function bool: IsZombieWantSurrender()
{
	return (IsGameProgress() && IsPlayerConnected(hostZombie) && requestZombieSurrender);
}

function SetZombieWantSurrender(bool: want)
{
	requestZombieSurrender = want;
}
