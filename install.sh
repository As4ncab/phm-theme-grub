#! /usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

GRUB_THEME='phm-grub-theme'
INSTALLER_LANG='English'

# Check dependencies
INSTALLER_DEPENDENCIES=(
    'mktemp'
    'sed'
    'sort'
    'sudo'
    'tar'
    'tee'
    'tr'
    'wget'
)

for i in "${INSTALLER_DEPENDENCIES[@]}"; do
    command -v $i > /dev/null 2>&1 || {
        echo >&2 "'$i' command is required, but not available. Aborting.";
        exit 1;
    }
done

# Change to temporary directory
cd $(mktemp -d)

# Pre-authorise sudo
sudo echo

# Select language, optional
declare -A INSTALLER_LANGS=(
    [Chinese_simplified]=zh_CN
    [Chinese_traditional]=zh_TW
    [English]=EN
    [French]=FR
    [German]=DE
    [Hungarian]=HU
    [Italian]=IT
    [Korean]=KO
    [Latvian]=LV
    [Norwegian]=NO
    [Polish]=PL
    [Portuguese]=PT
    [Russian]=RU
    [Rusyn]=RUE
    [Spanish]=ES
    [Turkish]=TR
    [Ukrainian]=UA
)

if [[ ${1:-} == "--lang" && -v 2 && -v INSTALLER_LANGS[$2] ]]; then
    INSTALLER_LANG=$2
else
    INSTALLER_LANG_NAMES=($(echo ${!INSTALLER_LANGS[*]} | tr ' ' '\n' | sort -n))

    PS3='Please select language #: '
    select l in "${INSTALLER_LANG_NAMES[@]}"; do
        if [[ -v INSTALLER_LANGS[$l] ]]; then
            INSTALLER_LANG=$l
            break
        else
            echo 'No such language, try again'
        fi
    done < /dev/tty
fi

echo 'Fetching and unpacking theme'
wget -O - https://github.com/As4ncab/phm-theme-grub/archive/refs/heads/main.zip | tar -xzf - --strip-components=1

if [[ "$INSTALLER_LANG" != "English" ]]; then
    echo "Changing language to ${INSTALLER_LANG}"
    sed -i -r -e '/^\s+# EN$/{n;s/^(\s*)/\1# /}' \
              -e '/^\s+# '"${INSTALLER_LANGS[$INSTALLER_LANG]}"'$/{n;s/^(\s*)#\s*/\1/}' theme.txt
fi

# Detect distro and set GRUB location and update method
GRUB_DIR='grub'
UPDATE_GRUB=''
BOOT_MODE='legacy'

if [[ -d /boot/efi && -d /sys/firmware/efi ]]; then
    BOOT_MODE='UEFI'
fi

echo "Boot mode: ${BOOT_MODE}"

if [[ -e /etc/os-release ]]; then

    ID=""
    ID_LIKE=""
    source /etc/os-release

    if [[ "$ID" =~ (debian|ubuntu|solus|void) || \
          "$ID_LIKE" =~ (debian|ubuntu|void) ]]; then

        UPDATE_GRUB='update-grub'

    elif [[ "$ID" =~ (arch|gentoo|artix) || \
            "$ID_LIKE" =~ (^arch|gentoo|^artix) ]]; then

        UPDATE_GRUB="grub-mkconfig -o /boot/${GRUB_DIR}/grub.cfg"

    elif [[ "$ID" =~ (centos|fedora|opensuse) || \
            "$ID_LIKE" =~ (fedora|rhel|suse) ]]; then

        GRUB_DIR='grub2'
        UPDATE_GRUB="grub2-mkconfig -o /boot/${GRUB_DIR}/grub.cfg"

        # BLS etries have 'kernel' class, copy corresponding icon
        if [[ -d /boot/loader/entries && -e icons/${ID}.png ]]; then
            cp icons/${ID}.png icons/kernel.png
        fi
    fi
fi

echo 'Creating GRUB themes directory'
sudo mkdir -p /boot/${GRUB_DIR}/themes/${GRUB_THEME}

echo 'Copying theme to GRUB themes directory'
sudo cp -r * /boot/${GRUB_DIR}/themes/${GRUB_THEME}

echo 'Removing other themes from GRUB config'
sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub

echo 'Making sure GRUB uses graphical output'
sudo sed -i 's/^\(GRUB_TERMINAL\w*=.*\)/#\1/' /etc/default/grub

echo 'Removing empty lines at the end of GRUB config' # optional
sudo sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' /etc/default/grub

echo 'Adding new line to GRUB config just in case' # optional
echo | sudo tee -a /etc/default/grub

echo 'Adding theme to GRUB config'
echo "GRUB_THEME=/boot/${GRUB_DIR}/themes/${GRUB_THEME}/theme.txt" | sudo tee -a /etc/default/grub

echo 'Removing theme installation files'
rm -rf "$PWD"
cd

echo 'Updating GRUB'
if [[ $UPDATE_GRUB ]]; then
    eval sudo "$UPDATE_GRUB"
else
    cat << '    EOF'
    --------------------------------------------------------------------------------
    Cannot detect your distro, you will need to run `grub-mkconfig` (as root) manually.

    Common ways:
    - Debian, Ubuntu, Solus and derivatives: `update-grub` or `grub-mkconfig -o /boot/grub/grub.cfg`
    - RHEL, CentOS, Fedora, SUSE and derivatives: `grub2-mkconfig -o /boot/grub2/grub.cfg`
    - Arch, Artix, Gentoo and derivatives: `grub-mkconfig -o /boot/grub/grub.cfg`
    --------------------------------------------------------------------------------
    EOF
