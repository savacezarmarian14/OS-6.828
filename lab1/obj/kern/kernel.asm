
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5a 00 00 00       	call   f0100098 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	53                   	push   %ebx
f0100048:	83 ec 0c             	sub    $0xc,%esp
f010004b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004e:	53                   	push   %ebx
f010004f:	68 a0 19 10 f0       	push   $0xf01019a0
f0100054:	e8 49 09 00 00       	call   f01009a2 <cprintf>
	if (x > 0)
f0100059:	83 c4 10             	add    $0x10,%esp
f010005c:	85 db                	test   %ebx,%ebx
f010005e:	7e 25                	jle    f0100085 <test_backtrace+0x45>
		test_backtrace(x-1);
f0100060:	83 ec 0c             	sub    $0xc,%esp
f0100063:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100066:	50                   	push   %eax
f0100067:	e8 d4 ff ff ff       	call   f0100040 <test_backtrace>
f010006c:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f010006f:	83 ec 08             	sub    $0x8,%esp
f0100072:	53                   	push   %ebx
f0100073:	68 bc 19 10 f0       	push   $0xf01019bc
f0100078:	e8 25 09 00 00       	call   f01009a2 <cprintf>
}
f010007d:	83 c4 10             	add    $0x10,%esp
f0100080:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100083:	c9                   	leave  
f0100084:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100085:	83 ec 04             	sub    $0x4,%esp
f0100088:	6a 00                	push   $0x0
f010008a:	6a 00                	push   $0x0
f010008c:	6a 00                	push   $0x0
f010008e:	e8 ff 06 00 00       	call   f0100792 <mon_backtrace>
f0100093:	83 c4 10             	add    $0x10,%esp
f0100096:	eb d7                	jmp    f010006f <test_backtrace+0x2f>

f0100098 <i386_init>:

void
i386_init(void)
{
f0100098:	f3 0f 1e fb          	endbr32 
f010009c:	55                   	push   %ebp
f010009d:	89 e5                	mov    %esp,%ebp
f010009f:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a2:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f01000a7:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000ac:	50                   	push   %eax
f01000ad:	6a 00                	push   $0x0
f01000af:	68 00 23 11 f0       	push   $0xf0112300
f01000b4:	e8 6c 14 00 00       	call   f0101525 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b9:	e8 af 04 00 00       	call   f010056d <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000be:	83 c4 08             	add    $0x8,%esp
f01000c1:	68 ac 1a 00 00       	push   $0x1aac
f01000c6:	68 d7 19 10 f0       	push   $0xf01019d7
f01000cb:	e8 d2 08 00 00       	call   f01009a2 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000d0:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000d7:	e8 64 ff ff ff       	call   f0100040 <test_backtrace>
f01000dc:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000df:	83 ec 0c             	sub    $0xc,%esp
f01000e2:	6a 00                	push   $0x0
f01000e4:	e8 2e 07 00 00       	call   f0100817 <monitor>
f01000e9:	83 c4 10             	add    $0x10,%esp
f01000ec:	eb f1                	jmp    f01000df <i386_init+0x47>

f01000ee <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000ee:	f3 0f 1e fb          	endbr32 
f01000f2:	55                   	push   %ebp
f01000f3:	89 e5                	mov    %esp,%ebp
f01000f5:	56                   	push   %esi
f01000f6:	53                   	push   %ebx
f01000f7:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000fa:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f0100101:	74 0f                	je     f0100112 <_panic+0x24>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100103:	83 ec 0c             	sub    $0xc,%esp
f0100106:	6a 00                	push   $0x0
f0100108:	e8 0a 07 00 00       	call   f0100817 <monitor>
f010010d:	83 c4 10             	add    $0x10,%esp
f0100110:	eb f1                	jmp    f0100103 <_panic+0x15>
	panicstr = fmt;
f0100112:	89 35 40 29 11 f0    	mov    %esi,0xf0112940
	asm volatile("cli; cld");
f0100118:	fa                   	cli    
f0100119:	fc                   	cld    
	va_start(ap, fmt);
f010011a:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f010011d:	83 ec 04             	sub    $0x4,%esp
f0100120:	ff 75 0c             	pushl  0xc(%ebp)
f0100123:	ff 75 08             	pushl  0x8(%ebp)
f0100126:	68 f2 19 10 f0       	push   $0xf01019f2
f010012b:	e8 72 08 00 00       	call   f01009a2 <cprintf>
	vcprintf(fmt, ap);
f0100130:	83 c4 08             	add    $0x8,%esp
f0100133:	53                   	push   %ebx
f0100134:	56                   	push   %esi
f0100135:	e8 3e 08 00 00       	call   f0100978 <vcprintf>
	cprintf("\n");
f010013a:	c7 04 24 2e 1a 10 f0 	movl   $0xf0101a2e,(%esp)
f0100141:	e8 5c 08 00 00       	call   f01009a2 <cprintf>
f0100146:	83 c4 10             	add    $0x10,%esp
f0100149:	eb b8                	jmp    f0100103 <_panic+0x15>

f010014b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010014b:	f3 0f 1e fb          	endbr32 
f010014f:	55                   	push   %ebp
f0100150:	89 e5                	mov    %esp,%ebp
f0100152:	53                   	push   %ebx
f0100153:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100156:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100159:	ff 75 0c             	pushl  0xc(%ebp)
f010015c:	ff 75 08             	pushl  0x8(%ebp)
f010015f:	68 0a 1a 10 f0       	push   $0xf0101a0a
f0100164:	e8 39 08 00 00       	call   f01009a2 <cprintf>
	vcprintf(fmt, ap);
f0100169:	83 c4 08             	add    $0x8,%esp
f010016c:	53                   	push   %ebx
f010016d:	ff 75 10             	pushl  0x10(%ebp)
f0100170:	e8 03 08 00 00       	call   f0100978 <vcprintf>
	cprintf("\n");
f0100175:	c7 04 24 2e 1a 10 f0 	movl   $0xf0101a2e,(%esp)
f010017c:	e8 21 08 00 00       	call   f01009a2 <cprintf>
	va_end(ap);
}
f0100181:	83 c4 10             	add    $0x10,%esp
f0100184:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100187:	c9                   	leave  
f0100188:	c3                   	ret    

f0100189 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100189:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010018d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100192:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100193:	a8 01                	test   $0x1,%al
f0100195:	74 0a                	je     f01001a1 <serial_proc_data+0x18>
f0100197:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010019c:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010019d:	0f b6 c0             	movzbl %al,%eax
f01001a0:	c3                   	ret    
		return -1;
f01001a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001a6:	c3                   	ret    

f01001a7 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001a7:	55                   	push   %ebp
f01001a8:	89 e5                	mov    %esp,%ebp
f01001aa:	53                   	push   %ebx
f01001ab:	83 ec 04             	sub    $0x4,%esp
f01001ae:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001b0:	ff d3                	call   *%ebx
f01001b2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001b5:	74 29                	je     f01001e0 <cons_intr+0x39>
		if (c == 0)
f01001b7:	85 c0                	test   %eax,%eax
f01001b9:	74 f5                	je     f01001b0 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01001bb:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001c1:	8d 51 01             	lea    0x1(%ecx),%edx
f01001c4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ca:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01001d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01001d5:	0f 44 d0             	cmove  %eax,%edx
f01001d8:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001de:	eb d0                	jmp    f01001b0 <cons_intr+0x9>
	}
}
f01001e0:	83 c4 04             	add    $0x4,%esp
f01001e3:	5b                   	pop    %ebx
f01001e4:	5d                   	pop    %ebp
f01001e5:	c3                   	ret    

f01001e6 <kbd_proc_data>:
{
f01001e6:	f3 0f 1e fb          	endbr32 
f01001ea:	55                   	push   %ebp
f01001eb:	89 e5                	mov    %esp,%ebp
f01001ed:	53                   	push   %ebx
f01001ee:	83 ec 04             	sub    $0x4,%esp
f01001f1:	ba 64 00 00 00       	mov    $0x64,%edx
f01001f6:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001f7:	a8 01                	test   $0x1,%al
f01001f9:	0f 84 f2 00 00 00    	je     f01002f1 <kbd_proc_data+0x10b>
	if (stat & KBS_TERR)
f01001ff:	a8 20                	test   $0x20,%al
f0100201:	0f 85 f1 00 00 00    	jne    f01002f8 <kbd_proc_data+0x112>
f0100207:	ba 60 00 00 00       	mov    $0x60,%edx
f010020c:	ec                   	in     (%dx),%al
f010020d:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010020f:	3c e0                	cmp    $0xe0,%al
f0100211:	74 61                	je     f0100274 <kbd_proc_data+0x8e>
	} else if (data & 0x80) {
f0100213:	84 c0                	test   %al,%al
f0100215:	78 70                	js     f0100287 <kbd_proc_data+0xa1>
	} else if (shift & E0ESC) {
f0100217:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010021d:	f6 c1 40             	test   $0x40,%cl
f0100220:	74 0e                	je     f0100230 <kbd_proc_data+0x4a>
		data |= 0x80;
f0100222:	83 c8 80             	or     $0xffffff80,%eax
f0100225:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100227:	83 e1 bf             	and    $0xffffffbf,%ecx
f010022a:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	shift |= shiftcode[data];
f0100230:	0f b6 d2             	movzbl %dl,%edx
f0100233:	0f b6 82 80 1b 10 f0 	movzbl -0xfefe480(%edx),%eax
f010023a:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f0100240:	0f b6 8a 80 1a 10 f0 	movzbl -0xfefe580(%edx),%ecx
f0100247:	31 c8                	xor    %ecx,%eax
f0100249:	a3 00 23 11 f0       	mov    %eax,0xf0112300
	c = charcode[shift & (CTL | SHIFT)][data];
f010024e:	89 c1                	mov    %eax,%ecx
f0100250:	83 e1 03             	and    $0x3,%ecx
f0100253:	8b 0c 8d 60 1a 10 f0 	mov    -0xfefe5a0(,%ecx,4),%ecx
f010025a:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010025e:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100261:	a8 08                	test   $0x8,%al
f0100263:	74 61                	je     f01002c6 <kbd_proc_data+0xe0>
		if ('a' <= c && c <= 'z')
f0100265:	89 da                	mov    %ebx,%edx
f0100267:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010026a:	83 f9 19             	cmp    $0x19,%ecx
f010026d:	77 4b                	ja     f01002ba <kbd_proc_data+0xd4>
			c += 'A' - 'a';
f010026f:	83 eb 20             	sub    $0x20,%ebx
f0100272:	eb 0c                	jmp    f0100280 <kbd_proc_data+0x9a>
		shift |= E0ESC;
f0100274:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f010027b:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100280:	89 d8                	mov    %ebx,%eax
f0100282:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100285:	c9                   	leave  
f0100286:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100287:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010028d:	89 cb                	mov    %ecx,%ebx
f010028f:	83 e3 40             	and    $0x40,%ebx
f0100292:	83 e0 7f             	and    $0x7f,%eax
f0100295:	85 db                	test   %ebx,%ebx
f0100297:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010029a:	0f b6 d2             	movzbl %dl,%edx
f010029d:	0f b6 82 80 1b 10 f0 	movzbl -0xfefe480(%edx),%eax
f01002a4:	83 c8 40             	or     $0x40,%eax
f01002a7:	0f b6 c0             	movzbl %al,%eax
f01002aa:	f7 d0                	not    %eax
f01002ac:	21 c8                	and    %ecx,%eax
f01002ae:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f01002b3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002b8:	eb c6                	jmp    f0100280 <kbd_proc_data+0x9a>
		else if ('A' <= c && c <= 'Z')
f01002ba:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002bd:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002c0:	83 fa 1a             	cmp    $0x1a,%edx
f01002c3:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c6:	f7 d0                	not    %eax
f01002c8:	a8 06                	test   $0x6,%al
f01002ca:	75 b4                	jne    f0100280 <kbd_proc_data+0x9a>
f01002cc:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002d2:	75 ac                	jne    f0100280 <kbd_proc_data+0x9a>
		cprintf("Rebooting!\n");
f01002d4:	83 ec 0c             	sub    $0xc,%esp
f01002d7:	68 24 1a 10 f0       	push   $0xf0101a24
f01002dc:	e8 c1 06 00 00       	call   f01009a2 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e1:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e6:	ba 92 00 00 00       	mov    $0x92,%edx
f01002eb:	ee                   	out    %al,(%dx)
}
f01002ec:	83 c4 10             	add    $0x10,%esp
f01002ef:	eb 8f                	jmp    f0100280 <kbd_proc_data+0x9a>
		return -1;
f01002f1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002f6:	eb 88                	jmp    f0100280 <kbd_proc_data+0x9a>
		return -1;
f01002f8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002fd:	eb 81                	jmp    f0100280 <kbd_proc_data+0x9a>

f01002ff <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002ff:	55                   	push   %ebp
f0100300:	89 e5                	mov    %esp,%ebp
f0100302:	57                   	push   %edi
f0100303:	56                   	push   %esi
f0100304:	53                   	push   %ebx
f0100305:	83 ec 1c             	sub    $0x1c,%esp
f0100308:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f010030a:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010030f:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100314:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100319:	89 fa                	mov    %edi,%edx
f010031b:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031c:	a8 20                	test   $0x20,%al
f010031e:	75 13                	jne    f0100333 <cons_putc+0x34>
f0100320:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100326:	7f 0b                	jg     f0100333 <cons_putc+0x34>
f0100328:	89 da                	mov    %ebx,%edx
f010032a:	ec                   	in     (%dx),%al
f010032b:	ec                   	in     (%dx),%al
f010032c:	ec                   	in     (%dx),%al
f010032d:	ec                   	in     (%dx),%al
	     i++)
f010032e:	83 c6 01             	add    $0x1,%esi
f0100331:	eb e6                	jmp    f0100319 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f0100333:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100336:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010033b:	89 c8                	mov    %ecx,%eax
f010033d:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010033e:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100343:	bf 79 03 00 00       	mov    $0x379,%edi
f0100348:	bb 84 00 00 00       	mov    $0x84,%ebx
f010034d:	89 fa                	mov    %edi,%edx
f010034f:	ec                   	in     (%dx),%al
f0100350:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100356:	7f 0f                	jg     f0100367 <cons_putc+0x68>
f0100358:	84 c0                	test   %al,%al
f010035a:	78 0b                	js     f0100367 <cons_putc+0x68>
f010035c:	89 da                	mov    %ebx,%edx
f010035e:	ec                   	in     (%dx),%al
f010035f:	ec                   	in     (%dx),%al
f0100360:	ec                   	in     (%dx),%al
f0100361:	ec                   	in     (%dx),%al
f0100362:	83 c6 01             	add    $0x1,%esi
f0100365:	eb e6                	jmp    f010034d <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100367:	ba 78 03 00 00       	mov    $0x378,%edx
f010036c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100370:	ee                   	out    %al,(%dx)
f0100371:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100376:	b8 0d 00 00 00       	mov    $0xd,%eax
f010037b:	ee                   	out    %al,(%dx)
f010037c:	b8 08 00 00 00       	mov    $0x8,%eax
f0100381:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100382:	89 c8                	mov    %ecx,%eax
f0100384:	80 cc 07             	or     $0x7,%ah
f0100387:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f010038d:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f0100390:	0f b6 c1             	movzbl %cl,%eax
f0100393:	80 f9 0a             	cmp    $0xa,%cl
f0100396:	0f 84 dd 00 00 00    	je     f0100479 <cons_putc+0x17a>
f010039c:	83 f8 0a             	cmp    $0xa,%eax
f010039f:	7f 46                	jg     f01003e7 <cons_putc+0xe8>
f01003a1:	83 f8 08             	cmp    $0x8,%eax
f01003a4:	0f 84 a7 00 00 00    	je     f0100451 <cons_putc+0x152>
f01003aa:	83 f8 09             	cmp    $0x9,%eax
f01003ad:	0f 85 d3 00 00 00    	jne    f0100486 <cons_putc+0x187>
		cons_putc(' ');
