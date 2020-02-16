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
	if (strcmp(command, "/help", true) == 0 || strcmp(command, "/?") == 0 || strcmp(command, "/����") == 0)
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
			new string[128] = { "{FFFFFF}���� ���\n���� ��Ģ {FF0000}(�ʵ�){FFFFFF}\n��ɾ�\n��� ���� �� ������\n���� "MODE_VERSION" ������Ʈ ����\n���̼��� ����" };

			if (IsPlayerAdmin(playerid) || IsPlayerSubAdmin(playerid))
				strcat(string, "\n������ ��ɾ�");

			ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST, "����", string, "����", "���");
		}
	case 1:
		{
			new string[2048];

			strcat(string, "{FF0000}[����]\n\n");
			strcat(string, "{FFFFFF}ī��Ʈ 20�� �� ������ �� �������� ���� ����� ���õ˴ϴ�.\n");
			strcat(string, "���� ����� ���� �� �÷��̾�� �ΰ����� �������Ѿ� �ϸ�, ��� �ΰ��� �����Ǹ� ���ӿ��� �¸��մϴ�.\n");
			strcat(string, "���� �¸� �� ���� ����� ���ʽ� ������ �����˴ϴ�.\n\n");
			strcat(string, "{32CD32}[�ΰ�]\n\n");
			strcat(string, "{FFFFFF}������ ���۵Ǹ� ��� �÷��̾�� �ΰ����� �����մϴ�.\n");
			strcat(string, "ī��Ʈ�� ������ 5�� �� ������ ���õǰ� ������ ���� �߰� ������� �޽��ϴ�.\n");
			strcat(string, "�Ϲ� �ΰ��� ������ ������ ������ ü���� �ڵ����� ä�����ϴ�.\n");
			strcat(string, "�����κ��� ������ ���Ƴ��� ���尡 ���� ������ ��Ƴ����� ���ӿ��� �¸��մϴ�.\n");
			strcat(string, "���� �¸� �� ������ ���ʽ� ������ �����˴ϴ�.");

			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "���� ���", string, "Ȯ��", "");
		}
	case 2:
		{
			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "���� ��Ģ",
				"1. ���� ������ ��� ����\n\
				2. ��ġ ���� �߾� ����\n\
				3. ��ų ����\n\
				4. ������ ä���� �������� 5ȸ �̻� �ø��� �� ä��â ���� ����\n\
				5. �ɰ��� �νŰ��� ����\n\
				6. �ҹ� ���α׷� ��� ����\n\
				7. ���������� ���� ������ ���� ��� ����(�ǵ��� �����鿡�� �㰡�� ���� ��)\n\
				\n\
				{FF0000}��� �Ǵܰ� ó�� ������ �������� �緮�� ���� �����˴ϴ�.", "Ȯ��", "");
		}
	case 3:
		{
			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "��ɾ�",
				"{FF0000}����: {FFFFFF}/������� /������ /���� /�����ʱ�ȭ /��Ų����[ù ���Ž� ���ھ� 2500, ���ĺ��� ���ھ� 100 �Ҹ�]\n\
				{FF0000}���� ����: {FFFFFF}/mapid /��ī����[$1000] /r /Īȣ /kill /���ǹ�� /���ǵ��[$"#MUSIC_CAST_PRICE"]\n\
				{FF0000}���� ����: {FFFFFF}/���ǻ��� /��Ÿ���� /t(eam)[NUM 4] /���ŷ� /�ѹ����� /�������α�\n\
				{FF0000}����: {FFFFFF}/�׺�\n\
				{FF0000}�ΰ�: {FFFFFF}/gun /��������� /����ȿ��[NUM 6]\n\
				{FF0000}��Ÿ: {FFFFFF}/admincall /�Ű�", "Ȯ��", ""
			);
		}
	case 4:
		{
			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "��� ���� �� ������",
				"{FFFFFF}"HOST_NAME"\n\n\
				{FF0000}������: {FFFFFF}Qoo\n\
				{FF0000}������: {FFFFFF}Junggle\n\
				{FF0000}����: {FFFFFF}Fasa, Keroro, RangE, Claire_Redfield, EVOLUTION\n\n\
				{FF0000}��� ����: {FFFFFF}QModule "QMODULE_ENGINE_VERSION"\n\
				{FF0000}SA-MP Server ����: {FFFFFF}0.3d\n\
				{FF0000}MySQL Plugin ����: {FFFFFF}R41-4\n\
				\n\
				{FFFFFF}Copyright (c) {FF0000}2019 Qoo All rights reserved.",
				"Ȯ��", ""
			);
		}
	case 5:
		{
			new string[4096] = { "{FFFFFF}"MODE_VERSION" {FF0000}������Ʈ ����\n\n" };

			for (new i = 0, len = sizeof(updatedLog); i < len; ++i)
				format(string, sizeof(string), "%s{FF0000}%d. {FFFFFF}%s\n", string, i + 1, updatedLog[i]);
			
			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "��� ���� "MODE_VERSION" ������Ʈ ����", string, "Ȯ��", "");
		}
	case 6:
		{
			new string[256] = { "{FF0000}Lv. 1: {FFFFFF}/��� /���� /��ǥ���� /��ǥ��Ȳ /��ǥ�ߴ� /���ǹ�� /����˻� /���� /���� /�������α���ȸ" };
			new rcon = IsPlayerAdmin(playerid);

			if (rcon || IsPlayerSubAdmin(playerid, 2))
				strcat(string, "\n{FF0000}Lv. 2: {FFFFFF}/(����)���� /redo /�ʺ��� /������ /�μ��� /����� /��þŸ�� /�һ� /�̺�Ʈ");
			else if (rcon || IsPlayerSubAdmin(playerid, 3))
				strcat(string, "\n{FF0000}Lv. 3, RCON: {FFFFFF}/����");
			else if (rcon)
				strcat(string, "\n{FF0000}RCON: {FFFFFF}/(��)���� /�������� /��۱���");
			
			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "������ ��ɾ�", string, "Ȯ��", "");
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

			ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, "���̼��� ����", string, "Ȯ��", "");
		}
	}

	return 1;
}
