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
obj-m += mhi.o
mhi-y := init.o main.o pm.o boot.o
mhi-y += debugfs.o
obj-m += mhi_pci_semtech.o
mhi_pci_semtech-y += pci_generic.o

obj-m += uci.o
mhi_uci-y += uci.o

KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD       := $(shell pwd)

all:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) ccflags-y="-DCONFIG_MHI_BUS_DEBUG"

clean:
	rm -rf *.o *.cmd *.ko *.mod.c .tmp_versions *.o.ur-safe *.symvers *.order .cache.mk .mhi* .built-in* built-in.a 

install:
	sudo cp mhi.ko /lib/modules/`uname -r`/kernel/drivers/bus/mhi/host/mhi.ko
	sudo cp mhi_pci_semtech.ko /lib/modules/`uname -r`/kernel/drivers/bus/mhi/host/mhi_pci_semtech.ko
	sudo cp uci.ko /lib/modules/`uname -r`/kernel/drivers/bus/mhi/host/uci.ko
	sudo depmod


	