f01003b3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b8:	e8 42 ff ff ff       	call   f01002ff <cons_putc>
		cons_putc(' ');
f01003bd:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c2:	e8 38 ff ff ff       	call   f01002ff <cons_putc>
		cons_putc(' ');
f01003c7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cc:	e8 2e ff ff ff       	call   f01002ff <cons_putc>
		cons_putc(' ');
f01003d1:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d6:	e8 24 ff ff ff       	call   f01002ff <cons_putc>
		cons_putc(' ');
f01003db:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e0:	e8 1a ff ff ff       	call   f01002ff <cons_putc>
		break;
f01003e5:	eb 25                	jmp    f010040c <cons_putc+0x10d>
	switch (c & 0xff) {
f01003e7:	83 f8 0d             	cmp    $0xd,%eax
f01003ea:	0f 85 96 00 00 00    	jne    f0100486 <cons_putc+0x187>
		crt_pos -= (crt_pos % CRT_COLS);
f01003f0:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003f7:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003fd:	c1 e8 16             	shr    $0x16,%eax
f0100400:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100403:	c1 e0 04             	shl    $0x4,%eax
f0100406:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
	if (crt_pos >= CRT_SIZE) {
f010040c:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f0100413:	cf 07 
f0100415:	0f 87 8e 00 00 00    	ja     f01004a9 <cons_putc+0x1aa>
	outb(addr_6845, 14);
f010041b:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f0100421:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100429:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f0100430:	8d 71 01             	lea    0x1(%ecx),%esi
f0100433:	89 d8                	mov    %ebx,%eax
f0100435:	66 c1 e8 08          	shr    $0x8,%ax
f0100439:	89 f2                	mov    %esi,%edx
f010043b:	ee                   	out    %al,(%dx)
f010043c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100441:	89 ca                	mov    %ecx,%edx
f0100443:	ee                   	out    %al,(%dx)
f0100444:	89 d8                	mov    %ebx,%eax
f0100446:	89 f2                	mov    %esi,%edx
f0100448:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100449:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010044c:	5b                   	pop    %ebx
f010044d:	5e                   	pop    %esi
f010044e:	5f                   	pop    %edi
f010044f:	5d                   	pop    %ebp
f0100450:	c3                   	ret    
		if (crt_pos > 0) {
f0100451:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100458:	66 85 c0             	test   %ax,%ax
f010045b:	74 be                	je     f010041b <cons_putc+0x11c>
			crt_pos--;
f010045d:	83 e8 01             	sub    $0x1,%eax
f0100460:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100466:	0f b7 d0             	movzwl %ax,%edx
f0100469:	b1 00                	mov    $0x0,%cl
f010046b:	83 c9 20             	or     $0x20,%ecx
f010046e:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100473:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f0100477:	eb 93                	jmp    f010040c <cons_putc+0x10d>
		crt_pos += CRT_COLS;
f0100479:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f0100480:	50 
f0100481:	e9 6a ff ff ff       	jmp    f01003f0 <cons_putc+0xf1>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100486:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010048d:	8d 50 01             	lea    0x1(%eax),%edx
f0100490:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f0100497:	0f b7 c0             	movzwl %ax,%eax
f010049a:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01004a0:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f01004a4:	e9 63 ff ff ff       	jmp    f010040c <cons_putc+0x10d>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004a9:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f01004ae:	83 ec 04             	sub    $0x4,%esp
f01004b1:	68 00 0f 00 00       	push   $0xf00
f01004b6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004bc:	52                   	push   %edx
f01004bd:	50                   	push   %eax
f01004be:	e8 ae 10 00 00       	call   f0101571 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004c3:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01004c9:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004cf:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004d5:	83 c4 10             	add    $0x10,%esp
f01004d8:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004dd:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004e0:	39 d0                	cmp    %edx,%eax
f01004e2:	75 f4                	jne    f01004d8 <cons_putc+0x1d9>
		crt_pos -= CRT_COLS;
f01004e4:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004eb:	50 
f01004ec:	e9 2a ff ff ff       	jmp    f010041b <cons_putc+0x11c>

f01004f1 <serial_intr>:
{
f01004f1:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f01004f5:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004fc:	75 01                	jne    f01004ff <serial_intr+0xe>
f01004fe:	c3                   	ret    
{
f01004ff:	55                   	push   %ebp
f0100500:	89 e5                	mov    %esp,%ebp
f0100502:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100505:	b8 89 01 10 f0       	mov    $0xf0100189,%eax
f010050a:	e8 98 fc ff ff       	call   f01001a7 <cons_intr>
}
f010050f:	c9                   	leave  
f0100510:	c3                   	ret    

f0100511 <kbd_intr>:
{
f0100511:	f3 0f 1e fb          	endbr32 
f0100515:	55                   	push   %ebp
f0100516:	89 e5                	mov    %esp,%ebp
f0100518:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010051b:	b8 e6 01 10 f0       	mov    $0xf01001e6,%eax
f0100520:	e8 82 fc ff ff       	call   f01001a7 <cons_intr>
}
f0100525:	c9                   	leave  
f0100526:	c3                   	ret    

f0100527 <cons_getc>:
{
f0100527:	f3 0f 1e fb          	endbr32 
f010052b:	55                   	push   %ebp
f010052c:	89 e5                	mov    %esp,%ebp
f010052e:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100531:	e8 bb ff ff ff       	call   f01004f1 <serial_intr>
	kbd_intr();
f0100536:	e8 d6 ff ff ff       	call   f0100511 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010053b:	a1 20 25 11 f0       	mov    0xf0112520,%eax
	return 0;
f0100540:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100545:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f010054b:	74 1c                	je     f0100569 <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f010054d:	8d 48 01             	lea    0x1(%eax),%ecx
f0100550:	0f b6 90 20 23 11 f0 	movzbl -0xfeedce0(%eax),%edx
			cons.rpos = 0;
f0100557:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f010055c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100561:	0f 45 c1             	cmovne %ecx,%eax
f0100564:	a3 20 25 11 f0       	mov    %eax,0xf0112520
}
f0100569:	89 d0                	mov    %edx,%eax
f010056b:	c9                   	leave  
f010056c:	c3                   	ret    

f010056d <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010056d:	f3 0f 1e fb          	endbr32 
f0100571:	55                   	push   %ebp
f0100572:	89 e5                	mov    %esp,%ebp
f0100574:	57                   	push   %edi
f0100575:	56                   	push   %esi
f0100576:	53                   	push   %ebx
f0100577:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f010057a:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100581:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100588:	5a a5 
	if (*cp != 0xA55A) {
f010058a:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100591:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100595:	0f 84 b7 00 00 00    	je     f0100652 <cons_init+0xe5>
		addr_6845 = MONO_BASE;
f010059b:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f01005a2:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005a5:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01005aa:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005b0:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b5:	89 fa                	mov    %edi,%edx
f01005b7:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005b8:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005bb:	89 ca                	mov    %ecx,%edx
f01005bd:	ec                   	in     (%dx),%al
f01005be:	0f b6 c0             	movzbl %al,%eax
f01005c1:	c1 e0 08             	shl    $0x8,%eax
f01005c4:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005cb:	89 fa                	mov    %edi,%edx
f01005cd:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ce:	89 ca                	mov    %ecx,%edx
f01005d0:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01005d1:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	pos |= inb(addr_6845 + 1);
f01005d7:	0f b6 c0             	movzbl %al,%eax
f01005da:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01005dc:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005e7:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01005ec:	89 d8                	mov    %ebx,%eax
f01005ee:	89 ca                	mov    %ecx,%edx
f01005f0:	ee                   	out    %al,(%dx)
f01005f1:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01005f6:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005fb:	89 fa                	mov    %edi,%edx
f01005fd:	ee                   	out    %al,(%dx)
f01005fe:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100603:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100608:	ee                   	out    %al,(%dx)
f0100609:	be f9 03 00 00       	mov    $0x3f9,%esi
f010060e:	89 d8                	mov    %ebx,%eax
f0100610:	89 f2                	mov    %esi,%edx
f0100612:	ee                   	out    %al,(%dx)
f0100613:	b8 03 00 00 00       	mov    $0x3,%eax
f0100618:	89 fa                	mov    %edi,%edx
f010061a:	ee                   	out    %al,(%dx)
f010061b:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100620:	89 d8                	mov    %ebx,%eax
f0100622:	ee                   	out    %al,(%dx)
f0100623:	b8 01 00 00 00       	mov    $0x1,%eax
f0100628:	89 f2                	mov    %esi,%edx
f010062a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010062b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100630:	ec                   	in     (%dx),%al
f0100631:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100633:	3c ff                	cmp    $0xff,%al
f0100635:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f010063c:	89 ca                	mov    %ecx,%edx
f010063e:	ec                   	in     (%dx),%al
f010063f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100644:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100645:	80 fb ff             	cmp    $0xff,%bl
f0100648:	74 23                	je     f010066d <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
}
f010064a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010064d:	5b                   	pop    %ebx
f010064e:	5e                   	pop    %esi
f010064f:	5f                   	pop    %edi
f0100650:	5d                   	pop    %ebp
f0100651:	c3                   	ret    
		*cp = was;
f0100652:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100659:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100660:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100663:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100668:	e9 3d ff ff ff       	jmp    f01005aa <cons_init+0x3d>
		cprintf("Serial port does not exist!\n");
f010066d:	83 ec 0c             	sub    $0xc,%esp
f0100670:	68 30 1a 10 f0       	push   $0xf0101a30
f0100675:	e8 28 03 00 00       	call   f01009a2 <cprintf>
f010067a:	83 c4 10             	add    $0x10,%esp
}
f010067d:	eb cb                	jmp    f010064a <cons_init+0xdd>

f010067f <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010067f:	f3 0f 1e fb          	endbr32 
f0100683:	55                   	push   %ebp
f0100684:	89 e5                	mov    %esp,%ebp
f0100686:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100689:	8b 45 08             	mov    0x8(%ebp),%eax
f010068c:	e8 6e fc ff ff       	call   f01002ff <cons_putc>
}
f0100691:	c9                   	leave  
f0100692:	c3                   	ret    

f0100693 <getchar>:

int
getchar(void)
{
f0100693:	f3 0f 1e fb          	endbr32 
f0100697:	55                   	push   %ebp
f0100698:	89 e5                	mov    %esp,%ebp
f010069a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010069d:	e8 85 fe ff ff       	call   f0100527 <cons_getc>
f01006a2:	85 c0                	test   %eax,%eax
f01006a4:	74 f7                	je     f010069d <getchar+0xa>
		/* do nothing */;
	return c;
}
f01006a6:	c9                   	leave  
f01006a7:	c3                   	ret    

f01006a8 <iscons>:

int
iscons(int fdnum)
{
f01006a8:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f01006ac:	b8 01 00 00 00       	mov    $0x1,%eax
f01006b1:	c3                   	ret    

f01006b2 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006b2:	f3 0f 1e fb          	endbr32 
f01006b6:	55                   	push   %ebp
f01006b7:	89 e5                	mov    %esp,%ebp
f01006b9:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006bc:	68 80 1c 10 f0       	push   $0xf0101c80
f01006c1:	68 9e 1c 10 f0       	push   $0xf0101c9e
f01006c6:	68 a3 1c 10 f0       	push   $0xf0101ca3
f01006cb:	e8 d2 02 00 00       	call   f01009a2 <cprintf>
f01006d0:	83 c4 0c             	add    $0xc,%esp
f01006d3:	68 30 1d 10 f0       	push   $0xf0101d30
f01006d8:	68 ac 1c 10 f0       	push   $0xf0101cac
f01006dd:	68 a3 1c 10 f0       	push   $0xf0101ca3
f01006e2:	e8 bb 02 00 00       	call   f01009a2 <cprintf>
	return 0;
}
f01006e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ec:	c9                   	leave  
f01006ed:	c3                   	ret    

f01006ee <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006ee:	f3 0f 1e fb          	endbr32 
f01006f2:	55                   	push   %ebp
f01006f3:	89 e5                	mov    %esp,%ebp
f01006f5:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006f8:	68 b5 1c 10 f0       	push   $0xf0101cb5
f01006fd:	e8 a0 02 00 00       	call   f01009a2 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100702:	83 c4 08             	add    $0x8,%esp
f0100705:	68 0c 00 10 00       	push   $0x10000c
f010070a:	68 58 1d 10 f0       	push   $0xf0101d58
f010070f:	e8 8e 02 00 00       	call   f01009a2 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100714:	83 c4 0c             	add    $0xc,%esp
f0100717:	68 0c 00 10 00       	push   $0x10000c
f010071c:	68 0c 00 10 f0       	push   $0xf010000c
f0100721:	68 80 1d 10 f0       	push   $0xf0101d80
f0100726:	e8 77 02 00 00       	call   f01009a2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010072b:	83 c4 0c             	add    $0xc,%esp
f010072e:	68 8d 19 10 00       	push   $0x10198d
f0100733:	68 8d 19 10 f0       	push   $0xf010198d
f0100738:	68 a4 1d 10 f0       	push   $0xf0101da4
f010073d:	e8 60 02 00 00       	call   f01009a2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100742:	83 c4 0c             	add    $0xc,%esp
f0100745:	68 00 23 11 00       	push   $0x112300
f010074a:	68 00 23 11 f0       	push   $0xf0112300
f010074f:	68 c8 1d 10 f0       	push   $0xf0101dc8
f0100754:	e8 49 02 00 00       	call   f01009a2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100759:	83 c4 0c             	add    $0xc,%esp
f010075c:	68 44 29 11 00       	push   $0x112944
f0100761:	68 44 29 11 f0       	push   $0xf0112944
f0100766:	68 ec 1d 10 f0       	push   $0xf0101dec
f010076b:	e8 32 02 00 00       	call   f01009a2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100770:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100773:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f0100778:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010077d:	c1 f8 0a             	sar    $0xa,%eax
f0100780:	50                   	push   %eax
f0100781:	68 10 1e 10 f0       	push   $0xf0101e10
f0100786:	e8 17 02 00 00       	call   f01009a2 <cprintf>
	return 0;
}
f010078b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100790:	c9                   	leave  
f0100791:	c3                   	ret    

f0100792 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100792:	f3 0f 1e fb          	endbr32 
f0100796:	55                   	push   %ebp
f0100797:	89 e5                	mov    %esp,%ebp
f0100799:	57                   	push   %edi
f010079a:	56                   	push   %esi
f010079b:	53                   	push   %ebx
f010079c:	83 ec 38             	sub    $0x38,%esp
	// Your code here.

	
	cprintf("Stack backtrace:\n");
f010079f:	68 ce 1c 10 f0       	push   $0xf0101cce
f01007a4:	e8 f9 01 00 00       	call   f01009a2 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01007a9:	89 eb                	mov    %ebp,%ebx
	char *format = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n";
	char *info_format = "\t%s:%d: %.*s+%u\n";
	int info_ret;
	uint32_t *ebp = (uint32_t *) read_ebp();
	
	while (ebp) {
f01007ab:	83 c4 10             	add    $0x10,%esp
f01007ae:	85 db                	test   %ebx,%ebx
f01007b0:	74 58                	je     f010080a <mon_backtrace+0x78>
		uint32_t old_ebp = *(ebp + 0);
f01007b2:	8b 3b                	mov    (%ebx),%edi
		uint32_t eip     = *(ebp + 1);
f01007b4:	8b 73 04             	mov    0x4(%ebx),%esi

		info_ret = debuginfo_eip(eip, &info);
f01007b7:	83 ec 08             	sub    $0x8,%esp
f01007ba:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01007bd:	50                   	push   %eax
f01007be:	56                   	push   %esi
f01007bf:	e8 eb 02 00 00       	call   f0100aaf <debuginfo_eip>
		if (info_ret != 0) 
f01007c4:	83 c4 10             	add    $0x10,%esp
f01007c7:	85 c0                	test   %eax,%eax
f01007c9:	75 44                	jne    f010080f <mon_backtrace+0x7d>
		uint32_t arg1    = *(ebp + 3);
		uint32_t arg2    = *(ebp + 4);
		uint32_t arg3 	 = *(ebp + 5);
		uint32_t arg4    = *(ebp + 6);

		cprintf(format, ebp, eip,
f01007cb:	ff 73 18             	pushl  0x18(%ebx)
f01007ce:	ff 73 14             	pushl  0x14(%ebx)
f01007d1:	ff 73 10             	pushl  0x10(%ebx)
f01007d4:	ff 73 0c             	pushl  0xc(%ebx)
f01007d7:	ff 73 08             	pushl  0x8(%ebx)
f01007da:	56                   	push   %esi
f01007db:	53                   	push   %ebx
f01007dc:	68 3c 1e 10 f0       	push   $0xf0101e3c
f01007e1:	e8 bc 01 00 00       	call   f01009a2 <cprintf>
				arg0, arg1,
				arg2, arg3, arg4);
		cprintf(info_format,
f01007e6:	83 c4 18             	add    $0x18,%esp
f01007e9:	2b 75 e0             	sub    -0x20(%ebp),%esi
f01007ec:	56                   	push   %esi
f01007ed:	ff 75 d8             	pushl  -0x28(%ebp)
f01007f0:	ff 75 dc             	pushl  -0x24(%ebp)
f01007f3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007f6:	ff 75 d0             	pushl  -0x30(%ebp)
f01007f9:	68 e0 1c 10 f0       	push   $0xf0101ce0
f01007fe:	e8 9f 01 00 00       	call   f01009a2 <cprintf>
			info.eip_file,
			info.eip_line,
			info.eip_fn_namelen,
	        	info.eip_fn_name,
			eip - info.eip_fn_addr);		
		ebp = (uint32_t *) old_ebp;
f0100803:	89 fb                	mov    %edi,%ebx
f0100805:	83 c4 20             	add    $0x20,%esp
f0100808:	eb a4                	jmp    f01007ae <mon_backtrace+0x1c>
	}


	return 0;
f010080a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010080f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100812:	5b                   	pop    %ebx
f0100813:	5e                   	pop    %esi
f0100814:	5f                   	pop    %edi
f0100815:	5d                   	pop    %ebp
f0100816:	c3                   	ret    

f0100817 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100817:	f3 0f 1e fb          	endbr32 
f010081b:	55                   	push   %ebp
f010081c:	89 e5                	mov    %esp,%ebp
f010081e:	57                   	push   %edi
f010081f:	56                   	push   %esi
f0100820:	53                   	push   %ebx
f0100821:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100824:	68 74 1e 10 f0       	push   $0xf0101e74
f0100829:	e8 74 01 00 00       	call   f01009a2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010082e:	c7 04 24 98 1e 10 f0 	movl   $0xf0101e98,(%esp)
f0100835:	e8 68 01 00 00       	call   f01009a2 <cprintf>
f010083a:	83 c4 10             	add    $0x10,%esp
f010083d:	e9 cf 00 00 00       	jmp    f0100911 <monitor+0xfa>
		while (*buf && strchr(WHITESPACE, *buf))
f0100842:	83 ec 08             	sub    $0x8,%esp
f0100845:	0f be c0             	movsbl %al,%eax
f0100848:	50                   	push   %eax
f0100849:	68 f5 1c 10 f0       	push   $0xf0101cf5
f010084e:	e8 8d 0c 00 00       	call   f01014e0 <strchr>
f0100853:	83 c4 10             	add    $0x10,%esp
f0100856:	85 c0                	test   %eax,%eax
f0100858:	74 6c                	je     f01008c6 <monitor+0xaf>
			*buf++ = 0;
f010085a:	c6 03 00             	movb   $0x0,(%ebx)
f010085d:	89 f7                	mov    %esi,%edi
f010085f:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100862:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100864:	0f b6 03             	movzbl (%ebx),%eax
f0100867:	84 c0                	test   %al,%al
f0100869:	75 d7                	jne    f0100842 <monitor+0x2b>
	argv[argc] = 0;
f010086b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100872:	00 
	if (argc == 0)
f0100873:	85 f6                	test   %esi,%esi
f0100875:	0f 84 96 00 00 00    	je     f0100911 <monitor+0xfa>
		if (strcmp(argv[0], commands[i].name) == 0)
f010087b:	83 ec 08             	sub    $0x8,%esp
f010087e:	68 9e 1c 10 f0       	push   $0xf0101c9e
f0100883:	ff 75 a8             	pushl  -0x58(%ebp)
f0100886:	e8 ef 0b 00 00       	call   f010147a <strcmp>
f010088b:	83 c4 10             	add    $0x10,%esp
f010088e:	85 c0                	test   %eax,%eax
f0100890:	0f 84 a7 00 00 00    	je     f010093d <monitor+0x126>
f0100896:	83 ec 08             	sub    $0x8,%esp
f0100899:	68 ac 1c 10 f0       	push   $0xf0101cac
f010089e:	ff 75 a8             	pushl  -0x58(%ebp)
f01008a1:	e8 d4 0b 00 00       	call   f010147a <strcmp>
f01008a6:	83 c4 10             	add    $0x10,%esp
f01008a9:	85 c0                	test   %eax,%eax
f01008ab:	0f 84 87 00 00 00    	je     f0100938 <monitor+0x121>
	cprintf("Unknown command '%s'\n", argv[0]);
f01008b1:	83 ec 08             	sub    $0x8,%esp
f01008b4:	ff 75 a8             	pushl  -0x58(%ebp)
f01008b7:	68 17 1d 10 f0       	push   $0xf0101d17
f01008bc:	e8 e1 00 00 00       	call   f01009a2 <cprintf>
	return 0;
f01008c1:	83 c4 10             	add    $0x10,%esp
f01008c4:	eb 4b                	jmp    f0100911 <monitor+0xfa>
		if (*buf == 0)
f01008c6:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008c9:	74 a0                	je     f010086b <monitor+0x54>
		if (argc == MAXARGS-1) {
f01008cb:	83 fe 0f             	cmp    $0xf,%esi
f01008ce:	74 2f                	je     f01008ff <monitor+0xe8>
		argv[argc++] = buf;
f01008d0:	8d 7e 01             	lea    0x1(%esi),%edi
f01008d3:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01008d7:	0f b6 03             	movzbl (%ebx),%eax
f01008da:	84 c0                	test   %al,%al
f01008dc:	74 84                	je     f0100862 <monitor+0x4b>
f01008de:	83 ec 08             	sub    $0x8,%esp
f01008e1:	0f be c0             	movsbl %al,%eax
f01008e4:	50                   	push   %eax
f01008e5:	68 f5 1c 10 f0       	push   $0xf0101cf5
f01008ea:	e8 f1 0b 00 00       	call   f01014e0 <strchr>
f01008ef:	83 c4 10             	add    $0x10,%esp
f01008f2:	85 c0                	test   %eax,%eax
f01008f4:	0f 85 68 ff ff ff    	jne    f0100862 <monitor+0x4b>
			buf++;
f01008fa:	83 c3 01             	add    $0x1,%ebx
f01008fd:	eb d8                	jmp    f01008d7 <monitor+0xc0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008ff:	83 ec 08             	sub    $0x8,%esp
f0100902:	6a 10                	push   $0x10
f0100904:	68 fa 1c 10 f0       	push   $0xf0101cfa
f0100909:	e8 94 00 00 00       	call   f01009a2 <cprintf>
			return 0;
f010090e:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100911:	83 ec 0c             	sub    $0xc,%esp
f0100914:	68 f1 1c 10 f0       	push   $0xf0101cf1
f0100919:	e8 74 09 00 00       	call   f0101292 <readline>
f010091e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100920:	83 c4 10             	add    $0x10,%esp
f0100923:	85 c0                	test   %eax,%eax
f0100925:	74 ea                	je     f0100911 <monitor+0xfa>
	argv[argc] = 0;
f0100927:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f010092e:	be 00 00 00 00       	mov    $0x0,%esi
f0100933:	e9 2c ff ff ff       	jmp    f0100864 <monitor+0x4d>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100938:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f010093d:	83 ec 04             	sub    $0x4,%esp
f0100940:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100943:	ff 75 08             	pushl  0x8(%ebp)
f0100946:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100949:	52                   	push   %edx
f010094a:	56                   	push   %esi
f010094b:	ff 14 85 c8 1e 10 f0 	call   *-0xfefe138(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100952:	83 c4 10             	add    $0x10,%esp
f0100955:	85 c0                	test   %eax,%eax
f0100957:	79 b8                	jns    f0100911 <monitor+0xfa>
				break;
	}
}
f0100959:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010095c:	5b                   	pop    %ebx
f010095d:	5e                   	pop    %esi
f010095e:	5f                   	pop    %edi
f010095f:	5d                   	pop    %ebp
f0100960:	c3                   	ret    

f0100961 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100961:	f3 0f 1e fb          	endbr32 
f0100965:	55                   	push   %ebp
f0100966:	89 e5                	mov    %esp,%ebp
f0100968:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010096b:	ff 75 08             	pushl  0x8(%ebp)
f010096e:	e8 0c fd ff ff       	call   f010067f <cputchar>
	*cnt++;
}
f0100973:	83 c4 10             	add    $0x10,%esp
f0100976:	c9                   	leave  
f0100977:	c3                   	ret    

