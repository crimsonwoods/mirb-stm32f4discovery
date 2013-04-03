#include <stdint.h>
#include <reent.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "stm32f4xx.h"
#include "stm32f4xx_usart.h"
#include "board_setup.h"

#define PUTC(x) stm32f4xx_discovery_putc((USART_TypeDef *)get_stdio_device_addr(), (x))
#define PUTS(x) stm32f4xx_discovery_puts((USART_TypeDef *)get_stdio_device_addr(), (x))
#define PUTP(x) put_ptr((USART_TypeDef *)get_stdio_device_addr(), (x))

void stm32f4xx_discovery_putc(USART_TypeDef *usart, uint8_t c)
{
	while (SET != USART_GetFlagStatus(usart, USART_FLAG_TXE)) {
		asm volatile ("nop");
	}
	USART_SendData(usart, c);
	while (SET != USART_GetFlagStatus(usart, USART_FLAG_TC)) {
		asm volatile ("nop");
	}
}

void stm32f4xx_discovery_puts(USART_TypeDef *usart, char const *s) {
	char c;
	while ('\0' != (c = *s++)) {
		stm32f4xx_discovery_putc(usart, c);
	}
}

char hex_to_c(int hex) {
	return hex < 0xa ? '0' + hex : 'a' + (hex - 0xa);
}

void put_ptr(USART_TypeDef *usart, void const *ptr) {
	stm32f4xx_discovery_putc(usart, '0');
	stm32f4xx_discovery_putc(usart, 'x');
	stm32f4xx_discovery_putc(usart, hex_to_c(((uintptr_t)ptr & 0xf0000000) >> 28));
	stm32f4xx_discovery_putc(usart, hex_to_c(((uintptr_t)ptr & 0x0f000000) >> 24));
	stm32f4xx_discovery_putc(usart, hex_to_c(((uintptr_t)ptr & 0x00f00000) >> 20));
	stm32f4xx_discovery_putc(usart, hex_to_c(((uintptr_t)ptr & 0x000f0000) >> 16));
	stm32f4xx_discovery_putc(usart, hex_to_c(((uintptr_t)ptr & 0x0000f000) >> 12));
	stm32f4xx_discovery_putc(usart, hex_to_c(((uintptr_t)ptr & 0x00000f00) >>  8));
	stm32f4xx_discovery_putc(usart, hex_to_c(((uintptr_t)ptr & 0x000000f0) >>  4));
	stm32f4xx_discovery_putc(usart, hex_to_c(((uintptr_t)ptr & 0x0000000f) >>  0));
}

int stm32f4xx_discovery_getc(USART_TypeDef *usart)
{
	while (SET != USART_GetFlagStatus(usart, USART_FLAG_RXNE)) {
		asm volatile ("nop");
	}
	return USART_ReceiveData(usart) & 0xff;
}

/*
 * system calls for "STM32F4 Discovery" board.
 */

void *_sbrk(ptrdiff_t increment)
{
	extern char _end;
	static char *heap_end = 0;
	char *prev_heap_end;
	char register *stack_ptr asm("sp");

	if (heap_end == 0) {
		heap_end = &_end;
	}
	prev_heap_end = heap_end;
	if ((heap_end + increment) > stack_ptr) {
		PUTS("sp=");
		PUTP(stack_ptr);
		PUTS("\n");
		PUTS("heap=");
		PUTP(heap_end);
		PUTS("\n");
		PUTS("sbrk: no more heap\n");
		errno = ENOMEM;
		return (void*)-1;
	}
	heap_end += increment;
	return prev_heap_end;
}

void *_sbrk_r(struct _reent *ptr, ptrdiff_t increment)
{
	return _sbrk(increment);
}

int _fstat(int fd, struct stat *st)
{
	st->st_mode = S_IFCHR;
	return 0;
}

int _kill(pid_t pid, int signum)
{
	errno = EINVAL;
	return -1;
}

pid_t _getpid()
{
	return 1;
}

ssize_t _write(int fd, void const *data, size_t size)
{
	USART_TypeDef *usart = (USART_TypeDef*)get_stdio_device_addr();
	size_t i;
	if ((fd != 1) && (fd != 2)) {
		errno = EINVAL;
		return -1;
	}
	for (i = 0; i < size; ++i) {
		stm32f4xx_discovery_putc(usart, ((uint8_t *)data)[i]);
	}
	return (ssize_t)size;
}

ssize_t _read(int fd, void *data, size_t size)
{
	USART_TypeDef *usart = (USART_TypeDef*)get_stdio_device_addr();
	size_t i;
	int c;
	if (fd != 0) {
		errno = EINVAL;
		return -1;
	}
	for (i = 0; i < size; ++i) {
		c = stm32f4xx_discovery_getc(usart);
		if (c != '\r') {
			PUTC((char)c);
		}
		((uint8_t *)data)[i] = (uint8_t)(c & 0xff);
		if ((c == '\r') || (c == '\n')) {
			((uint8_t *)data)[i] = '\n';
			return i + 1;
		}
	}
	return i;
}

int _close(int fd)
{
	return 0;
}

int _isatty(int fd)
{
	return ((fd == 0) || (fd == 1) || (fd == 2)) ? 1 : 0;
}

off_t _lseek(int fd, off_t offset, int whence)
{
	return 0;
}

