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

#include "out.h"
#include "crossapi.h"

static int iPrevSize=0;

int GetLastFrameSize() {
	return iPrevSize;
}

int WriteToFile(int hFile,char *baseptr,int index,int bytes,int iFileSize) {
	int tmp;
	int iBytesWritten,iBytesWrittenTotal=0;
	
	if(bytes<0) {
		if(iPrevSize) CrossAPI_SetFilePointer(hFile,-iPrevSize,true);
		tmp=iPrevSize;
		iPrevSize=0;
		return tmp;
	}

	if(iFileSize>=0) {
		if(index+bytes>iFileSize) bytes=iFileSize-index;
	}

	while(iBytesWrittenTotal<bytes) {
		if(!CrossAPI_WriteFile(hFile,&baseptr[index+iBytesWrittenTotal],bytes-iBytesWrittenTotal,&iBytesWritten)) {
			return -1;
		}
		iBytesWrittenTotal+=iBytesWritten;
	}

	iPrevSize=bytes;

	return bytes;
}
