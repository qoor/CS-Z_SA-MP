/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Adding timers and Calling handler functions of timers
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

#include "./CZ/Inc/Timer.inc"

InitModule("Timer")
{
	SetTimer("OnSecondTimer", GetRealTimerTime(1000), 1);
	SetTimer("On500msTimer", GetRealTimerTime(500), 1);
}

public OnSecondTimer()
{
	TriggerEventWithBreak(global1sTimer, 1, "");

	contloop (new playerid : playerList)
	{
		HandlerLoop (player1sTimer)
		{
			if (HandlerAction(player1sTimer, "i", playerid) != 0)
				break;
		}
	}
}

public On500msTimer()
{
	TriggerEventWithBreak(global500msTimer, 1, "");

	contloop (new playerid : playerList)
	{
		HandlerLoop (player500msTimer)
		{
			if (HandlerAction(player500msTimer, "i", playerid) != 0)
				break;
		}
	}
}