f0100978 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100978:	f3 0f 1e fb          	endbr32 
f010097c:	55                   	push   %ebp
f010097d:	89 e5                	mov    %esp,%ebp
f010097f:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100982:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100989:	ff 75 0c             	pushl  0xc(%ebp)
f010098c:	ff 75 08             	pushl  0x8(%ebp)
f010098f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100992:	50                   	push   %eax
f0100993:	68 61 09 10 f0       	push   $0xf0100961
f0100998:	e8 31 04 00 00       	call   f0100dce <vprintfmt>
	return cnt;
}
f010099d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009a0:	c9                   	leave  
f01009a1:	c3                   	ret    

f01009a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009a2:	f3 0f 1e fb          	endbr32 
f01009a6:	55                   	push   %ebp
f01009a7:	89 e5                	mov    %esp,%ebp
f01009a9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009ac:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009af:	50                   	push   %eax
f01009b0:	ff 75 08             	pushl  0x8(%ebp)
f01009b3:	e8 c0 ff ff ff       	call   f0100978 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009b8:	c9                   	leave  
f01009b9:	c3                   	ret    

f01009ba <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009ba:	55                   	push   %ebp
f01009bb:	89 e5                	mov    %esp,%ebp
f01009bd:	57                   	push   %edi
f01009be:	56                   	push   %esi
f01009bf:	53                   	push   %ebx
f01009c0:	83 ec 14             	sub    $0x14,%esp
f01009c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01009cc:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009cf:	8b 1a                	mov    (%edx),%ebx
f01009d1:	8b 01                	mov    (%ecx),%eax
f01009d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009d6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009dd:	eb 23                	jmp    f0100a02 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009df:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01009e2:	eb 1e                	jmp    f0100a02 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009e4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009e7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009ea:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009ee:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01009f1:	73 46                	jae    f0100a39 <stab_binsearch+0x7f>
			*region_left = m;
f01009f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01009f6:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01009f8:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f01009fb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100a02:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a05:	7f 5f                	jg     f0100a66 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a0a:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100a0d:	89 d0                	mov    %edx,%eax
f0100a0f:	c1 e8 1f             	shr    $0x1f,%eax
f0100a12:	01 d0                	add    %edx,%eax
f0100a14:	89 c7                	mov    %eax,%edi
f0100a16:	d1 ff                	sar    %edi
f0100a18:	83 e0 fe             	and    $0xfffffffe,%eax
f0100a1b:	01 f8                	add    %edi,%eax
f0100a1d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a20:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100a24:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100a26:	39 c3                	cmp    %eax,%ebx
f0100a28:	7f b5                	jg     f01009df <stab_binsearch+0x25>
f0100a2a:	0f b6 0a             	movzbl (%edx),%ecx
f0100a2d:	83 ea 0c             	sub    $0xc,%edx
f0100a30:	39 f1                	cmp    %esi,%ecx
f0100a32:	74 b0                	je     f01009e4 <stab_binsearch+0x2a>
			m--;
f0100a34:	83 e8 01             	sub    $0x1,%eax
f0100a37:	eb ed                	jmp    f0100a26 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0100a39:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100a3c:	76 14                	jbe    f0100a52 <stab_binsearch+0x98>
			*region_right = m - 1;
f0100a3e:	83 e8 01             	sub    $0x1,%eax
f0100a41:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a44:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100a47:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100a49:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a50:	eb b0                	jmp    f0100a02 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100a55:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100a57:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a5b:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100a5d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a64:	eb 9c                	jmp    f0100a02 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0100a66:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a6a:	75 15                	jne    f0100a81 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a6f:	8b 00                	mov    (%eax),%eax
f0100a71:	83 e8 01             	sub    $0x1,%eax
f0100a74:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100a77:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100a79:	83 c4 14             	add    $0x14,%esp
f0100a7c:	5b                   	pop    %ebx
f0100a7d:	5e                   	pop    %esi
f0100a7e:	5f                   	pop    %edi
f0100a7f:	5d                   	pop    %ebp
f0100a80:	c3                   	ret    
		for (l = *region_right;
f0100a81:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a84:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100a89:	8b 0f                	mov    (%edi),%ecx
f0100a8b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a8e:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100a91:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100a95:	eb 03                	jmp    f0100a9a <stab_binsearch+0xe0>
		     l--)
