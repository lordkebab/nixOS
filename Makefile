NIXOS_SSH_ADDR ?= unset
NIXOS_SSH_PORT ?= 22

vm/partition:
        ssh root@$(NIXOS_SSH_ADDR) " \
                parted /dev/sda -- mklabel gpt; \
                parted /dev/sda -- mkpart primary 512MB -8GB; \
                parted /dev/sda -- mkpart primary linux-swap -8GB 100%; \
                parted /dev/sda -- mkpart ESP fat32 1MB 512MB; \
                parted /dev/sda -- set 3 esp on; \
                sleep 1; \
                mkfs.ext4 -L nixos /dev/sda1; \
                mkswap -L swap /dev/sda2; \
                swapon /dev/sda2; \
                mkfs.fat -F 32 -n boot /dev/sda3; \
                mount /dev/disk/by-label/nixos /mnt; \
                mkdir -p /mnt/boot; \
                mount /dev/disk/by-label/boot /mnt/boot; \
        "
vm/bootstrap:
        ssh root@$(NIXOS_SSH_ADDR) " \
                nixos-generate-config --root /mnt; \
        "
        scp configuration.nix root@$(NIXOS_SSH_ADDR):/mnt/etc/nixos/configuration.nix

        ssh root@$(NIXOS_SSH_ADDR) " \
                nixos-install --no-root-passwd; \
                reboot; \
        "