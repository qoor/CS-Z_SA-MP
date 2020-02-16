/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Game/Message.pwn
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

#if defined __MESSAGE_H__
	#endinput
#endif

#define __MESSAGE_H__

#define MAX_MESSAGE_LENGTH 145

new nickName[MAX_PLAYERS][MAX_NICKNAME_LENGTH];
new bool: teamChat[MAX_PLAYERS];

forward InfoClientMessage(playerid, const message[]);
forward ErrorClientMessage(playerid, const message[]);
forward PayClientMessage(playerid, const message[]);
forward SystemClientMessage(playerid, const message[]);
forward NewsClientMessage(playerid, const message[]);
forward SystemClientMessageToAll(const message[]);
forward NewsClientMessageToAll(const message[]);
forward ClearMessageToAll(line = 20);
forward ClearMessage(playerid, line = 20);
forward SendAdminMessage(COLOR, const text[], level = 1);
forward SendClientMessageToTeam(playerid, color, const message[]);
forward ChangePlayerTeamChatToggle(playerid);

forward G_Message_PlayerConnect(playerid);
forward G_Message_PlayerText(playerid, const text[]);
forward G_Message_PlayerCommandText(playerid, const command[], const params[]);
forward G_Message_PlayerKeyStateChange(playerid, newkeys);
