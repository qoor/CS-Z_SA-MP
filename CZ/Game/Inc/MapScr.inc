/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Game/MapScr.pwn
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

#if defined __GAME_MAPSCR_H__
	#endinput
#endif

#define __GAME_MAPSCR_H__

#define MAX_LIFT_OBJECTS 3

enum E_LIFT_OBJECT_INFO {
	loObject,
	Float: loStartX,
	Float: loStartY,
	Float: loStartZ,
	Float: loStartRotX,
	Float: loStartRotY,
	Float: loStartRotZ,
	Float: loEndX,
	Float: loEndY,
	Float: loEndZ,
	Float: loStartSpeed,
	Float: loEndSpeed,
	Float: loEndRotX,
	Float: loEndRotY,
	Float: loEndRotZ,
	loTime,
	loTimer
};

new liftObjects;

new liftObject[MAX_LIFT_OBJECTS][E_LIFT_OBJECT_INFO];

forward CreateLiftObject(modelid, Float: startX, Float: startY, Float: startZ, Float: startRotX, Float: startRotY, Float: startRotZ, Float: endX, Float: endY, Float: endZ,\
	Float: startSpeed, Float: endSpeed, Float: endRotX, Float: endRotY, Float: endRotZ, time);
forward bool: IsMapDisallowWaterDeath(mapid);
forward GivePlayerParachute(playerid);

forward OnLiftObjectArrived(index, step);

forward G_MapScr_GamemodeMapStart();
