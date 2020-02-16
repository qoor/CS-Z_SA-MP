/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * System for human survivor
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

#include "./CZ/Game/Inc/Human.inc"
#include "./CZ/Game/Inc/Zombie.inc"

InitModule("Game_Human")
{
	InitSpawnWeapons();
	InitWeaponShop();

	AddEventHandler(D_PlayerConnect, "G_Human_PlayerConnect");
	AddEventHandler(D_PlayerDisconnect, "G_Human_PlayerDisconnect");
	AddEventHandler(D_PlayerSpawn, "G_Human_PlayerSpawn");
	AddEventHandler(D_PlayerKeyStateChange, "G_Human_PlayerKeyStateChange");
	AddEventHandler(D_PlayerCommandText, "G_Human_PlayerCommandText");
	AddEventHandler(D_DialogResponse, "G_Human_DialogResponse");
	AddEventHandler(D_PlayerUpdate, "G_Human_PlayerUpdate");
	AddEventHandler(D_PlayerStreamIn, "G_Human_PlayerStreamIn");
	AddEventHandler(D_PlayerTakeDamage, "G_Human_PlayerTakeDamage");
	AddEventHandler(D_PlayerDeath, "G_Human_PlayerDeath");
	AddEventHandler(gamemodeMapStartEvent, "G_Human_GamemodeMapStart");
	AddEventHandler(gameRoundFinishEvent, "G_Human_GameRoundFinish");
	AddEventHandler(gameCountEvent, "G_Human_GameCount");
	AddEventHandler(global1sTimer, "G_Human_Global1sTimer");
	AddEventHandler(playerKilledEvent, "G_Human_PlayerKilled");
}

function InitSpawnWeapons()
{
	AddSpawnWeapon(0, WEAPON_SNIPER, 30);
	AddSpawnWeapon(0, WEAPON_M4, 300);
	//
	AddSpawnWeapon(1, WEAPON_DEAGLE, 100);
	AddSpawnWeapon(1, WEAPON_SHOTGUN, 50);
	//
	AddSpawnWeapon(2, WEAPON_TEC9, 150);
	AddSpawnWeapon(2, WEAPON_COLT45, 100);
	//
	AddSpawnWeapon(3, WEAPON_MP5, 300);
	AddSpawnWeapon(3, WEAPON_GRENADE, 3);
	//
	AddSpawnWeapon(4, WEAPON_M4, 300);
	AddSpawnWeapon(4, WEAPON_RIFLE, 50);
	//
	AddSpawnWeapon(5, WEAPON_AK47, 200);
	AddSpawnWeapon(5, WEAPON_SAWEDOFF, 200);
	//
	AddSpawnWeapon(6, WEAPON_AK47, 300);
	AddSpawnWeapon(6, WEAPON_SHOTGUN, 50);
	//
	AddSpawnWeapon(7, WEAPON_AK47, 300);
	AddSpawnWeapon(7, WEAPON_MP5, 100);
	//
	AddSpawnWeapon(8, WEAPON_SPRAYCAN, 100);
	AddSpawnWeapon(8, WEAPON_MP5, 300);
	//
	AddSpawnWeapon(9, WEAPON_SATCHEL, 7);
	AddSpawnWeapon(9, WEAPON_FIREEXTINGUISHER, 150);
	//
	AddSpawnWeapon(10, WEAPON_SILENCED, 100);
	AddSpawnWeapon(10, WEAPON_SAWEDOFF, 200);
	//
	AddSpawnWeapon(11, WEAPON_CHAINSAW, 1);
	//
	AddSpawnWeapon(12, WEAPON_SHOTGSPA, 200);
	AddSpawnWeapon(12, WEAPON_SILENCED, 100);
	//
	AddSpawnWeapon(13, WEAPON_UZI, 200);
	AddSpawnWeapon(13, WEAPON_AK47, 200);
	//
	AddSpawnWeapon(14, WEAPON_KATANA, 1);
	//
	AddSpawnWeapon(15, WEAPON_BAT, 1);
	//
	AddSpawnWeapon(16, WEAPON_SHOTGUN, 50);
	//
	AddSpawnWeapon(17, WEAPON_SILENCED, 100);
	//
	AddSpawnWeapon(18, WEAPON_DEAGLE, 100);
	//
	AddSpawnWeapon(19, WEAPON_RIFLE, 50);
	//
	AddSpawnWeapon(20, WEAPON_SILENCED, 80);
	AddSpawnWeapon(20, WEAPON_TEARGAS, 1);
	//
	AddSpawnWeapon(21, WEAPON_SILENCED, 80);
	AddSpawnWeapon(21, WEAPON_TEARGAS, 1);
}

function InitWeaponShop()
{
	for (new i = 0; i < 47; ++i)
	{
		weaponShopCache[i][0] = -1;
		weaponShopCache[i][1] = -1;
	}

	AddWeaponToShop(0, WEAPON_SILENCED, 100, 500);
	AddWeaponToShop(0, WEAPON_DEAGLE, 200, 3000);
	AddWeaponToShop(0, WEAPON_AK47, 500, 3500);
	AddWeaponToShop(0, WEAPON_M4, 500, 5000);
	//
	AddWeaponToShop(1, WEAPON_SHOTGUN, 100, 5000);
	AddWeaponToShop(1, WEAPON_SAWEDOFF, 500, 7000);
	AddWeaponToShop(1, WEAPON_SHOTGSPA, 500, 7000);
	AddWeaponToShop(1, WEAPON_MOLTOV, 3, 5000);
	AddWeaponToShop(1, WEAPON_GRENADE, 3, 5000);
	AddWeaponToShop(1, WEAPON_SATCHEL, 5, 7000);
	//
	AddWeaponToShop(2, WEAPON_TEC9, 300, 3000);
	AddWeaponToShop(2, WEAPON_UZI, 300, 4000);
	AddWeaponToShop(2, WEAPON_MP5, 300, 4000);
	AddWeaponToShop(2, WEAPON_RIFLE, 100, 2000);
	AddWeaponToShop(2, WEAPON_SNIPER, 100, 7000);
}

