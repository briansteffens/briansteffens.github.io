Graphics in a bootloader
========================

### Intro


Reference previous post


# BIOS graphics modes






# Video memory layout

<img border="1" width="70%" src="/blog/graphics-in-a-bootloader/video-layout.jpg" />

|  0   |  1   |  2   |  3   |  4   |  5   |  6   |  7   |  8   |
|------|------|------|------|------|------|------|------|------|
|  0   |  0   |  0   |  0   |  0   |  0   |  0   |  0   |  0   |
|**9** |**10**|**11**|**12**|**13**|**14**|**15**|**16**|**17**|
|  0   |  0   |  0   |  0   |  0   |  0   |  0   |  0   |  0   |
|**18**|**19**|**20**|**21**|**22**|**23**|**24**|**25**|**26**|
|  0   |  0   |  0   |  0   |  0   |  0   |  0   |  0   |  0   |



# Memory segmentation

So we know video memory starts at `0xA0000` which is `655,360` and we know how
to translate 2-dimensional screen-space coordinates into a 1-dimensional offset
into that video memory. All we need to do is write some instructions to perform
this math, load the final memory address into a register, and write some color
data to that memory location, right?

The problem is we're using 16-bit code, which means registers are also 16-bit:
the highest unsigned integer we can store is `65,536` but video memory doesn't
even start until `655,360`! How can we access this memory?

If we were running in 32-bit or 64-bit mode, this wouldn't be a problem:

| Register size | Largest unsigned integer   | Directly-addressable memory |
|---------------|----------------------------|-----------------------------|
| 16 bits       | 65,536                     | 64 kilobytes                |
| 32 bits       | 4,294,967,296              | 4 gigabytes                 |
| 64 bits       | 18,446,744,073,709,551,616 | 16 exabytes                 |

So how can we address memory beyond 64 KiB with 16-bit registers? By using
more than one!

16-bit mode uses a *memory segmentation* model where the total addressable
memory is divided into a number of virtual segments. A simpler way of
explaining this is we use two registers to refer to an address in memory since
one register wouldn't be enough.

To use a segment that begins where the video memory begins at `0xA0000`, we
would use the segment selector `0xA000`. Notice there's one fewer zero. A
segment selector has an additional implicit 4 zero bits on the least significant
bit side. So the segment `0xA000`, which is `0b1010000000000000`, becomes
`0b10100000000000000000` or `0xA0000`.

TODO: drawing?

*Note: you can also multiply/divide by `0x10` to make this conversion simpler.*

Once you have a segment selector, you can combine it with an offset to produce
a complete *segmented address*: `[0xA000:0x0]` refers to the first byte of
video memory and `[0xA000:0x20]` refers to the 32nd byte of video memory.

## Segment registers

To use a segmented address in assembly code, we need to load the segment
selector into a segment register. There are 6, some with special uses:

- SS: Stack segment.
- CS: Code segment.
- DS: Data segment.
- ES: Extra segment.
- FS: Another extra segment.
- GS: Another another extra segment.

The stack segment is used for stack operations so we should leave that one
alone. Similarly, the code segment is used when the CPU reads code from
memory in order to execute it. Pointing either of these segment registers to
video memory would cause big problems.

The data segment and the three extra segments are all options. The main
difference between these segments is some of them are used by default in
specific situations.

- Stack instructions like `push`, `pop`, `call`, and `ret` use the stack
  segment.
- Code-related instructions like `jmp` use the code segment.
- The data segment is the default for many data operations.
- The first extra segment `ES` is the default for string operations like `movs`
  or `cmps`.

With the exception of the stack and code segments, the other segment defaults
can be overridden by specifying a segment register. So to write the value `42`
to the 32nd byte of video memory, we could do:

```nasm
mov gs, 0xA000
mov bx, 0x20
mov [gs:bx], 42
```

(Let's go with `gs` and pretend it stands for graphics segment!)


# Color codes



# Drawing pixels to screen



# Animated rainbow demo thing
