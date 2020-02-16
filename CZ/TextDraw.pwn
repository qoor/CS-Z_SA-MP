/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Creating and loading TextDraw
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

#include "./CZ/Inc/TextDraw.inc"

InitModule("TextDraw")
{
	OnTextDrawInitialize();

	AddEventHandler(D_PlayerConnect, "TextDraw_PlayerConnect");
	AddEventHandler(D_PlayerDisconnect, "TextDraw_PlayerDisconnect");
}

public OnTextDrawInitialize()
{
	nexonText = TextDrawCreate(320.000000,187.000000,"NEXON");
	TextDrawAlignment(nexonText,2);
	TextDrawBackgroundColor(nexonText,0xffffffff);
	TextDrawFont(nexonText,2);
	TextDrawLetterSize(nexonText,0.799999,3.500000);
	TextDrawColor(nexonText,0xffffffff);
	TextDrawSetOutline(nexonText,0);
	TextDrawSetProportional(nexonText,1);
	TextDrawSetShadow(nexonText,0);

	blackScreen = TextDrawCreate(1.000000,1.000000,"_");
	TextDrawUseBox(blackScreen,1);
	TextDrawTextSize(blackScreen,639.000000,0.000000);
	TextDrawAlignment(blackScreen,0);
	TextDrawFont(blackScreen,3);
	TextDrawLetterSize(blackScreen,1.000000,50.000000);
	TextDrawBoxColor(blackScreen, 0x000000FF);
	TextDrawColor(blackScreen, 0x00000000);

	introText[0] = TextDrawCreate(199.000000,187.000000,"OUNTER      TRIKE");
	introText[1] = TextDrawCreate(164.000000,178.000000,"C");
	introText[2] = TextDrawCreate(343.000000,179.000000,"S");
	introText[3] = TextDrawCreate(386.000000,209.000000,"ONLINE");
	introText[4] = TextDrawCreate(320.000000,232.000000,"~r~Zombie 2~n~(Junggle version)"); // x: 174
	TextDrawAlignment(introText[0],0);
	TextDrawAlignment(introText[1],0);
	TextDrawAlignment(introText[2],0);
	TextDrawAlignment(introText[3],0);
	TextDrawAlignment(introText[4],2);
	TextDrawBackgroundColor(introText[0],0x000000ff);
	TextDrawBackgroundColor(introText[1],0xffffffff);
	TextDrawBackgroundColor(introText[2],0xffffffff);
	TextDrawBackgroundColor(introText[3],0x000000ff);
	TextDrawBackgroundColor(introText[4],0x000000ff);
	TextDrawFont(introText[0],2);
	TextDrawLetterSize(introText[0],0.699999,2.499999);
	TextDrawFont(introText[1],2);
	TextDrawLetterSize(introText[1],1.400000,3.700000);
	TextDrawFont(introText[2],2);
	TextDrawLetterSize(introText[2],1.000000,3.600000);
	TextDrawFont(introText[3],2);
	TextDrawLetterSize(introText[3],0.419999,1.500000);
	TextDrawFont(introText[4],2);
	TextDrawLetterSize(introText[4],0.699999,2.300000); // 0.899999, 2.3
	TextDrawColor(introText[0],0xffffffff);
	TextDrawColor(introText[1],0xffffffff);
	TextDrawColor(introText[2],0xffffffff);
	TextDrawColor(introText[3],0xffffffff);
	TextDrawColor(introText[4],0xffffffff);
	TextDrawSetOutline(introText[0],1);
	TextDrawSetOutline(introText[1],0);
	TextDrawSetOutline(introText[2],0);
	TextDrawSetOutline(introText[3],1);
	TextDrawSetOutline(introText[4],1);
	TextDrawSetProportional(introText[0],1);
	TextDrawSetProportional(introText[1],1);
	TextDrawSetProportional(introText[2],1);
	TextDrawSetProportional(introText[3],1);
	TextDrawSetProportional(introText[4],1);
	TextDrawSetShadow(introText[0],1);
	TextDrawSetShadow(introText[1],1);
	TextDrawSetShadow(introText[2],1);
	TextDrawSetShadow(introText[3],1);
	TextDrawSetShadow(introText[4],1);
	
	introText[5] = TextDrawCreate(322.000000,148.000000,".");
	introText[6] = TextDrawCreate(320.000000,180.000000,"i");
	introText[7] = TextDrawCreate(315.000000,197.500000,"/");
	introText[8] = TextDrawCreate(334.000000,196.500000,"/");
	introText[9] = TextDrawCreate(328.000000,185.000000,"/");
	introText[10] = TextDrawCreate(328.000000,177.000000,"-");
	introText[11] = TextDrawCreate(340.000000,182.000000,"/");
	introText[12] = TextDrawCreate(349.000000,186.000000,"-");
	introText[13] = TextDrawCreate(338.000000,212.000000,".");
	TextDrawUseBox(introText[12],1);
	TextDrawBoxColor(introText[12],0xffffffff);
	TextDrawTextSize(introText[12],330.000000,20.000000);
	TextDrawUseBox(introText[13],1);
	TextDrawBoxColor(introText[13],0x000000ff);
	TextDrawTextSize(introText[13],299.000000,0.000000);
	TextDrawAlignment(introText[5],0);
	TextDrawAlignment(introText[6],0);
	TextDrawAlignment(introText[7],0);
	TextDrawAlignment(introText[8],0);
	TextDrawAlignment(introText[9],0);
	TextDrawAlignment(introText[10],0);
	TextDrawAlignment(introText[11],0);
	TextDrawAlignment(introText[12],0);
	TextDrawAlignment(introText[13],0);
	TextDrawBackgroundColor(introText[5],0xffffffff);
	TextDrawBackgroundColor(introText[6],0xffffffff);
	TextDrawBackgroundColor(introText[7],0xffffffff);
	TextDrawBackgroundColor(introText[8],0xffffffff);
	TextDrawBackgroundColor(introText[9],0xffffffff);
	TextDrawBackgroundColor(introText[10],0xffffffff);
	TextDrawBackgroundColor(introText[11],0x00000000);
	TextDrawBackgroundColor(introText[12],0x00000000);
	TextDrawBackgroundColor(introText[13],0x00000000);
	TextDrawFont(introText[5],2);
	TextDrawLetterSize(introText[5],1.000000,4.700000);
	TextDrawFont(introText[6],3);
	TextDrawLetterSize(introText[6],1.200000,2.500000);
	TextDrawFont(introText[7],3);
	TextDrawLetterSize(introText[7],0.599999,1.400000);
	TextDrawFont(introText[8],3);
	TextDrawLetterSize(introText[8],-0.599999,1.300000);
	TextDrawFont(introText[9],2);
	TextDrawLetterSize(introText[9],0.799999,0.799999);
	TextDrawFont(introText[10],3);
	TextDrawLetterSize(introText[10],1.200000,1.300000);
	TextDrawFont(introText[11],3);
	TextDrawLetterSize(introText[11],-0.499999,1.000000);
	TextDrawFont(introText[12],2);
	TextDrawLetterSize(introText[12],0.599999,-0.200000);
	TextDrawFont(introText[13],3);
	TextDrawLetterSize(introText[13],1.000000,0.399999);
	TextDrawColor(introText[5],0xffffffff);
	TextDrawColor(introText[6],0xffffffff);
	TextDrawColor(introText[7],0xffffffff);
	TextDrawColor(introText[8],0xffffffff);
	TextDrawColor(introText[9],0xffffffff);
	TextDrawColor(introText[10],0xffffffff);
	TextDrawColor(introText[11],0xffffffff);
	TextDrawColor(introText[12],0x00000000);
	TextDrawColor(introText[13],0x00000000);
	TextDrawSetOutline(introText[5],1);
	TextDrawSetOutline(introText[6],1);
	TextDrawSetOutline(introText[7],1);
	TextDrawSetOutline(introText[8],1);
	TextDrawSetOutline(introText[9],1);
	TextDrawSetOutline(introText[10],1);
	TextDrawSetOutline(introText[11],1);
	TextDrawSetOutline(introText[12],1);
	TextDrawSetOutline(introText[13],1);
	TextDrawSetProportional(introText[5],1);
	TextDrawSetProportional(introText[6],1);
	TextDrawSetProportional(introText[7],1);
	TextDrawSetProportional(introText[8],1);
	TextDrawSetProportional(introText[9],1);
	TextDrawSetProportional(introText[10],1);
	TextDrawSetProportional(introText[11],1);
	TextDrawSetProportional(introText[12],1);
	TextDrawSetProportional(introText[13],1);
	TextDrawSetShadow(introText[5],1);
	TextDrawSetShadow(introText[6],1);
	TextDrawSetShadow(introText[7],1);
	TextDrawSetShadow(introText[8],1);
	TextDrawSetShadow(introText[9],1);
	TextDrawSetShadow(introText[10],1);
	TextDrawSetShadow(introText[11],1);
	TextDrawSetShadow(introText[12],1);
	TextDrawSetShadow(introText[13],1);
	
	loadingBar[0] = TextDrawCreate(21.000000,423.000000,"IIIII");
	TextDrawAlignment(loadingBar[0],0);
	TextDrawBackgroundColor(loadingBar[0],0xffffffff);
	TextDrawFont(loadingBar[0],2);
	TextDrawLetterSize(loadingBar[0],1.200000,1.900000);
	TextDrawColor(loadingBar[0],0xffffffff);
	TextDrawSetOutline(loadingBar[0],1);
	TextDrawSetProportional(loadingBar[0],1);
	TextDrawSetShadow(loadingBar[0],1);
	
	loadingBar[1] = TextDrawCreate(21.000000,423.000000,"IIIIIIIIIIIIIIII");
	TextDrawAlignment(loadingBar[1],0);
	TextDrawBackgroundColor(loadingBar[1],0xffffffff);
	TextDrawFont(loadingBar[1],2);
	TextDrawLetterSize(loadingBar[1],1.200000,1.900000);
	TextDrawColor(loadingBar[1],0xffffffff);
	TextDrawSetOutline(loadingBar[1],1);
	TextDrawSetProportional(loadingBar[1],1);
	TextDrawSetShadow(loadingBar[1],1);
	
	loadingBar[2] = TextDrawCreate(21.000000,423.000000,"IIIIIIIIIIIIIIIIIIIIIIII");
	TextDrawAlignment(loadingBar[2],0);
	TextDrawBackgroundColor(loadingBar[2],0xffffffff);
	TextDrawFont(loadingBar[2],2);
	TextDrawLetterSize(loadingBar[2],1.200000,1.900000);
	TextDrawColor(loadingBar[2],0xffffffff);
	TextDrawSetOutline(loadingBar[2],1);
	TextDrawSetProportional(loadingBar[2],1);
	TextDrawSetShadow(loadingBar[2],1);
	
	loadingBar[3] = TextDrawCreate(21.000000,423.000000,"IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");
	TextDrawAlignment(loadingBar[3],0);
	TextDrawBackgroundColor(loadingBar[3],0xffffffff);
	TextDrawFont(loadingBar[3],2);
	TextDrawLetterSize(loadingBar[3],1.200000,1.900000);
	TextDrawColor(loadingBar[3],0xffffffff);
	TextDrawSetOutline(loadingBar[3],1);
	TextDrawSetProportional(loadingBar[3],1);
	TextDrawSetShadow(loadingBar[3],1);
	
	loadingBar[4] = TextDrawCreate(21.000000,423.000000,"IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");
	TextDrawAlignment(loadingBar[4],0);
	TextDrawBackgroundColor(loadingBar[4],0xffffffff);
	TextDrawFont(loadingBar[4],2);
	TextDrawLetterSize(loadingBar[4],1.200000,1.900000);
	TextDrawColor(loadingBar[4],0xffffffff);
	TextDrawSetOutline(loadingBar[4],1);
	TextDrawSetProportional(loadingBar[4],1);
	TextDrawSetShadow(loadingBar[4],1);

	gameTimeText = TextDrawCreate(227.0, 3.0, "Time Left : READY (!)");
	TextDrawAlignment(gameTimeText, 0);
	TextDrawBackgroundColor(gameTimeText, 0x000000FF);
	TextDrawFont(gameTimeText, 1);
	TextDrawLetterSize(gameTimeText, 0.5099, 1.9999);
	TextDrawColor(gameTimeText, 0xAFEEEEFF);
	TextDrawSetOutline(gameTimeText, 1);
	TextDrawSetProportional(gameTimeText, 1);
	TextDrawSetShadow(gameTimeText, 1);
}

