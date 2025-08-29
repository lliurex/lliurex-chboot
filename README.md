# Lliurex chboot
## Context
Since the first versions of LliureX, the classroom, centre and smart centre models included management, update and configuration tools for the centre's computers that have been widely used by support technicians (SAI), ICT coordinators and other staff with management responsibilities for the centres' computers.
These utilities could be used also centrally from the centre's servers. These applications made use of features such as configuration and network boot services (DHCP, DNS, PXE) that were managed directly on the centre's LliureX servers. 

After the release of lliurex23, a much more corporate vision of the educational centres' workstation has been introduced.
The main objectives of this new model are to increase security and facilitate a centralised management of the IT infrastructure.
In order to achieve these objectives, important transformations have taken place in the IT infrastructure of all the educational centres in the Valencian Community. These changes affect the architecture and characteristics of the networks and communications as well as the configuration details of the computer equipment.

LliureX's management models were designed in a previous context that was very different from the current IT infrastructure paradigm.
In particular, the capabilities for network booting (in order to achieve network operations as cloning computer's or installation) have been drastically reduced and are no longer viable in practice as a consequence of the centraliced management of DHCP and DNS from the DGTIC (which makes it impossible to configure ad hoc network parameters from LLiureX computers).
To make matters worse, the computer's security settings (SecureBoot, BIOS password ... ) difficult not only to boot from network but also from any removable media, making reinstalling or updating the equipment a real mission impossible. 

LliureX chboot tries to mitigate network boot limitations, and provides an alternative environment that can be used to install, upgrade or clone LliureX computers from images or installation media. Use cases range from installing individual computers to run massive deployments with tools as clonezilla or LliureX open-sysclone 

## Overview
Lliurex chboot responds to LliureX ch(ange) boot, and includes a set of tools to configure alternative boot modes for LliureX computers.

The (simple) and main idea is to use a second partition of the hard disk (labelled 'chboot') to boot an alternative system. avoiding the need to configure computers to boot from network or removable media to perform operations such as:

* installation of a new OS version
* reinstallation from a recovery disk image

LliureX chboot can be run in a single an network isolated computer, but in combination with other LliureX tools, can be also used in computer labs environments to distribute configurations and disk images to perform massive deployments (from a IP address known in advance).

The included configurations, allow different boot modes:

- self (and unattended) clonezilla instance to restore disk image from chboot partition
- self (and unattended) clonezilla instance to restore from network in LliureX computer lab environment
- automated clonezilla server for massive deployments
- run clonezilla image in interactive mode 
- run interactive LliureX installation image

## Boot procedure details
To configure alternative boot options, LliureX chboot depends on ***UEFI Boot Manager and grub***.

When a new boot entry is created, chboot generates:

- A ***UEFI boot entry***.

>This entry is availabe for UEFI Boot Manager, but chboot ***does not include it in the boot order***.

- The associated ***directory folder in the EFI System Partition*** to launch grub

>When creating this directory, chboot scans current EFI partition and search for 'EFI/lliurex-25/', 'EFI/lliurex-23/' or ' EFI/ubuntu/' folders (in that order) and uses the first match as a 'template' to copy files for the new entry. The grub.cfg file is rewritten to provide an appropiated grub prefix configuration for the new boot entry.

- A ***grub boot directory in the chboot partition*** with the required boot files and grub configuration

LliureX chboot uses exactly the same name for the EFI folder, the grub directory in chboot partition and the UEFI boot entry. This names are prefixed with 'chboot_'. At this moment, chboot manages only one boot entry with a fixed name (***chboot_lliurex***) regardless of the specific image name to boot. This strategy prevents the proliferation of unnecessary entries in the UEFI Boot Manager.

The UEFI boot entry loads 'shimx64.efi' file to provide compatibility with Secure Boot configurations.

## The chboot disk partition
LliureX chboot requires a dedicated disk partition. Partition size should be set according to the disk images or iso files you wish to use. The default size when running lliureX installer in OEM mode is 12 GB, enough to accommodate an ISO image of Clonezilla and the LliureX installer at the same time.

LliureX chboot requires the use of a specific disk label ('chboot') to correctly identify the chboot partition. The hard disk partition mut be labelled using e2label, tune2fs or alternative disk utilities. To ensure the operation, the “chboot” label must be displayed correctly when using blkid or lsblk commands, and the disk partitin must be accesible under '/dev/disk/by-label/chboot' path.

The default filesystem for chboot partition is ext4, but any other filesystem supported by grub could be used.

LliureX chboot provides the appropiate systemd mount configuration to access chboot partition under /chboot mount point, so it should not to be added to fstab file.

## chboot directory structure
LliureX chboot creates the following directory structure, where ***/chboot*** is the partition mount point:
```
/chboot
└── lliurex-chboot
    ├── boot
    ├── imgs
    ├── isos
    └── srcs
        ├── ENTRY_FOLDER_1
        ...
        └── ENTRY_FOLDER_n
```


- ***lliurex-chboot***: Base directory for all the LliureX chboot stuff.
  - ***lliurex-chboot/boot***: grub boot directory
  - ***lliurex-chboot/imgs***: clonezilla images directory
  - ***lliurex-chboot/isos***: directory for bootable iso files
  - ***lliurex-chboot/srcs***: chboot bootable (source) configurations

## chboot source configurations (chboot entries)
A chboot source configuration (aka chboot entry) is a directory under lliurex-chboot/srcs folder containing all the information necessary to configure an alternative boot option.
```
/chboot
└── lliurex-chboot
    └── srcs
        └── ENTRY_FOLDER
            ├── chboot.cfg
            └── scripts
                ├── install
                ├── testsrc
                └── gengrub
```
The ***mandatory*** files and folders for each source configuration are:

- ***chboot.cfg*** file: This includes description and other information about the entry. The structure and syntax of the file is similar to debian/control files.
- ***scripts*** folder: This directory must include the following executables:
  - ***testsrc***: LliureX chboot runs this script to ensure that the source configuration is ready to use and can be activated. It is only a test script to check the presence of required files and configurations without trying to fix anything. A non zero exit status indicates that the entry is not ready, and the standard output is displayed as an explanation of the problem.
  - ***install***: The intended use of this script is to download/install/generate ***ALL*** the required files to get the chboot entry ready to boot. The script can use any kind of arbitrary arguments. The exit status is ignored, but the standard output is displayed to user.
  - ***gengrub***: The standard output of this script is used to generate the grub.cfg file in the chboot partition. It works in a similar way to the scripts in /etc/grub.d/.

### parameters and environment variables for chboot script execution
All hook scripts have access to the following environment variables:

#### System paths
- CHBOOT_MOUNT: mount point for chboot partition (defaults to '/chboot'). The rest of environment variables are relatives to this mount point to reflect paths inside the chboot partition.

#### Chboot partition relative paths
- CHBOOT_BASEDIR: base directory for all the chboot stuff (defaults to '/lliurex-chboot')
- CHBOOT_ISODIR : iso files folder (defaults to '$CHBOOT_BASEDIR/isos')
- CHBOOT_IMGDIR : directory to store clonezilla images (defaults to '$CHBOOT_BASEDIR/imgs')
- CHBOOT_SRCDIR : chboot source configurations base directory (defaults to '$CHBOOT_BASEDIR/srcs')
- CHBOOT_BOOTDIR: this directory hosts the grub boot directory for chboot sources, like boot/grub folder in a standard linux system (defaults to '$CHBOOT_BASEDIR/boot')

#### Chboot partition info
- CHBOOT_UUID: UUID of chboot partition
- CHBOOT_PART: chboot disk partition device

## Binary packages
* **lliurex-chboot**
