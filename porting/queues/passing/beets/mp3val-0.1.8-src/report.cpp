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

#include "report.h"
#include <iostream>
#include <iomanip>
#include <fstream>
#include <cstdio>

extern bool bSuppressInfo;

int PrintMessage(ostream *out,char *caption,char *filename,char *message,int iErrorFrame);

int PrintReport(ostream *out,char *filename,MPEGINFO *mpginfo) {
	int frame_types=0;
	int mpeg_total;
	int tags_total;
	char szMsgBuf[256];
	
	mpeg_total=
		mpginfo->mpeg1layer1+
		mpginfo->mpeg1layer2+
		mpginfo->mpeg1layer3+
		mpginfo->mpeg2layer1+
		mpginfo->mpeg2layer2+
		mpginfo->mpeg2layer3+
		mpginfo->mpeg25layer1+
		mpginfo->mpeg25layer2+
		mpginfo->mpeg25layer3;
	
//Errors
	if(mpginfo->unknown_format>=0) {
		PrintMessage(out,"ERROR",filename,"Unknown file format",-1);
		return 0;
	}

//Warnings
	if(mpeg_total<10) {
		PrintMessage(out,"WARNING",filename,"Too few MPEG frames (it's unlikely that this is a MPEG audio file)",-1);
	}
	
	if(mpginfo->riff>=0) {
		PrintMessage(out,"WARNING",filename,"This is a RIFF file, not MPEG stream",-1);
		mpginfo->iErrors++;
	}

	if(mpginfo->truncated>=0) {
		PrintMessage(out,"WARNING",filename,"It seems that file is truncated or there is garbage at the end of the file",mpginfo->truncated);
		mpginfo->iErrors++;
	}
	
	if(mpginfo->bCRCError) {
		sprintf(szMsgBuf,"Wrong CRC in %d frames",mpginfo->iCRCErrors);
		PrintMessage(out,"WARNING",filename,szMsgBuf,-1);
		mpginfo->iErrors++;
	}
	
	if(mpginfo->VBRHeaderPresent) {
		if(mpginfo->IsXingHeader) {
/*
 * LAME and Foobar2000 write (TotalFrames-1) as frames number in Xing header.
 * Some other encoders seem to write TotalFrames as this value.
 * We'll consider both first and second methods right.
 */

/*
 * Foobar2000 (at least version 0.9.4) doesn't count the first frame (with Xing header) as MPEG data when fixing VBR header.
 * LAME does the other way round.
 * We'll consider both first and second methods right.
 */

			if(mpginfo->FramesPresent&&mpginfo->iFrames!=mpeg_total&&mpginfo->iFrames+1!=mpeg_total) {
				sprintf(szMsgBuf,"Wrong number of MPEG frames specified in Xing header (%d instead of %d)",mpginfo->iFrames,mpeg_total);
				PrintMessage(out,"WARNING",filename,szMsgBuf,-1);
				mpginfo->iErrors++;
			}
			if(mpginfo->BytesPresent&&mpginfo->iBytes!=mpginfo->iTotalMPEGBytes&&mpginfo->iBytes!=mpginfo->iTotalMPEGBytes-mpginfo->iFirstMPEGFrameSize) {
				sprintf(szMsgBuf,"Wrong number of MPEG data bytes specified in Xing header (%d instead of %d)",mpginfo->iBytes,mpginfo->iTotalMPEGBytes);
				PrintMessage(out,"WARNING",filename,szMsgBuf,-1);
				mpginfo->iErrors++;
			}
		}
		else {
			if(mpginfo->FramesPresent&&mpginfo->iFrames!=mpeg_total) {
				sprintf(szMsgBuf,"Wrong number of MPEG frames specified in VBRI header (%d instead of %d)",mpginfo->iFrames,mpeg_total);
				PrintMessage(out,"WARNING",filename,szMsgBuf,-1);
				mpginfo->iErrors++;
			}
			if(mpginfo->BytesPresent&&mpginfo->iBytes!=mpginfo->iTotalMPEGBytes) {
				sprintf(szMsgBuf,"Wrong number of MPEG data bytes specified in VBRI header (%d instead of %d)",mpginfo->iBytes,mpginfo->iTotalMPEGBytes);
				PrintMessage(out,"WARNING",filename,szMsgBuf,-1);
				mpginfo->iErrors++;
			}
		}
	}
	
	if(mpginfo->bVariableBitrate&&!mpginfo->VBRHeaderPresent) {
		PrintMessage(out,"WARNING",filename,"VBR detected, but no VBR header is present. Seeking may not work properly.",-1);
	}
	
	if(mpginfo->mpeg1layer1||
		mpginfo->mpeg1layer2||
		mpginfo->mpeg2layer1||
		mpginfo->mpeg2layer2||
		mpginfo->mpeg25layer1||
		mpginfo->mpeg25layer2) {
		PrintMessage(out,"WARNING",filename,"Non-layer-III frame encountered. See related INFO message for details.",-1);
		mpginfo->iErrors++;
	}

	if(mpginfo->mpeg1layer1) frame_types++;
	if(mpginfo->mpeg1layer2) frame_types++;
	if(mpginfo->mpeg1layer3) frame_types++;
	if(mpginfo->mpeg2layer1) frame_types++;
	if(mpginfo->mpeg2layer2) frame_types++;
	if(mpginfo->mpeg2layer3) frame_types++;
	if(mpginfo->mpeg25layer1) frame_types++;
	if(mpginfo->mpeg25layer2) frame_types++;
	if(mpginfo->mpeg25layer3) frame_types++;

	if(frame_types>1) {
		PrintMessage(out,"WARNING",filename,"Different MPEG versions or layers in one file. See related INFO message for details.",-1);
	}

	if(mpginfo->apev2>1) {
		PrintMessage(out,"WARNING",filename,"Several APEv2 tags in one file. See related INFO message for details.",-1);
		mpginfo->iErrors++;
	}

	if(!(mpginfo->id3v1)&&!(mpginfo->id3v2)&&!(mpginfo->apev2)) {
		PrintMessage(out,"WARNING",filename,"No supported tags in the file",-1);
	}

	tags_total=
		mpginfo->id3v1+
		mpginfo->id3v2+
		mpginfo->apev2;
	
	if(!bSuppressInfo) {
		(*out)<<"INFO: ";
		(*out)<<"\""<<filename<<"\": ";
		if(mpeg_total) {
			(*out)<<mpeg_total<<" MPEG frames (";
			if(frame_types>1) {
				(*out)<<mpginfo->mpeg1layer1<<" V1L1, ";
				(*out)<<mpginfo->mpeg1layer2<<" V1L2, ";
				(*out)<<mpginfo->mpeg1layer3<<" V1L3, ";
				(*out)<<mpginfo->mpeg2layer1<<" V2L1, ";
				(*out)<<mpginfo->mpeg2layer2<<" V2L2, ";
				(*out)<<mpginfo->mpeg2layer3<<" V2L3, ";
				(*out)<<mpginfo->mpeg25layer1<<" V2.5L1, ";
				(*out)<<mpginfo->mpeg25layer2<<" V2.5L2, ";
				(*out)<<mpginfo->mpeg25layer3<<" V2.5L3";
			}
			else {
				if(mpginfo->mpeg1layer1) (*out)<<"MPEG 1 Layer I";
				else if(mpginfo->mpeg1layer2) (*out)<<"MPEG 1 Layer II";
				else if(mpginfo->mpeg1layer3) (*out)<<"MPEG 1 Layer III";
				else if(mpginfo->mpeg2layer1) (*out)<<"MPEG 2 Layer I";
				else if(mpginfo->mpeg2layer2) (*out)<<"MPEG 2 Layer II";
				else if(mpginfo->mpeg2layer3) (*out)<<"MPEG 2 Layer III";
				else if(mpginfo->mpeg25layer1) (*out)<<"MPEG 2.5 Layer I";
				else if(mpginfo->mpeg25layer2) (*out)<<"MPEG 2.5 Layer II";
				else if(mpginfo->mpeg25layer3) (*out)<<"MPEG 2.5 Layer III";
			}
	
			(*out)<<"), ";
		}	
		else {
		(*out)<<"No MPEG frames, ";
		}

		if(tags_total) {
			if(mpginfo->id3v1>1||mpginfo->id3v2>1||mpginfo->apev2>1) {
				(*out)<<tags_total<<" tags (";
				(*out)<<mpginfo->id3v1<<" ID3v1, ";
				(*out)<<mpginfo->id3v2<<" ID3v2, ";
				(*out)<<mpginfo->apev2<<" APEv2";
				(*out)<<")";
			}
			else {
				if(mpginfo->id3v1) (*out)<<"+ID3v1";
				if(mpginfo->id3v2) (*out)<<"+ID3v2";
				if(mpginfo->apev2) (*out)<<"+APEv2";
			}
		}
		else {
			(*out)<<"no tags";
		}
	
		(*out)<<", ";
		
		if(!mpginfo->bVariableBitrate) {
			(*out)<<"CBR";
		}
		else if(mpginfo->VBRHeaderPresent) {
			if(mpginfo->IsXingHeader) (*out)<<"Xing header";
			else (*out)<<"VBRI header";
		}
		else {
			(*out)<<"no VBR header";
		}
		
		if(mpginfo->bCRC) {
			(*out)<<", CRC";
		}

		(*out)<<"\n";
	}

	return 0;

}

int PrintMessage(ostream *out,char *caption,char *filename,char *message,int iErrorFrame) {
	(*out)<<caption<<": ";
	if(iErrorFrame>=0) {
		(*out)<<"\""<<filename<<"\" (offset 0x"<<hex<<iErrorFrame<<dec<<"): ";
	}
	else {
		(*out)<<"\""<<filename<<"\": ";
	}
	(*out)<<message<<'\n';
	return 0;
}
