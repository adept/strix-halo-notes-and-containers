# Strix Halo Installation Notes

## The Goal

To get Ubuntu 25.10 Server running, with most of the memory made available to the GPU and a 6.18+ kernel that would include the VGPR bugfix.
I plan to run everything via containers, so no rocm/vulkan software will be installed on the host system.

## Acknowledgements

These notes are heavily based on:
- https://github.com/kyuz0/amd-strix-halo-toolboxes?tab=readme-ov-file#%EF%B8%8F-host-configuration
- https://github.com/technigmaai/technigmaai-wiki/wiki/AMD-Ryzen-AI-Max--395:-GTT--Memory-Step%E2%80%90by%E2%80%90Step-Instructions-%28Ubuntu-24.04%29
- https://github.com/kyuz0/amd-strix-halo-gfx1151-toolboxes/issues/1
- https://github.com/Gygeek/Framework-strix-halo-llm-setup
- https://github.com/pablo-ross/strix-halo-gmktec-evo-x2
- 

## Initial Setup

**Distro:** Ubuntu 25.10 Server (which I've chosen for familiarity)

Grab iso, burn it to the flash drive, reboot and install.

**Disk layout:**
- 100GB for `/` as ext4
- Remainder as `/home` in xfs (which imo is marginally better than ext4 for large files)

After installation, the system runs kernel 6.17.0-12. Our target is 6.18+ and rocm-7.2+

## BIOS Configuration

Reboot, go to BIOS, navigate to Advanced settings and make the following changes:

- **iGPU configuration:** Change from `AUTO` to `UMA_SPECIFIED`
- **UMA buffer size:** Set to 1GB (reduced from 64GB; use 512MB if your BIOS supports it)
- **Secure boot:** Disable if not already disabled, IMO this will give you less headache in the long run.
- **Power mode:** I changed it from `Performance` to `Balanced` to achieve ~85W peak power draw with occasional small spikes, instead of peak 140W TDP as in my experiments difference in performace was not drastic.

Reboot after making these changes.

## Kernel Update

Install the mainline kernel tool and update to kernel 6.18.7:

```bash
sudo add-apt-repository ppa:cappelikan/ppa -y # adds a repo for 'mainline' tool
sudo apt update                               # pull the package list from there
sudo apt install mainline pkexec -y           # install "mainline"
mainline --install 6.18.7                     # use mainline to install kernel 6.18.17
```

Instead of the last step, you can do `mainline --list` and choose a different kernel. 6.18.7 was the latest at the time of writing.

## Linux Firmware Update

Since the latest firmware wasn't available in the 25.10 repository, we can install it manually:

```bash
wget https://archive.ubuntu.com/ubuntu/pool/main/l/linux-firmware/linux-firmware_20260108.gitd86b47f7-0ubuntu1_all.deb
dpkg -i linux-firmware_20260108.gitd86b47f7-0ubuntu1_all.deb
```

You can go to https://archive.ubuntu.com/ubuntu/pool/main/l/linux-firmware/ and browse and see what other versions are available.

## GRUB Configuration

Edit `/etc/default/grub` and add the following kernel parameters:

```bash
GRUB_CMDLINE_LINUX="amd_iommu=off amdgpu.gttsize=122880 ttm.pages_limit=31457280"
```

Update GRUB and reboot:

```bash
update-grub
reboot
```

## Verification

After completing all steps, verify the GPU memory configuration:

```bash
dmesg | grep "amdgpu.*memory"
```

Expected output:
```
[    4.759832] amdgpu 0000:c5:00.0: amdgpu: amdgpu: 1024M of VRAM memory ready
[    4.759834] amdgpu 0000:c5:00.0: amdgpu: amdgpu: 122880M of GTT memory ready.
```

## User Permissions

Add your user to the necessary groups for GPU access:

```bash
sudo usermod -aG video,render $USER
```

Log out and log back in for the changes to take effect.

## Container Management

Install Podman and Distrobox:

```bash
apt install podman distrobox
```

## ROCm Container Setup

Create and enter the ROCm toolbox from the container provided by [@kyuz0](https://github.com/kyuz0/amd-strix-halo-toolboxes):

```bash
distrobox create llama-rocm \
  --image docker.io/kyuz0/amd-strix-halo-toolboxes:rocm-7.2 \
  --additional-flags "--device /dev/dri --device /dev/kfd --group-add video --group-add render"

distrobox enter llama-rocm
```

At this point you should be able to run `llama-cli --version` while being inside the toolbox and you should see:

```text
ggml_cuda_init: found 1 ROCm devices:
  Device 0: Radeon 8060S Graphics, gfx1151 (0x1151), VMM: no, Wave Size: 32
```