public G_Human_PlayerConnect(playerid)
{
	hiddenWeapon[playerid] = 0;
	hiddenWeaponAmmo[playerid] = 0;

	pipeBombTargeted[playerid] = INVALID_PLAYER_ID;

	return 0;
}

public G_Human_PlayerDisconnect(playerid)
{
	if (freezeTimer[playerid] != 0)
	{
		KillTimer(freezeTimer[playerid]);

		freezeTimer[playerid] = 0;
	}

	if (flashBangEndTimer[playerid] != 0)
	{
		KillTimer(flashBangEndTimer[playerid]);
		flashBangEndTimer[playerid] = 0;
	}

	if (pipeBombActivated[playerid])
		OnPlayerPipeBombEnd(playerid);

	return 0;
}

public G_Human_PlayerSpawn(playerid)
{
	if (IsGameCount())
		SpawnPlayerOfHuman(playerid);
	
	contloop (new i : playerList)
	{
		if (flashBangEndTimer[i])
			SetPlayerMarkerForPlayer(i, playerid, GetPlayerColor(playerid) & 0xFFFFFF00);
	}
	
	if (flashBangEndTimer[playerid])
	{
		FadeCamera(playerid, true, 0.0);
		ResetPlayerFlashBangEffect(playerid);
	}

	pipeBombTargeted[playerid] = INVALID_PLAYER_ID;
	return 0;
}

public G_Human_PlayerKeyStateChange(playerid, newkeys)
{
	if (IsPlayerHuman(playerid))
	{
		if (IsAttackKeyPressed(newkeys))
		{
			if ((hiddenWeapon[playerid] == HIDDEN_WEAPON_KATANA || hiddenWeapon[playerid] == HIDDEN_WEAPON_BAT) && IsPlayerHoldHiddenWeapon(playerid))
				AttackHiddenHitWeaponPlayer(playerid);
			
			return 1;
		}
	}

	if (newkeys & KEY_ANALOG_RIGHT)
	{
		TogglePlayerGrenadeEffect(playerid, !grenadeEffectOff[playerid]);
	}

	return 0;
}

public G_Human_PlayerCommandText(playerid, const command[], const params[])
{
	if (strcmp(command, "/gun", true) == 0 || strcmp(command, "/총") == 0 || strcmp(command, "/무기") == 0)
	{
		if (!IsGameProgress())
			return ErrorClientMessage(playerid, "0~400초 사이에서만 무기 구입이 가능합니다.");
		if (IsPlayerZombie(playerid))
			return ErrorClientMessage(playerid, "좀비는 총을 살 수 없습니다.");
		
		new weapon[64];

		if (!MergeParams(weapon, params))
		{
			ShowPlayerGunShopDialog(playerid);
			return 1;
		}
		
		new weaponid;

		if (IsNumeric(weapon))
		{
			weaponid = strval(weapon);
		}
		else
		{
			new englishWeaponName[64];

			for (new i = 1; i < 47; ++i)
			{
				GetWeaponName(i, englishWeaponName);

				if (strcmp(englishWeaponName, weapon, true) == 0 || strcmp(GetKoreanWeaponName(i), weapon, true) == 0)
				{
					weaponid = i;
					break;
				}
			}
		}

		if (weaponid <= 0 || weaponid > 46 || weaponShopCache[weaponid][0] == -1)
		{
			new string[MAX_MESSAGE_LENGTH];
			new englishWeaponName[64];
			new listCount;

			ErrorClientMessage(playerid, "상점에 존재하지 않는 무기입니다.");
			ErrorClientMessage(playerid, "사용법: /gun [무기 번호/이름]");
			SystemClientMessage(playerid, "==== 무기 판매 목록 ====");

			for (new i = 1; i < 47; ++i)
			{
				if (weaponShopCache[i][0] >= 0)
				{
					GetWeaponName(i, englishWeaponName);

					if (listCount == 0)
					{
						format(string, sizeof(string), "%d: %s(%s)", i, englishWeaponName, GetKoreanWeaponName(i));
					}
					else
					{
						format(string, sizeof(string), "%s, %d: %s(%s)", string, i, englishWeaponName, GetKoreanWeaponName(i));
					}

					if (++listCount >= 5)
					{
						SendClientMessage(playerid, 0xFFFFFFFF, string);
						string[0] = '\0';
						listCount = 0;
					}
				}
			}
		}
		else
		{
			TryPlayerWeaponBuying(playerid, weaponShopCache[weaponid][0], weaponShopCache[weaponid][1]);
		}

		return 1;
	}

	if (strcmp(command, "/총버리기") == 0 || strcmp(command, "/무기버리기") == 0)
	{
		if (!IsGameCount() && !IsGameProgress())
			return ErrorClientMessage(playerid, "게임이 진행중이지 않습니다.");
		
		new weaponid = GetPlayerWeapon(playerid);

		if (weaponid == 0)
			return ErrorClientMessage(playerid, "버리려는 무기를 들고 다시 시도해주세요.");
		
		new string[MAX_MESSAGE_LENGTH];

		GetWeaponName(weaponid, string, sizeof(string));

		if (IsPlayerHoldHiddenWeapon(playerid))
			hiddenWeapon[playerid] = 0;
		
		RemovePlayerWeapon(playerid, weaponid);

		format(string, sizeof(string), "들고있던 무기 %s을(를) 버렸습니다.", string);
		SystemClientMessage(playerid, string);

		return 1;
	}

	if (strcmp(command, "/폭발효과") == 0)
	{
		TogglePlayerGrenadeEffect(playerid, !grenadeEffectOff[playerid]);
		return 1;
	}

	return 0;
}

