AS:=as
CC:=gcc

CFLAGS:=-ffreestanding -O2 -Wall -Wextra -nostdlib -nostartfiles -nodefaultlibs
CPPFLAGS:=
LIBS:=-lgcc

OBJS:=\
boot.o \
kernel.o \

all: iRTOS.bin

.PHONEY: all clean iso run-qemu

iRTOS.bin: $(OBJS) linker.ld
	$(CC) -T linker.ld -o $@ $(CFLAGS) $(OBJS) $(LIBS)

%.o: %.c
	$(CC) -c $< -o $@ -std=gnu99 $(CFLAGS) $(CPPFLAGS)

%.o: %.s
	$(AS) $< -o $@

clean:
	rm -rf isodir
	rm -f iRTOS.bin iRTOS.iso $(OBJS)

iso: iRTOS.iso

isodir isodir/boot isodir/boot/grub:
	mkdir -p $@

isodir/boot/iRTOS.bin: iRTOS.bin isodir/boot
	cp $< $@

isodir/boot/grub/grub.cfg: grub.cfg isodir/boot/grub
	cp $< $@

iRTOS.iso: isodir/boot/iRTOS.bin isodir/boot/grub/grub.cfg
	grub-mkrescue -o $@ isodir

run-qemu: iRTOS.iso
	qemu-system-i386 -cdrom iRTOS.iso
