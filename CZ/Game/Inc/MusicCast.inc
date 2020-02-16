/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Game/MusicCast.pwn
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

#if defined __GAME_MUSICCAST_H__
	#endinput
#endif

#define __GAME_MUSICCAST_H__

#define MAX_MUSIC_CASTS 30

#define MUSIC_CAST_PRICE 35000

enum E_MUSIC_CAST {
	mName[128],
	mURL[128]
};

new musicCastIndex = -1;
new musicCastManualURL[128];
new musicCastAddPlayer = INVALID_PLAYER_ID;
new musicCastAddName[128];

new musicCasts[MAX_MUSIC_CASTS][E_MUSIC_CAST];

new selectCast[MAX_PLAYERS] = { -1, ... };
new bool: listenCast[MAX_PLAYERS];

forward OnMusicCastLoad();
forward OnMusicCastAdd(playerid, index, const name[], const url[]);
forward OnMusicCastRemove(playerid, index, step);

forward LoadMusicCasts();
forward ShowPlayerMusicCastDialog(playerid, step = 0);
forward AddMusicCast(playerid, const name[], const url[]);
forward RemoveMusicCast(playerid, index);
forward PlayMusicCastForPlayer(playerid);
forward bool: IsValidMusicURL(const url[]);
forward bool: IsMusicCasting();
forward bool: IsPlayerMusicCastAdmin(playerid);

forward G_MusicCast_PlayerConnect(playerid);
forward G_MusicCast_PlayerDisconnect(playerid);
forward G_MusicCast_PlayerCommandText(playerid, const command[], const params[]);
forward G_MusicCast_DialogResponse(playerid, dialogid, response, listitem, const inputtext[]);
forward G_MusicCast_PlayerIntroFinish(playerid);
