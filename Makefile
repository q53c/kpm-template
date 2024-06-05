#ifndef TARGET_COMPILE
#    $(error TARGET_COMPILE not set)
#endif

ANDROID=1

ifndef KP_DIR
    KP_DIR = $(HOME)/repos/KernelPatch
endif


CC = $(TARGET_COMPILE)gcc
LD = $(TARGET_COMPILE)ld

INCLUDE_DIRS := . include patch/include linux/include linux/arch/arm64/include linux/tools/arch/arm64/include

INCLUDE_FLAGS := $(foreach dir,$(INCLUDE_DIRS),-I$(KP_DIR)/kernel/$(dir))

CFLAGS += -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-pic

objs := syscallhook.o

all: syscallhook.kpm

syscallhook.kpm: ${objs}
	${CC} -r -o $@ $^

%.o: %.c
	${CC} $(CFLAGS) $(INCLUDE_FLAGS) -c -O2 -o $@ $<

.PHONY: clean
clean:
	rm -rf *.kpm
	find . -name "*.o" | xargs rm -f


load: syscallhook.kpm
	kpatch qsecskey kpm load syscallhook.kpm function_pointer_hook


unload:
	kpatch qsecskey kpm unload kpm-syscall-hook-demo