public TextDraw_PlayerConnect(playerid)
{
	moneyText[playerid] = TextDrawCreate(555.0, 79.0, "$00000000"); // 498.0, 73.0
	TextDrawUseBox(moneyText[playerid], 1);
	TextDrawBoxColor(moneyText[playerid], 0x000000FF);
	TextDrawTextSize(moneyText[playerid], 0.0, 125.0);
	TextDrawAlignment(moneyText[playerid], 2);
	TextDrawBackgroundColor(moneyText[playerid], 0x000000FF);
	TextDrawFont(moneyText[playerid], 3);
	TextDrawLetterSize(moneyText[playerid], 0.5999, 2.8999);
	TextDrawColor(moneyText[playerid], 0xFFFFFFFF);
	TextDrawSetOutline(moneyText[playerid], 1);
	TextDrawSetProportional(moneyText[playerid], true);

	healthText[playerid] = TextDrawCreate(566.0, 67.0, "100");
	TextDrawBackgroundColor(healthText[playerid], 0x000000FF);
	TextDrawFont(healthText[playerid], 1);
	TextDrawLetterSize(healthText[playerid], 0.34, 0.7999);
	TextDrawColor(healthText[playerid], 0xFFA000FF);
	TextDrawSetOutline(healthText[playerid], 1);
	TextDrawSetProportional(healthText[playerid], true);

	return 0;
}

