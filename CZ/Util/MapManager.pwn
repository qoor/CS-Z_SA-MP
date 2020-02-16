/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Handle map changes
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

#include "./CZ/Util/Inc/MapManager.inc"
#include "./CZ/Game/Inc/Message.inc"

stock SetNextMap(mapid)
{
	if (!IsValidMap(mapid))
	{
		new string[MAX_MESSAGE_LENGTH];

		format(string, sizeof(string), "다음 맵 지정을 실패했습니다. %d번 맵은 존재하지 않습니다.", mapid);
		ServerLog(LOG_TYPE_ERROR, string);
		
		return 0;
	}
	
	forceNextMap = mapid;

	return 1;
}

stock StartNextMap()
{
	if (IsValidMap(forceNextMap))
	{
		currentMap = forceNextMap;
		forceNextMap = -1;
	}
	else currentMap = GetNextMapID();

	if (currentMap != -1) LoadMapData();
	else
		ServerLog(LOG_TYPE_ERROR, "다음 맵 로드를 할 수 없습니다. 맵 번호가 지정되지 않았습니다.");
}

stock LoadMapData()
{
	UnloadMapData();

	new string[256];

	format(string, sizeof(string), ""MAP_PATH"/%d.ini", currentMap);

	if (!fexist(string))
	{
		format(string, sizeof(string), "맵 로드를 실패했습니다. %d번 맵 데이터가 존재하지 않습니다.", currentMap);
		ServerLog(LOG_TYPE_ERROR, string);
		
		return 0;
	}

	new File: fFile = fopen(string, io_read);

	new i, length;
	new tag[MAX_MAP_TAG_LENGTH];
	new parameter[256];
	new tagBracketOpen = -1;
	new funcBracketOpen = -1, funcBracketClose = -1;
	new ignoreParse;
	new temp[MAX_MAP_TAG_LENGTH];

	while (fread(fFile, string, 256))
	{
		if (IsNull(string)) continue;

		length = strlen(string);
		funcBracketOpen = -1;
		funcBracketClose = -1;
		ignoreParse = 0;

		for (i = 0; i < length; ++i)
		{
			if (string[i] == '\r' || string[i] == '\n') string[i] = 0;
		}

		if (IsNull(string)) continue;

		for (i = 0; i < length; ++i)
		{
			if (string[i] == '(') funcBracketOpen = i;
			else if (string[i] == ')') funcBracketClose = i;
			else if (string[i] == '[')
			{
				if (tagBracketOpen == -1) tagBracketOpen = i;
			}
			else if (string[i] == ']')
			{
				if (tagBracketOpen != -1 && tagBracketOpen < i)
				{
					strmid(temp, string, tagBracketOpen + 1, i, MAX_MAP_TAG_LENGTH);

					if (strcmp(temp, "DM", true) != 0)
					{
						tagBracketOpen = -1;
						ignoreParse = 1;
						tag = temp;

						break;
					}
				}
			}
		}

		if (ignoreParse == 0 && !IsNull(tag))
		{
			if (funcBracketOpen != -1)
			{
				if (funcBracketClose != -1) length = funcBracketClose;

				strmid(parameter, string, funcBracketOpen + 1, length, 256);
				
				string[funcBracketOpen] = 0;

				OnMapDataFunctionFound(tag, string, parameter);
			}
			else OnMapDataFunctionFound(tag, "\1", string);
		}
	}

	fclose(fFile);

	if (IsNull(currentMapName))
		format(currentMapName, sizeof(currentMapName), "%d", currentMap);
	
	format(string, sizeof(string), "Map Starting: %s", currentMapName);
	ServerLog(LOG_TYPE_INFO, string);

	TriggerEventNoSuspend(gamemodeMapStartEvent, "");

	return 1;
}

public UnloadMapData()
{
	currentMapName = "";
	currentAuthorName = "";
	
	RemoveMapElements();
}

public OnMapDataFunctionFound(const tag[], const func[], const value[])
{
	new parameter[10][32];

	if (strcmp(tag, "mapname", true) == 0) SetMapName(value);
	else if (strcmp(tag, "author", true) == 0) SetAuthorName(value);
	/*else if (strcmp(tag, "gametime", true) == 0) SetWorldTime(strval(value));
	else if (strcmp(tag, "weather", true) == 0) SetWeather(strval(value));
	else */
	if (strcmp(tag, "object", true) == 0)
	{
		split(value, parameter, ',');

		CreateMapObject(strval(parameter[0]), floatstr(parameter[1]), floatstr(parameter[2]), floatstr(parameter[3]),
				floatstr(parameter[4]), floatstr(parameter[5]), floatstr(parameter[6]));
	}

	TriggerEventNoSuspend(mapDataFuncFoundEvent, "sss", tag, func, value);
}

stock RemoveMapElements()
{
	for (new i = minMapObjectID; i <= maxMapObjectID; ++i)
	{
		if(IsValidObject(i))
			DestroyObject(i);
	}

	TriggerEventNoSuspend(removeMapElementsEvent, "");

	minMapObjectID = MAX_OBJECTS;
	maxMapObjectID = -1;
}

