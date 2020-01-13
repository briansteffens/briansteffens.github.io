Hello world from a bootloader
=============================

In my day, registers were 16 bits, computers ran one program at a time, and the
highest number known was 65,536. Programs had direct access to memory so if you
messed up your pointer math you could crash the whole computer, which was the
style at the time..

<img width="50%" src="/blog/hello-world-from-a-bootloader/onion-belt.jpg" />

Modern processors run hundreds or thousands of programs at once and use
newfangled things like virtual memory to provide isolation between programs.
Registers doubled to 32 bits and then again to a ridiculous 64 bits.

Despite all these supposed advancements,
[x86](https://en.wikipedia.org/wiki/X86) computers have remained remarkably
backwards-compatible: 16-bit [real mode](https://wiki.osdev.org/Real_Mode)
still exists on every modern x86 CPU.

Even today, when a modern x86 computer boots, it assumes it may be running
software from the 80s, so it starts in real mode for compatibility purposes.
It executes a tiny chunk of 16-bit code from the beginning of the boot disk.
These days, this is usually just enough code to bootstrap the rest of the
system and switch to the modern 64-bit
[protected mode](https://en.wikipedia.org/wiki/Protected_mode).

This tiny piece of 16-bit bootstrapping code is called a bootloader.

## Boot sequence

*Note:
[UEFI](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface) is
a newer replacement for the BIOS but since I don't know anything about UEFI,
we'll target the legacy BIOS.*

When an x86 computer boots, the [BIOS](https://en.wikipedia.org/wiki/BIOS)
starts first. Its job is to initialize hardware and start the boot process.
Additionally, the BIOS provides a set of services which can be used by
bootloaders and operating systems to do useful stuff like:

- Print text to the screen.
- Manipulate the cursor.
- Switch to certain graphics modes.
- Inspect the computer's hardware configuration.

These services are accessed by setting registers to specific values and then
issuing an [interrupt](https://en.wikipedia.org/wiki/BIOS_interrupt_call) with
the appropriate code.

As an example, the following snippet prints the character `A` to screen:

```nasm
    mov ah, 0x0E
    mov al, 'A'
    int 0x10
```

The BIOS then checks the configured boot disk to make sure it contains a
valid boot sector. A boot sector is a small 512-byte chunk of code
at the very beginning of a disk or hard drive, in the space before any
partitions.

The BIOS checks the boot disk for a magic number sequence of `[0x55, 0xAA]` at
byte offsets 510 and 511. If found, the BIOS assumes it's a valid boot sector.
It loads the first 512 bytes from the disk into memory at address 0x7C00 and
executes the code at this address, passing control over to the bootloader.

The bootloader uses the services provided by the BIOS to inspect the computer's
hardware configuration and boot the operating system (or the next stage in the
boot process in the case of multi-stage boot). It may also present a boot menu
to the user or display a logo or other graphic.

We can make a very simple bootloader by writing a bit of 16-bit x86 code and
assembling it with [NASM](https://en.wikipedia.org/wiki/Netwide_Assembler).
This could be used to boot a physical computer but it's much easier to use a
virtual machine. [QEMU](https://en.wikipedia.org/wiki/QEMU) can be used for
this purpose.


## The bootloader

A typical bootloader runs just enough code to bootstrap the rest of the system.
It may lookup hardware configuration data from the BIOS, implement simple disk
and filesystem drivers, and use those drivers to load the rest of the system
into memory from disk.

Our simple bootloader won't be quite so fancy: we'll just boot up and write a
message to the screen by performing a BIOS interrupt for each character in a
string.

Here's the full assembly file (line-by-line breakdown to follow):

```nasm
%define NULL 0

org 0x7C00

    mov si, message

print_string:
    lodsb

    ; Check for the NULL-termination character. If found, exit the loop.
    cmp al, NULL
    je infinite_loop

    ; Write the byte in `al` as an ASCII character to the screen.
    mov ah, 0x0E
    int 0x10

    jmp print_string

infinite_loop:
    jmp infinite_loop

message: db "Hi, I'm a bootloader who doesn't load anything.", `\r`, `\n`, NULL

times 510-($-$$) db 0
dw 0xAA55
```

To boot a computer with this, save the above code to a file named `hello.asm`
and use NASM to assemble it:

```bash
$ nasm hello.asm -f bin -o hello.bin
```

Now use QEMU to emulate an x86 computer and tell it to boot our custom
bootloader:

```bash
$ qemu-system-x86 hello.bin
```

When I run this, I see:

<img width="100%" src="/blog/hello-world-from-a-bootloader/in-qemu.png" />


## Line-by-line breakdown

If you're interested in a line-by-line breakdown, read on!

```nasm
%define NULL 0
```

This is a NASM macro. No code is emitted to the binary as a result of this
directive, it's just a convenience for the programmer to make it a little
clearer that the `0` is the NULL-termination character.

```nasm
org 0x7C00
```

When the virtual machine boots, it will load our bootloader binary into memory
starting at address 0x7C00. NASM uses the `org` directive to figure out what
offsets to use for things like jump labels and the message string.

```nasm
    mov si, message
```

`si` is the *source index register*. It's commonly used for reading source data
into an algorithm, and that's exactly what we'll use it for!

```nasm
print_string:
```

This begins the loop to print the message to the screen. Each time the loop
runs, it prints one character.

```nasm
    lodsb
```

This instruction is short for something like *load string byte*. It loads one
byte into the `al` register from the address `si` is pointing to (in this case,
the message string).

Additionally, it increments the address in `si` so we'll see the next character
in the following loop iteration instead of processing the same character over
and over.

```nasm
    cmp al, NULL
```

The message string is NULL-terminated, which means the end of the string is
marked by the NULL value: `0` in ASCII. We compare the current character to the
NULL-termination character to see if we've reached the end of the string yet.

```nasm
    je break_loop
```

If the current character is NULL, we've reached the end of the string, so we
jump out of the loop to stop processing.

```nasm
    mov ah, 0x0E
    int 0x10
```

If there are still characters left in the string, we ask the BIOS to print one!
By setting `ah` to `0x0E` and then interrupting the BIOS with interrupt code
`0x10`, the BIOS will check `al` for an ASCII character and print it out on
the screen.

It's not super important to memorize these specific codes, they're just magic
numbers you look up when you need to make calls. In this situation, the BIOS
is a lot like a library we'd use in a normal program.

```nasm
    jmp print_string
```

Jump back to the `print_string:` label. This starts the loop over again and
outputs the next character to the screen.

```nasm
infinite_loop:
    jmp infinite_loop
```

Once the entire string has been printed, we'll jump here to stop printing
characters.

This is an infinite loop at the end of the bootloader. If this wasn't here,
execution would continue and the computer would try to execute the contents
of `message` as if it were x86 code.

```nasm
message: db "Hi, I'm a bootloader who doesn't load anything.", `\r`, `\n`, NULL
```

This is the message we print to screen, in
[ASCII](https://en.wikipedia.org/wiki/ASCII) encoding. The last 3 characters
are *control characters*:

- `\r` is a carriage return, which moves the cursor back to the beginning of
  the line.
- `\n` is the newline character, which moves the cursor down to the next line.
- The NULL-termination character indicates the end of the string so we know
  when to stop printing characters.

```nasm
times 510-($-$$) db 0
```

This inscrutable-looking line tells the assembler to pad out the generated
binary file to the 510th byte with `0`s.

Roughly translated:

- `times` repeats a directive a given number of times.
- `510-($-$$)` is an expression which evaluates to `510 minus the number of
  bytes before this position in the file`.
- `db` generates a byte in the binary file.
- `0` indicates the generated byte should have a value of, you guessed it, `0`.

So all together, this writes `0`s up to and including the 510th byte of the
binary file.

```nasm
dw 0xAA55
```

This writes the 2-byte boot sequence to the end of the file. For a bootloader
to be recognized as such, it's expected to have its 511th and 512th bytes set
to the values `0xAA` and `0x55`. If these aren't here, some BIOS
implementations may not recognize this as a bootloader and fail to load it.

