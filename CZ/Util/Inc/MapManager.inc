/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Util/MapManager.pwn
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

#if defined __MAPMANAGER_H__
	#endinput
#endif

#define __MAPMANAGER_H__

#define MAX_MAPS 200
#define MAX_MAP_TAG_LENGTH 20
#define MAX_MAP_NAME 256

#define MAP_PATH "[CZ2]/Maps"

#define MAP_CHANGE_TYPE_ASC 0
#define MAP_CHANGE_TYPE_DESC 1
#define MAP_CHANGE_TYPE_RANDOM 2
#define MAP_CHANGE_TYPE_SHUFFLE 3

new mapDataFuncFoundEvent;
new mapNameChangedEvent;
new removeMapElementsEvent;
new gamemodeMapStartEvent;

new currentMap = -1;
new mapChangeType = MAP_CHANGE_TYPE_ASC;
new minMapObjectID = MAX_OBJECTS;
new maxMapObjectID = -1;
new forceNextMap = -1;
new lastMinMapID = -1;
new lastMaxMapID = -1;
new lastShuffleIndex = -1;

new shuffleMapList[MAX_MAPS];

new currentMapName[MAX_MAP_NAME];
new currentAuthorName[64];

forward MapManager_AuthPass();

forward LoadMapData();
forward UnloadMapData();

forward GetNextMapID();
forward bool: IsValidMap(mapid);
forward GetMinMaxMapID(&minOut, &maxOut);
forward GetMapName(mapid, output[], size = sizeof(output));
forward SetMapName(const mapName[]);
forward SetAuthorName(const authorName[]);
forward CreateMapObject(modelid, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz, transparent = 0);
forward SetMapChangeType(type);

forward OnMapDataFunctionFound(const tag[], const func[], const value[]);
