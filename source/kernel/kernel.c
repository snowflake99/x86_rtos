#include <driver/tty.h>

void kmain()
{
	unsigned int i = 0;
	unsigned int j = 0;

	terminal_initialize();
	terminal_writestring("Hello, kernel World!\n");
   terminal_writestring("kernel World!\n");
   terminal_writestring("World!\n");
   terminal_writestring("this is fun");

   //cls();

	for (j = 0; j < 6; j++)
	for (i = 0; i < 0xFFFFFFFF; i++);
		//terminal_writestring ("-");

	//cls ();			
}
