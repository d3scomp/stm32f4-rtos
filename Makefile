PROJECT:=rtos
ELF = $(PROJECT).elf

# Library paths (adjust to match your needs)
STM32F4CUBE=$(ERS_ROOT)/stm32f4cube
FREERTOS:=$(CURDIR)/FreeRTOS
CMSIS=$(STM32F4CUBE)/Drivers/CMSIS
HAL=$(STM32F4CUBE)/Drivers/STM32F4xx_HAL_Driver

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


# Defines
#CDEFS=-DUSE_STDPERIPH_DRIVER
#CDEFS+=-DSTM32F4XX
#CDEFS+=-DHSE_VALUE=8000000
#CDEFS+=-D__FPU_PRESENT=1
#CDEFS+=-D__FPU_USED=1
#CDEFS+=-DARM_MATH_CM4
CDEFS=-DSTM32F405xx

# Flags
MCUFLAGS=-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mthumb-interwork -MMD -MP -mlittle-endian
COMMONFLAGS=-O$(OPTLVL) $(DBG) -Wall
CFLAGS=$(COMMONFLAGS) $(MCUFLAGS) $(CDEFS)
CPPFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti -std=c++11 -fno-use-cxa-atexit 
#LDFLAGS=$(COMMONFLAGS) $(MCUFLAGS) -fno-exceptions -ffunction-sections -fdata-sections -nostartfiles -Wl,--gc-sections,-T$(LINKER_SCRIPT)
LDFLAGS=$(COMMONFLAGS) -T$(LINKER_SCRIPT) -Wl,-Map,$(BIN_DIR)/$(PROJECT).map $(CPPFLAGS)


# Includes including library includes
INCLUDES+=-I./src
INCLUDES+=-I./config
INCLUDES+=-I$(HAL)/Inc
INCLUDES+=-I$(CMSIS)/Device/ST/STM32F4xx/Include
INCLUDES+=-I$(CMSIS)/Include
INCLUDES+=-I$(CURDIR)/src
INCLUDES+=-I$(CURDIR)/hardware
INCLUDES+=-I$(TSRC)
INCLUDES+=-I$(FREERTOS)/include
INCLUDES+=-I$(FREERTOS)/portable/GCC/ARM_CM4F
INCLUDES+=-I$(CURDIR)/config


TSRC = $(CURDIR)/../src



BUILD_DIR = $(CURDIR)/build
BIN_DIR = $(CURDIR)/binary

# vpath is used so object files are written to the current directory instead
# of the same directory as their source files
vpath %.c $(CURDIR)/src $(CURDIR)/libraries/syscall $(CURDIR)/hardware $(FREERTOS) $(FREERTOS)/portable/MemMang $(FREERTOS)/portable/GCC/ARM_CM4F $(HAL)/Src

vpath %.s $(STARTUP)

vpath %.cpp $(CURDIR)/src $(TSRC)

# Project Source Files
APP_SRC+=startup_stm32f4xx.s
APP_SRC+=stm32f4xx_it.c
APP_SRC+=system_stm32f4xx.c
APP_SRC+=syscalls.c
APP_SRC+=main.cpp
APP_SRC+=hooks.cpp
APP_SRC+=Button.cpp
APP_SRC+=LED.cpp

# FreeRTOS Source Files
RTOS_SRC+=port.c
RTOS_SRC+=list.c
RTOS_SRC+=queue.c
RTOS_SRC+=tasks.c
RTOS_SRC+=event_groups.c
RTOS_SRC+=timers.c
RTOS_SRC+=heap_4.c

# Currenly used STM32F4 HAL module objects
HAL_SRC+=stm32f4xx_hal.c
HAL_SRC+=stm32f4xx_hal_gpio.c
HAL_SRC+=stm32f4xx_hal_tim.c
HAL_SRC+=stm32f4xx_hal_tim_ex.c
HAL_SRC+=stm32f4xx_hal_rcc.c
HAL_SRC+=stm32f4xx_hal_rcc_ex.c
HAL_SRC+=stm32f4xx_hal_dma.c
HAL_SRC+=stm32f4xx_hal_dma_ex.c
HAL_SRC+=stm32f4xx_hal_cortex.c
HAL_SRC+=stm32f4xx_hal_usart.c
HAL_SRC+=stm32f4xx_hal_uart.c

