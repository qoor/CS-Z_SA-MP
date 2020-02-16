/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Mode logger
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

#include "./CZ/Util/Inc/Log.inc"

stock ToggleServerLogSave(toggle)
{
	if (toggle > 0) logSave = 1;
	else logSave = 0;
}

stock ServerLog(E_SERVER_LOG_TYPE: logType, const content[], {Float, _}: ...)
{
	new string[MAX_LOG_LENGTH];

	format(string, MAX_LOG_LENGTH, "[%s] ", logTags[logType]);
	strcat(string, content, MAX_LOG_LENGTH);

	if (logType == LOG_TYPE_MYSQL)
	{
		if (numargs() > 2) format(string, MAX_LOG_LENGTH, "%s (에러코드: %d)", string, getarg(2));
	}

	print(string);

	return (logSave == 1) ? WriteLogToFile(logType, string) : 1;
}

stock WriteLogToFile(E_SERVER_LOG_TYPE: logType, const string[])
{
	if (logSave != 1) return 0;

	new filePath[64];

	format(filePath, 64, ""LOG_PATH"/%s.log", logTags[logType]);

	new File: file = fopen(filePath, io_append);

	if (!file)
	{
		print("[server] 로그를 저장하는 폴더가 생성 돼있지 않습니다.");
		print("[server] scriptfiles 폴더에 "LOG_PATH" 경로를 생성해 주세요.");

		return 0;
	}

	fwrite(file, string);
	fwrite(file, "\r\n");

	fclose(file);

	return 1;
}
