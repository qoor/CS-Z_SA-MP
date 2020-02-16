/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Registering custom events to QModule
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

#include "./CZ/Inc/Intro.inc"
#include "./CZ/Account/Inc/Core.inc"
#include "./CZ/Inc/Timer.inc"
#include "./CZ/Game/Inc/Damage.inc"
#include "./CZ/Util/Inc/DetectJump.inc"

InitModule("EventMgr")
{
	mapDataFuncFoundEvent = AddEvent("OnMapDataFuncFound");
	mapNameChangedEvent = AddEvent("OnMapNameChange");
	removeMapElementsEvent = AddEvent("OnRemoveMapElements");
	gamemodeMapStartEvent = AddEvent("OnGamemodeMapStart");

	introPausedEvent = AddEvent("OnPlayerPausedIntro");
	introFinishEvent = AddEvent("OnPlayerIntroFinish");
	loggedInEvent = AddEvent("OnPlayerLoggedIn");

	global1sTimer = AddEvent("OnGlobal1sTimer");
	player1sTimer = AddEvent("OnPlayer1sTimer");

	global500msTimer = AddEvent("OnGlobal500msTimer");
	player500msTimer = AddEvent("OnPlayer500msTimer");
	
	playerKilledEvent = AddEvent("OnPlayerKilled");
	gameRoundFinishEvent = AddEvent("OnGameRoundFinish");
	gameCountEvent = AddEvent("OnGameCount");
	gameCountEndEvent = AddEvent("OnGameCountEnd");
	playerSpawnedEvent = AddEvent("OnPlayerSpawned");

	playerJumpEvent = AddEvent("OnPlayerJump");
}