public G_Human_DialogResponse(playerid, dialogid, response, listitem)
{
	if (dialogid == DIALOG_WEAPON_SHOP)
	{
		if (IsPlayerHuman(playerid) && response != 0)
			ShowPlayerGunShopDialog(playerid, listitem + 1);
		
		return 1;
	}

	if (dialogid >= DIALOG_WEAPON_SHOP + 1 && dialogid < DIALOG_WEAPON_SHOP + sizeof(gunShopList) + 1)
	{
		if (IsPlayerZombie(playerid))
			return 1;
		
		if (response == 0)
			return ShowPlayerGunShopDialog(playerid);
		
		new category = dialogid - DIALOG_WEAPON_SHOP - 1;

		TryPlayerWeaponBuying(playerid, category, listitem);
		//ShowPlayerGunShopDialog(playerid, category + 1);

		return 1;
	}

	return 0;
}

public G_Human_PlayerDeath(playerid)
{
	if (IsPlayerHuman(playerid))
	{
		GetPlayerPos(playerid, lastDeathPosX[playerid], lastDeathPosY[playerid], lastDeathPosZ[playerid]);
		GetPlayerFacingAngle(playerid, lastDeathPosA[playerid]);

		if (heroPlayer == playerid)
			heroPlayer = INVALID_PLAYER_ID;
	}

	return 0;
}

public G_Human_GamemodeMapStart()
{
	heroPlayer = INVALID_PLAYER_ID;

	contloop (new playerid : playerList)
	{
		if (flashBangEndTimer[playerid])
		{
			FadeCamera(playerid, true, 0.0);
			ResetPlayerFlashBangEffect(playerid);
		}
	}
}

public G_Human_PlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
	if (!IsPlayerHuman(issuerid))
		return 0;
	
	new bool: damageGive = true;
	
	if (IsPlayerZombie(playerid))
	{
		new bool: hiddenWeaponDamaged;
		
		if ((hiddenWeapon[issuerid] == HIDDEN_WEAPON_KATANA || hiddenWeapon[issuerid] == HIDDEN_WEAPON_BAT) && IsPlayerHoldHiddenWeapon(issuerid, weaponid))
		{
			hiddenWeaponDamaged = true;

			HiddenWeaponDamageForPlayer(issuerid, playerid, amount);

			PlayerPlaySound(issuerid, 1095, 0.0, 0.0, 0.0);
			PlayerPlaySound(playerid, 17802, 0.0, 0.0, 0.0);
		}
		else
		{
			if (freezeTimer[playerid] != 0)
				return 0;
			
			if (IsPlayerInSwam(playerid))
			{
				new Float: health;

				GetPlayerHealth(playerid, health);
				SetPlayerHealth(playerid, health + amount);

				damageGive = false;
			}
			else
			{
				// Chicken game
				if (IsPlayerChicken(issuerid))
				{
					damageGive = false;
					amount = 0.0;
				}
				else if (weaponid == WEAPON_CHAINSAW)
				{
					amount += 20.0;
				}
				else if (weaponid == WEAPON_GRENADE)
				{
					amount += 8.0;
				}
			}

			if (zombieType[playerid] != ZOMBIE_TYPE_HAMMER_HOST && IsPlayerHoldHiddenWeapon(issuerid, weaponid))
			{
				hiddenWeaponDamaged = true;

				HiddenWeaponDamageForPlayer(issuerid, playerid, amount);
			}

			if (damageGive)
			{
				GivePlayerDamage(issuerid, playerid, weaponid, amount);

				if (IsPlayerChicken(playerid))
				{
					HiddenWeaponDamageForPlayer(issuerid, playerid, amount);
				}
			}
		}

		// Chicken exception
		if (!IsPlayerChicken(playerid) && IsPlayerGodModeEnabled(playerid))
		{
			if (!hiddenWeaponDamaged)
				OnPlayerRespawnKill(issuerid, amount);
			else
			{
				if (hiddenWeapon[issuerid] == HIDDEN_WEAPON_COUNTRYRIFLE && IsPlayerHoldHiddenWeapon(issuerid, weaponid))
				{
					GivePlayerDamage(playerid, issuerid, weaponid, amount);
				}

				HiddenWeaponDamageForPlayer(playerid, issuerid, amount);
			}
		}
		//
	}
	else if (IsPlayerHuman(playerid))
	{
		if (IsGameCount() || IsGameProgress())
		{
			if (hiddenWeapon[issuerid] == HIDDEN_WEAPON_HEALTHGUN && IsPlayerHoldHiddenWeapon(issuerid, weaponid))
			{
				new Float: health;

				GetPlayerHealth(playerid, health);
				
				if (health < 100.0)
					SetPlayerHealth(playerid, health + amount);
			}
			else
			{
				amount = 0.0;

				if (weaponid != WEAPON_GRENADE && weaponid != 51)
					return 0;

				if (issuerid != playerid && grenadeEffectOff[playerid])
				{
					new Float: vx, Float: vy, Float: vz;

					GetPlayerVelocity(playerid, vx, vy, vz);
					SetPlayerVelocity(playerid, vx, vy, vz);
				}
			}

			InsertPlayerDamagedInfo(playerid, issuerid, weaponid, -amount);
		}
	}

	PlayerPlaySound(issuerid, 1057, 0.0, 0.0, 0.0);
	PlayerPlaySound(playerid, 17802, 0.0, 0.0, 0.0);

	return (damageGive) ? 1 : 0;
}

