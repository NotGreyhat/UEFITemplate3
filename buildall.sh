for i in $(find kernel/src -type f -name "*.c")
do
    gcc                  \
	-Ikernel/src         \
	-std=c11             \
	-ffreestanding       \
	-fno-stack-protector \
	-fno-stack-check     \
	-fno-pic             \
	-mabi=sysv           \
	-mno-80387           \
	-mno-mmx             \
	-mno-3dnow           \
	-mno-sse             \
	-mno-sse2            \
	-mno-red-zone        \
	-mcmodel=kernel      \
	-MMD                 \
    -O2                  \
    -Wall                \
    -Wextra              \
    -Wpedantic           \
    -pipe                \
    $i                   \
    -o kernel/kernel.elf
done


for i in $(find kernel/src -type f -name "*.o")
do
    ld                     \
    -Tkernel/linker.ld     \
	-nostdlib              \
	-zmax-page-size=0x1000 \
	-static                 \
    $i                      
done


rm -f ViridianOS.hdd
dd if=/dev/zero bs=1M count=0 seek=64 of=ViridianOS.hdd
parted -s ViridianOS.hdd mklabel gpt
parted -s ViridianOS.hdd mkpart ESP fat32 2048s 100%
parted -s ViridianOS.hdd set 1 esp on
limine/limine-s2deploy ViridianOS.hdd
sudo losetup -Pf --show ViridianOS.hdd >loopback_dev
sudo mkfs.fat -F 32 `cat loopback_dev`p1
mkdir -p img_mount
sudo mount `cat loopback_dev`p1 img_mount
sudo mkdir -p img_mount/EFI/BOOT
sudo cp -v kernel/kernel.elf limine.cfg assets/* limine/limine.sys img_mount/
sudo cp -v limine/BOOTX64.EFI img_mount/EFI/BOOT/
sync
sudo umount img_mount
sudo losetup -d `cat loopback_dev`
rm -rf loopback_dev img_mount
