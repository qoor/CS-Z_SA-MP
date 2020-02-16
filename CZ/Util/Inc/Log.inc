/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Declarations of Util/Log.pwn
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

#if defined __LOG_H__
	#endinput
#endif

#define __LOG_H__

#define MAX_LOG_LENGTH 256

#define LOG_PATH "[CZ2]/Logs"

enum E_SERVER_LOG_TYPE
{
	LOG_TYPE_ERROR,
	LOG_TYPE_MYSQL,
	LOG_TYPE_INFO,
	LOG_TYPE_VOTE,
	LOG_TYPE_SUGGESTION,
	LOG_TYPE_DEAL
};

new const logTags[E_SERVER_LOG_TYPE][] = {
	"error",
	"mysql",
	"info",
	"vote",
	"suggestion",
	"deal"
};

new logSave = 1;

forward ServerLog(E_SERVER_LOG_TYPE: logType, const content[], {Float, _}: ...);
forward WriteLogToFile(E_SERVER_LOG_TYPE: logType, const string[]);
