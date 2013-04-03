#ifndef BOARD_SETUP_STM32F4_DISCOVERY_H_
#define BOARD_SETUP_STM32F4_DISCOVERY_H_

/*
 * setup the configuration that depends on the target board (STM32F4 Discovery).
 */
extern void board_setup(void);

/*
 * get the base address of the device that is used as standard in/out.
 */
extern void *get_stdio_device_addr(void);

#endif /* end of BOARD_SETUP_STM32F4_DISCOVERY_H_ */

