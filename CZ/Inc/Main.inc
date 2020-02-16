/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Main.pwn
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

#if defined __MAIN_H__
	#endinput
#endif

#define __MAIN_H__

#pragma dynamic 20480

#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 40

#include <a_mysql>

#include <flydetect>

#include <QAuth>
#include <QFader>

#include <QModule>

#define DEFAULT_TEAM 7

#include "./CZ/Inc/Hook.inc"
#include "./CZ/Inc/Color.inc"

#include "./CZ/Util/Inc/Dialog.inc"


#define MODE_VERSION "v1.107"

new const updatedLog[][145] = {
	"이제 리스폰 무적 상태인 유저를 구분할 수 있습니다.",
	"특수좀비 스팅핑거의 점프력 향상 스킬 발동 키를 Y키로 변경했습니다.",
	"\"/데미지로그\" 명령어로 받았던 데미지의 로그를 확인할 수 있습니다.",
	"이제 ESC 상태에서도 데미지를 입습니다.",
	"사살 된 상태에서 ESC 상태일 시 게임이 진행되지 않는 문제를 수정했습니다.",
	"Pipe Bomb, Flash Bang 특수무기를 추가했습니다.",
	"첫 숙주좀비 선택 시 특수 숙주좀비 해머가 제외됩니다.",
	"\"/폭발효과\" 명령어로 타인의 폭발 효과를 받을지를 결정할 수 있습니다.",
	"\"/폭발효과\" 명령어를 단축키 NUM 6으로도 사용할 수 있습니다.",
	"SA-MP 0.3d 지원이 중단 되었습니다.",
	"기타 버그를 수정했습니다."
};

new bool: toggleAdminCall = true;

new bool: reboot;

new playerName[MAX_PLAYERS][MAX_PLAYER_NAME];
new playerKickTimer[MAX_PLAYERS];

forward GetPlayerNameEx(playerid);
forward bool: IsServerReboot();

forward OnGameModeLoadFinish();
forward OnPlayerKick(playerid);

forward Main_GameModeExit();
forward Main_PlayerConnect(playerid);
forward Main_PlayerDisconnect(playerid);
forward Main_PlayerCommandText(playerid, const command[]);
forward Main_PlayerCommandTextFail(playerid);
