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
	"���� ������ ���� ������ ������ ������ �� �ֽ��ϴ�.",
	"Ư������ �����ΰ��� ������ ��� ��ų �ߵ� Ű�� YŰ�� �����߽��ϴ�.",
	"\"/�������α�\" ���ɾ�� �޾Ҵ� �������� �α׸� Ȯ���� �� �ֽ��ϴ�.",
	"���� ESC ���¿����� �������� �Խ��ϴ�.",
	"��� �� ���¿��� ESC ������ �� ������ ������� �ʴ� ������ �����߽��ϴ�.",
	"Pipe Bomb, Flash Bang Ư�����⸦ �߰��߽��ϴ�.",
	"ù �������� ���� �� Ư�� �������� �ظӰ� ���ܵ˴ϴ�.",
	"\"/����ȿ��\" ���ɾ�� Ÿ���� ���� ȿ���� �������� ������ �� �ֽ��ϴ�.",
	"\"/����ȿ��\" ���ɾ ����Ű NUM 6���ε� ����� �� �ֽ��ϴ�.",
	"SA-MP 0.3d ������ �ߴ� �Ǿ����ϴ�.",
	"��Ÿ ���׸� �����߽��ϴ�."
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