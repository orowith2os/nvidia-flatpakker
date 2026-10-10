# nvidia-flatpakker
Convert NVIDIA driver archives into Flatpak driver extensions.

Run the script by setting NVIDIA_DIR to an extracted NVIDIA driver archive's 
directory.

If you want to build 32-bit driver extensions (x86 only), re-run the script with 
`BUILD_32_BIT=1` (you will have to re-run the script to build both 32-bit and 
64-bit options).

## How do I use this?
1. run `VERSION=$(rpm -q --qf "%{VERSION}\n" kmod-nvidia | head -n 1)`
2. run `wget https://download.nvidia.com/XFree86/Linux-x86_64/$VERSION/NVIDIA-Linux-x86_64-$VERSION.run`
3. run `chmod +x NVIDIA-Linux-x86_64-$VERSION.run && NVIDIA-Linux-x86_64-$VERSION.run --extract-only`
5. run `NVIDIA_DIR=NVIDIA-Linux-x86_64-$VERSION NVIDIA_DRIVER_VERSION=$VERSION BUILD_32_BIT=1 ./nvidia-flatpakker.sh`
6. run `NVIDIA_DIR=NVIDIA-Linux-x86_64-$VERSION NVIDIA_DRIVER_VERSION=$VERSION ./nvidia-flatpakker.sh`
7. run `sudo cp -r org.freedesktop.Platform.GL32.host org.freedesktop.Platform.GL.host /var/lib/flatpak/extension/`

## Will you make this grab files from the rootfs?
No. You can run this in your NVIDIA driver package's build steps and point it to
the extracted archive there, or if you're a user, download the archive from
NVIDIA and run this script on that.