public G_Human_PlayerUpdate(playerid)
{
	if (!IsGameCount() && !IsGameProgress())
		return 1;
	
	if (IsPlayerZombie(playerid))
	{
		contloop (new issuerid : playerList)
		{
			if (!pipeBombActivated[issuerid])
				continue;
			
			if (pipeBombTargeted[playerid] == INVALID_PLAYER_ID)
			{
				if (IsPlayerInRangeOfPoint(playerid, 35.0, pipeBombPosX[issuerid], pipeBombPosY[issuerid], pipeBombPosZ[issuerid]))
				{
					pipeBombTargeted[playerid] = issuerid;
					InfoClientMessage(playerid, "Pipe Bomb에 휘말리셨습니다.");
				}
			}

			if (pipeBombTargeted[playerid] == issuerid)
			{
				SetPlayerPos(playerid, pipeBombPosX[issuerid], pipeBombPosY[issuerid], pipeBombPosZ[issuerid]);
				break;
			}
		}
	}
	
	if (hiddenWeapon[playerid] == HIDDEN_WEAPON_PIPEBOMB || hiddenWeapon[playerid] == HIDDEN_WEAPON_FLASHBANG)
	{
		new weaponid, ammo;

		GetPlayerWeaponData(playerid, GetWeaponSlot(WEAPON_TEARGAS), weaponid, ammo);

		if (weaponid != WEAPON_TEARGAS)
			return 1;

		if (hiddenWeaponAmmo[playerid] != ammo)
		{
			if (hiddenWeaponAmmo[playerid] > ammo)
			{
				if (hiddenWeapon[playerid] == HIDDEN_WEAPON_PIPEBOMB)
				{
					new Float: angle;

					GetPlayerPos(playerid, pipeBombPosX[playerid], pipeBombPosY[playerid], pipeBombPosZ[playerid]);
					GetPlayerFacingAngle(playerid, angle);

					pipeBombActivated[playerid] = true;
					pipeBombPosX[playerid] += floatsin(-angle, degrees) * 35.0;
					pipeBombPosY[playerid] += floatcos(-angle, degrees) * 35.0;

					skillEndTimer[playerid] = SetTimerEx("OnPlayerPipeBombEnd", GetRealTimerTime(9000), false, "i", playerid);
				}
				else
				{
					new Float: x, Float: y, Float: z, Float: angle;

					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, angle);

					x += floatsin(-angle, degrees) * 10.0;
					y += floatcos(-angle, degrees) * 10.0;

					contloop (new targetid : playerList)
					{
						if (IsPlayerZombie(targetid) && IsPlayerInRangeOfPoint(targetid, 35.0, x, y, z))
						{
							new Float: temp;

							HiddenWeaponDamageForPlayer(playerid, targetid, temp);
						}
					}
				}
			}

			hiddenWeaponAmmo[playerid] = ammo;
		}
	}

	return 1;
}

public G_Human_PlayerStreamIn(playerid, forplayerid)
{
	if (flashBangEndTimer[forplayerid])
		ShowPlayerNameTagForPlayer(forplayerid, playerid, false);
	
	return 0;
}

public G_Human_PlayerKilled(playerid, killerid, reason)
{
	if (!IsPlayerConnected(killerid) || !IsPlayerConnected(playerid) || !IsPlayerHuman(killerid) || !IsPlayerZombie(playerid))
		return 1;
	
	new string[32];

	++killCount[killerid];
	
	AddPlayerKillCount(killerid);
	GivePlayerMoney(killerid, KILL_REWARD(killerid));

	format(string, sizeof(string), "~y~> SHOT <~n~~w~x %d", killCount[killerid]);
	GameTextForPlayer(killerid, string, 3000, 3);
	return 1;
}

public G_Human_GameRoundFinish(type)
{
	if (type == GAMEOVER_TYPE_HUMAN_WIN)
	{
		new heroBonus;

		if (IsPlayerConnected(heroPlayer))
			heroBonus = 1;

		contloop (new playerid : playerList)
		{
			if (!IsPlayerGamePlayer(playerid))
				continue;
			
			ClearMessage(playerid);
			NewsClientMessage(playerid, "생존자들이 구출 되었습니다!");
			NewsClientMessage(playerid, "생존자의 승리입니다!");
			
			TogglePlayerControllable(playerid, 0);

			GameTextForPlayer(playerid, "~b~Survivor ~n~~w~Win", 5000, 0);

			if (IsPlayerHuman(playerid))
			{
				GivePlayerScore(playerid, 10);
				GivePlayerMoney(playerid, 10000);
				
				PayClientMessage(playerid, "생존하여 $10,000와 스코어 10을 얻었습니다.");

				if (heroBonus != 0 && playerid != heroPlayer)
				{
					GivePlayerScore(playerid, 5);
					GivePlayerMoney(playerid, 5000);

					PayClientMessage(playerid, "영웅이 생존하여 추가로 $5,000와 스코어 5을 얻었습니다.");
				}
			}
		}

		if (heroBonus != 0)
		{
			GivePlayerScore(heroPlayer, 10);
			GivePlayerMoney(heroPlayer, 10000);

			PayClientMessage(heroPlayer, "생존자를 무사히 지켜 추가로 $10,000와 스코어 10을 얻었습니다.");
		}
	}
}

