# Lliurex chboot
## Context
Since the first versions of LliureX, the classroom, centre and smart centre models included management, update and configuration tools for the centre's computers that have been widely used by support technicians (SAI), ICT coordinators and other staff with management responsibilities for the centres' computers.
These utilities could be used centrally from the centre's servers. These applications made use of features such as configuration and network boot services (DHCP, DNS, PXE) that were managed directly on the centre's LliureX servers. 

After the release of lliurex23, a much more corporate vision of the educational centres' workstation has been introduced.
The main objectives of this new model are to increase security and facilitate a centralised management of the IT infrastructure.
In order to achieve these objectives, important transformations have taken place in the IT infrastructure of all the educational centres in the Valencian Community. These changes affect the architecture and characteristics of the networks and communications as well as the configuration details of the computer equipment.

LliureX's management models were designed in a previous context that was very different from the current IT infrastructure paradigm.
In particular, the capabilities of network booting (in order to achieve network operations as cloning computer's or installation) have been drastically reduced and are no longer viable in practice as a consequence of the centraliced management of DHCP and DNS from the DGTIC (which makes it impossible to configure ad hoc network parameters from LLiureX computers).
To make matters worse, the computer's security settings (SecureBoot, BIOS password ... ) difficult not only to boot from network but also from any removable media, making reinstalling or updating the equipment a real mission impossible. 

LliureX chboot tries to mitigate network boot limitations, and provides an alternative environment that can be used to install, upgrade or clone LliureX computers from images or installation media. Use cases range from installing individual computers to run massive deployments with tools as clonezilla or LliureX open-sysclone 

## Overview
Lliurex chboot responds to LliureX ch(ange) boot, and includes a set of tools to configure alternative boot modes for LliureX computers.

The (simple) and main idea is to use a second partition of the hard disk (labelled 'chboot') to boot an alternative system. avoiding the need to configure computers to boot from network or removable media to perform operations such as:
* installation of a new OS version
* reinstallation from a recovery disk image

LliureX chboot can be run in a single an network isolated computer, but in combination with other LliureX tools, can be also used in computer labs environments to distribute configurations and disk images to perform massive deployments (from a IP address known in advance).

The included configurations, allow different boot modes:
* self (and unattended) clonezilla instance to restore disk image from chboot partition
* self (and unattended) clonezilla instance to restore from network(LliureX computer labs)
* automated clonezilla server for massive deployments
* run clonezilla image in interactive mode 
* run interactve LliureX installation image

## Binary packages
* **lliurex-chboot**