f0100a97:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100a9a:	39 c1                	cmp    %eax,%ecx
f0100a9c:	7d 0a                	jge    f0100aa8 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0100a9e:	0f b6 1a             	movzbl (%edx),%ebx
f0100aa1:	83 ea 0c             	sub    $0xc,%edx
f0100aa4:	39 f3                	cmp    %esi,%ebx
f0100aa6:	75 ef                	jne    f0100a97 <stab_binsearch+0xdd>
		*region_left = l;
f0100aa8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100aab:	89 07                	mov    %eax,(%edi)
}
f0100aad:	eb ca                	jmp    f0100a79 <stab_binsearch+0xbf>

f0100aaf <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100aaf:	f3 0f 1e fb          	endbr32 
f0100ab3:	55                   	push   %ebp
f0100ab4:	89 e5                	mov    %esp,%ebp
f0100ab6:	57                   	push   %edi
f0100ab7:	56                   	push   %esi
f0100ab8:	53                   	push   %ebx
f0100ab9:	83 ec 3c             	sub    $0x3c,%esp
f0100abc:	8b 75 08             	mov    0x8(%ebp),%esi
f0100abf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100ac2:	c7 03 d8 1e 10 f0    	movl   $0xf0101ed8,(%ebx)
	info->eip_line = 0;
f0100ac8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100acf:	c7 43 08 d8 1e 10 f0 	movl   $0xf0101ed8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100ad6:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100add:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100ae0:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100ae7:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100aed:	0f 86 03 01 00 00    	jbe    f0100bf6 <debuginfo_eip+0x147>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100af3:	b8 72 7f 10 f0       	mov    $0xf0107f72,%eax
f0100af8:	3d 69 65 10 f0       	cmp    $0xf0106569,%eax
f0100afd:	0f 86 bc 01 00 00    	jbe    f0100cbf <debuginfo_eip+0x210>
f0100b03:	80 3d 71 7f 10 f0 00 	cmpb   $0x0,0xf0107f71
f0100b0a:	0f 85 b6 01 00 00    	jne    f0100cc6 <debuginfo_eip+0x217>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b10:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b17:	b8 68 65 10 f0       	mov    $0xf0106568,%eax
f0100b1c:	2d 10 21 10 f0       	sub    $0xf0102110,%eax
f0100b21:	c1 f8 02             	sar    $0x2,%eax
f0100b24:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b2a:	83 e8 01             	sub    $0x1,%eax
f0100b2d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b30:	83 ec 08             	sub    $0x8,%esp
f0100b33:	56                   	push   %esi
f0100b34:	6a 64                	push   $0x64
f0100b36:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b39:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b3c:	b8 10 21 10 f0       	mov    $0xf0102110,%eax
f0100b41:	e8 74 fe ff ff       	call   f01009ba <stab_binsearch>
	if (lfile == 0)
