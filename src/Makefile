#
# @(#)Makefile
#
# Copyright 2000, Aaron Ardiri     (mailto:aaron@ardiri.com)
#                 Michael Ethetton (mailto:methetton@gambitstudios.com)
#                 Fredrik Nylund   (mailto:fnylund@hotmail.com)
# All rights reserved.
# 
# This file was generated as part of the "liberty" program developed for 
# the Helio Computing Platform designed by VTech Holdings:
#
#   http://www.vtechinfo.com/ 
#
# The  contents of this  file is confidential and proprietrary in nature 
# ("Confidential Information").  Redistribution or modification  without 
# prior consent of the original author(s) is prohibited.
#
# NOTE:
# The following portions of code found within this source code file  are
# owned  exclusively by  Michael Ethetton,  and shall  not be used in or
# sold  to other projects  (internal or external)  without  the  written
# permission of Michael Ethetton.
#
# - z-80 CPU Emulation
# - Nintendo Gameboy Emulation System
#
# The following portions of code found within this source code file are
# owned  exclusively  by  Aaron Ardiri,  and  shall  not be  used in or 
# sold to  other projects  (internal or external)  without the  written 
# permission of Aaron Ardiri.
#
# - GNU vtos application framework
# - Help System
#
# The following portions of code found within this source code file are
# owned  exclusively by Fredrik Nylund and Aaron Ardiri, and  shall not 
# be used in or sold to  other projects  (internal or external) without
# the written permission of one of the owners.
#
# - GameBoy(tm) ROM image memory management (desktop + handheld)
#
# It  shall be noted  that the Liberty  application was ported from the 
# Palm Computing Platform version under sponsorship by VTech Holdings.
#

# compiler setup
PREFIX    = 
AS        = $(PREFIX)mips-vtos-as
CC        = $(PREFIX)mips-vtos-gcc
LD        = $(PREFIX)mips-vtos-ld

# source / outputs
LD_OBJS   = appstart.o gccfix.o syscall.o resource/gfx.a
OBJS      = helio.o device.o animate.o help.o game.o gameboy.o resource.o
EXEC      = liberty

# compiler flags 
ASFLAGS   = -O2
CCFLAGS   = -O2
LDFLAGS   = -T resource/link.cmd

# compile requirements
$(EXEC).app: main.obj
	chop main.obj main.out .head .text .data
	acompile /S:37 $(EXEC).app main.out images/mainicon.bmp "Liberty"
	cp $(EXEC).app ..
	make clean

main.obj: $(OBJS) $(LD_OBJS)
#	$(LD) $(LDFLAGS) -o $@ *.o $(OBJS) $(LD_OBJS)  # linker dont like :)
	$(LD) $(LDFLAGS) -o $@ *.o resource/gfx.a

resource.c: resource.rcp
	rcompile resource.rcp > tmp.out
	bin2hex resource.bin resource.c > tmp.out

# compile rules
%.o: %.s
	cp $< tmp.S; $(AS) -c $(ASFLAGS) tmp.S -o $@
%.o: %.c
	$(CC) -c $(CCFLAGS) $<
%.o: %.cc
	$(CC) -E $(CCFLAGS) $< -o tmp.S
	$(AS) -c $(ASFLAGS) tmp.S -o $@

# clean-up funtions
clean:
	rm -f *.[oO] *.OBJ *.BIN c.txt resource.c *~ main.* tmp.* TMP.S

distclean:
	rm -f *.[oO] *.OBJ *.BIN c.txt resource.c *~ main.* *.app tmp.* TMP.S
