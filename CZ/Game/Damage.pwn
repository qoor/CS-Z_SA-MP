/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Customizing SA-MP default damage system and damage logging
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

#include "./CZ/Game/Inc/Damage.inc"

InitModule("Game_Damage")
{
	AddEventHandler(D_PlayerConnect, "G_Damage_PlayerConnect");
	AddEventHandler(D_PlayerDisconnect, "G_Damage_PlayerDisconnect");
	AddEventHandler(D_PlayerTakeDamage, "G_Damage_PlayerTakeDamage");
	AddEventHandler(D_PlayerCommandText, "G_Damage_PlayerCommandText");
}

public G_Damage_PlayerConnect(playerid)
{
	new name[MAX_PLAYER_NAME];

	name = GetPlayerNameEx(playerid);

	ResetDamageInfo(playerid);

	contloop (new i : playerList)
	{
		if (i == playerid)
			continue;
		
		for (new j = 0; j < damagedPlayerCount[i]; ++j)
		{
			if (damagedInfo[i][j][dmIssuerId] == INVALID_PLAYER_ID && strcmp(damagedPlayerName[i][j], name, true) == 0)
				damagedInfo[i][j][dmIssuerId] = playerid;
		}
	}

	return 0;
}

public G_Damage_PlayerDisconnect(playerid)
{
	contloop (new i : playerList)
	{
		if (i == playerid)
			continue;
		
		for (new j = 0; j < damagedPlayerCount[i]; ++j)
		{
			if (damagedInfo[i][j][dmIssuerId] == playerid)
				damagedInfo[i][j][dmIssuerId] = INVALID_PLAYER_ID;
		}
	}

	return 0;
}

public G_Damage_PlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
	new Float: health;
	new bool: canDamage;
	
	if (!IsPlayerConnected(issuerid) || issuerid == playerid)
	{
		new bool: alreadyDamaged;

		GetPlayerHealth(playerid, health);

		if (weaponid == WEAPON_COLLISION || weaponid == 255)
		{
			if (GetPlayerWeapon(playerid) == WEAPON_PARACHUTE)
			{
				alreadyDamaged = true;

				GivePlayerDamage(issuerid, playerid, weaponid, -health);
			}
		}

		if (!alreadyDamaged)
		{
			GivePlayerDamage(issuerid, playerid, weaponid, amount);
		}
	}
	else // If damaged by other players
	{
		canDamage = true;
	}
	
	if (!canDamage)
	{
		return 1;
	}

	return 0;
}

public G_Damage_PlayerCommandText(playerid, const command[], const params[])
{
	if (strcmp(command, "/데미지로그") == 0)
	{
		ShowPlayerDamagedInfo(playerid);
		return 1;
	}

	if (strcmp(command, "/데미지로그조회") == 0)
	{
		if (!IsPlayerAdmin(playerid) && !IsPlayerSubAdmin(playerid))
			return ErrorClientMessage(playerid, "관리자만 사용할 수 있습니다.");
		
		new string[MAX_PLAYER_NAME];

		if (!GetParamString(string, params, 0))
			return ErrorClientMessage(playerid, "사용법: /데미지로그조회 [플레이어 번호/이름의 부분]");
		
		new targetid = ReturnUser(string);

		if (!IsPlayerConnected(targetid))
			return ErrorClientMessage(playerid, "접속하지 않은 플레이어입니다.");
		
		ShowPlayerDamagedInfo(targetid, playerid);
		return 1;
	}

	return 0;
}

function GivePlayerDamage(issuerid, targetid, weaponid, Float: amount)
{
	if (!IsPlayerConnected(targetid))
		return 0;
	
	new Float: health;
	new Float: totalAmount = amount;

	GetPlayerHealth(targetid, health);

	if (health <= 0.0)
		return 0;
	
	if (IsWeaponCanDamageToArmour(weaponid))
	{
		new Float: armour;

		GetPlayerArmour(targetid, armour);

		if (armour > 0.0)
		{
			if (armour >= amount)
			{
				SetPlayerArmour(targetid, armour - amount);
			}
			else
			{
				SetPlayerArmour(targetid, 0.0);
				amount -= armour;
			}
		}
	}

	lastDamagedPlayer[targetid] = issuerid;

	if (amount > 0.0)
	{
		new bool: killPlayer = true;

		if (health <= amount)
		{
			HandlerLoop (playerKilledEvent)
			{
				if (HandlerAction(playerKilledEvent, "iii", targetid, issuerid, weaponid) == 0)
				{
					InfoClientMessage(targetid, "사살 부정");
					killPlayer = false;
					break;
				}
			}

			if (killPlayer)
			{
				ClearAnimations(targetid, 1);

				playerDeathTick[targetid] = GetTickCount();
			}
		}

		if (health > amount || killPlayer)
		{
			SetPlayerHealth(targetid, health - amount);
		}
	}

	if (IsPlayerConnected(issuerid))
	{
		InsertPlayerDamagedInfo(targetid, issuerid, weaponid, totalAmount);
	}

	return 1;
}

