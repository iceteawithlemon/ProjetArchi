OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(_start)
SECTIONS
{
  _begin = 0x00100000;
  . = _begin + SIZEOF_HEADERS;
  .text : { *(.text) }
  .data = .;
  .data : { *(.data) }
  _edata = .;
  . = ALIGN(4096);
  __bss_start = .;
  .bss : { *(.bss) }
  __bss_end = .;
  _end = .;
}
