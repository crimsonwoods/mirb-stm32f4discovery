ENTRY(Reset_Handler)

_estack = 0x2001c000;

_Minimum_Heap_Size  = 0x1a000;
_Minimum_Stack_Size = 0x00400;

MEMORY
{
	FLASH     (rx)   : ORIGIN = 0x08000000, LENGTH = 1024K
	RAM       (rwx)  : ORIGIN = 0x20000000, LENGTH =  112K
	SRAM      (rwx)  : ORIGIN = 0x10000000, LENGTH =   64K
	CONFIG    (r)    : ORIGIN = 0x1FFFC000, LENGTH = 0x10
	FLASHB1   (rx)   : ORIGIN = 0x00000000, LENGTH =    0
	EXTMEMB0  (rx)   : ORIGIN = 0x00000000, LENGTH =    0
	EXTMEMB1  (rx)   : ORIGIN = 0x00000000, LENGTH =    0
	EXTMEMB2  (rx)   : ORIGIN = 0x00000000, LENGTH =    0
	EXTMEMB3  (rx)   : ORIGIN = 0x00000000, LENGTH =    0
}

SECTIONS
{
	.vector :
	{
		. = ALIGN(4);
		KEEP(*(.isr_vector))
		. = ALIGN(4);
	} >FLASH

	.text :
	{
		. = ALIGN(4);
		*(.text)
		*(.text*)
		*(.rodata)
		*(.rodata*)
		*(.glue_7)
		*(.glue_7t)
		*(.eh_frame)

		KEEP (*(.init))
		KEEP (*(.fini))

		. = ALIGN(4);
		_etext = .;
		_exit = .;
	} >FLASH

	.ARM.extab :
	{
		*(.ARM.extab* .gnu.linkonce.armextab.*)
	} >FLASH

	.ARM :
	{
		__exidx_start = .;
		*(.ARM.exidx*)
		__exidx_end = .;
	} >FLASH

	.preinit_array :
	{
		PROVIDE_HIDDEN (__preinit_array_start = .);
		KEEP (*(.preinit_array*))
		PROVIDE_HIDDEN (__preinit_array_end = .);
	} >FLASH

	.init_array :
	{
		PROVIDE_HIDDEN (__init_array_start = .);
		KEEP (*(SORT(.init_array.*)))
		KEEP (*(.init_array*))
		PROVIDE_HIDDEN (__init_array_end = .);
	} >FLASH

	.fini_array :
	{
		PROVIDE_HIDDEN (__fini_array_start = .);
		KEEP (*(.fini_array*))
		KEEP (*(SORT(.fini_array.*)))
		PROVIDE_HIDDEN (__fini_array_end = .);
	} >FLASH

	_sidata = .;

	.config :
	{
		. = ALIGN(4);
		KEEP (*(.config))
		. = ALIGN(4);
	} >CONFIG

	.optionbytes :
	{
		. = ALIGN(4);
		KEEP (*(.optionbytes))
		. = ALIGN(4);
	} >CONFIG

	.data : AT ( _sidata )
	{
		. = ALIGN(4);
		_sdata = .;
		*(.data)
		*(.data*)
		*(.RAMtext)

		. = ALIGN(4);
		_edata = .;
	} > RAM

	_eidata = _sidata + (_edata - _sdata);
	_lastdataromaddress = ORIGIN(FLASH) + LENGTH(FLASH);
	__toobig__ = ( _eidata > _lastdataromaddress) ? 1 : 0;
	__toobigmsg__ = ( __toobig__ ) ? "FLASH is full." : 0;

	.bss :
	{
		. = ALIGN(4);
		_sbss = .;
		__bss_start__ = _sbss;
		*(.bss)
		*(.bss*)
		*(COMMON)

		. = ALIGN(4);
		_ebss = .;
		__bss_end__ = _ebss;
	} >RAM

	PROVIDE (end  = _ebss);
	PROVIDE (_end = _ebss);

	.heap :
	{
		. = ALIGN(4);
		*(.heap)
		*(.heap*)
		*(.HEAP)
		. = . + _Minimum_Heap_Size;
		. = ALIGN(4);
	} >RAM

	.stack :
	{
		. = ALIGN(4);
		*(.stack)
		*(.stack*)
		*(.STACK)
		. = . + _Minimum_Stack_Size;
		. = ALIGN(4);
	} >RAM

	.eb0text :
	{
		*(.eb0text)
		*(.eb0text*)
		*(.eb0rodata)
		*(.eb0rodata*)
	} >EXTMEMB0

	/DISCARD/ :
	{
		libc.a ( * )
		libm.a ( * )
		libgcc.a ( * )
	}

	.ARM.attributes 0 :
	{
		*(.ARM.attributes)
	}
}