# Available HAL module objects
HAL_SRC_EXTRA+=stm32f4xx_hal_wwdg.c
HAL_SRC_EXTRA+=stm32f4xx_ll_fmc.c
HAL_SRC_EXTRA+=stm32f4xx_ll_fsmc.c
HAL_SRC_EXTRA+=stm32f4xx_ll_sdmmc.c
HAL_SRC_EXTRA+=stm32f4xx_ll_usb.c
HAL_SRC_EXTRA+=stm32f4xx_hal_hash.c
HAL_SRC_EXTRA+=stm32f4xx_hal_hash_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_hcd.c
HAL_SRC_EXTRA+=stm32f4xx_hal_i2c.c
HAL_SRC_EXTRA+=stm32f4xx_hal_i2c_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_i2s.c
HAL_SRC_EXTRA+=stm32f4xx_hal_i2s_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_irda.c
HAL_SRC_EXTRA+=stm32f4xx_hal_iwdg.c
HAL_SRC_EXTRA+=stm32f4xx_hal_lptim.c
HAL_SRC_EXTRA+=stm32f4xx_hal_ltdc.c
HAL_SRC_EXTRA+=stm32f4xx_hal_ltdc_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_nand.c
HAL_SRC_EXTRA+=stm32f4xx_hal_nor.c
HAL_SRC_EXTRA+=stm32f4xx_hal_pccard.c
HAL_SRC_EXTRA+=stm32f4xx_hal_pcd.c
HAL_SRC_EXTRA+=stm32f4xx_hal_pcd_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_pwr.c
HAL_SRC_EXTRA+=stm32f4xx_hal_pwr_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_qspi.c
HAL_SRC_EXTRA+=stm32f4xx_hal_rng.c
HAL_SRC_EXTRA+=stm32f4xx_hal_rtc.c
HAL_SRC_EXTRA+=stm32f4xx_hal_rtc_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_sai.c
HAL_SRC_EXTRA+=stm32f4xx_hal_sai_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_sdram.c
HAL_SRC_EXTRA+=stm32f4xx_hal_smartcard.c
HAL_SRC_EXTRA+=stm32f4xx_hal_spdifrx.c
HAL_SRC_EXTRA+=stm32f4xx_hal_spi.c
HAL_SRC_EXTRA+=stm32f4xx_hal_sram.c
HAL_SRC_EXTRA+=stm32f4xx_hal_adc.c
HAL_SRC_EXTRA+=stm32f4xx_hal_adc_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_can.c
HAL_SRC_EXTRA+=stm32f4xx_hal_cec.c
HAL_SRC_EXTRA+=stm32f4xx_hal_crc.c
HAL_SRC_EXTRA+=stm32f4xx_hal_cryp.c
HAL_SRC_EXTRA+=stm32f4xx_hal_cryp_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_dac.c
HAL_SRC_EXTRA+=stm32f4xx_hal_dac_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_dcmi.c
HAL_SRC_EXTRA+=stm32f4xx_hal_dcmi_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_dfsdm.c
HAL_SRC_EXTRA+=stm32f4xx_hal_dma2d.c
HAL_SRC_EXTRA+=stm32f4xx_hal_dsi.c
HAL_SRC_EXTRA+=stm32f4xx_hal_eth.c
HAL_SRC_EXTRA+=stm32f4xx_hal_flash.c
HAL_SRC_EXTRA+=stm32f4xx_hal_flash_ex.c
HAL_SRC_EXTRA+=stm32f4xx_hal_flash_ramfunc.c
HAL_SRC_EXTRA+=stm32f4xx_hal_fmpi2c.c
HAL_SRC_EXTRA+=stm32f4xx_hal_fmpi2c_ex.o

SRC=$(APP_SRC) $(RTOS_SRC) $(HAL_SRC)



OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(SRC))
OBJ := $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(OBJ))
OBJ := $(patsubst %.s,$(BUILD_DIR)/%.o,$(OBJ))

DEP = $(patsubst %.c,$(BUILD_DIR)/%.d,$(SRC))
DEP := $(patsubst %.cpp,$(BUILD_DIR)/%.d,$(DEP))
DEP := $(patsubst %.s,,$(DEP))


$(BUILD_DIR)/%.o: %.c
	@echo [CC] $(notdir $<)
	$(CC) $(CFLAGS) $(INCLUDES) $< -c -o $@

$(BUILD_DIR)/%.o: %.cpp
	@echo [C++] $(notdir $<)
	$(CXX) $(CPPFLAGS) $(INCLUDES) $< -c -o $@

$(BUILD_DIR)/%.o: %.s
	@echo [AS] $(notdir $<)
	$(CC) -c $(CPPFLAGS) $(INCLUDES) $< -o $@

$(BUILD_DIR)/%.dep: %.c
	$(CC) -M $(CFLAGS) $(INCLUDES) "$<" > "$@"

$(BUILD_DIR)/%.dep: %.cpp
	$(CPP) -M $(CPPFLAGS) $(INCLUDES) "$<" > "$@"

all: $(BIN_DIR)/$(PROJECT).elf

$(BIN_DIR)/$(PROJECT).elf: $(OBJ)
	@echo [LD] $(PROJECT).elf
	$(CC) -o $(BIN_DIR)/$(PROJECT).elf $(LDFLAGS) $(OBJ) $(LDLIBS)
	@echo [OBJCOPY] $(PROJECT).hex
	@$(OBJCOPY) -O ihex $(BIN_DIR)/$(PROJECT).elf $(BIN_DIR)/$(PROJECT).hex
	@$(SIZE) --format=berkeley $(BIN_DIR)/$(PROJECT).elf
	
#	@echo [OBJCOPY] $(PROJECT).bin
#	@$(OBJCOPY) -O binary $(BIN_DIR)/$(PROJECT).elf $(BIN_DIR)/$(PROJECT).bin


clean:
	@echo [RM] OBJ
	@rm -f $(OBJ) $(patsubst %.o,%.d,$(OBJ))
	@echo [RM] BIN
	@rm -f $(BIN_DIR)/$(PROJECT).elf
	@rm -f $(BIN_DIR)/$(PROJECT).hex
	@rm -f $(BIN_DIR)/$(PROJECT).bin
	@rm -f $(BIN_DIR)/$(PROJECT).map

# Flash final elf into device
flash: all
	${OPENOCD} -f board/stm32f4discovery-v2.1.cfg -c "program $(BIN_DIR)/$(PROJECT).elf verify reset exit"

flash1: all
	${OPENOCD} -f board/stm32f4discovery.cfg -c "program $(BIN_DIR)/$(PROJECT).elf verify reset exit"

# Debug
debug: all
	$(GDB) $(BIN_DIR)/$(PROJECT).elf -ex "PROJECT remote | ${OPENOCD} -f board/stm32f4discovery-v2.1.cfg --pipe" -ex load

debug1: all
	$(GDB) $(BIN_DIR)/$(PROJECT).elf -ex "PROJECT remote | $(OPENOCD} -f board/stm32f4discovery.cfg --pipe" -ex load


-include $(DEP)

.PHONY: all flash clean debug
