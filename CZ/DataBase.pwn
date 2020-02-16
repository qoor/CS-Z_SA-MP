/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Part of database connection
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

#include "./CZ/Inc/DataBase.inc"

InitModule("DataBase")
{
	mysql_log(ERROR);
	CreateDataBaseConnection();
}

function CreateDataBaseConnection()
{
	new MySQLOpt: option = mysql_init_options();
	new errno;

	mysql_set_option(option, AUTO_RECONNECT, true);
	mysql_set_option(option, SSL_ENABLE, true);

	MySQL = mysql_connect(DATABASE_HOST, DATABASE_USER, DATABASE_PASSWORD, DATABASE_SCHEMA, option);

	errno = mysql_errno(MySQL);

	if (errno != 0)
	{
		ServerLog(LOG_TYPE_MYSQL, "데이터베이스 서버에 접속을 실패했습니다.", errno);
		SendRconCommand("exit");

		return;
	}

	mysql_set_charset("euckr", MySQL);
}