f0100b46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b49:	83 c4 10             	add    $0x10,%esp
f0100b4c:	85 c0                	test   %eax,%eax
f0100b4e:	0f 84 79 01 00 00    	je     f0100ccd <debuginfo_eip+0x21e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b54:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b57:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b5a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b5d:	83 ec 08             	sub    $0x8,%esp
f0100b60:	56                   	push   %esi
f0100b61:	6a 24                	push   $0x24
f0100b63:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b66:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b69:	b8 10 21 10 f0       	mov    $0xf0102110,%eax
f0100b6e:	e8 47 fe ff ff       	call   f01009ba <stab_binsearch>

	if (lfun <= rfun) {
f0100b73:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b76:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b79:	83 c4 10             	add    $0x10,%esp
f0100b7c:	39 d0                	cmp    %edx,%eax
f0100b7e:	0f 8f 86 00 00 00    	jg     f0100c0a <debuginfo_eip+0x15b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b84:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100b87:	c1 e1 02             	shl    $0x2,%ecx
f0100b8a:	8d b9 10 21 10 f0    	lea    -0xfefdef0(%ecx),%edi
f0100b90:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100b93:	8b b9 10 21 10 f0    	mov    -0xfefdef0(%ecx),%edi
f0100b99:	b9 72 7f 10 f0       	mov    $0xf0107f72,%ecx
f0100b9e:	81 e9 69 65 10 f0    	sub    $0xf0106569,%ecx
f0100ba4:	39 cf                	cmp    %ecx,%edi
f0100ba6:	73 09                	jae    f0100bb1 <debuginfo_eip+0x102>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100ba8:	81 c7 69 65 10 f0    	add    $0xf0106569,%edi
f0100bae:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100bb1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100bb4:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100bb7:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100bba:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100bbc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100bbf:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100bc2:	83 ec 08             	sub    $0x8,%esp
f0100bc5:	6a 3a                	push   $0x3a
f0100bc7:	ff 73 08             	pushl  0x8(%ebx)
f0100bca:	e8 36 09 00 00       	call   f0101505 <strfind>
f0100bcf:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bd2:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	which one.
	
	// Your code here.
	/*------------------------------------------------------------*/
	/* Daca lline > rline => valorile sunt ordonate */
	if (lfun <= rfun) {
f0100bd5:	83 c4 10             	add    $0x10,%esp
f0100bd8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bdb:	39 45 dc             	cmp    %eax,-0x24(%ebp)
f0100bde:	7e 3b                	jle    f0100c1b <debuginfo_eip+0x16c>
		if (lline > rline)
			return -1;
	} 
	/* valorile nu sunt ordonate asa ca iau valoare cu valoare */
	
	info->eip_line = stabs[lline].n_desc;
f0100be0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100be3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100be6:	0f b7 14 95 16 21 10 	movzwl -0xfefdeea(,%edx,4),%edx
f0100bed:	f0 
f0100bee:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bf1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bf4:	eb 53                	jmp    f0100c49 <debuginfo_eip+0x19a>
  	        panic("User address");
f0100bf6:	83 ec 04             	sub    $0x4,%esp
f0100bf9:	68 e2 1e 10 f0       	push   $0xf0101ee2
f0100bfe:	6a 7f                	push   $0x7f
f0100c00:	68 ef 1e 10 f0       	push   $0xf0101eef
f0100c05:	e8 e4 f4 ff ff       	call   f01000ee <_panic>
		info->eip_fn_addr = addr;
f0100c0a:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100c0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c10:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100c13:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c16:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100c19:	eb a7                	jmp    f0100bc2 <debuginfo_eip+0x113>
		stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100c1b:	83 ec 08             	sub    $0x8,%esp
f0100c1e:	56                   	push   %esi
f0100c1f:	6a 44                	push   $0x44
f0100c21:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100c24:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100c27:	b8 10 21 10 f0       	mov    $0xf0102110,%eax
f0100c2c:	e8 89 fd ff ff       	call   f01009ba <stab_binsearch>
		if (lline > rline)
f0100c31:	83 c4 10             	add    $0x10,%esp
f0100c34:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100c37:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0100c3a:	7e a4                	jle    f0100be0 <debuginfo_eip+0x131>
			return -1;
f0100c3c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100c41:	e9 93 00 00 00       	jmp    f0100cd9 <debuginfo_eip+0x22a>
f0100c46:	83 e8 01             	sub    $0x1,%eax
	while (lline >= lfile
f0100c49:	39 c6                	cmp    %eax,%esi
f0100c4b:	7f 3f                	jg     f0100c8c <debuginfo_eip+0x1dd>
f0100c4d:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
	       && stabs[lline].n_type != N_SOL
f0100c50:	0f b6 14 8d 14 21 10 	movzbl -0xfefdeec(,%ecx,4),%edx
f0100c57:	f0 
f0100c58:	80 fa 84             	cmp    $0x84,%dl
f0100c5b:	74 0f                	je     f0100c6c <debuginfo_eip+0x1bd>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c5d:	80 fa 64             	cmp    $0x64,%dl
f0100c60:	75 e4                	jne    f0100c46 <debuginfo_eip+0x197>
f0100c62:	83 3c 8d 18 21 10 f0 	cmpl   $0x0,-0xfefdee8(,%ecx,4)
f0100c69:	00 
f0100c6a:	74 da                	je     f0100c46 <debuginfo_eip+0x197>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c6c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100c6f:	8b 14 85 10 21 10 f0 	mov    -0xfefdef0(,%eax,4),%edx
f0100c76:	b8 72 7f 10 f0       	mov    $0xf0107f72,%eax
f0100c7b:	2d 69 65 10 f0       	sub    $0xf0106569,%eax
f0100c80:	39 c2                	cmp    %eax,%edx
f0100c82:	73 08                	jae    f0100c8c <debuginfo_eip+0x1dd>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c84:	81 c2 69 65 10 f0    	add    $0xf0106569,%edx
f0100c8a:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c8f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c92:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f0100c97:	39 c8                	cmp    %ecx,%eax
f0100c99:	7d 3e                	jge    f0100cd9 <debuginfo_eip+0x22a>
		for (lline = lfun + 1;
f0100c9b:	83 c0 01             	add    $0x1,%eax
f0100c9e:	eb 04                	jmp    f0100ca4 <debuginfo_eip+0x1f5>
			info->eip_fn_narg++;
f0100ca0:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0100ca4:	39 c1                	cmp    %eax,%ecx
f0100ca6:	7e 2c                	jle    f0100cd4 <debuginfo_eip+0x225>
f0100ca8:	83 c0 01             	add    $0x1,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100cab:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100cae:	80 3c 95 08 21 10 f0 	cmpb   $0xa0,-0xfefdef8(,%edx,4)
f0100cb5:	a0 
f0100cb6:	74 e8                	je     f0100ca0 <debuginfo_eip+0x1f1>
	return 0;
f0100cb8:	ba 00 00 00 00       	mov    $0x0,%edx
f0100cbd:	eb 1a                	jmp    f0100cd9 <debuginfo_eip+0x22a>
		return -1;
f0100cbf:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100cc4:	eb 13                	jmp    f0100cd9 <debuginfo_eip+0x22a>
f0100cc6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ccb:	eb 0c                	jmp    f0100cd9 <debuginfo_eip+0x22a>
		return -1;
f0100ccd:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100cd2:	eb 05                	jmp    f0100cd9 <debuginfo_eip+0x22a>
	return 0;
f0100cd4:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100cd9:	89 d0                	mov    %edx,%eax
f0100cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cde:	5b                   	pop    %ebx
f0100cdf:	5e                   	pop    %esi
f0100ce0:	5f                   	pop    %edi
f0100ce1:	5d                   	pop    %ebp
f0100ce2:	c3                   	ret    

f0100ce3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ce3:	55                   	push   %ebp
f0100ce4:	89 e5                	mov    %esp,%ebp
f0100ce6:	57                   	push   %edi
f0100ce7:	56                   	push   %esi
f0100ce8:	53                   	push   %ebx
f0100ce9:	83 ec 1c             	sub    $0x1c,%esp
f0100cec:	89 c7                	mov    %eax,%edi
f0100cee:	89 d6                	mov    %edx,%esi
f0100cf0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cf3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100cf6:	89 d1                	mov    %edx,%ecx
f0100cf8:	89 c2                	mov    %eax,%edx
f0100cfa:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cfd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100d00:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d03:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d06:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d09:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100d10:	39 c2                	cmp    %eax,%edx
f0100d12:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100d15:	72 3e                	jb     f0100d55 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d17:	83 ec 0c             	sub    $0xc,%esp
f0100d1a:	ff 75 18             	pushl  0x18(%ebp)
f0100d1d:	83 eb 01             	sub    $0x1,%ebx
f0100d20:	53                   	push   %ebx
f0100d21:	50                   	push   %eax
f0100d22:	83 ec 08             	sub    $0x8,%esp
f0100d25:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d28:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d2b:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d2e:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d31:	e8 fa 09 00 00       	call   f0101730 <__udivdi3>
f0100d36:	83 c4 18             	add    $0x18,%esp
f0100d39:	52                   	push   %edx
f0100d3a:	50                   	push   %eax
f0100d3b:	89 f2                	mov    %esi,%edx
f0100d3d:	89 f8                	mov    %edi,%eax
f0100d3f:	e8 9f ff ff ff       	call   f0100ce3 <printnum>
f0100d44:	83 c4 20             	add    $0x20,%esp
f0100d47:	eb 13                	jmp    f0100d5c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d49:	83 ec 08             	sub    $0x8,%esp
f0100d4c:	56                   	push   %esi
f0100d4d:	ff 75 18             	pushl  0x18(%ebp)
f0100d50:	ff d7                	call   *%edi
f0100d52:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100d55:	83 eb 01             	sub    $0x1,%ebx
f0100d58:	85 db                	test   %ebx,%ebx
f0100d5a:	7f ed                	jg     f0100d49 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d5c:	83 ec 08             	sub    $0x8,%esp
f0100d5f:	56                   	push   %esi
f0100d60:	83 ec 04             	sub    $0x4,%esp
f0100d63:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d66:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d69:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d6c:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d6f:	e8 cc 0a 00 00       	call   f0101840 <__umoddi3>
f0100d74:	83 c4 14             	add    $0x14,%esp
f0100d77:	0f be 80 fd 1e 10 f0 	movsbl -0xfefe103(%eax),%eax
f0100d7e:	50                   	push   %eax
f0100d7f:	ff d7                	call   *%edi
}
f0100d81:	83 c4 10             	add    $0x10,%esp
f0100d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d87:	5b                   	pop    %ebx
f0100d88:	5e                   	pop    %esi
f0100d89:	5f                   	pop    %edi
f0100d8a:	5d                   	pop    %ebp
f0100d8b:	c3                   	ret    

f0100d8c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d8c:	f3 0f 1e fb          	endbr32 
f0100d90:	55                   	push   %ebp
f0100d91:	89 e5                	mov    %esp,%ebp
f0100d93:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d96:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100d9a:	8b 10                	mov    (%eax),%edx
f0100d9c:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d9f:	73 0a                	jae    f0100dab <sprintputch+0x1f>
		*b->buf++ = ch;
f0100da1:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100da4:	89 08                	mov    %ecx,(%eax)
f0100da6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100da9:	88 02                	mov    %al,(%edx)
}
f0100dab:	5d                   	pop    %ebp
f0100dac:	c3                   	ret    

f0100dad <printfmt>:
{
f0100dad:	f3 0f 1e fb          	endbr32 
f0100db1:	55                   	push   %ebp
f0100db2:	89 e5                	mov    %esp,%ebp
f0100db4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100db7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100dba:	50                   	push   %eax
f0100dbb:	ff 75 10             	pushl  0x10(%ebp)
f0100dbe:	ff 75 0c             	pushl  0xc(%ebp)
f0100dc1:	ff 75 08             	pushl  0x8(%ebp)
f0100dc4:	e8 05 00 00 00       	call   f0100dce <vprintfmt>
}
f0100dc9:	83 c4 10             	add    $0x10,%esp
f0100dcc:	c9                   	leave  
f0100dcd:	c3                   	ret    

f0100dce <vprintfmt>:
{
f0100dce:	f3 0f 1e fb          	endbr32 
f0100dd2:	55                   	push   %ebp
f0100dd3:	89 e5                	mov    %esp,%ebp
f0100dd5:	57                   	push   %edi
f0100dd6:	56                   	push   %esi
f0100dd7:	53                   	push   %ebx
f0100dd8:	83 ec 3c             	sub    $0x3c,%esp
f0100ddb:	8b 75 08             	mov    0x8(%ebp),%esi
f0100dde:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100de1:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100de4:	e9 8e 03 00 00       	jmp    f0101177 <vprintfmt+0x3a9>
		padc = ' ';
f0100de9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0100ded:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0100df4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0100dfb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100e02:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100e07:	8d 47 01             	lea    0x1(%edi),%eax
f0100e0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e0d:	0f b6 17             	movzbl (%edi),%edx
f0100e10:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100e13:	3c 55                	cmp    $0x55,%al
f0100e15:	0f 87 df 03 00 00    	ja     f01011fa <vprintfmt+0x42c>
f0100e1b:	0f b6 c0             	movzbl %al,%eax
f0100e1e:	3e ff 24 85 8c 1f 10 	notrack jmp *-0xfefe074(,%eax,4)
f0100e25:	f0 
f0100e26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100e29:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0100e2d:	eb d8                	jmp    f0100e07 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f0100e2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e32:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0100e36:	eb cf                	jmp    f0100e07 <vprintfmt+0x39>
f0100e38:	0f b6 d2             	movzbl %dl,%edx
f0100e3b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100e3e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e43:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0100e46:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e49:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100e4d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100e50:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100e53:	83 f9 09             	cmp    $0x9,%ecx
f0100e56:	77 55                	ja     f0100ead <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
f0100e58:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0100e5b:	eb e9                	jmp    f0100e46 <vprintfmt+0x78>
			precision = va_arg(ap, int);
f0100e5d:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e60:	8b 00                	mov    (%eax),%eax
f0100e62:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e65:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e68:	8d 40 04             	lea    0x4(%eax),%eax
f0100e6b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100e6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0100e71:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100e75:	79 90                	jns    f0100e07 <vprintfmt+0x39>
				width = precision, precision = -1;
f0100e77:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e7d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0100e84:	eb 81                	jmp    f0100e07 <vprintfmt+0x39>
f0100e86:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e89:	85 c0                	test   %eax,%eax
f0100e8b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e90:	0f 49 d0             	cmovns %eax,%edx
f0100e93:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100e96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0100e99:	e9 69 ff ff ff       	jmp    f0100e07 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f0100e9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0100ea1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0100ea8:	e9 5a ff ff ff       	jmp    f0100e07 <vprintfmt+0x39>
f0100ead:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100eb0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100eb3:	eb bc                	jmp    f0100e71 <vprintfmt+0xa3>
			lflag++;
f0100eb5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100eb8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0100ebb:	e9 47 ff ff ff       	jmp    f0100e07 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f0100ec0:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ec3:	8d 78 04             	lea    0x4(%eax),%edi
f0100ec6:	83 ec 08             	sub    $0x8,%esp
f0100ec9:	53                   	push   %ebx
f0100eca:	ff 30                	pushl  (%eax)
f0100ecc:	ff d6                	call   *%esi
			break;
f0100ece:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100ed1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0100ed4:	e9 9b 02 00 00       	jmp    f0101174 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
f0100ed9:	8b 45 14             	mov    0x14(%ebp),%eax
f0100edc:	8d 78 04             	lea    0x4(%eax),%edi
f0100edf:	8b 00                	mov    (%eax),%eax
f0100ee1:	99                   	cltd   
f0100ee2:	31 d0                	xor    %edx,%eax
f0100ee4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100ee6:	83 f8 06             	cmp    $0x6,%eax
f0100ee9:	7f 23                	jg     f0100f0e <vprintfmt+0x140>
f0100eeb:	8b 14 85 e4 20 10 f0 	mov    -0xfefdf1c(,%eax,4),%edx
f0100ef2:	85 d2                	test   %edx,%edx
f0100ef4:	74 18                	je     f0100f0e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
f0100ef6:	52                   	push   %edx
f0100ef7:	68 1e 1f 10 f0       	push   $0xf0101f1e
f0100efc:	53                   	push   %ebx
f0100efd:	56                   	push   %esi
f0100efe:	e8 aa fe ff ff       	call   f0100dad <printfmt>
f0100f03:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100f06:	89 7d 14             	mov    %edi,0x14(%ebp)
f0100f09:	e9 66 02 00 00       	jmp    f0101174 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
f0100f0e:	50                   	push   %eax
f0100f0f:	68 15 1f 10 f0       	push   $0xf0101f15
f0100f14:	53                   	push   %ebx
f0100f15:	56                   	push   %esi
f0100f16:	e8 92 fe ff ff       	call   f0100dad <printfmt>
f0100f1b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100f1e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100f21:	e9 4e 02 00 00       	jmp    f0101174 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
f0100f26:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f29:	83 c0 04             	add    $0x4,%eax
f0100f2c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100f2f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f32:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0100f34:	85 d2                	test   %edx,%edx
f0100f36:	b8 0e 1f 10 f0       	mov    $0xf0101f0e,%eax
f0100f3b:	0f 45 c2             	cmovne %edx,%eax
f0100f3e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0100f41:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f45:	7e 06                	jle    f0100f4d <vprintfmt+0x17f>
f0100f47:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0100f4b:	75 0d                	jne    f0100f5a <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f4d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100f50:	89 c7                	mov    %eax,%edi
f0100f52:	03 45 e0             	add    -0x20(%ebp),%eax
f0100f55:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f58:	eb 55                	jmp    f0100faf <vprintfmt+0x1e1>
f0100f5a:	83 ec 08             	sub    $0x8,%esp
f0100f5d:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f60:	ff 75 cc             	pushl  -0x34(%ebp)
f0100f63:	e8 2c 04 00 00       	call   f0101394 <strnlen>
f0100f68:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100f6b:	29 c2                	sub    %eax,%edx
f0100f6d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0100f70:	83 c4 10             	add    $0x10,%esp
f0100f73:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f0100f75:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0100f79:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f7c:	85 ff                	test   %edi,%edi
f0100f7e:	7e 11                	jle    f0100f91 <vprintfmt+0x1c3>
					putch(padc, putdat);
f0100f80:	83 ec 08             	sub    $0x8,%esp
f0100f83:	53                   	push   %ebx
f0100f84:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f87:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f89:	83 ef 01             	sub    $0x1,%edi
f0100f8c:	83 c4 10             	add    $0x10,%esp
f0100f8f:	eb eb                	jmp    f0100f7c <vprintfmt+0x1ae>
f0100f91:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100f94:	85 d2                	test   %edx,%edx
f0100f96:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f9b:	0f 49 c2             	cmovns %edx,%eax
f0100f9e:	29 c2                	sub    %eax,%edx
f0100fa0:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100fa3:	eb a8                	jmp    f0100f4d <vprintfmt+0x17f>
					putch(ch, putdat);
f0100fa5:	83 ec 08             	sub    $0x8,%esp
f0100fa8:	53                   	push   %ebx
f0100fa9:	52                   	push   %edx
f0100faa:	ff d6                	call   *%esi
f0100fac:	83 c4 10             	add    $0x10,%esp
f0100faf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fb2:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100fb4:	83 c7 01             	add    $0x1,%edi
f0100fb7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100fbb:	0f be d0             	movsbl %al,%edx
f0100fbe:	85 d2                	test   %edx,%edx
f0100fc0:	74 4b                	je     f010100d <vprintfmt+0x23f>
f0100fc2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100fc6:	78 06                	js     f0100fce <vprintfmt+0x200>
f0100fc8:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0100fcc:	78 1e                	js     f0100fec <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
f0100fce:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100fd2:	74 d1                	je     f0100fa5 <vprintfmt+0x1d7>
f0100fd4:	0f be c0             	movsbl %al,%eax
f0100fd7:	83 e8 20             	sub    $0x20,%eax
f0100fda:	83 f8 5e             	cmp    $0x5e,%eax
f0100fdd:	76 c6                	jbe    f0100fa5 <vprintfmt+0x1d7>
					putch('?', putdat);
f0100fdf:	83 ec 08             	sub    $0x8,%esp
f0100fe2:	53                   	push   %ebx
f0100fe3:	6a 3f                	push   $0x3f
f0100fe5:	ff d6                	call   *%esi
f0100fe7:	83 c4 10             	add    $0x10,%esp
f0100fea:	eb c3                	jmp    f0100faf <vprintfmt+0x1e1>
f0100fec:	89 cf                	mov    %ecx,%edi
f0100fee:	eb 0e                	jmp    f0100ffe <vprintfmt+0x230>
				putch(' ', putdat);
f0100ff0:	83 ec 08             	sub    $0x8,%esp
f0100ff3:	53                   	push   %ebx
f0100ff4:	6a 20                	push   $0x20
f0100ff6:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0100ff8:	83 ef 01             	sub    $0x1,%edi
f0100ffb:	83 c4 10             	add    $0x10,%esp
f0100ffe:	85 ff                	test   %edi,%edi
f0101000:	7f ee                	jg     f0100ff0 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
f0101002:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101005:	89 45 14             	mov    %eax,0x14(%ebp)
f0101008:	e9 67 01 00 00       	jmp    f0101174 <vprintfmt+0x3a6>
f010100d:	89 cf                	mov    %ecx,%edi
f010100f:	eb ed                	jmp    f0100ffe <vprintfmt+0x230>
	if (lflag >= 2)
f0101011:	83 f9 01             	cmp    $0x1,%ecx
f0101014:	7f 1b                	jg     f0101031 <vprintfmt+0x263>
	else if (lflag)
f0101016:	85 c9                	test   %ecx,%ecx
f0101018:	74 63                	je     f010107d <vprintfmt+0x2af>
		return va_arg(*ap, long);
f010101a:	8b 45 14             	mov    0x14(%ebp),%eax
f010101d:	8b 00                	mov    (%eax),%eax
f010101f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101022:	99                   	cltd   
f0101023:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101026:	8b 45 14             	mov    0x14(%ebp),%eax
f0101029:	8d 40 04             	lea    0x4(%eax),%eax
f010102c:	89 45 14             	mov    %eax,0x14(%ebp)
f010102f:	eb 17                	jmp    f0101048 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
f0101031:	8b 45 14             	mov    0x14(%ebp),%eax
f0101034:	8b 50 04             	mov    0x4(%eax),%edx
f0101037:	8b 00                	mov    (%eax),%eax
f0101039:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010103c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010103f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101042:	8d 40 08             	lea    0x8(%eax),%eax
f0101045:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101048:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010104b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010104e:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0101053:	85 c9                	test   %ecx,%ecx
f0101055:	0f 89 ff 00 00 00    	jns    f010115a <vprintfmt+0x38c>
				putch('-', putdat);
f010105b:	83 ec 08             	sub    $0x8,%esp
f010105e:	53                   	push   %ebx
f010105f:	6a 2d                	push   $0x2d
f0101061:	ff d6                	call   *%esi
				num = -(long long) num;
f0101063:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101066:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101069:	f7 da                	neg    %edx
f010106b:	83 d1 00             	adc    $0x0,%ecx
f010106e:	f7 d9                	neg    %ecx
f0101070:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101073:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101078:	e9 dd 00 00 00       	jmp    f010115a <vprintfmt+0x38c>
		return va_arg(*ap, int);
f010107d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101080:	8b 00                	mov    (%eax),%eax
f0101082:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101085:	99                   	cltd   
f0101086:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101089:	8b 45 14             	mov    0x14(%ebp),%eax
f010108c:	8d 40 04             	lea    0x4(%eax),%eax
f010108f:	89 45 14             	mov    %eax,0x14(%ebp)
f0101092:	eb b4                	jmp    f0101048 <vprintfmt+0x27a>
	if (lflag >= 2)
f0101094:	83 f9 01             	cmp    $0x1,%ecx
f0101097:	7f 1e                	jg     f01010b7 <vprintfmt+0x2e9>
	else if (lflag)
f0101099:	85 c9                	test   %ecx,%ecx
f010109b:	74 32                	je     f01010cf <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
f010109d:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a0:	8b 10                	mov    (%eax),%edx
f01010a2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010a7:	8d 40 04             	lea    0x4(%eax),%eax
f01010aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01010ad:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f01010b2:	e9 a3 00 00 00       	jmp    f010115a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f01010b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ba:	8b 10                	mov    (%eax),%edx
f01010bc:	8b 48 04             	mov    0x4(%eax),%ecx
f01010bf:	8d 40 08             	lea    0x8(%eax),%eax
f01010c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01010c5:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f01010ca:	e9 8b 00 00 00       	jmp    f010115a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f01010cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d2:	8b 10                	mov    (%eax),%edx
f01010d4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010d9:	8d 40 04             	lea    0x4(%eax),%eax
f01010dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01010df:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f01010e4:	eb 74                	jmp    f010115a <vprintfmt+0x38c>
	if (lflag >= 2)
f01010e6:	83 f9 01             	cmp    $0x1,%ecx
f01010e9:	7f 1b                	jg     f0101106 <vprintfmt+0x338>
	else if (lflag)
f01010eb:	85 c9                	test   %ecx,%ecx
f01010ed:	74 2c                	je     f010111b <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
f01010ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f2:	8b 10                	mov    (%eax),%edx
f01010f4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010f9:	8d 40 04             	lea    0x4(%eax),%eax
f01010fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01010ff:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f0101104:	eb 54                	jmp    f010115a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f0101106:	8b 45 14             	mov    0x14(%ebp),%eax
f0101109:	8b 10                	mov    (%eax),%edx
f010110b:	8b 48 04             	mov    0x4(%eax),%ecx
f010110e:	8d 40 08             	lea    0x8(%eax),%eax
f0101111:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101114:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f0101119:	eb 3f                	jmp    f010115a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f010111b:	8b 45 14             	mov    0x14(%ebp),%eax
f010111e:	8b 10                	mov    (%eax),%edx
f0101120:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101125:	8d 40 04             	lea    0x4(%eax),%eax
f0101128:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010112b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f0101130:	eb 28                	jmp    f010115a <vprintfmt+0x38c>
			putch('0', putdat);
f0101132:	83 ec 08             	sub    $0x8,%esp
f0101135:	53                   	push   %ebx
f0101136:	6a 30                	push   $0x30
f0101138:	ff d6                	call   *%esi
			putch('x', putdat);
f010113a:	83 c4 08             	add    $0x8,%esp
f010113d:	53                   	push   %ebx
f010113e:	6a 78                	push   $0x78
f0101140:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101142:	8b 45 14             	mov    0x14(%ebp),%eax
f0101145:	8b 10                	mov    (%eax),%edx
f0101147:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010114c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010114f:	8d 40 04             	lea    0x4(%eax),%eax
f0101152:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101155:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010115a:	83 ec 0c             	sub    $0xc,%esp
f010115d:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0101161:	57                   	push   %edi
f0101162:	ff 75 e0             	pushl  -0x20(%ebp)
f0101165:	50                   	push   %eax
f0101166:	51                   	push   %ecx
f0101167:	52                   	push   %edx
f0101168:	89 da                	mov    %ebx,%edx
f010116a:	89 f0                	mov    %esi,%eax
f010116c:	e8 72 fb ff ff       	call   f0100ce3 <printnum>
			break;
f0101171:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0101174:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101177:	83 c7 01             	add    $0x1,%edi
f010117a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010117e:	83 f8 25             	cmp    $0x25,%eax
f0101181:	0f 84 62 fc ff ff    	je     f0100de9 <vprintfmt+0x1b>
			if (ch == '\0')
f0101187:	85 c0                	test   %eax,%eax
f0101189:	0f 84 8b 00 00 00    	je     f010121a <vprintfmt+0x44c>
			putch(ch, putdat);
f010118f:	83 ec 08             	sub    $0x8,%esp
f0101192:	53                   	push   %ebx
f0101193:	50                   	push   %eax
f0101194:	ff d6                	call   *%esi
f0101196:	83 c4 10             	add    $0x10,%esp
f0101199:	eb dc                	jmp    f0101177 <vprintfmt+0x3a9>
	if (lflag >= 2)
f010119b:	83 f9 01             	cmp    $0x1,%ecx
f010119e:	7f 1b                	jg     f01011bb <vprintfmt+0x3ed>
	else if (lflag)
f01011a0:	85 c9                	test   %ecx,%ecx
f01011a2:	74 2c                	je     f01011d0 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
f01011a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01011a7:	8b 10                	mov    (%eax),%edx
f01011a9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011ae:	8d 40 04             	lea    0x4(%eax),%eax
f01011b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01011b4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f01011b9:	eb 9f                	jmp    f010115a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f01011bb:	8b 45 14             	mov    0x14(%ebp),%eax
f01011be:	8b 10                	mov    (%eax),%edx
f01011c0:	8b 48 04             	mov    0x4(%eax),%ecx
f01011c3:	8d 40 08             	lea    0x8(%eax),%eax
f01011c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01011c9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f01011ce:	eb 8a                	jmp    f010115a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f01011d0:	8b 45 14             	mov    0x14(%ebp),%eax
f01011d3:	8b 10                	mov    (%eax),%edx
f01011d5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011da:	8d 40 04             	lea    0x4(%eax),%eax
f01011dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01011e0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f01011e5:	e9 70 ff ff ff       	jmp    f010115a <vprintfmt+0x38c>
			putch(ch, putdat);
f01011ea:	83 ec 08             	sub    $0x8,%esp
f01011ed:	53                   	push   %ebx
f01011ee:	6a 25                	push   $0x25
f01011f0:	ff d6                	call   *%esi
			break;
f01011f2:	83 c4 10             	add    $0x10,%esp
f01011f5:	e9 7a ff ff ff       	jmp    f0101174 <vprintfmt+0x3a6>
			putch('%', putdat);
f01011fa:	83 ec 08             	sub    $0x8,%esp
f01011fd:	53                   	push   %ebx
f01011fe:	6a 25                	push   $0x25
f0101200:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101202:	83 c4 10             	add    $0x10,%esp
f0101205:	89 f8                	mov    %edi,%eax
f0101207:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010120b:	74 05                	je     f0101212 <vprintfmt+0x444>
f010120d:	83 e8 01             	sub    $0x1,%eax
f0101210:	eb f5                	jmp    f0101207 <vprintfmt+0x439>
f0101212:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101215:	e9 5a ff ff ff       	jmp    f0101174 <vprintfmt+0x3a6>
}
f010121a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010121d:	5b                   	pop    %ebx
f010121e:	5e                   	pop    %esi
f010121f:	5f                   	pop    %edi
f0101220:	5d                   	pop    %ebp
f0101221:	c3                   	ret    

f0101222 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101222:	f3 0f 1e fb          	endbr32 
f0101226:	55                   	push   %ebp
f0101227:	89 e5                	mov    %esp,%ebp
f0101229:	83 ec 18             	sub    $0x18,%esp
f010122c:	8b 45 08             	mov    0x8(%ebp),%eax
f010122f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101232:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101235:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101239:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010123c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101243:	85 c0                	test   %eax,%eax
f0101245:	74 26                	je     f010126d <vsnprintf+0x4b>
f0101247:	85 d2                	test   %edx,%edx
f0101249:	7e 22                	jle    f010126d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010124b:	ff 75 14             	pushl  0x14(%ebp)
f010124e:	ff 75 10             	pushl  0x10(%ebp)
f0101251:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101254:	50                   	push   %eax
f0101255:	68 8c 0d 10 f0       	push   $0xf0100d8c
f010125a:	e8 6f fb ff ff       	call   f0100dce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010125f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101262:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101265:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101268:	83 c4 10             	add    $0x10,%esp
}
f010126b:	c9                   	leave  
f010126c:	c3                   	ret    
		return -E_INVAL;
