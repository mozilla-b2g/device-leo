$(call inherit-product, device/qcom/common/common.mk)

$(shell ln -sf $(abspath $(TOP))/device/qcom/msm7627a/system.prop $(LOCAL_PATH)/system.prop)

PRODUCT_COPY_FILES := \
  device/qcom/leo/touchscreen.idc:system/usr/idc/touch_mcs8000.idc \
  device/qcom/leo/media_profiles.xml:system/etc/media_profiles.xml \
  device/qcom/leo/vold.fstab:system/etc/vold.fstab \
  device/qcom/msm7627a/wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf

$(call inherit-product-if-exists, vendor/qcom/leo/leo-vendor-blobs.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full.mk)

PRODUCT_PROPERTY_OVERRIDES += \
  rild.libpath=/system/lib/libril-qc-1.so \
  rild.libargs=-d/dev/smd0 \
  ro.use_data_netmgrd=true \
  ro.moz.ril.emergency_by_default=true \
  ro.display.colorfill=1 \
  ro.fm.analogpath.supported=true \
  ro.moz.omx.hw.max_width=640 \
  ro.moz.omx.hw.max_height=480 \

ENABLE_LIBRECOVERY := true
# Discard inherited values and use our own instead.
PRODUCT_NAME := full_leo
PRODUCT_DEVICE := leo
PRODUCT_BRAND := qcom
PRODUCT_MANUFACTURER := qcom
PRODUCT_MODEL := leo