public G_Human_GameCount(count)
{
	if (count == 5)
		SelectHeroHuman();
}

public G_Human_Global1sTimer()
{
	if (GetGameTime() != -1 && IsPlayerConnected(heroPlayer))
	{
		new Float: x, Float: y, Float: z;
		new Float: health;

		GetPlayerPos(heroPlayer, x, y, z);

		contloop (new targetid : playerList)
		{
			if (heroPlayer == targetid || !IsPlayerHuman(targetid))
				continue;
			
			if (IsPlayerInRangeOfPoint(targetid, 5.0, x, y, z))
			{
				GetPlayerHealth(targetid, health);
				
				if (health < 100.0)
					SetPlayerHealth(targetid, health + 1.0);
			}
		}
	}

	return 0;
}

public OnPlayerPipeBombEnd(playerid)
{
	if (!pipeBombActivated[playerid])
		return;
	
	new Float: health;
	
	contloop (new targetid : playerList)
	{
		if (pipeBombTargeted[targetid] == playerid)
		{
			pipeBombTargeted[targetid] = INVALID_PLAYER_ID;

			GetPlayerHealth(targetid, health);
			GivePlayerDamage(playerid, targetid, WEAPON_TEARGAS, health);
		}
	}

	CreateExplosion(pipeBombPosX[playerid], pipeBombPosY[playerid], pipeBombPosZ[playerid], 0, 0.0);

	pipeBombActivated[playerid] = false;
	pipeBombPosX[playerid] = 0.0;
	pipeBombPosY[playerid] = 0.0;
	pipeBombPosZ[playerid] = 0.0;
}

public OnPlayerFlashBangEnd(playerid)
{
	ResetPlayerFlashBangEffect(playerid, true);
}

function SpawnPlayerOfHuman(playerid)
{
	SetPlayerSpawnPos(playerid);

	InfoClientMessage(playerid, "당신은 생존자입니다! 구출 될 때 까지 생존하십시오!");
	InfoClientMessage(playerid, "\"/gun\" 명령어로 1회용 무기를 구입할 수 있습니다!");

	SetPlayerHuman(playerid);
}

