#!/usr/bin/env bash

#    Copyright (C) 2026 Yves Auxier
#
#    This library is free software; you can redistribute it and/or
#    modify it under the terms of the GNU Lesser General Public
#    License as published by the Free Software Foundation; either
#    version 2.1 of the License, or (at your option) any later version.
#
#    This library is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public
#    License along with this library; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
#    USA

if [[ -v NVIDIA_DIR ]]; then
    if [[ ! -d "$NVIDIA_DIR" ]]; then
    	echo "${DIR} doesn't exist, run it again with a valid path to the NVIDIA driver files."
    	echo "This should be the extracted form of your NVIDIA driver version (generated with NVIDIA-Linux-ARCH-VERSION.run --extract-only)."
    	exit 1;
    fi
    NVIDIA_DIR=$(basename $NVIDIA_DIR)
    
    if [[ ! -v NVIDIA_DRIVER_VERSION ]]; then
        echo "NVIDIA_DRIVER_VERSION isn't set. This should be exactly as it shows in the extracted NVIDIA driver archive (VERSION in NVIDIA-Linux-ARCH-VERSION.run)."
        exit 1;
    fi
else
    echo "NVIDIA_DIR isn't set. Exiting."
    exit 1;
fi


if [[ ! -v BUILD_32_BIT ]]; then
    echo "set BUILD_32_BIT=1 to build the 32-bit driver."
    
    EXTENSION_ID="org.freedesktop.Platform.GL.host"
    PREFIX="${EXTENSION_ID}/$(uname -m)/1.4"
    
    install -d $PREFIX/lib
    cp -a $NVIDIA_DIR/*.so $NVIDIA_DIR/*.so.* $PREFIX/lib/
else
    if [[ "$(uname -m)" != "x86_64" ]]; then
      echo "32-bit driver only available for x86_64. Exiting."
      exit 1;
    fi
    
    echo "unset the BUILD_32_BIT environment variable to build the 64-bit driver."
    
    EXTENSION_ID="org.freedesktop.Platform.GL32.host"
    PREFIX="${EXTENSION_ID}/$(uname -m)/1.4"
    
    install -d $PREFIX/lib
    cp -a $NVIDIA_DIR/32/*.so $NVIDIA_DIR/32/*.so.* $PREFIX/lib/
fi

# Adapted from the Arch packaging at https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-utils/-/blob/781100d68445c9d44e8850809489648178288c4c/PKGBUILD#L37
# create soname links
find $PREFIX/lib/ -type f -name '*.so*' -print0 | while read -d $'\0' _lib; do
    _soname=$(dirname "${_lib}")/$(readelf -d "${_lib}" | grep -Po 'SONAME.*: \[\K[^]]*' || true)
    _base=$(echo ${_soname} | sed -r 's/(.*)\.so.*/\1.so/')
    [[ -e "${_soname}" ]] || ln -s $(basename "${_lib}") "${_soname}"
    [[ -e "${_base}" ]] || ln -s $(basename "${_soname}") "${_base}"
done

# Vulkan
if [[ "$(uname -m)" == "x86_64" ]]; then
    install -d $PREFIX/vulkansc/icd.d/
fi
install -d $PREFIX/vulkan/icd.d/
install -d $PREFIX/vulkan/implicit_layer.d/

install $NVIDIA_DIR/nvidia_icd_vksc.json $PREFIX/vulkansc/icd.d/nvidia_icd_vksc.json
install $NVIDIA_DIR/nvidia_icd.json $PREFIX/vulkan/icd.d/nvidia_icd.json
install $NVIDIA_DIR/nvidia_layers.json $PREFIX/vulkan/implicit_layer.d/nvidia_layers.json

# EGL and GLVND files
install -d $PREFIX/egl/egl_external_platform.d/
install -d $PREFIX/glvnd/egl_vendor.d/
cp -a $NVIDIA_DIR/*_nvidia_*.json $PREFIX/egl/egl_external_platform.d/
# Move the main icd file to glvnd's path, since we just copied it unconditionally above
cp $NVIDIA_DIR/*_nvidia.json $PREFIX/glvnd/egl_vendor.d/10_nvidia.json
# rename this (I don't know why, but everyone does it, including flathub, so....)
mv $PREFIX/egl/egl_external_platform.d/10_nvidia_wayland.json $PREFIX/egl/egl_external_platform.d/10_nvidia.json

# OpenCL
install -d $PREFIX/OpenCL/vendors
install -p -Dm644 $NVIDIA_DIR/nvidia.icd $PREFIX/OpenCL/vendors/nvidia.icd

# Wine, only for x86
if [[ "$(uname -m)" == "x86_64" ]]; then
    install -d $PREFIX/lib/nvidia/wine
    cp -a $NVIDIA_DIR/*.dll $PREFIX/lib/nvidia/wine/
fi

echo "All done. Move $EXTENSION_ID to /var/lib/flatpak/extension, or if running as a user, XDG_DATA_HOME/flatpak/extension."

exit 0;