stock GetNextMapID()
{
	new existMap[MAX_MAPS];
	new minMapID = -1;
	new maxMapID = -1;
	new newMapID = -1;
	new mapCount;

	for (new i = 0; i < MAX_MAPS; ++i)
	{
		if (IsValidMap(i))
		{
			existMap[i] = 1;

			if (minMapID == -1)
				minMapID = i;
			
			maxMapID = i;

			++mapCount;
		}
	}

	if (minMapID == maxMapID) return minMapID;

	if (mapChangeType == MAP_CHANGE_TYPE_ASC)
	{
		if ((newMapID = currentMap + 1) > maxMapID) return minMapID;

		while (existMap[newMapID] == 0)
		{
			if (++newMapID > maxMapID) return minMapID;
		}
	}
	else if (mapChangeType == MAP_CHANGE_TYPE_DESC)
	{
		if ((newMapID = currentMap - 1) < minMapID) return maxMapID;

		while (existMap[newMapID] == 0)
		{
			if (--newMapID < minMapID) return maxMapID;
		}
	}
	else if (mapChangeType == MAP_CHANGE_TYPE_RANDOM)
	{
		newMapID = currentMap;

		while (currentMap == newMapID || existMap[newMapID] == 0)
			newMapID = random(maxMapID + 1);
	}
	else if (mapChangeType == MAP_CHANGE_TYPE_SHUFFLE)
	{
		new listExpired = (lastMinMapID != minMapID || lastMaxMapID != maxMapID);

		if (listExpired || lastShuffleIndex >= mapCount)
		{
			new randA, randB;
			new temp;
			new range = mapCount;

			if (listExpired)
			{
				new index = -1;

				lastMinMapID = minMapID;
				lastMaxMapID = maxMapID;
				lastShuffleIndex = -1;

				for (new i = minMapID; i <= maxMapID; ++i)
				{
					if (existMap[i])
						shuffleMapList[++index] = i;
				}
			}

			for (new i = 0; i < range; ++i) // Shuffle amount of map
			{
				randA = random(range);
				randB = random(range);

				temp = shuffleMapList[randA];
				shuffleMapList[randA] = shuffleMapList[randB];
				shuffleMapList[randB] = temp;
			}
		}

		return (shuffleMapList[++lastShuffleIndex]);
	}

	return newMapID;
}

stock bool: IsValidMap(mapid)
{
	new string[128];

	format(string, sizeof(string), ""MAP_PATH"/%d.ini", mapid);

	return (fexist(string) != 0);
}

stock GetMinMaxMapID(&minOut, &maxOut)
{
	minOut = -1;
	maxOut = -1;

	for (new i = 0; i < MAX_MAPS; ++i)
	{
		if (IsValidMap(i))
		{
			if (minOut == -1) minOut = i;
			if (i > maxOut) maxOut = i;
		}
	}

	return 1;
}

stock GetMapName(mapid, output[], size = sizeof(output))
{
	output[0] = '\0';
	
	if (IsValidMap(mapid))
	{
		if (mapid == currentMap)
		{
			strcpy(output, currentMapName, size);

			return 1;
		}

		new string[256];

		format(string, 256, ""MAP_PATH"/%d.ini", mapid);

		if (!fexist(string))
			return 0;

		new File: fFile = fopen(string, io_read);
		new i, mapNameTagFound;

		while (fread(fFile, string, 256))
		{
			if (IsNull(string)) continue;

			for (i = strlen(string) - 1; i >= 0; --i)
			{
				if (string[i] == '\r' || string[i] == '\n') string[i] = 0;
			}

			if (IsNull(string)) continue;

			if (mapNameTagFound == 0)
			{
				if (strcmp(string, "[mapname]", true) == 0)
				{
					mapNameTagFound = 1;
					
					continue;
				}
			}
			else
			{
				strcpy(output, string, size);
				fclose(fFile);

				return 1;
			}
		}

		fclose(fFile);
	}

	return 0;
}

stock SetMapName(const mapName[])
{
	strcpy(currentMapName, mapName, sizeof(currentMapName));

	TriggerEventNoSuspend(mapNameChangedEvent, "");
}

stock SetAuthorName(const authorName[])
{
	strcpy(currentAuthorName, authorName, sizeof(currentAuthorName));
}

stock CreateMapObject(modelid, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz)
{
	new objectid = CreateObject(modelid, x, y, z, rx, ry, rz);

	if (objectid != INVALID_OBJECT_ID)
	{
		if (objectid < minMapObjectID) minMapObjectID = objectid;
		if (objectid > maxMapObjectID) maxMapObjectID = objectid;
	}

	return objectid;
}

stock SetMapChangeType(type)
{
	if (type < MAP_CHANGE_TYPE_ASC || type > MAP_CHANGE_TYPE_SHUFFLE)
		return 0;
	
	mapChangeType = type;

	return 1;
}
