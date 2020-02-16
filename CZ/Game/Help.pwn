/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Help guide dialog
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

#include "./CZ/Game/Inc/Help.inc"
#include "./CZ/Game/Inc/MusicCast.inc"

InitModule("Game_Help")
{
	AddEventHandler(D_PlayerCommandText, "G_Help_PlayerCommandText");
	AddEventHandler(D_DialogResponse, "G_Help_DialogResponse");
}

public G_Help_PlayerCommandText(playerid, const command[])
{
	if (strcmp(command, "/help", true) == 0 || strcmp(command, "/?") == 0 || strcmp(command, "/도움말") == 0)
	{
		ShowPlayerHelpDialog(playerid);

		return 1;
	}

	return 0;
}

public G_Help_DialogResponse(playerid, dialogid, response, listitem)
{
	if (dialogid == DIALOG_HELP)
	{
		if (response != 0)
			ShowPlayerHelpDialog(playerid, listitem + 1);
		
		return 1;
	}
	if (dialogid == DIALOG_HELP + 1)
		return ShowPlayerHelpDialog(playerid);

	return 0;
}

function ShowPlayerHelpDialog(playerid, step = 0)
{
	if (!IsPlayerConnected(playerid))
		return 0;
	
	switch (step)
	{
	case 0:
		{
			new string[128] = { "{FFFFFF}게임 방식\n서버 규칙 {FF0000}(필독){FFFFFF}\n명령어\n모드 정보 및 제작자\n버전 "MODE_VERSION" 업데이트 내역\n라이선스 정보" };

			if (IsPlayerAdmin(playerid) || IsPlayerSubAdmin(playerid))
				strcat(string, "\n관리자 명령어");

			ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST, "도움말", string, "보기", "취소");
		}
	case 1:
		{
			new string[2048];

			strcat(string, "{FF0000}[좀비]\n\n");
			strcat(string, "{FFFFFF}카운트 20초 후 생존자 중 랜덤으로 숙주 좀비로 선택됩니다.\n");
			strcat(string, "숙주 좀비로 선택 된 플레이어는 인간들을 감염시켜야 하며, 모든 인간이 감염되면 게임에서 승리합니다.\n");
			strcat(string, "또한 승리 시 숙주 좀비는 보너스 보상이 제공됩니다.\n\n");
			strcat(string, "{32CD32}[인간]\n\n");
			strcat(string, "{FFFFFF}게임이 시작되면 모든 플레이어는 인간으로 시작합니다.\n");
			strcat(string, "카운트가 끝나기 5초 전 영웅이 선택되고 영웅은 각종 추가 무기들을 받습니다.\n");
			strcat(string, "일반 인간은 영웅에 가까이 있으면 체력이 자동으로 채워집니다.\n");
			strcat(string, "좀비들로부터 공격을 막아내고 라운드가 끝날 때까지 살아남으면 게임에서 승리합니다.\n");
			strcat(string, "또한 승리 시 영웅은 보너스 보상이 제공됩니다.");

			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "게임 방식", string, "확인", "");
		}
	case 2:
		{
			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "서버 규칙",
				"1. 가족 단위의 모욕 금지\n\
				2. 정치 관련 발언 금지\n\
				3. 팀킬 금지\n\
				4. 본인의 채팅을 연속으로 5회 이상 올리는 등 채팅창 도배 금지\n\
				5. 심각한 인신공격 금지\n\
				6. 불법 프로그램 사용 엄금\n\
				7. 보편적이지 않은 취향의 음악 방송 금지(되도록 유저들에게 허가를 맡을 것)\n\
				\n\
				{FF0000}모든 판단과 처벌 수위는 관리자의 재량에 의해 결정됩니다.", "확인", "");
		}
	case 3:
		{
			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "명령어",
				"{FF0000}계정: {FFFFFF}/비번변경 /내정보 /스탯 /스탯초기화 /스킨구매[첫 구매시 스코어 2500, 이후부터 스코어 100 소모]\n\
				{FF0000}게임 공통: {FFFFFF}/mapid /스카우터[$1000] /r /칭호 /kill /음악방송 /음악듣기[$"#MUSIC_CAST_PRICE"]\n\
				{FF0000}게임 공통: {FFFFFF}/건의사항 /산타모자 /t(eam)[NUM 4] /돈거래 /총버리기 /데미지로그\n\
				{FF0000}좀비: {FFFFFF}/항복\n\
				{FF0000}인간: {FFFFFF}/gun /무기버리기 /폭발효과[NUM 6]\n\
				{FF0000}기타: {FFFFFF}/admincall /신고", "확인", ""
			);
		}
	case 4:
		{
			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "모드 정보 및 제작자",
				"{FFFFFF}"HOST_NAME"\n\n\
				{FF0000}제작자: {FFFFFF}Qoo\n\
				{FF0000}원작자: {FFFFFF}Junggle\n\
				{FF0000}도움: {FFFFFF}Fasa, Keroro, RangE, Claire_Redfield, EVOLUTION\n\n\
				{FF0000}모드 엔진: {FFFFFF}QModule "QMODULE_ENGINE_VERSION"\n\
				{FF0000}SA-MP Server 버전: {FFFFFF}0.3d\n\
				{FF0000}MySQL Plugin 버전: {FFFFFF}R41-4\n\
				\n\
				{FFFFFF}Copyright (c) {FF0000}2019 Qoo All rights reserved.",
				"확인", ""
			);
		}
	case 5:
		{
			new string[4096] = { "{FFFFFF}"MODE_VERSION" {FF0000}업데이트 내역\n\n" };

			for (new i = 0, len = sizeof(updatedLog); i < len; ++i)
				format(string, sizeof(string), "%s{FF0000}%d. {FFFFFF}%s\n", string, i + 1, updatedLog[i]);
			
			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "모드 버전 "MODE_VERSION" 업데이트 내역", string, "확인", "");
		}
	case 6:
		{
			new string[256] = { "{FF0000}Lv. 1: {FFFFFF}/경고 /차감 /투표시작 /투표현황 /투표중단 /음악방송 /무기검사 /동의 /거절 /데미지로그조회" };
			new rcon = IsPlayerAdmin(playerid);

			if (rcon || IsPlayerSubAdmin(playerid, 2))
				strcat(string, "\n{FF0000}Lv. 2: {FFFFFF}/(게임)중지 /redo /맵변경 /좀숙주 /인숙주 /어드콜 /맵첸타입 /소생 /이벤트");
			else if (rcon || IsPlayerSubAdmin(playerid, 3))
				strcat(string, "\n{FF0000}Lv. 3, RCON: {FFFFFF}/리붓");
			else if (rcon)
				strcat(string, "\n{FF0000}RCON: {FFFFFF}/(운)영자 /서버종료 /방송권한");
			
			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "관리자 명령어", string, "확인", "");
		}
	case 7:
		{
			new string[4096];

			strcat(string, "Counter-Strike: Zombie for SA-MP");
			strcat(string, "\n");
			strcat(string, "MIT License\n");
			strcat(string, "\n");
			strcat(string, "Copyright (c) 2020 Qoo\n");
			strcat(string, "\n");
			strcat(string, "Permission is hereby granted, free of charge, to any person obtaining a copy\n");
			strcat(string, "of this software and associated documentation files (the \"Software\"), to deal\n");
			strcat(string, "in the Software without restriction, including without limitation the rights\n");
			strcat(string, "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n");
			strcat(string, "copies of the Software, and to permit persons to whom the Software is\n");
			strcat(string, "furnished to do so, subject to the following conditions:\n");
			strcat(string, "\n");
			strcat(string, "The above copyright notice and this permission notice shall be included in all\n");
			strcat(string, "copies or substantial portions of the Software.\n");
			strcat(string, "\n");
			strcat(string, "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n");
			strcat(string, "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n");
			strcat(string, "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n");
			strcat(string, "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n");
			strcat(string, "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n");
			strcat(string, "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n");
			strcat(string, "SOFTWARE.");

			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "라이선스 정보", string, "확인", "");
		}
	}

	return 1;
}
