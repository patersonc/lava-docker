# How to setup x86 boards in CIP LAVA lab #

## Steps for setup ##
As by-default no OS is installed to some x86 boards, it is expected
not get anything on the console. To do so you will need to do the following:

1) First write the ipxe binary to an USB device. As Serial console support
is not enabled in the standard binaries from http://ipxe.org/, 
use the binary provided from LAVA which is available at 
https://validation.linaro.org/static/docs/v2/ipxe.html.

Download the ipxe binary and prepare the USB with this binary for target booting as below
```
$sudo dd if=/dev/zero of=/dev/sdX bs=1024 count=1024
$sudo dd if=<path-to-ipxe>/ipxe.usb of=/dev/sdX bs=8MB oflag=sync
```
2) Connect the prepare USB stick to the target board, power on to boot
and then stop at IPXE prompt by pressing Ctrl+B from the keyboard
connected directly to target or from minicom console from connected host

### IPXE boot procedure ###
Once power ON the board go to bios setting by pressing "Esc" from 
keyboard then go to "boot manager" and select usb device as boot
media with boot type as "Legacy" or else it will try to boot from
hard disk which is empty by-default.  It is better to disable the
SATA option so it won't go for the hard disk part.

Note: This settings needs to setup only once after that LAVA will
always halt at IPXE prompt for setting up boot arguments

3) Connect Ethernet cable to the board 
4) Connect USB to serial device for console connection to the com1 port
of board
5) Execute the following commands in ipxe environment:
```
$ dhcp
$ initrd tftp://{SERVER_IP}:{PORT_NO}/initrd.img
$ kernel tftp://{SERVER_IP}:{PORT_NO}/vmlinuz  ip=dhcp root=/dev/nfs 
rw nfsroot=$serverip:$nfsrootfs_path ip=dhcp console=ttyS0,115200 console=tty1
$ boot
```
Then target will boot and able to see boot logs to the connected display

## LAVA board specific changes ##
X86 boards uses x86.jinja device-type directly from linaro and some parameters
getting over-ride by device configuration file
e.g:
{% set shutdown_message = 'reboot: Restarting system' %}
{% set extra_nfsroot_args = (',vers=3') %}
{% set extra_kernel_args = 'rootwait vga=792' %}
and some pdu specific changes 
