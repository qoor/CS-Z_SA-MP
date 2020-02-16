/*
 * Counter-Strike: Zombie mode for SA-MP
 * 
 * Useful functions of File-based save system
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

new ini_pivotChar = '=';

stock ini_GetKey(const line[], dest[], size = sizeof(dest))
{
	new index = charfind(line, ini_pivotChar);

	if (index == -1)
	{
		strcpy(dest, "", size);

		return 0;
	}

	strmid(dest, line, 0, index, size);

	return 1;
}

stock ini_GetValue(const line[], dest[], size = sizeof(dest))
{
	new index = charfind(line, ini_pivotChar);

	if (index == -1)
	{
		strcpy(dest, "", size);

		return 0;
	}
	
	new length, foundEscape;

	length = strlen(line);

	if (line[length - 2] == '\r')
		++foundEscape;
	if (line[length - 1] == '\n')
		++foundEscape;
	
	length -= foundEscape;

	strmid(dest, line, index + 1, length, size);

	return 1;
}

stock ini_GetValueInt(const line[], buffer[], size = sizeof(buffer))
{
	if (ini_GetValue(line, buffer, size) == 0)
		return 0;
	
	return strval(buffer);
}

stock Float: ini_GetValueFloat(const line[], buffer[], size = sizeof(buffer))
{
	if (ini_GetValue(line, buffer, size) == 0)
		return 0;
	
	return floatstr(buffer);
}

stock ini_Save(File: file, buffer[], const key[], const value[], size = sizeof(buffer))
{
	format(buffer, size, "%s%c%s\r\n", key, ini_pivotChar, value);
	fwrite(file, buffer);
}

stock ini_SaveInt(File: file, buffer[], const key[], value, size = sizeof(buffer))
{
	format(buffer, size, "%s%c%d\r\n", key, ini_pivotChar, value);
	fwrite(file, buffer);
}

stock ini_SaveFloat(File: file, buffer[], const key[], Float: value, size = sizeof(buffer))
{
	format(buffer, size, "%s%c%.4f\r\n", key, ini_pivotChar, value);
	fwrite(file, buffer);
}

stock ini_SetPivotChar(character)
{
	ini_pivotChar = character;
}
