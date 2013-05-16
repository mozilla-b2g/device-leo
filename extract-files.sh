#!/bin/bash

# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DEVICE=leo
MANUFACTURER=qcom

if [[ -z "${ANDROIDFS_DIR}" && -d ../../../backup-${DEVICE}/system ]]; then
    ANDROIDFS_DIR=../../../backup-${DEVICE}
fi

if [[ -z "${ANDROIDFS_DIR}" ]]; then
    echo Pulling files from device
    DEVICE_BUILD_ID=`adb shell cat /system/build.prop | grep ro.build.display.id | sed -e 's/ro.build.display.id=//' | tr -d '\n\r'`
else
    echo Pulling files from ${ANDROIDFS_DIR}
    DEVICE_BUILD_ID=`cat ${ANDROIDFS_DIR}/system/build.prop | grep ro.build.display.id | sed -e 's/ro.build.display.id=//' | tr -d '\n\r'`
fi

if [[ ! -d ../../../backup-${DEVICE}/system  && -z "${ANDROIDFS_DIR}" ]]; then
    echo Backing up system partition to backup-${DEVICE}
    mkdir -p ../../../backup-${DEVICE} &&
    adb pull /system ../../../backup-${DEVICE}/system
fi

BASE_PROPRIETARY_DEVICE_DIR=vendor/$MANUFACTURER/$DEVICE/proprietary
PROPRIETARY_DEVICE_DIR=../../../vendor/$MANUFACTURER/$DEVICE/proprietary

mkdir -p $PROPRIETARY_DEVICE_DIR

for NAME in audio hw wifi etc egl etc/firmware
do
    mkdir -p $PROPRIETARY_DEVICE_DIR/$NAME
done

BLOBS_LIST=../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk

(cat << EOF) | sed s/__DEVICE__/$DEVICE/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > ../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk
# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Prebuilt libraries that are needed to build open-source libraries
PRODUCT_COPY_FILES := device/sample/etc/apns-full-conf.xml:system/etc/apns-conf.xml

# All the blobs
PRODUCT_COPY_FILES += \\
EOF

# copy_file
# pull file from the device and adds the file to the list of blobs
#
# $1 = src/dst name
# $2 = directory path on device
# $3 = directory name in $PROPRIETARY_DEVICE_DIR
copy_file()
{
    echo Pulling \"$1\"
    if [[ -z "${ANDROIDFS_DIR}" ]]; then
        NAME=$1
        adb pull /$2/$1 $PROPRIETARY_DEVICE_DIR/$3/$2
    else
        NAME=`basename ${ANDROIDFS_DIR}/$2/$1`
        rm -f $PROPRIETARY_DEVICE_DIR/$3/$NAME
        cp ${ANDROIDFS_DIR}/$2/$NAME $PROPRIETARY_DEVICE_DIR/$3/$NAME
    fi

    if [[ -f $PROPRIETARY_DEVICE_DIR/$3/$NAME ]]; then
        echo   $BASE_PROPRIETARY_DEVICE_DIR/$3/$NAME:$2/$NAME \\ >> $BLOBS_LIST
    else
        echo Failed to pull $1. Giving up.
        exit -1
    fi
}

# copy_files
# pulls a list of files from the device and adds the files to the list of blobs
#
# $1 = list of files
# $2 = directory path on device
# $3 = directory name in $PROPRIETARY_DEVICE_DIR
copy_files()
{
    for NAME in $1
    do
        copy_file "$NAME" "$2" "$3"
    done
}

# copy_local_files
# puts files in this directory on the list of blobs to install
#
# $1 = list of files
# $2 = directory path on device
# $3 = local directory path
copy_local_files()
{
    for NAME in $1
    do
        echo Adding \"$NAME\"
        echo device/$MANUFACTURER/$DEVICE/$3/$NAME:$2/$NAME \\ >> $BLOBS_LIST
    done
}

