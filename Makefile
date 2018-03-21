TARGET:=rtos

# Library paths (adjust to match your needs)
STM32F4CUBE=$(ERS_ROOT)/stm32f4cube
FREERTOS:=$(CURDIR)/FreeRTOS
CMSIS=$(STM32F4CUBE)/Drivers/CMSIS
HAL=$(STM32F4CUBE)/Drivers/STM32F4xx_HAL_Driver
HAL_BIN=bin

# Tools gcc + binutils + gdb + openocd
TOOLCHAIN_PREFIX:=arm-none-eabi-
CC=$(TOOLCHAIN_PREFIX)gcc
CXX=$(TOOLCHAIN_PREFIX)g++
LD=$(TOOLCHAIN_PREFIX)ld
OBJCOPY=$(TOOLCHAIN_PREFIX)objcopy
SIZE=$(TOOLCHAIN_PREFIX)size
GDB=/$(TOOLCHAIN_PREFIX)gdb
AS=$(TOOLCHAIN_PREFIX)as
OPENOCD=openocd

# Optimization level, can be [0, 1, 2, 3, s].
OPTLVL:=0
DBG:=-g3


STARTUP:=$(CURDIR)/hardware
LINKER_SCRIPT:=$(CURDIR)/stm32_flash.ld


# Includes including library includes
INCLUDES=\
-I./src \
-I./config \
-I$(HAL)/Inc \
-I$(CMSIS)/Device/ST/STM32F4xx/Include \
-I$(CMSIS)/Include



TSRC = $(CURDIR)/../src

INCLUDES+=-I$(CURDIR)/src
INCLUDES+=-I$(CURDIR)/hardware
INCLUDES+=-I$(TSRC)
INCLUDES+=-I$(FREERTOS)/include
INCLUDES+=-I$(FREERTOS)/portable/GCC/ARM_CM4F
#INCLUDES+=-I$(CURDIR)/libraries/CMSIS/Device/ST/STM32F4xx/Include
#INCLUDES+=-I$(CURDIR)/libraries/CMSIS/Include
#INCLUDES+=-I$(CURDIR)/libraries/STM32F4xx_StdPeriph_Driver/inc
INCLUDES+=-I$(CURDIR)/config

BUILD_DIR = $(CURDIR)/build
BIN_DIR = $(CURDIR)/binary

# vpath is used so object files are written to the current directory instead
# of the same directory as their source files
vpath %.c $(CURDIR)/src $(CURDIR)/libraries/STM32F4xx_StdPeriph_Driver/src \
	  $(CURDIR)/libraries/syscall $(CURDIR)/hardware $(FREERTOS) \
	  $(FREERTOS)/portable/MemMang $(FREERTOS)/portable/GCC/ARM_CM4F 

vpath %.s $(STARTUP)

vpath %.cpp $(CURDIR)/src $(TSRC)

# Project Source Files
SRC+=startup_stm32f4xx.s
SRC+=stm32f4xx_it.c
SRC+=system_stm32f4xx.c
SRC+=syscalls.c
SRC+=main.cpp
SRC+=hooks.cpp
SRC+=Button.cpp
SRC+=LED.cpp

# FreeRTOS Source Files
SRC+=port.c
SRC+=list.c
SRC+=queue.c
SRC+=tasks.c
SRC+=event_groups.c
SRC+=timers.c
SRC+=heap_4.c

# Standard Peripheral Source Files
SRC+=stm32f4xx_syscfg.c
SRC+=misc.c
SRC+=stm32f4xx_adc.c
SRC+=stm32f4xx_dac.c
SRC+=stm32f4xx_dma.c
SRC+=stm32f4xx_exti.c
SRC+=stm32f4xx_flash.c
SRC+=stm32f4xx_gpio.c
SRC+=stm32f4xx_i2c.c
SRC+=stm32f4xx_rcc.c
SRC+=stm32f4xx_spi.c
SRC+=stm32f4xx_tim.c
SRC+=stm32f4xx_usart.c
SRC+=stm32f4xx_rng.c

