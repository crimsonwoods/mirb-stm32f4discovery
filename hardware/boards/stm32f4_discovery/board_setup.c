#include "board_setup.h"
#include "stm32f4xx.h"
#include "stm32f4xx_conf.h"
#include "stm32f4xx_rcc.h"
#include "stm32f4xx_gpio.h"
#include "stm32f4xx_usart.h"

#define USART_BAUDRATE 115200

extern void stm32f4xx_discovery_putc(USART_TypeDef *usart, uint8_t c);

static void usart_init(USART_TypeDef *usart, uint32_t baud);

void board_setup()
{
	GPIO_InitTypeDef usart_gpio_init = {
		GPIO_Pin_2 | GPIO_Pin_3,
		GPIO_Mode_AF,
		GPIO_Speed_100MHz,
		GPIO_OType_PP,
		GPIO_PuPd_UP,
	};
	GPIO_InitTypeDef led3_init = {
		GPIO_Pin_13,
		GPIO_Mode_OUT,
		GPIO_Speed_50MHz,
		GPIO_OType_PP,
		GPIO_PuPd_UP,
	};
	USART_InitTypeDef usart_init = {
		USART_BAUDRATE,
		USART_WordLength_8b,
		USART_StopBits_1,
		USART_Parity_No,
		USART_Mode_Rx | USART_Mode_Tx,
		USART_HardwareFlowControl_None,
	};
	USART_TypeDef *usart = (USART_TypeDef*)get_stdio_device_addr();

	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA, ENABLE);
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_USART2, ENABLE);

	GPIO_Init(GPIOA, &usart_gpio_init);
	GPIO_Init(GPIOD, &led3_init);

	GPIO_PinAFConfig(GPIOA, GPIO_PinSource2, GPIO_AF_USART2);
	GPIO_PinAFConfig(GPIOA, GPIO_PinSource3, GPIO_AF_USART2);

	USART_Init(usart, &usart_init);
	USART_Cmd(usart, ENABLE);

	stm32f4xx_discovery_putc(usart, '#');
	stm32f4xx_discovery_putc(usart, 'm');
	stm32f4xx_discovery_putc(usart, 'r');
	stm32f4xx_discovery_putc(usart, 'b');
	stm32f4xx_discovery_putc(usart, '\n');

	GPIO_WriteBit(GPIOD, GPIO_Pin_13, Bit_SET);
}

void *get_stdio_device_addr(void)
{
	return (void*)USART2;
}