f010126d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101272:	eb f7                	jmp    f010126b <vsnprintf+0x49>

f0101274 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101274:	f3 0f 1e fb          	endbr32 
f0101278:	55                   	push   %ebp
f0101279:	89 e5                	mov    %esp,%ebp
f010127b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010127e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101281:	50                   	push   %eax
f0101282:	ff 75 10             	pushl  0x10(%ebp)
f0101285:	ff 75 0c             	pushl  0xc(%ebp)
f0101288:	ff 75 08             	pushl  0x8(%ebp)
f010128b:	e8 92 ff ff ff       	call   f0101222 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101290:	c9                   	leave  
f0101291:	c3                   	ret    

f0101292 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101292:	f3 0f 1e fb          	endbr32 
f0101296:	55                   	push   %ebp
f0101297:	89 e5                	mov    %esp,%ebp
f0101299:	57                   	push   %edi
f010129a:	56                   	push   %esi
f010129b:	53                   	push   %ebx
f010129c:	83 ec 0c             	sub    $0xc,%esp
f010129f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01012a2:	85 c0                	test   %eax,%eax
f01012a4:	74 11                	je     f01012b7 <readline+0x25>
		cprintf("%s", prompt);
f01012a6:	83 ec 08             	sub    $0x8,%esp
f01012a9:	50                   	push   %eax
f01012aa:	68 1e 1f 10 f0       	push   $0xf0101f1e
f01012af:	e8 ee f6 ff ff       	call   f01009a2 <cprintf>
f01012b4:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01012b7:	83 ec 0c             	sub    $0xc,%esp
f01012ba:	6a 00                	push   $0x0
f01012bc:	e8 e7 f3 ff ff       	call   f01006a8 <iscons>
f01012c1:	89 c7                	mov    %eax,%edi
f01012c3:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01012c6:	be 00 00 00 00       	mov    $0x0,%esi
f01012cb:	eb 4b                	jmp    f0101318 <readline+0x86>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01012cd:	83 ec 08             	sub    $0x8,%esp
f01012d0:	50                   	push   %eax
f01012d1:	68 00 21 10 f0       	push   $0xf0102100
f01012d6:	e8 c7 f6 ff ff       	call   f01009a2 <cprintf>
			return NULL;
f01012db:	83 c4 10             	add    $0x10,%esp
f01012de:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01012e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012e6:	5b                   	pop    %ebx
f01012e7:	5e                   	pop    %esi
f01012e8:	5f                   	pop    %edi
f01012e9:	5d                   	pop    %ebp
f01012ea:	c3                   	ret    
			if (echoing)
f01012eb:	85 ff                	test   %edi,%edi
f01012ed:	75 05                	jne    f01012f4 <readline+0x62>
			i--;
f01012ef:	83 ee 01             	sub    $0x1,%esi
f01012f2:	eb 24                	jmp    f0101318 <readline+0x86>
				cputchar('\b');
f01012f4:	83 ec 0c             	sub    $0xc,%esp
f01012f7:	6a 08                	push   $0x8
f01012f9:	e8 81 f3 ff ff       	call   f010067f <cputchar>
f01012fe:	83 c4 10             	add    $0x10,%esp
f0101301:	eb ec                	jmp    f01012ef <readline+0x5d>
				cputchar(c);
f0101303:	83 ec 0c             	sub    $0xc,%esp
f0101306:	53                   	push   %ebx
f0101307:	e8 73 f3 ff ff       	call   f010067f <cputchar>
f010130c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010130f:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101315:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0101318:	e8 76 f3 ff ff       	call   f0100693 <getchar>
f010131d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010131f:	85 c0                	test   %eax,%eax
f0101321:	78 aa                	js     f01012cd <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101323:	83 f8 08             	cmp    $0x8,%eax
f0101326:	0f 94 c2             	sete   %dl
f0101329:	83 f8 7f             	cmp    $0x7f,%eax
f010132c:	0f 94 c0             	sete   %al
f010132f:	08 c2                	or     %al,%dl
f0101331:	74 04                	je     f0101337 <readline+0xa5>
f0101333:	85 f6                	test   %esi,%esi
f0101335:	7f b4                	jg     f01012eb <readline+0x59>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101337:	83 fb 1f             	cmp    $0x1f,%ebx
f010133a:	7e 0e                	jle    f010134a <readline+0xb8>
f010133c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101342:	7f 06                	jg     f010134a <readline+0xb8>
			if (echoing)
f0101344:	85 ff                	test   %edi,%edi
f0101346:	74 c7                	je     f010130f <readline+0x7d>
f0101348:	eb b9                	jmp    f0101303 <readline+0x71>
		} else if (c == '\n' || c == '\r') {
f010134a:	83 fb 0a             	cmp    $0xa,%ebx
f010134d:	74 05                	je     f0101354 <readline+0xc2>
f010134f:	83 fb 0d             	cmp    $0xd,%ebx
f0101352:	75 c4                	jne    f0101318 <readline+0x86>
			if (echoing)
f0101354:	85 ff                	test   %edi,%edi
f0101356:	75 11                	jne    f0101369 <readline+0xd7>
			buf[i] = 0;
f0101358:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f010135f:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
f0101364:	e9 7a ff ff ff       	jmp    f01012e3 <readline+0x51>
				cputchar('\n');
f0101369:	83 ec 0c             	sub    $0xc,%esp
f010136c:	6a 0a                	push   $0xa
f010136e:	e8 0c f3 ff ff       	call   f010067f <cputchar>
f0101373:	83 c4 10             	add    $0x10,%esp
f0101376:	eb e0                	jmp    f0101358 <readline+0xc6>

f0101378 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101378:	f3 0f 1e fb          	endbr32 
f010137c:	55                   	push   %ebp
f010137d:	89 e5                	mov    %esp,%ebp
f010137f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101382:	b8 00 00 00 00       	mov    $0x0,%eax
f0101387:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010138b:	74 05                	je     f0101392 <strlen+0x1a>
		n++;
f010138d:	83 c0 01             	add    $0x1,%eax
f0101390:	eb f5                	jmp    f0101387 <strlen+0xf>
	return n;
}
f0101392:	5d                   	pop    %ebp
f0101393:	c3                   	ret    

f0101394 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101394:	f3 0f 1e fb          	endbr32 
f0101398:	55                   	push   %ebp
f0101399:	89 e5                	mov    %esp,%ebp
f010139b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010139e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01013a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01013a6:	39 d0                	cmp    %edx,%eax
f01013a8:	74 0d                	je     f01013b7 <strnlen+0x23>
f01013aa:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01013ae:	74 05                	je     f01013b5 <strnlen+0x21>
		n++;
f01013b0:	83 c0 01             	add    $0x1,%eax
f01013b3:	eb f1                	jmp    f01013a6 <strnlen+0x12>
f01013b5:	89 c2                	mov    %eax,%edx
	return n;
}
f01013b7:	89 d0                	mov    %edx,%eax
f01013b9:	5d                   	pop    %ebp
f01013ba:	c3                   	ret    

f01013bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01013bb:	f3 0f 1e fb          	endbr32 
f01013bf:	55                   	push   %ebp
f01013c0:	89 e5                	mov    %esp,%ebp
f01013c2:	53                   	push   %ebx
f01013c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01013c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01013ce:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01013d2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01013d5:	83 c0 01             	add    $0x1,%eax
f01013d8:	84 d2                	test   %dl,%dl
f01013da:	75 f2                	jne    f01013ce <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f01013dc:	89 c8                	mov    %ecx,%eax
f01013de:	5b                   	pop    %ebx
f01013df:	5d                   	pop    %ebp
f01013e0:	c3                   	ret    

f01013e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01013e1:	f3 0f 1e fb          	endbr32 
f01013e5:	55                   	push   %ebp
f01013e6:	89 e5                	mov    %esp,%ebp
f01013e8:	53                   	push   %ebx
f01013e9:	83 ec 10             	sub    $0x10,%esp
f01013ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01013ef:	53                   	push   %ebx
f01013f0:	e8 83 ff ff ff       	call   f0101378 <strlen>
f01013f5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01013f8:	ff 75 0c             	pushl  0xc(%ebp)
f01013fb:	01 d8                	add    %ebx,%eax
f01013fd:	50                   	push   %eax
f01013fe:	e8 b8 ff ff ff       	call   f01013bb <strcpy>
	return dst;
}
f0101403:	89 d8                	mov    %ebx,%eax
f0101405:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101408:	c9                   	leave  
f0101409:	c3                   	ret    

f010140a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010140a:	f3 0f 1e fb          	endbr32 
f010140e:	55                   	push   %ebp
f010140f:	89 e5                	mov    %esp,%ebp
f0101411:	56                   	push   %esi
f0101412:	53                   	push   %ebx
f0101413:	8b 75 08             	mov    0x8(%ebp),%esi
f0101416:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101419:	89 f3                	mov    %esi,%ebx
f010141b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010141e:	89 f0                	mov    %esi,%eax
f0101420:	39 d8                	cmp    %ebx,%eax
f0101422:	74 11                	je     f0101435 <strncpy+0x2b>
		*dst++ = *src;
f0101424:	83 c0 01             	add    $0x1,%eax
f0101427:	0f b6 0a             	movzbl (%edx),%ecx
f010142a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010142d:	80 f9 01             	cmp    $0x1,%cl
f0101430:	83 da ff             	sbb    $0xffffffff,%edx
f0101433:	eb eb                	jmp    f0101420 <strncpy+0x16>
	}
	return ret;
}
f0101435:	89 f0                	mov    %esi,%eax
f0101437:	5b                   	pop    %ebx
f0101438:	5e                   	pop    %esi
f0101439:	5d                   	pop    %ebp
f010143a:	c3                   	ret    

f010143b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010143b:	f3 0f 1e fb          	endbr32 
f010143f:	55                   	push   %ebp
f0101440:	89 e5                	mov    %esp,%ebp
f0101442:	56                   	push   %esi
f0101443:	53                   	push   %ebx
f0101444:	8b 75 08             	mov    0x8(%ebp),%esi
f0101447:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010144a:	8b 55 10             	mov    0x10(%ebp),%edx
f010144d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010144f:	85 d2                	test   %edx,%edx
f0101451:	74 21                	je     f0101474 <strlcpy+0x39>
f0101453:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101457:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0101459:	39 c2                	cmp    %eax,%edx
f010145b:	74 14                	je     f0101471 <strlcpy+0x36>
f010145d:	0f b6 19             	movzbl (%ecx),%ebx
f0101460:	84 db                	test   %bl,%bl
f0101462:	74 0b                	je     f010146f <strlcpy+0x34>
			*dst++ = *src++;
