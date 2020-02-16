/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Game/Human.pwn
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

#if defined __GAME_HUMAN_H__
	#endinput
#endif

#define __GAME_HUMAN_H__

#define MAX_SPAWN_WEAPON_TYPE 22

enum _: E_HIDDEN_WEAPON_TYPE
{
	HIDDEN_WEAPON_KATANA = 14,
	HIDDEN_WEAPON_BAT,
	HIDDEN_WEAPON_NSHOTGUN,
	HIDDEN_WEAPON_HEALTHGUN,
	HIDDEN_WEAPON_FREEZEGUN,
	HIDDEN_WEAPON_COUNTRYRIFLE,
	HIDDEN_WEAPON_PIPEBOMB,
	HIDDEN_WEAPON_FLASHBANG
}

new spawnWeapons;
new heroPlayer = INVALID_PLAYER_ID;

new spawnWeaponList[MAX_SPAWN_WEAPON_TYPE][2][2];
new gunShopList[3][6][3];
new weaponShopCache[47][2];

new hiddenWeapon[MAX_PLAYERS];
new hiddenWeaponAmmo[MAX_PLAYERS];

new bool: pipeBombActivated[MAX_PLAYERS];
new pipeBombTargeted[MAX_PLAYERS];
new Float: pipeBombPosX[MAX_PLAYERS];
new Float: pipeBombPosY[MAX_PLAYERS];
new Float: pipeBombPosZ[MAX_PLAYERS];

new flashBangEndTimer[MAX_PLAYERS];

new bool: grenadeEffectOff[MAX_PLAYERS];

forward SelectHeroHuman();
forward SetPlayerHero(playerid);
forward AddSpawnWeapons();
forward AddSpawnWeapon(index, weaponid, ammo);
forward GivePlayerSpawnWeapons(playerid, index);
forward bool: IsPlayerHuman(playerid);
forward RandomHumanPlayer(heroCheck, bool: ignoreChicken = false);
forward PlayerKilledZombie(playerid, targetid);
forward AttackHiddenHitWeaponPlayer(playerid);
forward HiddenWeaponDamageForPlayer(playerid, targetid, &Float: amount);
forward bool: IsPlayerHoldHiddenWeapon(playerid, weaponid = -1);
forward bool: ShowPlayerGunShopDialog(playerid, step = 0);
forward RandomCitizenSkin();
forward CheckHumanCount(targetid);
forward SetPlayerHuman(playerid, type = -1);
forward ResetPlayerFlashBangEffect(playerid, bool: timeExpired = false);
forward TogglePlayerGrenadeEffect(playerid, bool: toggle);
forward TryPlayerWeaponBuying(playerid, category, itemid);
forward RemovePlayerWeapon(playerid, weaponid);
forward GetWeaponSlot(weaponid);

forward G_Human_PlayerConnect(playerid);
forward G_Human_PlayerDisconnect(playerid);
forward G_Human_PlayerSpawn(playerid);
forward G_Human_PlayerKeyStateChange(playerid, newkeys);
forward G_Human_PlayerTakeDamage(playerid, issuerid, Float: amount, weaponid);
forward G_Human_PlayerCommandText(playerid, const command[], const params[]);
forward G_Human_DialogResponse(playerid, dialogid, response, listitem);
forward G_Human_PlayerDeath(playerid);
forward G_Human_PlayerUpdate(playerid);
forward G_Human_GamemodeMapStart();
forward G_Human_GameRoundFinish(type);
forward G_Human_GameCount(count);
forward G_Human_Global1sTimer();
forward G_Human_PlayerStreamIn(playerid, forplayerid);
forward G_Human_PlayerKilled(playerid, killerid, reason);

forward InitSpawnWeapons();
forward InitWeaponShop();

forward OnPlayerPipeBombEnd(playerid);
forward OnPlayerFlashBangEnd(playerid);
