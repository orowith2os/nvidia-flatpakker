# nvidia-flatpakker
Convert NVIDIA driver archives into Flatpak driver extensions.

Run the script by setting NVIDIA_DIR to an extracted NVIDIA driver archive's 
directory.

If you want to build 32-bit driver extensions (x86 only), re-run the script with 
`BUILD_32_BIT=1` (you will have to re-run the script to build both 32-bit and 
64-bit options).


## Will you make this grab files from the rootfs?
No. You can run this in your NVIDIA driver package's build steps and point it to
the extracted archive there, or if you're a user, download the archive from
NVIDIA and run this script on that.
