# cloud-init

## Raspberry Pi

Extract `.img` file and find boot partition block size and start block:

```console
$ unxz /path/to/image.img.xz
$ fdisk -l /path/to/image.img
```

Multiply block size and start block to find offset and mount image to copy
files:

```console
$ mkdir img
$ sudo mount -o loop,offset=1048576 /path/to/img ./img
$ cp user-data ./img
$ sudo umount ./img
```

## ESXi

Create virtual machine with these two `Advanced Configuration Parameter`:

```
guestinfo.userdata.encoding: base64
guestinfo.userdata: <BASE64 userdata>
```

To generate the base64 string use the command:

```console
$ base64 -w 0 ./user-data
```
