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
#obj-m += wwan.o
#wwan-y := wwan_core.o

obj-m += mhi_wwan_ctrl.o

obj-m += mhi_wwan_mbim.o

obj-m += mhi_dtr.o

KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD       := $(shell pwd)

all:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) ccflags-y="-DCONFIG_MHI_BUS_DEBUG"

clean:
	rm -rf *.o *.cmd *.ko *.mod.c .tmp_versions *.o.ur-safe *.symvers *.order .cache.mk .mhi* .built-in* built-in.a 

install:
	sudo cp mhi.ko /lib/modules/`uname -r`/kernel/drivers/bus/mhi/host/mhi.ko
	sudo cp mhi_pci_generic.ko /lib/modules/`uname -r`/kernel/drivers/bus/mhi/host/mhi_pci_generic.ko
	sudo depmod


	

