/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Converting zero-based string to SA-MP server playerid
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

#include "./CZ/Util/Inc/ReturnUser.inc"

stock bool: IsNumeric(const string[])
{
	new length = strlen(string);

	if (length == 0)
		return false;
	
	for (new i = 0; i < length; ++i)
	{
		if (((string[i] > '9' || string[i] < '0') && string[i] != '-' && string[i] != '+') || ((string[i] == '-' || string[i] == '+') && i != 0))
			return false;
	}

	if (length == 1 && (string[0] == '+' || string[0] == '-'))
		return false;

	return true;
}

stock ReturnUser(const text[], playerid = INVALID_PLAYER_ID, size = sizeof(text))
{
	new pos = 0;

	while (pos < size && text[pos] < 0x21) // Strip out leading spaces
	{
		if (text[pos] == 0)
			return INVALID_PLAYER_ID; // No passed text

		++pos;
	}

	new userid = INVALID_PLAYER_ID;

	if (IsNumeric(text[pos])) // Check whole passed string
	{
		// If they have a numeric name you have a problem (although names are checked on id failure)
		userid = strval(text[pos]);

		if (userid >= 0 && userid < MAX_PLAYERS)
		{
			if(!IsPlayerConnected(userid))
				userid = INVALID_PLAYER_ID;
			else
				return userid; // A player was found
		}
	}

	// They entered [part of] a name or the id search failed (check names just incase)
	new len = strlen(text[pos]);
	new count = 0;
	new name[MAX_PLAYER_NAME];
	
	contloop (new i : playerList)
	{
		GetPlayerName(i, name, sizeof(name));

		if (strcmp(name, text[pos], true, len) == 0) // Check segment of name
		{
			if (len == strlen(name)) // Exact match
				return i;
			else // Partial match
			{
				++count;
				userid = i;
			}
		}
	}

	if (count != 1)
	{
		if (playerid != INVALID_PLAYER_ID)
		{
			if (count)
				SendClientMessage(playerid, 0xFF0000AA, "Multiple users found, please narrow earch");
			else
				SendClientMessage(playerid, 0xFF0000AA, "No matching user found");
		}

		userid = INVALID_PLAYER_ID;
	}

	return userid; // INVALID_USER_ID for bad return
}
