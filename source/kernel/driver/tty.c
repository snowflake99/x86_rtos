#include <types.h>
#include <string.h>

static const uint8_t COLOR_BLACK = 0;
static const uint8_t COLOR_BLUE = 1;
static const uint8_t COLOR_GREEN = 2;
static const uint8_t COLOR_CYAN = 3;
static const uint8_t COLOR_RED = 4;
static const uint8_t COLOR_MAGENTA = 5;
static const uint8_t COLOR_BROWN = 6;
static const uint8_t COLOR_LIGHT_GREY = 7;
static const uint8_t COLOR_DARK_GREY = 8;
static const uint8_t COLOR_LIGHT_BLUE = 9;
static const uint8_t COLOR_LIGHT_GREEN = 10;
static const uint8_t COLOR_LIGHT_CYAN = 11;
static const uint8_t COLOR_LIGHT_RED = 12;
static const uint8_t COLOR_LIGHT_MAGENTA = 13;
static const uint8_t COLOR_LIGHT_BROWN = 14;
static const uint8_t COLOR_WHITE = 15;

uint8_t make_color(uint8_t fg, uint8_t bg)
{
	return fg | bg << 4;
}

uint16_t make_vgaentry(char c, uint8_t color)
{
	uint16_t c16 = c;
	uint16_t color16 = color;
	return c16 | color16 << 8;
}

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 24;

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer;

void terminal_initialize()
{
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = make_color(COLOR_LIGHT_GREY, COLOR_BLACK);
	terminal_buffer = (uint16_t*) 0xB8000;
	for ( size_t y = 0; y < VGA_HEIGHT; y++ )
		for ( size_t x = 0; x < VGA_WIDTH; x++ )
		{
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = make_vgaentry(' ', terminal_color);
		}
}

void terminal_setcolor(uint8_t color)
{
	terminal_color = color;
}

void terminal_putentryat(char c, uint8_t color, size_t x, size_t y)
{
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = make_vgaentry(c, color);
}

/* We can use this for reading from the I/O ports to get data from
*  devices such as the keyboard. We are using what is called 'inline
*  assembly' in these routines to actually do the work. [XXX I still
*  have to add devices to the tutorial] */
unsigned char inportb (unsigned short _port)
{
    unsigned char rv;
    __asm__ __volatile__ ("inb %1, %0" : "=a" (rv) : "dN" (_port));
    return rv;
}

/* We can use this to write to I/O ports to send bytes to
*  devices. Again, we use some inline assembly for the stuff that
*  simply cannot be done in C */
void outportb (unsigned short _port, unsigned char _data)
{
    __asm__ __volatile__ ("outb %1, %0" : : "dN" (_port), "a" (_data));
}

/* Updates the hardware cursor: the little blinking line
*  on the screen under the last character pressed! */
void move_csr(void)
{
    unsigned temp;

    /* The equation for finding the index in a linear
    *  chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    temp = terminal_row * VGA_WIDTH + terminal_column;

    /* This sends a command to indicies 14 and 15 in the
    *  CRT Control Register of the VGA controller. These
    *  are the high and low bytes of the index that show
    *  where the hardware cursor is to be 'blinking'. To
    *  learn more, you should look up some VGA specific
    *  programming documents. A great start to graphics:
    *  http://www.brackeen.com/home/vga */
    outportb(0x3D4, 14);
    outportb(0x3D5, temp >> 8);
    outportb(0x3D4, 15);
    outportb(0x3D5, temp);
}


void terminal_putchar(char c)
{
   if (c == '\n') {
      terminal_column = 0;
      terminal_row++;
   } else {
	   terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
	   if ( ++terminal_column == VGA_WIDTH )
	   {
		   terminal_column = 0;
		   if ( ++terminal_row == VGA_HEIGHT )
		   {
			   terminal_row = 0;
		   }
	   }
   }

   move_csr();
}

/* Clears the screen */
void cls()
{
    unsigned short blank;
    unsigned int i;
    unsigned short attrb;

    attrb = ((COLOR_LIGHT_GREY) | (0x0000 << 4));

    /* Again, we need the 'short' that will be used to
    *  represent a space with color */
    blank = (0x20 | (attrb << 8));

    /* Sets the entire screen to spaces in our current
    *  color */
    for(i = 0; i < VGA_HEIGHT * VGA_WIDTH; i++)
        //memset ((void*)(0xB8000 + (i * VGA_WIDTH)), blank, VGA_WIDTH);
        terminal_buffer[i] = blank;

    /* Update out virtual cursor, and then move the
    *  hardware cursor */
    terminal_column = 0;
    terminal_row = 0;
    move_csr();
}

void terminal_writestring(const char* data)
{
	size_t datalen = strlen(data);
	for ( size_t i = 0; i < datalen; i++ )
		terminal_putchar(data[i]);
}
