stage2=stage2_eltorito
isodir=iso
grubdir=boot/grub
#QEMU=/net/cremi/sathibau/linux-i386/bin/qemu -no-kqemu
QEMU=kvm -no-kvm

ifeq ($(DISPLAY),)
# connecté via ssh, utiliser curses
MODE=-serial vc -curses
else
# session graphique, activer SDL
MODE=-serial stdio
endif

TORUN?=monprog

all: run

grub.iso: $(isodir)/$(grubdir)/$(stage2) $(isodir)/$(grubdir)/menu.lst $(TORUN)
	cp $(TORUN) $(isodir)/$(TORUN)
	genisoimage -R -b $(grubdir)/$(stage2) -no-emul-boot -boot-load-size 4 -boot-info-table -o $@ $(isodir)

run: grub.iso
	$(QEMU) -cdrom $< -m 16 $(MODE)

run-dbg: grub.iso
	(sleep 1 ; xterm -e gdb $(TORUN) -x gdbinit) &
	$(QEMU) -cdrom $< $(MODE) -gdb tcp::12345

%: %.S head.S link.lds
	$(CC) -m32 -g -static $< -o $@ -Wl,-T link.lds -nostdlib

$(isodir)/$(grubdir):
	mkdir -p $@

$(isodir)/$(grubdir)/$(stage2): $(stage2) $(isodir)/$(grubdir)
	cp $< $@

.PHONY: $(isodir)/$(grubdir)/menu.lst
$(isodir)/$(grubdir)/menu.lst: Makefile $(isodir)/$(grubdir)
	echo timeout 1 > $@
	echo title $(TORUN) >> $@
	echo kernel '(cd)/$(TORUN)' >> $@
	echo boot >> $@

clean:
	rm -fr $(TORUN) $(isodir) grub.iso