f0101464:	83 c1 01             	add    $0x1,%ecx
f0101467:	83 c2 01             	add    $0x1,%edx
f010146a:	88 5a ff             	mov    %bl,-0x1(%edx)
f010146d:	eb ea                	jmp    f0101459 <strlcpy+0x1e>
f010146f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101471:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101474:	29 f0                	sub    %esi,%eax
}
f0101476:	5b                   	pop    %ebx
f0101477:	5e                   	pop    %esi
f0101478:	5d                   	pop    %ebp
f0101479:	c3                   	ret    

f010147a <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010147a:	f3 0f 1e fb          	endbr32 
f010147e:	55                   	push   %ebp
f010147f:	89 e5                	mov    %esp,%ebp
f0101481:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101484:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101487:	0f b6 01             	movzbl (%ecx),%eax
f010148a:	84 c0                	test   %al,%al
f010148c:	74 0c                	je     f010149a <strcmp+0x20>
f010148e:	3a 02                	cmp    (%edx),%al
f0101490:	75 08                	jne    f010149a <strcmp+0x20>
		p++, q++;
f0101492:	83 c1 01             	add    $0x1,%ecx
f0101495:	83 c2 01             	add    $0x1,%edx
f0101498:	eb ed                	jmp    f0101487 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010149a:	0f b6 c0             	movzbl %al,%eax
f010149d:	0f b6 12             	movzbl (%edx),%edx
f01014a0:	29 d0                	sub    %edx,%eax
}
f01014a2:	5d                   	pop    %ebp
f01014a3:	c3                   	ret    

f01014a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01014a4:	f3 0f 1e fb          	endbr32 
f01014a8:	55                   	push   %ebp
f01014a9:	89 e5                	mov    %esp,%ebp
f01014ab:	53                   	push   %ebx
f01014ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01014af:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014b2:	89 c3                	mov    %eax,%ebx
f01014b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01014b7:	eb 06                	jmp    f01014bf <strncmp+0x1b>
		n--, p++, q++;
f01014b9:	83 c0 01             	add    $0x1,%eax
f01014bc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01014bf:	39 d8                	cmp    %ebx,%eax
f01014c1:	74 16                	je     f01014d9 <strncmp+0x35>
f01014c3:	0f b6 08             	movzbl (%eax),%ecx
f01014c6:	84 c9                	test   %cl,%cl
f01014c8:	74 04                	je     f01014ce <strncmp+0x2a>
f01014ca:	3a 0a                	cmp    (%edx),%cl
f01014cc:	74 eb                	je     f01014b9 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01014ce:	0f b6 00             	movzbl (%eax),%eax
f01014d1:	0f b6 12             	movzbl (%edx),%edx
f01014d4:	29 d0                	sub    %edx,%eax
}
f01014d6:	5b                   	pop    %ebx
f01014d7:	5d                   	pop    %ebp
f01014d8:	c3                   	ret    
		return 0;
f01014d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01014de:	eb f6                	jmp    f01014d6 <strncmp+0x32>

f01014e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01014e0:	f3 0f 1e fb          	endbr32 
f01014e4:	55                   	push   %ebp
f01014e5:	89 e5                	mov    %esp,%ebp
f01014e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01014ea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01014ee:	0f b6 10             	movzbl (%eax),%edx
f01014f1:	84 d2                	test   %dl,%dl
f01014f3:	74 09                	je     f01014fe <strchr+0x1e>
		if (*s == c)
f01014f5:	38 ca                	cmp    %cl,%dl
f01014f7:	74 0a                	je     f0101503 <strchr+0x23>
	for (; *s; s++)
f01014f9:	83 c0 01             	add    $0x1,%eax
f01014fc:	eb f0                	jmp    f01014ee <strchr+0xe>
			return (char *) s;
	return 0;
f01014fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101503:	5d                   	pop    %ebp
f0101504:	c3                   	ret    

f0101505 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101505:	f3 0f 1e fb          	endbr32 
f0101509:	55                   	push   %ebp
f010150a:	89 e5                	mov    %esp,%ebp
f010150c:	8b 45 08             	mov    0x8(%ebp),%eax
f010150f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101513:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101516:	38 ca                	cmp    %cl,%dl
f0101518:	74 09                	je     f0101523 <strfind+0x1e>
f010151a:	84 d2                	test   %dl,%dl
f010151c:	74 05                	je     f0101523 <strfind+0x1e>
	for (; *s; s++)
f010151e:	83 c0 01             	add    $0x1,%eax
f0101521:	eb f0                	jmp    f0101513 <strfind+0xe>
			break;
	return (char *) s;
}
f0101523:	5d                   	pop    %ebp
f0101524:	c3                   	ret    

f0101525 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101525:	f3 0f 1e fb          	endbr32 
f0101529:	55                   	push   %ebp
f010152a:	89 e5                	mov    %esp,%ebp
f010152c:	57                   	push   %edi
f010152d:	56                   	push   %esi
f010152e:	53                   	push   %ebx
f010152f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101532:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101535:	85 c9                	test   %ecx,%ecx
f0101537:	74 31                	je     f010156a <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101539:	89 f8                	mov    %edi,%eax
f010153b:	09 c8                	or     %ecx,%eax
f010153d:	a8 03                	test   $0x3,%al
f010153f:	75 23                	jne    f0101564 <memset+0x3f>
		c &= 0xFF;
f0101541:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101545:	89 d3                	mov    %edx,%ebx
f0101547:	c1 e3 08             	shl    $0x8,%ebx
f010154a:	89 d0                	mov    %edx,%eax
f010154c:	c1 e0 18             	shl    $0x18,%eax
f010154f:	89 d6                	mov    %edx,%esi
f0101551:	c1 e6 10             	shl    $0x10,%esi
f0101554:	09 f0                	or     %esi,%eax
f0101556:	09 c2                	or     %eax,%edx
f0101558:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010155a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010155d:	89 d0                	mov    %edx,%eax
f010155f:	fc                   	cld    
f0101560:	f3 ab                	rep stos %eax,%es:(%edi)
f0101562:	eb 06                	jmp    f010156a <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101564:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101567:	fc                   	cld    
f0101568:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010156a:	89 f8                	mov    %edi,%eax
f010156c:	5b                   	pop    %ebx
f010156d:	5e                   	pop    %esi
f010156e:	5f                   	pop    %edi
f010156f:	5d                   	pop    %ebp
f0101570:	c3                   	ret    

f0101571 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101571:	f3 0f 1e fb          	endbr32 
f0101575:	55                   	push   %ebp
f0101576:	89 e5                	mov    %esp,%ebp
f0101578:	57                   	push   %edi
f0101579:	56                   	push   %esi
f010157a:	8b 45 08             	mov    0x8(%ebp),%eax
f010157d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101580:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101583:	39 c6                	cmp    %eax,%esi
f0101585:	73 32                	jae    f01015b9 <memmove+0x48>
f0101587:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010158a:	39 c2                	cmp    %eax,%edx
f010158c:	76 2b                	jbe    f01015b9 <memmove+0x48>
		s += n;
		d += n;
f010158e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101591:	89 fe                	mov    %edi,%esi
f0101593:	09 ce                	or     %ecx,%esi
f0101595:	09 d6                	or     %edx,%esi
f0101597:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010159d:	75 0e                	jne    f01015ad <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010159f:	83 ef 04             	sub    $0x4,%edi
f01015a2:	8d 72 fc             	lea    -0x4(%edx),%esi
f01015a5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01015a8:	fd                   	std    
f01015a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01015ab:	eb 09                	jmp    f01015b6 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01015ad:	83 ef 01             	sub    $0x1,%edi
f01015b0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01015b3:	fd                   	std    
f01015b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01015b6:	fc                   	cld    
f01015b7:	eb 1a                	jmp    f01015d3 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01015b9:	89 c2                	mov    %eax,%edx
f01015bb:	09 ca                	or     %ecx,%edx
f01015bd:	09 f2                	or     %esi,%edx
f01015bf:	f6 c2 03             	test   $0x3,%dl
f01015c2:	75 0a                	jne    f01015ce <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01015c4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01015c7:	89 c7                	mov    %eax,%edi
f01015c9:	fc                   	cld    
f01015ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01015cc:	eb 05                	jmp    f01015d3 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f01015ce:	89 c7                	mov    %eax,%edi
f01015d0:	fc                   	cld    
f01015d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01015d3:	5e                   	pop    %esi
f01015d4:	5f                   	pop    %edi
f01015d5:	5d                   	pop    %ebp
f01015d6:	c3                   	ret    

f01015d7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01015d7:	f3 0f 1e fb          	endbr32 
f01015db:	55                   	push   %ebp
f01015dc:	89 e5                	mov    %esp,%ebp
f01015de:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01015e1:	ff 75 10             	pushl  0x10(%ebp)
f01015e4:	ff 75 0c             	pushl  0xc(%ebp)
f01015e7:	ff 75 08             	pushl  0x8(%ebp)
f01015ea:	e8 82 ff ff ff       	call   f0101571 <memmove>
}
f01015ef:	c9                   	leave  
f01015f0:	c3                   	ret    

f01015f1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01015f1:	f3 0f 1e fb          	endbr32 
f01015f5:	55                   	push   %ebp
f01015f6:	89 e5                	mov    %esp,%ebp
f01015f8:	56                   	push   %esi
f01015f9:	53                   	push   %ebx
f01015fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01015fd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101600:	89 c6                	mov    %eax,%esi
f0101602:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101605:	39 f0                	cmp    %esi,%eax
f0101607:	74 1c                	je     f0101625 <memcmp+0x34>
		if (*s1 != *s2)
f0101609:	0f b6 08             	movzbl (%eax),%ecx
f010160c:	0f b6 1a             	movzbl (%edx),%ebx
f010160f:	38 d9                	cmp    %bl,%cl
f0101611:	75 08                	jne    f010161b <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101613:	83 c0 01             	add    $0x1,%eax
f0101616:	83 c2 01             	add    $0x1,%edx
f0101619:	eb ea                	jmp    f0101605 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f010161b:	0f b6 c1             	movzbl %cl,%eax
f010161e:	0f b6 db             	movzbl %bl,%ebx
f0101621:	29 d8                	sub    %ebx,%eax
f0101623:	eb 05                	jmp    f010162a <memcmp+0x39>
	}

	return 0;
f0101625:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010162a:	5b                   	pop    %ebx
f010162b:	5e                   	pop    %esi
f010162c:	5d                   	pop    %ebp
f010162d:	c3                   	ret    

f010162e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010162e:	f3 0f 1e fb          	endbr32 
f0101632:	55                   	push   %ebp
f0101633:	89 e5                	mov    %esp,%ebp
f0101635:	8b 45 08             	mov    0x8(%ebp),%eax
f0101638:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010163b:	89 c2                	mov    %eax,%edx
f010163d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101640:	39 d0                	cmp    %edx,%eax
f0101642:	73 09                	jae    f010164d <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101644:	38 08                	cmp    %cl,(%eax)
f0101646:	74 05                	je     f010164d <memfind+0x1f>
	for (; s < ends; s++)
f0101648:	83 c0 01             	add    $0x1,%eax
f010164b:	eb f3                	jmp    f0101640 <memfind+0x12>
			break;
	return (void *) s;
}
f010164d:	5d                   	pop    %ebp
f010164e:	c3                   	ret    

f010164f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010164f:	f3 0f 1e fb          	endbr32 
f0101653:	55                   	push   %ebp
f0101654:	89 e5                	mov    %esp,%ebp
f0101656:	57                   	push   %edi
f0101657:	56                   	push   %esi
f0101658:	53                   	push   %ebx
f0101659:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010165c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010165f:	eb 03                	jmp    f0101664 <strtol+0x15>
		s++;
f0101661:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101664:	0f b6 01             	movzbl (%ecx),%eax
f0101667:	3c 20                	cmp    $0x20,%al
f0101669:	74 f6                	je     f0101661 <strtol+0x12>
f010166b:	3c 09                	cmp    $0x9,%al
f010166d:	74 f2                	je     f0101661 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f010166f:	3c 2b                	cmp    $0x2b,%al
f0101671:	74 2a                	je     f010169d <strtol+0x4e>
	int neg = 0;
f0101673:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101678:	3c 2d                	cmp    $0x2d,%al
f010167a:	74 2b                	je     f01016a7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010167c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101682:	75 0f                	jne    f0101693 <strtol+0x44>
f0101684:	80 39 30             	cmpb   $0x30,(%ecx)
f0101687:	74 28                	je     f01016b1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101689:	85 db                	test   %ebx,%ebx
f010168b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101690:	0f 44 d8             	cmove  %eax,%ebx
f0101693:	b8 00 00 00 00       	mov    $0x0,%eax
f0101698:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010169b:	eb 46                	jmp    f01016e3 <strtol+0x94>
		s++;
f010169d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01016a0:	bf 00 00 00 00       	mov    $0x0,%edi
f01016a5:	eb d5                	jmp    f010167c <strtol+0x2d>
		s++, neg = 1;
f01016a7:	83 c1 01             	add    $0x1,%ecx
f01016aa:	bf 01 00 00 00       	mov    $0x1,%edi
f01016af:	eb cb                	jmp    f010167c <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01016b1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01016b5:	74 0e                	je     f01016c5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01016b7:	85 db                	test   %ebx,%ebx
f01016b9:	75 d8                	jne    f0101693 <strtol+0x44>
		s++, base = 8;
f01016bb:	83 c1 01             	add    $0x1,%ecx
f01016be:	bb 08 00 00 00       	mov    $0x8,%ebx
f01016c3:	eb ce                	jmp    f0101693 <strtol+0x44>
		s += 2, base = 16;
f01016c5:	83 c1 02             	add    $0x2,%ecx
f01016c8:	bb 10 00 00 00       	mov    $0x10,%ebx
f01016cd:	eb c4                	jmp    f0101693 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01016cf:	0f be d2             	movsbl %dl,%edx
f01016d2:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01016d5:	3b 55 10             	cmp    0x10(%ebp),%edx
f01016d8:	7d 3a                	jge    f0101714 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01016da:	83 c1 01             	add    $0x1,%ecx
f01016dd:	0f af 45 10          	imul   0x10(%ebp),%eax
f01016e1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01016e3:	0f b6 11             	movzbl (%ecx),%edx
f01016e6:	8d 72 d0             	lea    -0x30(%edx),%esi
f01016e9:	89 f3                	mov    %esi,%ebx
f01016eb:	80 fb 09             	cmp    $0x9,%bl
f01016ee:	76 df                	jbe    f01016cf <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f01016f0:	8d 72 9f             	lea    -0x61(%edx),%esi
f01016f3:	89 f3                	mov    %esi,%ebx
f01016f5:	80 fb 19             	cmp    $0x19,%bl
f01016f8:	77 08                	ja     f0101702 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01016fa:	0f be d2             	movsbl %dl,%edx
f01016fd:	83 ea 57             	sub    $0x57,%edx
f0101700:	eb d3                	jmp    f01016d5 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0101702:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101705:	89 f3                	mov    %esi,%ebx
f0101707:	80 fb 19             	cmp    $0x19,%bl
f010170a:	77 08                	ja     f0101714 <strtol+0xc5>
			dig = *s - 'A' + 10;
