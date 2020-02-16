/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Vote.pwn
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

#if defined __VOTE_H__
	#endinput
#endif

#define __VOTE_H__

new voteTime;
new voteTopic[MAX_MESSAGE_LENGTH];
new voteAgree;
new voteDisagree;

new bool: playerVoted[MAX_PLAYERS];

forward ResetVoteResult();
forward ShowVoteResult(playerid = INVALID_PLAYER_ID);

forward Vote_PlayerConnect(playerid);
forward Vote_PlayerCommandText(playerid, const command[], const params[]);
forward Vote_Global1sTimer();
