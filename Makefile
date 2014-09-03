# Global variables
# ---------------------------------------------------------------------------
# We are doing a recursive build, so we need to set up some global variables
# so we don't have to redefine CC etc. in the sub-directories.
AS:=as
CC:=gcc

CFLAGS:=-ffreestanding -O2 -Wall -Wextra -nostdlib -nostartfiles -nodefaultlibs -Isource/include
CPPFLAGS:=
LIBS:=-lgcc

OBJS:=\
source/boot/boot.o      \
source/kernel/kernel.o  \
source/kernel/driver/tty.o  \

all: iRTOS.bin

.PHONEY: all clean iso qemu

# Object files that to be linked into mukernel. It'll be populated
# by the includes below.

include source/lib/Makefile

# Beautify output
# ---------------------------------------------------------------------------
QUIET_CC = @echo    '   ' CC'      '$<;
QUIET_AS = @echo    '   ' AS'      '$<;

# Build targets
# ---------------------------------------------------------------------------

iRTOS.bin: $(OBJS) linker.ld
	$(QUIET_CC)$(CC) -T linker.ld -o disk_image/$@ $(CFLAGS) $(OBJS) $(LIBS)

%.o: %.c
	$(QUIET_CC)$(CC) -c $< -o $@ -std=gnu99 $(CFLAGS) $(CPPFLAGS)

%.o: %.s
	$(QUIET_AS)$(AS) $< -o $@

clean:
	@rm -rf disk_image/isodir
	@rm -f disk_image/iRTOS.bin disk_image/iRTOS.iso $(OBJS)

iso: iRTOS.iso

isodir disk_image/isodir/boot disk_image/isodir/boot/grub:
	@mkdir -p $@

disk_image/isodir/boot/iRTOS.bin: iRTOS.bin disk_image/isodir/boot
	@cp disk_image/$< $@

disk_image/isodir/boot/grub/grub.cfg: grub/grub.cfg disk_image/isodir/boot/grub
	@cp $< $@

iRTOS.iso: disk_image/isodir/boot/iRTOS.bin disk_image/isodir/boot/grub/grub.cfg
	grub-mkrescue -o disk_image/$@ disk_image/isodir

qemu: iRTOS.iso
	qemu-system-i386 -cdrom disk_image/iRTOS.iso
