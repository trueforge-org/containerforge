/*
 * MP3val - a program for MPEG audio file validation
 * Copyright (C) 2005-2009 Alexey Kuznetsov (ring0) and Eugen Tikhonov (jetsys)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef __CROSSAPI_H__
#define __CROSSAPI_H__

#if (defined WIN32)||(defined __WIN32__)||(defined _MSC_VER)||(defined __NT__)

#include <windows.h>

#define CROSSAPI_MAX_PATH MAX_PATH

struct CROSSAPI_FILE_ATTRIBUTES {
	DWORD dwAttributes;
	FILETIME ftCreation;
	FILETIME ftLastAccess;
	FILETIME ftLastWrite;
};

#else

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <limits.h>
#include <time.h>

#define CROSSAPI_MAX_PATH PATH_MAX
typedef unsigned int DWORD;

struct CROSSAPI_FILE_ATTRIBUTES {
	mode_t st_mode;
	time_t t_atime;
	time_t t_mtime;
	time_t t_ctime;
};

#endif

struct CROSSAPI_FIND_DATA {
	char cFileName[CROSSAPI_MAX_PATH];
	bool bIsDirectory;
};

int CrossAPI_GetCurrentDirectory(int iBufSize,char *pcBuffer);

int CrossAPI_SetCurrentDirectory(char *pcBuffer);

/*
 * Be careful: Unix version of CrossAPI_FindFirstFile doesn't support
 * wildcards. It isn't very critical, because GCC replaces wildcards
 * in the command line by an enumeration of all corresponding files
 */
int CrossAPI_FindFirstFile(char *szFileName,CROSSAPI_FIND_DATA *cfd);
int CrossAPI_FindNextFile(int iHandle,CROSSAPI_FIND_DATA *cfd);
int CrossAPI_FindClose(int iHandle);

int CrossAPI_GetFullPathName(char *szFileName,char *pcBuffer,int iBufSize);

int CrossAPI_GetTempFileAndName(int iBufSize,char *pcBuffer);

int CrossAPI_MoveFile(char *szNewName,char *szOldName);
int CrossAPI_DeleteFile(char *szFileName);

int CrossAPI_OpenFile(char *szFileName,bool create,bool write);
int CrossAPI_SetFilePointer(int iHandle,int iPointer,bool bFromCurrent);
int CrossAPI_WriteFile(int iHandle,char *pcBuffer,int iBytes,int *iBytesWritten);
int CrossAPI_CloseFile(int iHandle);
int CrossAPI_GetFileSize(int iHandle);
int CrossAPI_SetEndOfFile(int iHandle);

void *CrossAPI_MapFile(char *filename);
int CrossAPI_UnmapFile(void *);

int CrossAPI_GetFileAttr(char *filename,CROSSAPI_FILE_ATTRIBUTES *cfa);
int CrossAPI_SetFileAttr(char *filename,CROSSAPI_FILE_ATTRIBUTES *cfa,bool timestamp);

#endif
