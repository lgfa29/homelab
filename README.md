# homelab

This is the setup I use for managing my homelab. This is a forever
work-in-progress and nothing should be considered to be production-ready or
best practice.

## Hardware

| Qty | Model                               | Spec.                                                                                                                                                                                                          | Description                                                             |
| --- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
|   1 | HPE ProLiant MicroServer Gen10 Plus | 4 x Intel Xeon E-2224 CPU @ 3.40 GHz<br />2 x HPE SmartMemory 16GB DDR4<br/>2 x Crucial MX500 1 TB SSD<br />1 x Seagate IronWolf ST8000VN004 8 TB HDD<br />1 x Western Digital Red Plus WD80EFBX-68A  8 TB HDD | Microserver running virtual machines using VMWare ESXi 7 as hypervisor. |
|   1 | Kobol Helios64                      | 2 x ARM Cortex-A72 CPU @ 1.8 GHz<br />4 x ARM Cortex-A53 CPU @ 1.4 GHz<br />4 GB LPDDR4<br />1 x Seagate IronWolf ST4000VN008 4 TB HDD<br />1 x Western Digital Red Plus WD40EFRX 4 TB HDD                     | 5 bay (but only 2 works due to hardware failure) NAS running Armbian.   |
|   3 | Raspberry Pi 4 Model B Rev 1.2      | 4 x ARM Cortex-A72 CPU @ 1.5 GHz<br />2 GB SDRAM                                                                                                                                                               | Boards stacked in a cluster case.                                       |

## Software

- [Nomad](https://www.nomadproject.io/) and [Consul](https://www.consul.io/) cluster.
  - 1 server running in an Ubuntu 22.04 VM on ESXi.
  - 4 clients running in the Helios64 and Raspberry Pis.

## Configuration Management

Cluster configuration is done in layers. The bottom layer is handled by
[cloud-init](./cloud-init) to bootstrap the base operating system, create
users, authorize SSH keys, and some other basic settings.

Next [Ansible](./ansible) is used to apply more advanced configuration to the
hosts.

Finally, [Terraform](./terraform) is used for application-level configuration,
such as creating Nomad and Consul ACL tokens.