public TextDraw_PlayerDisconnect(playerid)
{
	if (moneyText[playerid] != Text: INVALID_TEXT_DRAW)
	{
		TextDrawDestroy(moneyText[playerid]);

		moneyText[playerid] = Text: INVALID_TEXT_DRAW;
	}

	if (healthText[playerid] != Text: INVALID_TEXT_DRAW)
	{
		TextDrawDestroy(healthText[playerid]);

		healthText[playerid] = Text: INVALID_TEXT_DRAW;
	}

	return 0;
}

function UpdatePlayerMoneyText(playerid)
{
	if (!IsPlayerConnected(playerid) || moneyText[playerid] == Text: INVALID_TEXT_DRAW)
		return 0;
	
	new string[10];

	format(string, sizeof(string), "$%08d", GetPlayerMoney(playerid));
	TextDrawSetString(moneyText[playerid], string);

	return 1;
}

function UpdatePlayerHealthText(playerid)
{
	if (!IsPlayerConnected(playerid) || healthText[playerid] == Text: INVALID_TEXT_DRAW)
		return 0;
	
	new string[10];
	new Float: health;

	GetPlayerHealth(playerid, health);

	format(string, sizeof(string), "%.0f", health);
	TextDrawSetString(healthText[playerid], string);

	return 1;
}