CDEFS=-DUSE_STDPERIPH_DRIVER
CDEFS+=-DSTM32F4XX
CDEFS+=-DHSE_VALUE=8000000
CDEFS+=-D__FPU_PRESENT=1
CDEFS+=-D__FPU_USED=1
CDEFS+=-DARM_MATH_CM4

MCUFLAGS=-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mthumb-interwork -MMD -MP -mlittle-endian
COMMONFLAGS=-O$(OPTLVL) $(DBG) -Wall
CFLAGS=$(COMMONFLAGS) $(MCUFLAGS) $(INCLUDES) $(CDEFS)
CPPFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti -std=c++11 -fno-use-cxa-atexit 
#LDFLAGS=$(COMMONFLAGS) $(MCUFLAGS) -fno-exceptions -ffunction-sections -fdata-sections -nostartfiles -Wl,--gc-sections,-T$(LINKER_SCRIPT)
LDFLAGS=$(COMMONFLAGS) -T$(LINKER_SCRIPT) -Wl,-Map,$(BIN_DIR)/$(TARGET).map $(CPPFLAGS)


OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(SRC))
OBJ := $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(OBJ))
OBJ := $(patsubst %.s,$(BUILD_DIR)/%.o,$(OBJ))

DEP = $(patsubst %.c,$(BUILD_DIR)/%.d,$(SRC))
DEP := $(patsubst %.cpp,$(BUILD_DIR)/%.d,$(DEP))
DEP := $(patsubst %.s,,$(DEP))


$(BUILD_DIR)/%.o: %.c
	@echo [CC] $(notdir $<)
	$(CC) $(CFLAGS) $< -c -o $@

$(BUILD_DIR)/%.o: %.cpp
	@echo [C++] $(notdir $<)
	$(CXX) $(CPPFLAGS) $< -c -o $@

$(BUILD_DIR)/%.o: %.s
	@echo [AS] $(notdir $<)
	$(CC) -c $(CPPFLAGS) $< -o $@

$(BUILD_DIR)/%.dep: %.c
	$(CC) -M $(CFLAGS) "$<" > "$@"

$(BUILD_DIR)/%.dep: %.cpp
	$(CPP) -M $(CPPFLAGS) "$<" > "$@"

all: $(BIN_DIR)/$(TARGET).elf

$(BIN_DIR)/$(TARGET).elf: $(OBJ)
	@echo [LD] $(TARGET).elf
	$(CC) -o $(BIN_DIR)/$(TARGET).elf $(LDFLAGS) $(OBJ) $(LDLIBS)
	@echo [OBJCOPY] $(TARGET).hex
	@$(OBJCOPY) -O ihex $(BIN_DIR)/$(TARGET).elf $(BIN_DIR)/$(TARGET).hex
	@$(SIZE) --format=berkeley $(BIN_DIR)/$(TARGET).elf
	
#	@echo [OBJCOPY] $(TARGET).bin
#	@$(OBJCOPY) -O binary $(BIN_DIR)/$(TARGET).elf $(BIN_DIR)/$(TARGET).bin


clean:
	@echo [RM] OBJ
	@rm -f $(OBJ) $(patsubst %.o,%.d,$(OBJ))
	@echo [RM] BIN
	@rm -f $(BIN_DIR)/$(TARGET).elf
	@rm -f $(BIN_DIR)/$(TARGET).hex
	@rm -f $(BIN_DIR)/$(TARGET).bin
	@rm -f $(BIN_DIR)/$(TARGET).map

# Flash final elf into device
flash: all
	${OPENOCD} -f board/stm32f4discovery-v2.1.cfg -c "program $(BIN_DIR)/$(TARGET).elf verify reset exit"

flash1: all
	${OPENOCD} -f board/stm32f4discovery.cfg -c "program $(BIN_DIR)/$(TARGET).elf verify reset exit"

# Debug
debug: all
	$(GDB) $(BIN_DIR)/$(TARGET).elf -ex "target remote | ${OPENOCD} -f board/stm32f4discovery-v2.1.cfg --pipe" -ex load

debug1: all
	$(GDB) $(BIN_DIR)/$(TARGET).elf -ex "target remote | $(OPENOCD} -f board/stm32f4discovery.cfg --pipe" -ex load


-include $(DEP)

.PHONY: all flash clean debug
