# Declare constants used for creating a multiboot header.
.set ALIGN,    1<<0             # align loaded modules on page boundaries
.set MEMINFO,  1<<1             # provide memory map
.set FLAGS,    ALIGN | MEMINFO  # this is the Multiboot 'flag' field
.set MAGIC,    0x1BADB002       # 'magic number' lets bootloader find the header
.set CHECKSUM, -(MAGIC + FLAGS) # checksum of above, to prove we are multiboot

# Declare a header as in the Multiboot Standard.
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# Allocate room for a small temporary stack as a global variable called stack.
.section .bootstrap_stack
stack_bottom:
.skip 16384 # 16 KiB
stack_top:

# The linker script specifies _start as the entry point to the kernel and the
# bootloader will jump to this position once the kernel has been loaded.
.section .text
.global _start
_start:
	# Hello, World! This processor now belongs to us and we have complete
	# power of it and do anything we want - but there is nothing but us - if we
	# want to do anything, we'll have to do the whole job ourselves. Assembly
	# isn't the best language to write a kernel in, so we'll want to set up
	# the environment such that we can host a high-level language such as C.

	# First, we'll set the stack pointer to the top of our stack declared above.
	movl $stack_top, %esp

	# Now that we have a stack, we can provide the minimal environment needed to
	# run C code. Note that floating point instructions and other CPU features
	# currently are disabled. Enable them here once you add support.

	# Now that the initial bootstrap environment is set up, call the kernel's
	# main function using the C calling convention.
	call kmain

	# The kernel is done executing, so let's put the computer in an infinite
	# loop. The halt instruction ('hlt') stops the CPU until an interrupt
	# happens, and the clear interrupt ('cli') instruction disables interrupts.
	# The computer remains running - if you want to shut it down, you'll need a
	# driver for the CPU power interface.
	cli
hang:
	hlt
	jmp hang