function SetPlayerHuman(playerid, type = -1)
{
	CheckHumanCount(playerid);
	
	zombieType[playerid] = -1;
	hiddenWeapon[playerid] = 0;

	RemovePlayerAttachedObjects(playerid);
	ResetPlayerWeapons(playerid);
	ClearAnimations(playerid, 1);
	SetCameraBehindPlayer(playerid);
	SetPlayerColor(playerid, 0x32CD32FF);

	if (playerInfo[playerid][pSkin] == -1)
		SetPlayerSkin(playerid, RandomCitizenSkin());
	else
		SetPlayerSkin(playerid, playerInfo[playerid][pSkin]);
	
	SetPlayerHealth(playerid, 95.0 + playerInfo[playerid][pUpgHealth]);

	if (!IsPlayerChicken(playerid))
	{
		new weaponIndex;
	
		if (type == -1)
			weaponIndex = random(spawnWeapons);
		else
			weaponIndex = type;
		
		GivePlayerSpawnWeapons(playerid, weaponIndex);

		switch (weaponIndex)
		{
		case HIDDEN_WEAPON_KATANA:
			{
				hiddenWeapon[playerid] = HIDDEN_WEAPON_KATANA;

				if (playerInfo[playerid][pUpgPower] == 5 || playerInfo[playerid][pUpgDec] == 5)
					SetPlayerAttachedObject(playerid, 0, 339, 5, 0.0028, 0.0650, -0.0166, 182.8249, 0.0, 0.0, 1.0, 1.0, 1.0);
				else if (playerInfo[playerid][pUpgPower] == 5 && playerInfo[playerid][pUpgDec] == 5)
				{
					SetPlayerAttachedObject(playerid, 0, 339, 5, 0.0028, 0.0650, -0.0166, 182.8249, 0.0, 0.0, 1.0, 1.0, 1.0);
					SetPlayerAttachedObject(playerid, 1, 339, 2, -0.0573, 0.0791, -0.0018, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
				}

				InfoClientMessage(playerid, "카타나에 당첨되었습니다.");
				InfoClientMessage(playerid, "좀비를 한방에 사살할 수 있습니다.");
			}
		case HIDDEN_WEAPON_BAT:
			{
				hiddenWeapon[playerid] = HIDDEN_WEAPON_BAT;

				InfoClientMessage(playerid, "야구 방망이에 당첨되었습니다.");
				InfoClientMessage(playerid, "좀비를 방망이로 쳐서 멀리 날려보낼 수 있습니다. 단, 데미지는 없습니다.");
			}
		case HIDDEN_WEAPON_NSHOTGUN:
			{
				hiddenWeapon[playerid] = HIDDEN_WEAPON_NSHOTGUN;

				InfoClientMessage(playerid, "원작자 아이디어 : Claire_Redfield");
				InfoClientMessage(playerid, "N_Shotgun에 당첨되었습니다.");
				InfoClientMessage(playerid, "좀비를 쏴서 멀리 날려보낼 수 있습니다.");
			}
		case HIDDEN_WEAPON_HEALTHGUN:
			{
				hiddenWeapon[playerid] = HIDDEN_WEAPON_HEALTHGUN;
				
				InfoClientMessage(playerid, "원작자 아이디어 : Claire_Redfield");
				InfoClientMessage(playerid, "Health Gun에 당첨되었습니다.");
				InfoClientMessage(playerid, "다른 생존자에게 해독제를 맞춰 체력을 회복시켜줄 수 있습니다.");
			}
		case HIDDEN_WEAPON_FREEZEGUN:
			{
				hiddenWeapon[playerid] = HIDDEN_WEAPON_FREEZEGUN;
				
				InfoClientMessage(playerid, "Freeze Gun에 당첨되었습니다.");
				InfoClientMessage(playerid, "좀비를 쏴서 마비시킬 수 있습니다.");
			}
		case HIDDEN_WEAPON_COUNTRYRIFLE:
			{
				hiddenWeapon[playerid] = HIDDEN_WEAPON_COUNTRYRIFLE;

				InfoClientMessage(playerid, "원작자 아이디어 : Fasa, RangE");
				InfoClientMessage(playerid, "강력한 Country Rifle에 당첨되었습니다.");
				InfoClientMessage(playerid, "Country Rifle 데미지가 70까지 증가합니다.");
			}
		case HIDDEN_WEAPON_PIPEBOMB:
			{
				hiddenWeapon[playerid] = HIDDEN_WEAPON_PIPEBOMB;

				InfoClientMessage(playerid, "Pipe bomb에 당첨되었습니다.");
				InfoClientMessage(playerid, "전방에 Pipe bomb를 투척하여 좀비들을 처치할 수 있습니다.");
			}
		case HIDDEN_WEAPON_FLASHBANG:
			{
				hiddenWeapon[playerid] = HIDDEN_WEAPON_FLASHBANG;

				InfoClientMessage(playerid, "Flash bang에 당첨되었습니다.");
				InfoClientMessage(playerid, "전방에 Flash bang을 투척하여 좀비들의 시야를 방해할 수 있습니다.");
			}
		}
	}

	OnPlayerSpawned(playerid);
}

function SelectHeroHuman()
{
	if (IsPlayerConnected(heroPlayer))
		return 0;
	
	new targetid = RandomHumanPlayer(1, true);

	if (!IsPlayerConnected(targetid))
		return 0;
	
	heroPlayer = targetid;

	SetPlayerHero(targetid);

	return 1;
}

function SetPlayerHero(playerid)
{
	if (!IsPlayerConnected(playerid) || heroPlayer != playerid)
		return 0;
	
	new string[MAX_MESSAGE_LENGTH];

	SetPlayerColor(playerid, 0x87CEEBAA);
	
	if (hiddenWeapon[playerid] != HIDDEN_WEAPON_PIPEBOMB && hiddenWeapon[playerid] != HIDDEN_WEAPON_FLASHBANG)
		GivePlayerWeapon(playerid, WEAPON_GRENADE, 3);
	
	GivePlayerWeapon(playerid, WEAPON_SHOTGSPA, 500);
	GivePlayerWeapon(playerid, WEAPON_M4, 500);
	GivePlayerWeapon(playerid, WEAPON_SNIPER, 30);

	format(string, sizeof(string), "[영웅] 생존자 %s님께서 영웅이 되었습니다.", GetPlayerNameEx(playerid));
	SendClientMessageToAll(0x87CEEBAA, string);

	return 1;
}

function AddSpawnWeapon(index, weaponid, ammo)
{
	if (index < 0 || index >= MAX_SPAWN_WEAPON_TYPE)
		return 0;
	
	if (spawnWeaponList[index][0][0] == 0)
	{
		spawnWeaponList[index][0][0] = weaponid;
		spawnWeaponList[index][0][1] = ammo;
	}
	else if (spawnWeaponList[index][1][0] == 0)
	{
		spawnWeaponList[index][1][0] = weaponid;
		spawnWeaponList[index][1][1] = ammo;
	}
	else
		return 0;

	if (index >= spawnWeapons)
		spawnWeapons = index + 1;
	
	return 1;
}

function GivePlayerSpawnWeapons(playerid, index)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	if (spawnWeaponList[index][0][0] != 0)
		GivePlayerWeapon(playerid, spawnWeaponList[index][0][0], spawnWeaponList[index][0][1]);
	if (spawnWeaponList[index][1][0] != 0)
		GivePlayerWeapon(playerid, spawnWeaponList[index][1][0], spawnWeaponList[index][1][1]);

	return 1;
}

function bool: IsPlayerHuman(playerid)
{
	return (IsPlayerCurrentPlayer(playerid) && zombieType[playerid] == ZOMBIE_TYPE_HUMAN);
}

function RandomHumanPlayer(heroCheck, bool: ignoreChicken = false)
{
	new playerid = INVALID_PLAYER_ID;

	if (gameInfo[gPlayers] > 0)
	{
		new checkedPlayer[MAX_PLAYERS];
		new checked;

		// Chicken game
		if (!ignoreChicken)
		{
			contloop (new i : playerList)
			{
				if (IsPlayerChicken(i) && IsPlayerLoggedIn(i) && IsPlayerHuman(playerid))
				{
					i = playerid;
					break;
				}
			}
		}
		//

		if (playerid == INVALID_PLAYER_ID)
		{
			do {
				playerid = random(MAX_PLAYERS);

				if (checkedPlayer[playerid] == 0)
				{
					checkedPlayer[playerid] = 1;

					++checked;
				}
			} while (checked < MAX_PLAYERS && (!IsPlayerCurrentPlayer(playerid) || !IsPlayerHuman(playerid) || (ignoreChicken && IsPlayerChicken(playerid))
				|| (heroCheck != 0 && heroPlayer == playerid))); // Chicken game
		}
	}

	return playerid;
}