COMMON_LIBS="
	lib*ty.so
	libOmxAacDec.so
        libOmxAacEnc.so
        libOmxAmrDec.so
        libOmxAmrEnc.so
        libOmxAmrRtpDec.so
        libOmxAmrwbDec.so
        libOmxMpeg4Dec.so
	libOmxH264Dec.so
	libOmxMp3Dec.so
	libOmxVidEnc.so
	libOmxVp8Dec.so
	libOpenVG.so
	libauth.so
	libchromatix_hi542_default_video.so
	libchromatix_hi542_preview.so
	libcm.so
	libcnefeatureconfig.so
	libcommondefs.so
	libdiag.so
	libdivxdrmdecrypt.so
	libdsi_netctrl.so
	libdsm.so
	libdss.so
	libdsutils.so
	libgemini.so
	libgenlock.so
	libgps.utils.so
	libgsdi_exp.so
	libgsl.so
	libgstk_exp.so
	libidl.so
	libimage-jpeg-enc-omx-comp.so
	libimage-omx-common.so
	lib*eat.so
	libloc_adapter.so
	libloc_api-rpc-qc.so
	libloc_eng.so
	libmm-adspsvc.so
	libmmcamera_faceproc.so
	libmmcamera_frameproc.so
	libmmcamera_hdr_lib.so
	libmmcamera_image_stab.so
	libmmcamera_interface2.so
	libmmcamera_interface2.so
	libmmcamera_statsproc31.so
	libmmcamera_wavelet_lib.so
	libmmgsdilib.so
	libmmipl.so
	libmmjpeg.so
	libmmstillomx.so
	libnetmgr.so
	libnv.so
	liboem_rapi.so
	liboemcamera.so
	liboncrpc.so
	libpbmlib.so
	libqcci_legacy.so
	libqdi.so
	libqdp.so
	libqmi.so
	libqmi_client_qmux.so
	libqmiservices.so
	libqueue.so
	librfm_sar.so
	libril-qc-1.so
	libril-qc-qmi-1.so
	libril-qcril-hook-oem.so
	libsc-a2xx.so
	libwms.so
	libwmsts.so
	"

copy_files "$COMMON_LIBS" "system/lib" ""

COMMON_BINS="
	bridgemgrd
	fm_qsoc_patches
	fmconfig
	gpu_dcvsd
	hci_qcomm_init
	mm-qcamera-daemon
	netmgrd
	port-bridge
	qmiproxy
	qmuxd
	qosmgr
	radish
	sensord
	"
copy_files "$COMMON_BINS" "system/bin" ""

COMMON_HW="
	audio_policy.msm7627a.so
	audio.primary.msm7627a.so
	camera.msm7627a.so
	gps.default.so
	sensors.msm7627a.so
	"
copy_files "$COMMON_HW" "system/lib/hw" "hw"

COMMON_WIFI="
	librasdioif.ko
	"
copy_files "$COMMON_WIFI" "system/lib/modules" "wifi"

COMMON_WIFI_VOLANS="
	cfg80211.ko
	WCN1314_rf.ko
	"
copy_files "$COMMON_WIFI_VOLANS" "system/lib/modules/volans" "wifi"

COMMON_WLAN="
	WCN1314_cfg.dat
	WCN1314_qcom_cfg.ini
	WCN1314_qcom_fw.bin
	WCN1314_qcom_wlan_nv.bin
	"
copy_files "$COMMON_WLAN" "system/etc/firmware/wlan/volans" "wifi"

COMMON_ETC="AudioFilter.csv gps.conf"
copy_files "$COMMON_ETC" "system/etc" "etc"

COMMON_AUDIO="
	"
#copy_files "$COMMON_AUDIO" "system/lib" "audio"

COMMON_EGL="
	egl.cfg
	eglsubAndroid.so
	libEGL_adreno200.so
	libGLES_android.so
	libGLESv1_CM_adreno200.so
	libGLESv2_adreno200.so
	libq3dtools_adreno200.so
	"
copy_files "$COMMON_EGL" "system/lib/egl" "egl"

COMMON_FIRMWARE="
	yamato_pfp.fw
	yamato_pm4.fw
	"
copy_files "$COMMON_FIRMWARE" "system/etc/firmware" "etc/firmware"

echo $BASE_PROPRIETARY_DEVICE_DIR/libcnefeatureconfig.so:obj/lib/libcnefeatureconfig.so \\ >> $BLOBS_LIST

