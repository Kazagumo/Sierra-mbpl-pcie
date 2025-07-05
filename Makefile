#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sierra_mbpl_pcie
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/sierra_mbpl_pcie
  SUBMENU:=WWAN Support
  TITLE:=Kernel pcie driver for sierra MHI device
  DEPENDS:=+pciids +pciutils +kmod-wwan +kmod-qrtr-mhi
  FILES:= \
	$(PKG_BUILD_DIR)/host/uci.ko \
	$(PKG_BUILD_DIR)/host/mhi_pci_semtech.ko \
	$(PKG_BUILD_DIR)/wwan/mhi_wwan_ctrl.ko \
	$(PKG_BUILD_DIR)/wwan/mhi_wwan_mbim.ko
  AUTOLOAD:=$(call AutoLoad,90,mhi_pci_semtech)
endef

define KernelPackage/sierra_mbpl_pcie/description
  Kernel module for register a sierra wireless pciemhi platform device.
endef

MAKE_OPTS:= \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	M="$(PKG_BUILD_DIR)" \
	$(EXTRA_KCONFIG)

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		$(MAKE_OPTS) \
		modules
endef

$(eval $(call KernelPackage,sierra_mbpl_pcie))
