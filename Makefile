# put your *.o targets here, make should handle the rest!

#SRCS = main.c stm32f4xx_it.c system_stm32f4xx.c
SRCS = main.c system.c

# all the files will be generated with this name (main.elf, main.bin, main.hex, etc)

PROJ_NAME=main

# Put your stlink folder here so make burn will work.

STLINK=/mnt/share/Programming/embedded/stm32/stlink

# that's it, no need to change anything below this line!

###################################################

CC=clang
OBJCOPY=objcopy
AR=llvm-ar

CFLAGS  = -g -O2 -Wall -Tstm32_flash.ld 
CFLAGS += -target arm-none-eabi -mlittle-endian -mthumb -mcpu=cortex-m4 ##-mthumb-interwork
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -ffreestanding -nostdlib

CFLAGS_2  = -g -O2 -Wall -Tstm32_flash.ld 
CFLAGS_2 += -target arm-none-eabi -mlittle-endian -mthumb -mcpu=cortex-m4 ##-mthumb-interwork
CFLAGS_2 += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS_2 += -ffreestanding -nostdlib

###################################################

vpath %.c src
vpath %.a lib

ROOT=$(shell pwd)

CFLAGS += -Iinc -Ilib -Ilib/inc
CFLAGS += -Ilib/inc/core -Ilib/inc/peripherals 

SRCS += lib/startup_stm32f4xx.s # add startup file to build

OBJS = $(SRCS:.c=.o)
OBJS2 = $(OBJS:.s=.o)

###################################################

.PHONY: lib proj

all: lib proj

again: clean all

# Flash the STM32F4
burn:
	$(STLINK)/flash/st-flash write $(PROJ_NAME).bin 0x8000000

# Create tags; assumes ctags exists
ctags:
	ctags -R --exclude=*cm0.h --exclude=*cm3.h .

lib:
	$(MAKE) -C lib

# %.o : %.c
# 	$(CC) $(CFLAGS) -c -o $@ $^

proj: 	$(PROJ_NAME).elf


# $(PROJ_NAME).elf: $(SRCS)
# 	$(CC) $(CFLAGS) $^ -o $@ -Llib -lstm32f4

%.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $^

proj: 	$(PROJ_NAME).elf

$(PROJ_NAME).elf: $(SRCS)
	$(CC) $(CFLAGS) $^ -o $@ -Llib -lstm32f4
# $(OBJCOPY) -O ihex $(PROJ_NAME).elf $(PROJ_NAME).hex
# $(OBJCOPY) -O binary $(PROJ_NAME).elf $(PROJ_NAME).bin

clean:
	rm -f *.o *.i
	rm -f $(PROJ_NAME).elf
	rm -f $(PROJ_NAME).hex
	rm -f $(PROJ_NAME).bin
