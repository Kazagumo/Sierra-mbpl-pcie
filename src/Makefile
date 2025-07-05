#
# Makefile for the MHI stack
#

ifeq ($(DEBUG),y)
  DEBFLAGS = -O2 -g -DMHINET_DEBUG # "-O" is needed to expand inlines
else
  DEBFLAGS = -O2
endif

ccflags-$(DEBUG):=$(DEBFLAGS)

# core layer
obj-m := host/ wwan/ qrtr/

KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD       := $(shell pwd)

all:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) ccflags-y="-DCONFIG_MHI_BUS_DEBUG"

centos:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) ccflags-y="-DCENTOS"

clean:
	rm -rf *.symvers *.order
	cd host; rm -rf *.o *.cmd *.ko *.mod.c .tmp_versions *.o.ur-safe *.symvers *.order .cache.mk .mhi* .built-in* built-in.a *.ko.zst *.mod
	cd wwan; rm -rf *.o *.cmd *.ko *.mod.c .tmp_versions *.o.ur-safe *.symvers *.order .cache.mk .mhi* .built-in* built-in.a *.ko.zst *.mod
	cd qrtr; rm -rf *.o *.cmd *.ko *.mod.c .tmp_versions *.o.ur-safe *.symvers *.order .cache.mk .mhi* .built-in* built-in.a *.ko.zst *.mod

install:
	if [ -f /lib/modules/`uname -r`/kernel/drivers/bus/mhi/host/mhi.ko.zst ]; then \
	zstd -f host/mhi.ko; sudo cp host/mhi.ko.zst /lib/modules/`uname -r`/kernel/drivers/bus/mhi/host/mhi.ko.zst; \
	zstd -f host/mhi_pci_semtech.ko; sudo cp host/mhi_pci_semtech.ko.zst /lib/modules/`uname -r`/kernel/drivers/bus/mhi/host/mhi_pci_semtech.ko.zst; \
	zstd -f host/uci.ko; sudo cp host/uci.ko.zst /lib/modules/`uname -r`/kernel/drivers/bus/mhi/host/uci.ko.zst; \
	zstd -f wwan/mhi_wwan_ctrl.ko; sudo cp wwan/mhi_wwan_ctrl.ko.zst /lib/modules/`uname -r`/kernel/drivers/net/wwan/mhi_wwan_ctrl.ko.zst; \
	zstd -f wwan/mhi_wwan_mbim.ko; sudo cp wwan/mhi_wwan_mbim.ko.zst /lib/modules/`uname -r`/kernel/drivers/net/wwan/mhi_wwan_mbim.ko.zst; \
	zstd -f wwan/mhi_dtr.ko; sudo cp wwan/mhi_dtr.ko.zst /lib/modules/`uname -r`/kernel/drivers/net/wwan/mhi_dtr.ko.zst; \
	zstd -f qrtr/qrtr-mhi.ko; sudo cp qrtr/qrtr-mhi.ko.zst /lib/modules/`uname -r`/kernel/net/qrtr/qrtr-mhi.ko.zst; \
	else \
	sudo cp host/mhi.ko /lib/modules/`uname -r`/kernel/drivers/bus/mhi/host/mhi.ko; \
	sudo cp host/mhi_pci_semtech.ko /lib/modules/`uname -r`/kernel/drivers/bus/mhi/host/mhi_pci_semtech.ko; \
	sudo cp host/uci.ko /lib/modules/`uname -r`/kernel/drivers/bus/mhi/host/uci.ko; \
	sudo cp wwan/mhi_wwan_ctrl.ko /lib/modules/`uname -r`/kernel/drivers/net/wwan/mhi_wwan_ctrl.ko; \
	sudo cp wwan/mhi_wwan_mbim.ko /lib/modules/`uname -r`/kernel/drivers/net/wwan/mhi_wwan_mbim.ko; \
	sudo cp wwan/mhi_dtr.ko /lib/modules/`uname -r`/kernel/drivers/net/wwan/mhi_dtr.ko; \
	fi
	
	sudo depmod


	

