/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Intro.pwn
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

#if defined __INTRO_H__
	#endinput
#endif

#define __INTRO_H__

new introPausedEvent;
new introFinishEvent;

new introStep[MAX_PLAYERS];
new introPaused[MAX_PLAYERS];

forward Intro_PlayerConnect(playerid);
forward Intro_PlayerRequestClass(playerid);
forward Intro_PlayerSpawn(playerid);
forward Intro_Player1sTimer(playerid);

forward StartPlayerIntro(playerid);
forward PausePlayerIntro(playerid);
forward ResumePlayerIntro(playerid);
forward FinishPlayerIntro(playerid);
forward bool: IsPlayerFinishedIntro(playerid);
forward ShowLoadingBarForPlayer(playerid, step);
forward HideLoadingBarForPlayer(playerid);
forward bool: IsPlayerIntroPaused(playerid);