f010170c:	0f be d2             	movsbl %dl,%edx
f010170f:	83 ea 37             	sub    $0x37,%edx
f0101712:	eb c1                	jmp    f01016d5 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101714:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101718:	74 05                	je     f010171f <strtol+0xd0>
		*endptr = (char *) s;
f010171a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010171d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010171f:	89 c2                	mov    %eax,%edx
f0101721:	f7 da                	neg    %edx
f0101723:	85 ff                	test   %edi,%edi
f0101725:	0f 45 c2             	cmovne %edx,%eax
}
f0101728:	5b                   	pop    %ebx
f0101729:	5e                   	pop    %esi
f010172a:	5f                   	pop    %edi
f010172b:	5d                   	pop    %ebp
f010172c:	c3                   	ret    
f010172d:	66 90                	xchg   %ax,%ax
f010172f:	90                   	nop

f0101730 <__udivdi3>:
f0101730:	f3 0f 1e fb          	endbr32 
f0101734:	55                   	push   %ebp
f0101735:	57                   	push   %edi
f0101736:	56                   	push   %esi
f0101737:	53                   	push   %ebx
f0101738:	83 ec 1c             	sub    $0x1c,%esp
f010173b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010173f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101743:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101747:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010174b:	85 d2                	test   %edx,%edx
f010174d:	75 19                	jne    f0101768 <__udivdi3+0x38>
f010174f:	39 f3                	cmp    %esi,%ebx
f0101751:	76 4d                	jbe    f01017a0 <__udivdi3+0x70>
f0101753:	31 ff                	xor    %edi,%edi
f0101755:	89 e8                	mov    %ebp,%eax
f0101757:	89 f2                	mov    %esi,%edx
f0101759:	f7 f3                	div    %ebx
f010175b:	89 fa                	mov    %edi,%edx
f010175d:	83 c4 1c             	add    $0x1c,%esp
f0101760:	5b                   	pop    %ebx
f0101761:	5e                   	pop    %esi
f0101762:	5f                   	pop    %edi
f0101763:	5d                   	pop    %ebp
f0101764:	c3                   	ret    
f0101765:	8d 76 00             	lea    0x0(%esi),%esi
f0101768:	39 f2                	cmp    %esi,%edx
f010176a:	76 14                	jbe    f0101780 <__udivdi3+0x50>
f010176c:	31 ff                	xor    %edi,%edi
f010176e:	31 c0                	xor    %eax,%eax
f0101770:	89 fa                	mov    %edi,%edx
f0101772:	83 c4 1c             	add    $0x1c,%esp
f0101775:	5b                   	pop    %ebx
f0101776:	5e                   	pop    %esi
f0101777:	5f                   	pop    %edi
f0101778:	5d                   	pop    %ebp
f0101779:	c3                   	ret    
f010177a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101780:	0f bd fa             	bsr    %edx,%edi
f0101783:	83 f7 1f             	xor    $0x1f,%edi
f0101786:	75 48                	jne    f01017d0 <__udivdi3+0xa0>
f0101788:	39 f2                	cmp    %esi,%edx
f010178a:	72 06                	jb     f0101792 <__udivdi3+0x62>
f010178c:	31 c0                	xor    %eax,%eax
f010178e:	39 eb                	cmp    %ebp,%ebx
f0101790:	77 de                	ja     f0101770 <__udivdi3+0x40>
f0101792:	b8 01 00 00 00       	mov    $0x1,%eax
f0101797:	eb d7                	jmp    f0101770 <__udivdi3+0x40>
f0101799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017a0:	89 d9                	mov    %ebx,%ecx
f01017a2:	85 db                	test   %ebx,%ebx
f01017a4:	75 0b                	jne    f01017b1 <__udivdi3+0x81>
f01017a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01017ab:	31 d2                	xor    %edx,%edx
f01017ad:	f7 f3                	div    %ebx
f01017af:	89 c1                	mov    %eax,%ecx
f01017b1:	31 d2                	xor    %edx,%edx
f01017b3:	89 f0                	mov    %esi,%eax
f01017b5:	f7 f1                	div    %ecx
f01017b7:	89 c6                	mov    %eax,%esi
f01017b9:	89 e8                	mov    %ebp,%eax
f01017bb:	89 f7                	mov    %esi,%edi
f01017bd:	f7 f1                	div    %ecx
f01017bf:	89 fa                	mov    %edi,%edx
f01017c1:	83 c4 1c             	add    $0x1c,%esp
f01017c4:	5b                   	pop    %ebx
f01017c5:	5e                   	pop    %esi
f01017c6:	5f                   	pop    %edi
f01017c7:	5d                   	pop    %ebp
f01017c8:	c3                   	ret    
f01017c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017d0:	89 f9                	mov    %edi,%ecx
f01017d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01017d7:	29 f8                	sub    %edi,%eax
f01017d9:	d3 e2                	shl    %cl,%edx
f01017db:	89 54 24 08          	mov    %edx,0x8(%esp)
f01017df:	89 c1                	mov    %eax,%ecx
f01017e1:	89 da                	mov    %ebx,%edx
f01017e3:	d3 ea                	shr    %cl,%edx
f01017e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01017e9:	09 d1                	or     %edx,%ecx
f01017eb:	89 f2                	mov    %esi,%edx
f01017ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01017f1:	89 f9                	mov    %edi,%ecx
f01017f3:	d3 e3                	shl    %cl,%ebx
f01017f5:	89 c1                	mov    %eax,%ecx
f01017f7:	d3 ea                	shr    %cl,%edx
f01017f9:	89 f9                	mov    %edi,%ecx
f01017fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01017ff:	89 eb                	mov    %ebp,%ebx
f0101801:	d3 e6                	shl    %cl,%esi
f0101803:	89 c1                	mov    %eax,%ecx
f0101805:	d3 eb                	shr    %cl,%ebx
f0101807:	09 de                	or     %ebx,%esi
f0101809:	89 f0                	mov    %esi,%eax
f010180b:	f7 74 24 08          	divl   0x8(%esp)
f010180f:	89 d6                	mov    %edx,%esi
f0101811:	89 c3                	mov    %eax,%ebx
f0101813:	f7 64 24 0c          	mull   0xc(%esp)
f0101817:	39 d6                	cmp    %edx,%esi
f0101819:	72 15                	jb     f0101830 <__udivdi3+0x100>
f010181b:	89 f9                	mov    %edi,%ecx
f010181d:	d3 e5                	shl    %cl,%ebp
f010181f:	39 c5                	cmp    %eax,%ebp
f0101821:	73 04                	jae    f0101827 <__udivdi3+0xf7>
f0101823:	39 d6                	cmp    %edx,%esi
f0101825:	74 09                	je     f0101830 <__udivdi3+0x100>
f0101827:	89 d8                	mov    %ebx,%eax
f0101829:	31 ff                	xor    %edi,%edi
f010182b:	e9 40 ff ff ff       	jmp    f0101770 <__udivdi3+0x40>
f0101830:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101833:	31 ff                	xor    %edi,%edi
f0101835:	e9 36 ff ff ff       	jmp    f0101770 <__udivdi3+0x40>
f010183a:	66 90                	xchg   %ax,%ax
f010183c:	66 90                	xchg   %ax,%ax
f010183e:	66 90                	xchg   %ax,%ax

f0101840 <__umoddi3>:
f0101840:	f3 0f 1e fb          	endbr32 
f0101844:	55                   	push   %ebp
f0101845:	57                   	push   %edi
f0101846:	56                   	push   %esi
f0101847:	53                   	push   %ebx
f0101848:	83 ec 1c             	sub    $0x1c,%esp
f010184b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010184f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101853:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101857:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010185b:	85 c0                	test   %eax,%eax
f010185d:	75 19                	jne    f0101878 <__umoddi3+0x38>
f010185f:	39 df                	cmp    %ebx,%edi
f0101861:	76 5d                	jbe    f01018c0 <__umoddi3+0x80>
f0101863:	89 f0                	mov    %esi,%eax
f0101865:	89 da                	mov    %ebx,%edx
f0101867:	f7 f7                	div    %edi
f0101869:	89 d0                	mov    %edx,%eax
f010186b:	31 d2                	xor    %edx,%edx
f010186d:	83 c4 1c             	add    $0x1c,%esp
f0101870:	5b                   	pop    %ebx
f0101871:	5e                   	pop    %esi
f0101872:	5f                   	pop    %edi
f0101873:	5d                   	pop    %ebp
f0101874:	c3                   	ret    
f0101875:	8d 76 00             	lea    0x0(%esi),%esi
f0101878:	89 f2                	mov    %esi,%edx
f010187a:	39 d8                	cmp    %ebx,%eax
f010187c:	76 12                	jbe    f0101890 <__umoddi3+0x50>
f010187e:	89 f0                	mov    %esi,%eax
f0101880:	89 da                	mov    %ebx,%edx
f0101882:	83 c4 1c             	add    $0x1c,%esp
f0101885:	5b                   	pop    %ebx
f0101886:	5e                   	pop    %esi
f0101887:	5f                   	pop    %edi
f0101888:	5d                   	pop    %ebp
f0101889:	c3                   	ret    
f010188a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101890:	0f bd e8             	bsr    %eax,%ebp
f0101893:	83 f5 1f             	xor    $0x1f,%ebp
f0101896:	75 50                	jne    f01018e8 <__umoddi3+0xa8>
f0101898:	39 d8                	cmp    %ebx,%eax
f010189a:	0f 82 e0 00 00 00    	jb     f0101980 <__umoddi3+0x140>
f01018a0:	89 d9                	mov    %ebx,%ecx
f01018a2:	39 f7                	cmp    %esi,%edi
f01018a4:	0f 86 d6 00 00 00    	jbe    f0101980 <__umoddi3+0x140>
f01018aa:	89 d0                	mov    %edx,%eax
f01018ac:	89 ca                	mov    %ecx,%edx
f01018ae:	83 c4 1c             	add    $0x1c,%esp
f01018b1:	5b                   	pop    %ebx
f01018b2:	5e                   	pop    %esi
f01018b3:	5f                   	pop    %edi
f01018b4:	5d                   	pop    %ebp
f01018b5:	c3                   	ret    
f01018b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018bd:	8d 76 00             	lea    0x0(%esi),%esi
f01018c0:	89 fd                	mov    %edi,%ebp
f01018c2:	85 ff                	test   %edi,%edi
f01018c4:	75 0b                	jne    f01018d1 <__umoddi3+0x91>
f01018c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01018cb:	31 d2                	xor    %edx,%edx
f01018cd:	f7 f7                	div    %edi
f01018cf:	89 c5                	mov    %eax,%ebp
f01018d1:	89 d8                	mov    %ebx,%eax
f01018d3:	31 d2                	xor    %edx,%edx
f01018d5:	f7 f5                	div    %ebp
f01018d7:	89 f0                	mov    %esi,%eax
f01018d9:	f7 f5                	div    %ebp
f01018db:	89 d0                	mov    %edx,%eax
f01018dd:	31 d2                	xor    %edx,%edx
f01018df:	eb 8c                	jmp    f010186d <__umoddi3+0x2d>
f01018e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018e8:	89 e9                	mov    %ebp,%ecx
f01018ea:	ba 20 00 00 00       	mov    $0x20,%edx
f01018ef:	29 ea                	sub    %ebp,%edx
f01018f1:	d3 e0                	shl    %cl,%eax
f01018f3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018f7:	89 d1                	mov    %edx,%ecx
f01018f9:	89 f8                	mov    %edi,%eax
f01018fb:	d3 e8                	shr    %cl,%eax
f01018fd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101901:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101905:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101909:	09 c1                	or     %eax,%ecx
f010190b:	89 d8                	mov    %ebx,%eax
f010190d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101911:	89 e9                	mov    %ebp,%ecx
f0101913:	d3 e7                	shl    %cl,%edi
f0101915:	89 d1                	mov    %edx,%ecx
f0101917:	d3 e8                	shr    %cl,%eax
f0101919:	89 e9                	mov    %ebp,%ecx
f010191b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010191f:	d3 e3                	shl    %cl,%ebx
f0101921:	89 c7                	mov    %eax,%edi
f0101923:	89 d1                	mov    %edx,%ecx
f0101925:	89 f0                	mov    %esi,%eax
f0101927:	d3 e8                	shr    %cl,%eax
f0101929:	89 e9                	mov    %ebp,%ecx
f010192b:	89 fa                	mov    %edi,%edx
f010192d:	d3 e6                	shl    %cl,%esi
f010192f:	09 d8                	or     %ebx,%eax
f0101931:	f7 74 24 08          	divl   0x8(%esp)
f0101935:	89 d1                	mov    %edx,%ecx
f0101937:	89 f3                	mov    %esi,%ebx
f0101939:	f7 64 24 0c          	mull   0xc(%esp)
f010193d:	89 c6                	mov    %eax,%esi
f010193f:	89 d7                	mov    %edx,%edi
f0101941:	39 d1                	cmp    %edx,%ecx
f0101943:	72 06                	jb     f010194b <__umoddi3+0x10b>
f0101945:	75 10                	jne    f0101957 <__umoddi3+0x117>
f0101947:	39 c3                	cmp    %eax,%ebx
f0101949:	73 0c                	jae    f0101957 <__umoddi3+0x117>
f010194b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010194f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101953:	89 d7                	mov    %edx,%edi
f0101955:	89 c6                	mov    %eax,%esi
f0101957:	89 ca                	mov    %ecx,%edx
f0101959:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010195e:	29 f3                	sub    %esi,%ebx
f0101960:	19 fa                	sbb    %edi,%edx
f0101962:	89 d0                	mov    %edx,%eax
f0101964:	d3 e0                	shl    %cl,%eax
f0101966:	89 e9                	mov    %ebp,%ecx
f0101968:	d3 eb                	shr    %cl,%ebx
f010196a:	d3 ea                	shr    %cl,%edx
f010196c:	09 d8                	or     %ebx,%eax
f010196e:	83 c4 1c             	add    $0x1c,%esp
f0101971:	5b                   	pop    %ebx
f0101972:	5e                   	pop    %esi
f0101973:	5f                   	pop    %edi
f0101974:	5d                   	pop    %ebp
f0101975:	c3                   	ret    
f0101976:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010197d:	8d 76 00             	lea    0x0(%esi),%esi
f0101980:	29 fe                	sub    %edi,%esi
f0101982:	19 c3                	sbb    %eax,%ebx
f0101984:	89 f2                	mov    %esi,%edx
f0101986:	89 d9                	mov    %ebx,%ecx
f0101988:	e9 1d ff ff ff       	jmp    f01018aa <__umoddi3+0x6a>