function AttackHiddenHitWeaponPlayer(playerid)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerHuman(playerid))
		return 0;
	
	if ((hiddenWeapon[playerid] != HIDDEN_WEAPON_KATANA && hiddenWeapon[playerid] != HIDDEN_WEAPON_BAT) || !IsPlayerHoldHiddenWeapon(playerid))
		return 0;
	
	new Float: px, Float: py, Float: pz;
	new Float: tx, Float: ty, Float: tz;
	new weaponid = GetPlayerWeapon(playerid);

	GetFrontAttackPosition(playerid, px, py, pz);

	contloop (new targetid : playerList)
	{
		if (!IsPlayerZombie(targetid))
			continue;
		
		GetPlayerPos(targetid, tx, ty, tz);

		if (Get2DDistanceFromPoint(px, py, tx, ty) <= 1)
			OnPlayerTakeDamage(targetid, playerid, 0.0, weaponid, 0);
	}

	return 1;
}

function HiddenWeaponDamageForPlayer(playerid, targetid, &Float: amount)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid))
		return 0;

	new weaponType = hiddenWeapon[playerid];

	// Chicken game
	if (IsPlayerChicken(targetid))
	{
		do {
			weaponType = random(HIDDEN_WEAPON_FLASHBANG + 1) + HIDDEN_WEAPON_KATANA;
		} while (weaponType == HIDDEN_WEAPON_PIPEBOMB);
	}
	//
	
	switch (weaponType)
	{
	case HIDDEN_WEAPON_KATANA:
		{
			new Float: health;

			GetPlayerHealth(targetid, health);
			GivePlayerDamage(playerid, targetid, WEAPON_KATANA, health);
		}
	case HIDDEN_WEAPON_BAT:
		{
			new Float: vx, Float: vy, Float: a;

			GetPlayerFacingAngle(playerid, a);

			vx = floatsin(-a, degrees) * 3.0;
			vy = floatcos(-a, degrees) * 3.0;

			SetPlayerVelocity(targetid, vx, vy, 1.5);
		}
	case HIDDEN_WEAPON_NSHOTGUN:
		{
			new Float: pa;
			new Float: vx, Float: vy;

			GetPlayerFacingAngle(playerid, pa);

			vx = 3.0 * floatsin(-pa, degrees);
			vy = 3.0 * floatcos(-pa, degrees);

			SetPlayerVelocity(targetid, vx, vy, 0.2);
			ApplyAnimation(targetid, "PED", "KD_left", 4.1, 0, 1, 1, 1, 1, 1);
		}
	case HIDDEN_WEAPON_FREEZEGUN:
		SetPlayerFreezeWithTime(targetid);
	case HIDDEN_WEAPON_COUNTRYRIFLE:
		amount = 70.0;
	case HIDDEN_WEAPON_FLASHBANG:
		{
			contloop (new i : playerList)
			{
				ShowPlayerNameTagForPlayer(targetid, i, false);
				SetPlayerMarkerForPlayer(targetid, i, GetPlayerColor(i) & 0xFFFFFF00);
			}

			FadeCamera(targetid, false, 0.0, 255, 255, 255);

			if (flashBangEndTimer[targetid])
				KillTimer(flashBangEndTimer[targetid]);
			
			flashBangEndTimer[targetid] = SetTimerEx("OnPlayerFlashBangEnd", GetRealTimerTime(15000), false, "i", targetid);

			InfoClientMessage(targetid, "Flash Bang에 휘말리셨습니다.");
		}
	}

	return 1;
}

function bool: IsPlayerHoldHiddenWeapon(playerid, weaponid = -1)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerHuman(playerid) || hiddenWeapon[playerid] == 0)
		return false;
	
	if (weaponid == -1)
		weaponid = GetPlayerWeapon(playerid);

	if (hiddenWeapon[playerid] == HIDDEN_WEAPON_KATANA && weaponid == WEAPON_KATANA)
		return true;
	
	if (hiddenWeapon[playerid] == HIDDEN_WEAPON_BAT && weaponid == WEAPON_BAT)
		return true;
	
	if (hiddenWeapon[playerid] == HIDDEN_WEAPON_NSHOTGUN && weaponid == WEAPON_SHOTGUN)
		return true;
	
	if (hiddenWeapon[playerid] == HIDDEN_WEAPON_HEALTHGUN && weaponid == WEAPON_SILENCED)
		return true;
	
	if (hiddenWeapon[playerid] == HIDDEN_WEAPON_FREEZEGUN && weaponid == WEAPON_DEAGLE)
		return true;
	
	if (hiddenWeapon[playerid] == HIDDEN_WEAPON_COUNTRYRIFLE && weaponid == WEAPON_RIFLE)
		return true;
	
	return false;
}

function AddWeaponToShop(index, weaponid, ammo, price)
{
	if (index < 0 || index >= sizeof(gunShopList))
		return;
	
	new i, len = sizeof(gunShopList[]);

	for (i = 0; i < len; ++i)
	{
		if (gunShopList[index][i][0] == 0)
		{
			gunShopList[index][i][0] = weaponid;
			gunShopList[index][i][1] = ammo;
			gunShopList[index][i][2] = price;

			weaponShopCache[weaponid][0] = index;
			weaponShopCache[weaponid][1] = i;
			break;
		}
	}
}

