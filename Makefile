CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
AS=$(CROSS_COMPILE)as
OBJCOPY=$(CROSS_COMPILE)objcopy
BUILD_DIR=build
TARGETS=mirb.bin
MRUBY_ROOT=../mruby_p
MRUBY_TOOLS=$(MRUBY_ROOT)/tools
MRUBY_BUILD=$(MRUBY_ROOT)/build
MRUBY_DEFINES=-DMRB_HEAP_PAGE_SIZE=256 \
              -DPOOL_PAGE_SIZE=1000 \
              -DMRB_STR_BUF_MIN_SIZE=32 \
              -DMRB_PARSER_BUF_SIZE=256
MRUBY_CROSS_BUILD_NAME=stm32f407
STM32F4_CFLAGS=-D_STM32F407xG -DSTM3x_ -D_STM32x_ \
               -DHSE_VALUE=8000000 -DUSE_STDPERIPH_DRIVER -Os \
               -MD -mthumb -mcpu=cortex-m3 -nostdlib -mfloat-abi=softfp -mfpu=fpv4-sp-d16 \
               -fsigned-char -fno-inline -ffunction-sections -mlittle-endian \
               -Ihardware/chips/stm32f4xx \
               -Ihardware/chips/stm32f4xx/stdperiph/include \
               -Ihardware/boards/stm32f4_discovery
STM32F4_SOURCE=$(wildcard hardware/boards/stm32f4_discovery/*.c) \
               $(wildcard hardware/chips/stm32f4xx/*.c) \
               $(wildcard hardware/chips/stm32f4xx/*.s) \
               $(wildcard hardware/chips/stm32f4xx/stdperiph/src/*.c)
STM32F4_LDFLAGS=-mcpu=cortex-m3 -mthumb -Os \
                -T "hardware/chips/stm32f4xx/stm32f4xx.ld" -Wl,-Map,$(BUILD_DIR)/map -Wl,-static \
                -Wl,--cref -Wl,--check-sections -Wl,--gc-sections -Wl,--entry=Reset_Handler \
                -Wl,--unresolved-symbols=report-all
CFLAGS+=-I$(MRUBY_ROOT)/include -I$(MRUBY_ROOT)/src -Os $(MRUBY_DEFINES)
CFLAGS+=$(STM32F4_CFLAGS)
LDFLAGS+=$(STM32F4_LDFLAGS)
LDFLAGS+=-L$(MRUBY_BUILD)/$(MRUBY_CROSS_BUILD_NAME)/lib
LDLIBS+=-lm -lgcc -lmruby
OBJS=$(addprefix $(BUILD_DIR)/,$(notdir $(patsubst %.s,%.o,$(patsubst %.c,%.o,$(STM32F4_SOURCE)))))

.PHONY:all
all: $(BUILD_DIR) $(patsubst %,$(BUILD_DIR)/%,$(TARGETS))

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(OBJCOPY) -Obinary $< $@

$(BUILD_DIR)/%.elf: $(BUILD_DIR)/mirb.o $(OBJS)
	$(CC) $(LDFLAGS) $^ -o $@ $(LDLIBS)

$(BUILD_DIR)/%.o:$(MRUBY_TOOLS)/mirb/%.c
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o:$(MRUBY_TOOLS)/mrbc/%.c
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o:$(MRUBY_TOOLS)/mruby/%.c
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o:hardware/chips/stm32f4xx/%.c
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o:hardware/chips/stm32f4xx/%.s
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o:hardware/chips/stm32f4xx/stdperiph/src/%.c
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o:hardware/boards/stm32f4_discovery/%.c
	$(CC) -c $(CFLAGS) $< -o $@

.PHONY:clean
clean:
	rm -rf $(BUILD_DIR)
