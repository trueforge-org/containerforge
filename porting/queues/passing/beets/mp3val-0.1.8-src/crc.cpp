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

#include "crc.h"

unsigned int CalculateCRC16(unsigned int init, unsigned int polynom, char *buf, int cb) {
	int crc;
	int i,j;
	
	crc=init&0xFFFF;
	
	for(i=0;i<=cb-1;i++) {
		crc<<=8;
		((char *)&crc)[2]^=buf[i];
		for(j=0;j<=7;j++) {
			if((crc<<j)&0x00800000) {
				crc^=(polynom<<(7-j));
			}
		}
		crc&=0xFFFF;
	}
	
	return crc;
}
