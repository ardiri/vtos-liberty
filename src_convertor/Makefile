#
# @(#)Makefile.gcc
#
# Copyright 2000, Aaron Ardiri     (mailto:aaron@ardiri.com)
#                 Michael Ethetton (mailto:methetton@gambitstudios.com)
#                 Fredrik Nylund   (mailto:fnylund@hotmail.com)
# All rights reserved.
# 
# This file was generated as part of the "rom2app" program that generates
# app data files for the "liberty" program developed for the Helio 
# Computing Platform designed by VTech: http://www.vtechinfo.com/ 
#
# The contents of this file is confidential and proprietrary in nature 
# ("Confidential Information"). Redistribution or modification without 
# prior consent of the original author(s) is prohibited.
#
# REVISIONS:
# ----------
#
# 13-Jul-2000 Aaron Ardiri Creation
# 21-Apr-2000 Aaron Ardiri Updated for rom2app.exe (vtos)
#

# compiler commands 
PREFIX   = 
CC       = $(PREFIX)gcc

# source / outputs
SRCS     = rom2app.c
EXEC     = rom2app

# compiler flags 
CCFLAGS = -Wall 

# compile requirements
all:
	$(CC) $(CCFLAGS) -o $(EXEC) $(SRCS)

# clean-up funtions
clean:
	rm -f *.[oa] *~

distclean: 
	rm -f *.[oa] *~ $(EXEC)
