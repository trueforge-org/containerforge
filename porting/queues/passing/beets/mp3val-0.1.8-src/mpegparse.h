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

#ifndef __MPEGPARSE_H__
#define __MPEGPARSE_H__

#include <iostream>

/*
 * MPEGINFO structure is used to contain both information about the last analyzed
 * frame (filled by ValidateMPEGFrame) and for the entire stream.
 */


struct MPEGINFO {
//MPEG frames counts
	int mpeg1layer1;
	int mpeg1layer2;
	int mpeg1layer3;
	int mpeg2layer1;
	int mpeg2layer2;
	int mpeg2layer3;
	int mpeg25layer1;
	int mpeg25layer2;
	int mpeg25layer3;
//Tag counts
	int id3v1;
	int id3v2;
	int apev2;

//VBR header info
	bool VBRHeaderPresent;
	bool IsXingHeader; //otherwise it's Fraunhofer VBRI header
	bool BytesPresent;
	int iBytes;
	bool FramesPresent;
	int iFrames;
	int iFirstMPEGFrameSize; //because Foobar2000 doesn't count the first frame (with Xing header) as MPEG data

//Error flags
	int riff;
	int unknown_format;
	int truncated;
	int mpeg_stream_error;
	int garbage_at_the_begin;
	int garbage_at_the_end;

//MPEG-related data
	bool LastFrameStereo;
	bool bLastFrameCRC;
	bool bCRC;
	bool bCRCError;
	int iLastBitrate;
	int iLastMPEGLayer;
	int iLastMPEGVersion;
//Miscellaneous data
	bool bVariableBitrate;
	int iTotalMPEGBytes;
	int iErrors;
	int iDeletedFrames;
	int iCRCErrors;
	
	MPEGINFO() {
		clear();
	}

	void clear() {
		mpeg1layer1=0;
		mpeg1layer2=0;
		mpeg1layer3=0;
		mpeg2layer1=0;
		mpeg2layer2=0;
		mpeg2layer3=0;
		mpeg25layer1=0;
		mpeg25layer2=0;
		mpeg25layer3=0;
		id3v1=0;
		id3v2=0;
		apev2=0;
		
		VBRHeaderPresent=false;
		IsXingHeader=true;
		BytesPresent=false;
		iBytes=-1;
		FramesPresent=false;
		iFrames=-1;

		riff=-1;
		unknown_format=-1;
		mpeg_stream_error=-1;
		truncated=-1;
		garbage_at_the_begin=-1;
		garbage_at_the_end=-1;
		
		LastFrameStereo=false;
		bLastFrameCRC=false;
		bCRC=false;
		bCRCError=false;
		bVariableBitrate=false;
		iLastBitrate=-2;
		iLastMPEGLayer=0;
		iLastMPEGVersion=0;
		iCRCErrors=0;
		
		iTotalMPEGBytes=0;
		iErrors=0;
		iDeletedFrames=0;
	}
};

int ValidateFile(unsigned char *baseptr,int iFileSize, MPEGINFO *mpginfo,std::ostream *out,char *filename,bool fix,int hFile);

#endif