fi



# Text for Linux & Windows

# menuentry 'ERID (40-ERIDANI-A SYSTEM): Linux Mint 22.3 Cinnamon' --class linuxmint --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-simple-bbf4f8f3-d487-4122-9c2c-627aeafd0683' {
#         recordfail
#         load_video
#         gfxmode $linux_gfx_mode
#         insmod gzio
#         if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
#         insmod part_gpt
#         insmod ext2
#         search --no-floppy --fs-uuid --set=root bbf4f8f3-d487-4122-9c2c-627aeafd0683
#         linux   /boot/vmlinuz-7.0.0-31-generic root=UUID=bbf4f8f3-d487-4122-9c2c-627aeafd0683 ro  quiet splash 
#         initrd  /boot/initrd.img-7.0.0-31-generic
# }
# submenu 'Advanced options for Linux Mint 22.3 Cinnamon' $menuentry_id_option 'gnulinux-advanced-bbf4f8f3-d487-4122-9c2c-627aeafd0683' {
#         menuentry 'Linux Mint 22.3 Cinnamon, with Linux 7.0.0-31-generic' --class linuxmint --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-7.0.0-31-generic-advanced-bbf4f8f3-d487-4122-9c2c-627aeafd0683' {
#                 recordfail
#                 load_video
#                 gfxmode $linux_gfx_mode
#                 insmod gzio
#                 if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
#                 insmod part_gpt
#                 insmod ext2
#                 search --no-floppy --fs-uuid --set=root bbf4f8f3-d487-4122-9c2c-627aeafd0683
#                 echo    'Loading Linux 7.0.0-31-generic ...'
#                 linux   /boot/vmlinuz-7.0.0-31-generic root=UUID=bbf4f8f3-d487-4122-9c2c-627aeafd0683 ro  quiet splash 
#                 echo    'Loading initial ramdisk ...'
#                 initrd  /boot/initrd.img-7.0.0-31-generic
#         }
#         menuentry 'Linux Mint 22.3 Cinnamon, with Linux 7.0.0-31-generic (recovery mode)' --class linuxmint --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-7.0.0-31-generic-recovery-bbf4f8f3-d487-4122-9c2c-627aeafd0683' {
#                 recordfail
#                 load_video
#                 insmod gzio
#                 if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
#                 insmod part_gpt
#                 insmod ext2
#                 search --no-floppy --fs-uuid --set=root bbf4f8f3-d487-4122-9c2c-627aeafd0683
#                 echo    'Loading Linux 7.0.0-31-generic ...'
#                 linux   /boot/vmlinuz-7.0.0-31-generic root=UUID=bbf4f8f3-d487-4122-9c2c-627aeafd0683 ro recovery nomodeset dis_ucode_ldr 
#                 echo    'Loading initial ramdisk ...'
#                 initrd  /boot/initrd.img-7.0.0-31-generic
#         }
#         menuentry 'Linux Mint 22.3 Cinnamon, with Linux 6.14.0-37-generic' --class linuxmint --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-6.14.0-37-generic-advanced-bbf4f8f3-d487-4122-9c2c-627aeafd0683' {
#                 recordfail
#                 load_video
#                 gfxmode $linux_gfx_mode
#                 insmod gzio
#                 if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
#                 insmod part_gpt
#                 insmod ext2
#                 search --no-floppy --fs-uuid --set=root bbf4f8f3-d487-4122-9c2c-627aeafd0683
#                 echo    'Loading Linux 6.14.0-37-generic ...'
#                 linux   /boot/vmlinuz-6.14.0-37-generic root=UUID=bbf4f8f3-d487-4122-9c2c-627aeafd0683 ro  quiet splash 
#                 echo    'Loading initial ramdisk ...'
#                 initrd  /boot/initrd.img-6.14.0-37-generic
#         }
#         menuentry 'Linux Mint 22.3 Cinnamon, with Linux 6.14.0-37-generic (recovery mode)' --class linuxmint --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-6.14.0-37-generic-recovery-bbf4f8f3-d487-4122-9c2c-627aeafd0683' {
#                 recordfail
#                 load_video
#                 insmod gzio
#                 if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
#                 insmod part_gpt
#                 insmod ext2
#                 search --no-floppy --fs-uuid --set=root bbf4f8f3-d487-4122-9c2c-627aeafd0683
#                 echo    'Loading Linux 6.14.0-37-generic ...'
#                 linux   /boot/vmlinuz-6.14.0-37-generic root=UUID=bbf4f8f3-d487-4122-9c2c-627aeafd0683 ro recovery nomodeset dis_ucode_ldr 
#                 echo    'Loading initial ramdisk ...'
#                 initrd  /boot/initrd.img-6.14.0-37-generic
#         }
# }




# menuentry 'EARTH (SOLAR SYSTEM): Windows Boot Manager (on /dev/nvme0n1p1)' --class windows --class os $menuentry_id_option 'osprober-efi-78B9-55AF' {
#         insmod part_gpt
#         insmod fat
#         search --no-floppy --fs-uuid --set=root 78B9-55AF
#         chainloader /EFI/Microsoft/Boot/bootmgfw.efi
# }