function bool: ShowPlayerGunShopDialog(playerid, step = 0)
{
	if (!IsPlayerConnected(playerid))
		return false;
	
	if (step == 0)
		ShowPlayerDialog(playerid, DIALOG_WEAPON_SHOP, DIALOG_STYLE_LIST, "총기 상점", "권총/소총류\n샷건/투척류\n기관단총/라이플류", "선택", "취소");
	else
	{
		new string[1024];

		--step;

		for (new i = 0, len = sizeof(gunShopList[]); i < len; ++i)
		{
			if (gunShopList[step][i][0] == 0)
				continue;
			
			format(string, sizeof(string), "%s%s ($%d)\n", string, GetKoreanWeaponName(gunShopList[step][i][0]), gunShopList[step][i][2]);
		}
		
		ShowPlayerDialog(playerid, DIALOG_WEAPON_SHOP + 1 + step, DIALOG_STYLE_LIST, "총기 상점", string, "구매", "이전");
	}

	return true;
}

function RandomCitizenSkin()
{
	new skinid;

	do {
		skinid = random(300);
	} while (IsProhibitedSkin(skinid));

	return skinid;
}

function CheckHumanCount(targetid)
{
	if (!IsPlayerConnected(targetid))
		return;

	if (!IsPlayerHuman(targetid))
	{
		++gameInfo[gHumans];

		if (!IsPlayerZombie(targetid))
			return;
		
		--gameInfo[gZombies];
		CheckGameState();
	}
}

function ResetPlayerFlashBangEffect(playerid, bool: timeExpired = false)
{
	if (!IsPlayerConnected(playerid))
		return;

	contloop (new i : playerList)
	{
		ShowPlayerNameTagForPlayer(playerid, i, true);
		SetPlayerMarkerForPlayer(playerid, i, GetPlayerColor(i));
	}

	if (timeExpired)
		FadeCamera(playerid, true, 0.25, 0, 0, 0);
	else
		KillTimer(flashBangEndTimer[playerid]);
	
	flashBangEndTimer[playerid] = 0;
}

function TogglePlayerGrenadeEffect(playerid, bool: toggle)
{
	grenadeEffectOff[playerid] = toggle;

	if (toggle)
	{
		InfoClientMessage(playerid, "타인의 폭발 효과에 영향을 받지 않습니다.");
	}
	else
	{
		InfoClientMessage(playerid, "타인의 폭발 효과에 영향을 받습니다.");
	}
}

function TryPlayerWeaponBuying(playerid, category, itemid)
{
	if (GetPlayerMoney(playerid) < gunShopList[category][itemid][2])
			ErrorClientMessage(playerid, "돈이 부족합니다.");
	else
	{
		new string[MAX_MESSAGE_LENGTH];
		new weaponid = gunShopList[category][itemid][0];

		GivePlayerMoney(playerid, -gunShopList[category][itemid][2]);
		GivePlayerWeapon(playerid, weaponid, gunShopList[category][itemid][1]);

		format(string, sizeof(string), "%s을(를) 구입하셨습니다.", GetKoreanWeaponName(weaponid));
		SystemClientMessage(playerid, string);
	}
}

function RemovePlayerWeapon(playerid, weaponid)
{
	if (!IsPlayerConnected(playerid) || weaponid == 0)
		return 0;

	new slotid = GetWeaponSlot(weaponid);
	new weapons[13], ammo[13];
	new i;

	for (i = 0; i < 13; ++i)
	{
		if (slotid == i)
			continue;
		
		GetPlayerWeaponData(playerid, i, weapons[i], ammo[i]);
	}
	
	ResetPlayerWeapons(playerid);

	for (i = 0; i < 13; ++i)
	{
		if (slotid == i)
			continue;
		
		GivePlayerWeapon(playerid, weapons[i], ammo[i]);
	}

	return 1;
}

function GetWeaponSlot(weaponid)
{
	if (weaponid < 0 || weaponid > WEAPON_PARACHUTE)
		return -1;
	
	new slotid;
	
	switch (weaponid)
	{
		case 0..WEAPON_BRASSKNUCKLE:
			slotid = 0;
		case WEAPON_GOLFCLUB..WEAPON_CHAINSAW:
			slotid = 1;
		case WEAPON_DILDO..WEAPON_CANE:
			slotid = 10;
		case WEAPON_GRENADE..WEAPON_MOLTOV, WEAPON_SATCHEL:
			slotid = 8;
		case WEAPON_COLT45..WEAPON_DEAGLE:
			slotid = 2;
		case WEAPON_SHOTGUN..WEAPON_SHOTGSPA:
			slotid = 3;
		case WEAPON_UZI..WEAPON_MP5, WEAPON_TEC9:
			slotid = 4;
		case WEAPON_AK47..WEAPON_M4:
			slotid = 5;
		case WEAPON_RIFLE..WEAPON_SNIPER:
			slotid = 6;
		case WEAPON_ROCKETLAUNCHER..WEAPON_MINIGUN:
			slotid = 7;
		case WEAPON_BOMB:
			slotid = 12;
		case WEAPON_SPRAYCAN..WEAPON_CAMERA:
			slotid = 9;
		case 44..WEAPON_PARACHUTE:
			slotid = 11;
		default:
			slotid = - 1;
	}

	return slotid;
}