function bool: IsWeaponCanDamageToArmour(weaponid)
{
	return (weaponid > 0 && weaponid < WEAPON_DROWN);
}

function InsertPlayerDamagedInfo(playerid, issuerid, weaponid, Float: amount)
{
	if (issuerid == INVALID_PLAYER_ID)
		return;
	
	new index = damagedPlayerCount[playerid];
	new bool: indexFounded;

	for (new i = 0, j; i < index; ++i)
	{
		if (damagedInfo[playerid][i][dmIssuerId] == issuerid && damagedInfo[playerid][i][dmWeaponId] == weaponid)
		{
			new tempName[MAX_PLAYER_NAME];
			new tempData[E_DAMAGED_INFO];

			tempName = damagedPlayerName[playerid][i];
			tempData = damagedInfo[playerid][i];

			for (j = i + 1; j < index; ++j)
			{
				damagedPlayerName[playerid][j - 1] = damagedPlayerName[playerid][j];
				damagedInfo[playerid][j - 1] = damagedInfo[playerid][j];
			}

			--index;

			damagedPlayerName[playerid][index] = tempName;
			damagedInfo[playerid][index] = tempData;

			indexFounded = true;
			break;
		}
	}

	if (!indexFounded)
	{
		if (++damagedPlayerCount[playerid] >= MAX_DAMAGED_LOG_AMOUNT)
		{
			damagedPlayerCount[playerid] = MAX_DAMAGED_LOG_AMOUNT;
			index = MAX_DAMAGED_LOG_AMOUNT - 1;

			for (new i = 1; i < MAX_DAMAGED_LOG_AMOUNT; ++i)
			{
				damagedPlayerName[playerid][i - 1] = damagedPlayerName[playerid][i];
				damagedInfo[playerid][i - 1] = damagedInfo[playerid][i];
			}
		}
		
		damagedPlayerName[playerid][index] = GetPlayerNameEx(issuerid);
		damagedInfo[playerid][index][dmIssuerId] = issuerid;
		damagedInfo[playerid][index][dmWeaponId] = weaponid;
		damagedInfo[playerid][index][dmAmount] = amount;
	}
	else
		damagedInfo[playerid][index][dmAmount] += amount;
	
	gettime(damagedInfo[playerid][index][dmHour], damagedInfo[playerid][index][dmMinute], damagedInfo[playerid][index][dmSecond]);
}

function ShowPlayerDamagedInfo(playerid, showplayerid = INVALID_PLAYER_ID)
{
	if (!IsPlayerConnected(showplayerid))
		showplayerid = playerid;
	
	if (damagedPlayerCount[playerid] <= 0)
		ErrorClientMessage(showplayerid, "받은 데미지가 없습니다.");
	else
	{
		new title[32];
		new content[4096];
		new weaponName[32];

		if (playerid == showplayerid)
			title = "나의 데미지 로그";
		else
			format(title, sizeof(title), "%s(id:%d)님의 데미지 로그", GetPlayerNameEx(playerid), playerid);
		
		content = "{FF9900}피격자\t무기\t받은 데미지\t시간\n";
		
		for (new i = damagedPlayerCount[playerid] - 1; i >= 0; --i)
		{
			if (damagedInfo[playerid][i][dmWeaponId] == -1)
				continue;
			
			if (damagedInfo[playerid][i][dmIssuerId] != INVALID_PLAYER_ID)
				format(content, sizeof(content), "%s%s(id:%d)", content, damagedPlayerName[playerid][i], damagedInfo[playerid][i][dmIssuerId]);
			else
				strcat(content, damagedPlayerName[playerid][i]);
			
			GetWeaponName(damagedInfo[playerid][i][dmWeaponId], weaponName, sizeof(weaponName));
			format(content, sizeof(content), "%s\t%s\t%d\t%02d:%02d:%02d\n", content, weaponName, floatround(damagedInfo[playerid][i][dmAmount]),
				damagedInfo[playerid][i][dmHour], damagedInfo[playerid][i][dmMinute], damagedInfo[playerid][i][dmSecond]);
		}

		ShowPlayerDialog(showplayerid, DIALOG_NONE, DIALOG_STYLE_TABLIST_HEADERS, title, content, "닫기", "");
	}
}

function ResetDamageInfo(playerid)
{
	for (new i = 0; i < MAX_DAMAGED_LOG_AMOUNT; ++i)
	{
		damagedPlayerName[playerid][i] = "";
		damagedInfo[playerid][i][dmIssuerId] = INVALID_PLAYER_ID;
		damagedInfo[playerid][i][dmWeaponId] = -1;
	}

	damagedPlayerCount[playerid] = 0;
}
