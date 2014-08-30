AS:=as
CC:=gcc

CFLAGS:=-ffreestanding -O2 -Wall -Wextra -nostdlib -nostartfiles -nodefaultlibs
CPPFLAGS:=
LIBS:=-lgcc

OBJS:=\
source/boot/boot.o      \
source/kernel/kernel.o  \

all: iRTOS.bin

.PHONEY: all clean iso run-qemu

iRTOS.bin: $(OBJS) linker.ld
	$(CC) -T linker.ld -o disk_image/$@ $(CFLAGS) $(OBJS) $(LIBS)

%.o: %.c
	$(CC) -c $< -o $@ -std=gnu99 $(CFLAGS) $(CPPFLAGS)

%.o: %.s
	$(AS) $< -o $@

clean:
	rm -rf disk_image/isodir
	rm -f disk_image/iRTOS.bin disk_image/iRTOS.iso $(OBJS)

iso: iRTOS.iso

isodir disk_image/isodir/boot disk_image/isodir/boot/grub:
	mkdir -p $@

disk_image/isodir/boot/iRTOS.bin: iRTOS.bin disk_image/isodir/boot
	cp disk_image/$< $@

disk_image/isodir/boot/grub/grub.cfg: grub/grub.cfg disk_image/isodir/boot/grub
	cp $< $@

iRTOS.iso: disk_image/isodir/boot/iRTOS.bin disk_image/isodir/boot/grub/grub.cfg
	grub-mkrescue -o disk_image/$@ disk_image/isodir

run-qemu: iRTOS.iso
	qemu-system-i386 -cdrom disk_image/iRTOS.iso
