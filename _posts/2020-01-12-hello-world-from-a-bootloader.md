---
layout: default
title: Hello world from a bootloader
description: Printing text from a 512-byte bootloader in 16-bit x86 assembly
---
<link rel="stylesheet" type="text/css" href="/css/github-markdown.css" />

<style>
    .markdown-body {
        box-sizing: border-box;
        min-width: 200px;
        max-width: 980px;
        margin: 0 auto;
        padding: 45px;
    }

    .next-guide {
        text-align: center;
        font-weight: bold;
    }

    img {
        display: block;
        margin: 0 auto;
    }

    img.split {
    }

</style>

<script type="text/javascript" async
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

<div class="markdown-body"><h1>Hello world from a bootloader</h1>
<p>In my day, registers were 16 bits, computers ran one program at a time, and the
highest known number was 65,536. Programs had direct access to memory so if you
messed up your pointer math you could crash the whole computer, which was the
style at the time..</p>
<p><a target="_blank" rel="noopener noreferrer" href="/blog/hello-world-from-a-bootloader/onion-belt.jpg"><img width="50%" src="/blog/hello-world-from-a-bootloader/onion-belt.jpg" style="max-width:100%;"></a></p>
<p>Now, modern computers run hundreds or thousands of programs at once and use
newfangled nonsense like virtual memory to provide isolation between programs.
CPU register size doubled to 32 bits and then again to a ridiculous 64 bits.</p>
<p>Despite these supposed advancements,
<a href="https://en.wikipedia.org/wiki/X86" rel="nofollow">x86</a> computers have remained remarkably
backwards-compatible: 16-bit <a href="https://wiki.osdev.org/Real_Mode" rel="nofollow">real mode</a>
still exists on every modern x86 CPU.</p>
<p>Even today, when an x86 computer boots, it starts in 16-bit real mode for
compatibility with chips going back to the late 70s. It executes a tiny chunk
of 16-bit code from the beginning of the boot disk, just enough to load the
rest of the system and enable 64-bit and <a href="https://en.wikipedia.org/wiki/Protected_mode" rel="nofollow">protected
mode</a>.</p>
<p>This tiny piece of 16-bit code is called a bootloader, and as it turns out,
it's pretty straightforward to make one that does almost nothing!</p>
<h2>BIOS</h2>
<p>When an x86 computer boots, the <a href="https://en.wikipedia.org/wiki/BIOS" rel="nofollow">BIOS</a>
starts first. Its job is to initialize hardware and begin the boot process.</p>
<p><em>Note:
<a href="https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface" rel="nofollow">UEFI</a> is
a newer replacement for the BIOS but since I don't know anything about UEFI,
we'll go with the BIOS.</em></p>
<h2>BIOS interrupts</h2>
<p>The BIOS provides a set of services which can be used by our bootloader to do
useful things like:</p>
<ul>
<li>Print text to the screen.</li>
<li>Manipulate the cursor.</li>
<li>Switch to certain graphics modes.</li>
<li>Inspect the computer's hardware configuration.</li>
</ul>
<p>These services are accessed by setting registers to specific values and issuing
a <a href="https://en.wikipedia.org/wiki/BIOS_interrupt_call" rel="nofollow">BIOS interrupt</a> with the
appropriate code.</p>
<p>For example, this snippet prints the character <code>A</code> to screen:</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">ah</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">0x0E</span>
<span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">al</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-s">'A'</span>
<span class="pl-en">    </span><span class="pl-k">int</span><span class="pl-en"> </span><span class="pl-c1">0x10</span></pre></div>
<p>Back in the days of <a href="https://en.wikipedia.org/wiki/DOS" rel="nofollow">DOS</a> it was common for
everyday programs to use this BIOS-provided functionality, but these days it's
mostly just used by bootloaders.</p>
<p>With these services in place, the BIOS checks the configured boot device for
a <em>master boot record</em> which contains a bootloader which can be run.</p>
<h2>Master boot record</h2>
<p>The <a href="https://en.wikipedia.org/wiki/Master_boot_record" rel="nofollow">master boot record
(MBR)</a> is a tiny 512-byte
structure at the very beginning of a disk. This structure will house our
custom bootloader code.</p>
<p>Here's an example layout of a master boot record:</p>
<table>
<thead>
<tr>
<th>Offset</th>
<th>Description</th>
<th>Size (bytes)</th>
</tr>
</thead>
<tbody>
<tr>
<td>+0</td>
<td>Bootloader executable code</td>
<td>440</td>
</tr>
<tr>
<td>+446</td>
<td>Partition entry #1</td>
<td>16</td>
</tr>
<tr>
<td>+462</td>
<td>Partition entry #2</td>
<td>16</td>
</tr>
<tr>
<td>+478</td>
<td>Partition entry #3</td>
<td>16</td>
</tr>
<tr>
<td>+494</td>
<td>Partition entry #4</td>
<td>16</td>
</tr>
<tr>
<td>+510</td>
<td>Boot signature (0x55, 0xAA)</td>
<td>2</td>
</tr>
</tbody>
</table>
<p><em>Note: There are a lot of variations on this structure. Most involve using the
end of the code section to store additional meta-data about the disk.</em></p>
<p>When it's time to boot into an operating system, the BIOS checks the configured
boot disk for the boot signature: a magic number sequence of <code>[0x55, 0xAA]</code> at
byte offsets 510 and 511. If found, the BIOS assumes this is a valid boot
sector.</p>
<p>The BIOS loads the 512-byte MBR into memory starting at address 0x7C00 and
executes the code at this address, passing control over to the bootloader.</p>
<p><em>Note: The <a href="https://en.wikipedia.org/wiki/GUID_Partition_Table" rel="nofollow">GUID Partition Table or
GPT</a> is a newer replacement
format for partition tables.</em></p>
<h2>A custom bootloader</h2>
<p>A typical bootloader is responsible for bootstrapping the rest of the system.
It may look up hardware configuration data from the BIOS, implement a simple
filesystem driver, and use that driver to load the rest of the system into
memory from disk.</p>
<p>Our simple bootloader won't be quite so fancy: we'll just write a message to
the screen.</p>
<p>Here's the full assembly file (line-by-line breakdown to follow):</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-c1">%define</span> <span class="pl-en">NULL </span><span class="pl-c1">0</span>

<span class="pl-en">org </span><span class="pl-c1">0x7C00</span>

<span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">si</span><span class="pl-s1">,</span><span class="pl-en"> message</span>

<span class="pl-en">print_string:</span>
<span class="pl-en">    </span><span class="pl-k">lodsb</span>

<span class="pl-c">    ; Check for the NULL-termination character. If found, exit the loop.</span>
<span class="pl-en">    </span><span class="pl-k">cmp</span><span class="pl-en"> </span><span class="pl-v">al</span><span class="pl-s1">,</span><span class="pl-en"> NULL</span>
<span class="pl-en">    </span><span class="pl-k">je</span><span class="pl-en"> infinite_loop</span>

<span class="pl-c">    ; Write the byte in `al` as an ASCII character to the screen.</span>
<span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">ah</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">0x0E</span>
<span class="pl-en">    </span><span class="pl-k">int</span><span class="pl-en"> </span><span class="pl-c1">0x10</span>

<span class="pl-en">    </span><span class="pl-k">jmp</span><span class="pl-en"> print_string</span>

<span class="pl-en">infinite_loop:</span>
<span class="pl-en">    </span><span class="pl-k">jmp</span><span class="pl-en"> infinite_loop</span>

<span class="pl-en">message: db </span><span class="pl-s">"Hi, I'</span><span class="pl-en">m a bootloader who doesn</span><span class="pl-s">'t load anything."</span><span class="pl-s1">,</span><span class="pl-en"> `\r`</span><span class="pl-s1">,</span><span class="pl-en"> `\n`</span><span class="pl-s1">,</span><span class="pl-en"> NULL</span>

<span class="pl-c">; Pad out the file to the 510th byte with zeroes.</span>
<span class="pl-c1">times</span><span class="pl-en"> </span><span class="pl-c1">510</span><span class="pl-s1">-</span><span class="pl-en">($</span><span class="pl-s1">-</span><span class="pl-en">$$) db </span><span class="pl-c1">0</span>

<span class="pl-c">; MBR boot signature.</span>
<span class="pl-c1">db</span><span class="pl-en"> </span><span class="pl-c1">0x55</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">0xAA</span></pre></div>
<p>To run it, save the above code to a file named <code>hello.asm</code> and use
<a href="https://www.nasm.us/" rel="nofollow">NASM</a> to assemble it:</p>
<div class="highlight highlight-source-shell"><pre>$ nasm hello.asm -f bin -o hello.bin</pre></div>
<p>Now use <a href="https://www.qemu.org/" rel="nofollow">QEMU</a> to emulate an x86 computer and boot from
the custom bootloader:</p>
<div class="highlight highlight-source-shell"><pre>$ qemu-system-x86 hello.bin</pre></div>
<p>When I run this, I see:</p>
<p><a target="_blank" rel="noopener noreferrer" href="/blog/hello-world-from-a-bootloader/in-qemu.png"><img width="100%" src="/blog/hello-world-from-a-bootloader/in-qemu.png" style="max-width:100%;"></a></p>
<h2>Line-by-line breakdown</h2>
<p>If you're interested in a line-by-line breakdown, read on!</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-c1">%define</span> <span class="pl-en">NULL </span><span class="pl-c1">0</span></pre></div>
<p>This is a NASM macro. No code is emitted to the binary as a result of this
directive, it's just a convenience for the programmer to make it a little
clearer that the <code>0</code> is the NULL-termination character.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">org </span><span class="pl-c1">0x7C00</span></pre></div>
<p>When the virtual machine boots, it will load the bootloader binary into memory
starting at address 0x7C00. NASM uses the <code>org</code> directive to figure out what
offsets to use for things like jump labels and the message string.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">si</span><span class="pl-s1">,</span><span class="pl-en"> message</span></pre></div>
<p><code>si</code> is the <em>source index register</em>. It's commonly used for reading source data
into an algorithm, and that's exactly what we'll use it for!</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">print_string:</span></pre></div>
<p>This begins the loop to print the message to the screen. Each time the loop
runs, it prints one character.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">lodsb</span></pre></div>
<p>This instruction is short for something like <em>load string byte</em>. It loads one
byte into the <code>al</code> register from the address <code>si</code> is pointing to (in this case,
the message string).</p>
<p>Additionally, it increments the address in <code>si</code> so we'll see the next character
in the following loop iteration instead of processing the same character over
and over.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">cmp</span><span class="pl-en"> </span><span class="pl-v">al</span><span class="pl-s1">,</span><span class="pl-en"> NULL</span></pre></div>
<p>The message string is NULL-terminated, which means the end of the string is
marked by the NULL value: <code>0</code> in ASCII. We compare the current character to the
NULL-termination character to see if we've reached the end of the string yet.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">je</span><span class="pl-en"> break_loop</span></pre></div>
<p>If the current character is NULL, we've reached the end of the string, so we
jump out of the loop to stop processing.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">ah</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">0x0E</span>
<span class="pl-en">    </span><span class="pl-k">int</span><span class="pl-en"> </span><span class="pl-c1">0x10</span></pre></div>
<p>If there are still characters left in the string, we ask the BIOS to print one!
By setting <code>ah</code> to <code>0x0E</code> and then interrupting the BIOS with interrupt code
<code>0x10</code>, the BIOS will check <code>al</code> for an ASCII character and print it out on
the screen.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">jmp</span><span class="pl-en"> print_string</span></pre></div>
<p>Jump back to the <code>print_string:</code> label. This starts the loop over again and
outputs the next character to the screen.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">infinite_loop:</span>
<span class="pl-en">    </span><span class="pl-k">jmp</span><span class="pl-en"> infinite_loop</span></pre></div>
<p>Once the entire string has been printed, we'll jump here to stop printing
characters.</p>
<p>This is an infinite loop at the end of the bootloader. If this wasn't here,
execution would continue and the computer would try to execute the contents
of <code>message</code> as if it were x86 code.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">message: db </span><span class="pl-s">"Hi, I'</span><span class="pl-en">m a bootloader who doesn</span><span class="pl-s">'t load anything."</span><span class="pl-s1">,</span><span class="pl-en"> `\r`</span><span class="pl-s1">,</span><span class="pl-en"> `\n`</span><span class="pl-s1">,</span><span class="pl-en"> NULL</span></pre></div>
<p>This is the message we print to screen, in
<a href="https://en.wikipedia.org/wiki/ASCII" rel="nofollow">ASCII</a> encoding. The last 3 characters
are <em>control characters</em>:</p>
<ul>
<li><code>\r</code> is a carriage return, which moves the cursor back to the beginning of
the line.</li>
<li><code>\n</code> is the newline character, which moves the cursor down to the next line.</li>
<li>The NULL-termination character indicates the end of the string so the loop
can detect when to stop printing characters.</li>
</ul>
<div class="highlight highlight-source-assembly"><pre><span class="pl-c1">times</span><span class="pl-en"> </span><span class="pl-c1">510</span><span class="pl-s1">-</span><span class="pl-en">($</span><span class="pl-s1">-</span><span class="pl-en">$$) db </span><span class="pl-c1">0</span></pre></div>
<p>This inscrutable-looking line tells the assembler to pad out the generated
binary file to the 510th byte with <code>0</code>s.</p>
<p>Roughly translated:</p>
<ul>
<li><code>times</code> repeats a directive a given number of times.</li>
<li><code>510-($-$$)</code> is an expression which evaluates to <code>510 minus the number of bytes before this position in the file</code>.</li>
<li><code>db</code> generates a byte in the binary file.</li>
<li><code>0</code> indicates the generated byte should have a value of, you guessed it, <code>0</code>.</li>
</ul>
<p>So all together, this writes <code>0</code>s up to and including the 510th byte of the
binary file.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-c1">db</span><span class="pl-en"> </span><span class="pl-c1">0x55</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">0xAA</span></pre></div>
<p>This writes the 2-byte boot sequence to the end of the file. For a bootloader
to be recognized as such, it's expected to have its 511th and 512th bytes set
to the values <code>0x55</code> and <code>0xAA</code>. If these aren't here, some BIOS
implementations may not recognize this as a bootloader and fail to load it.</p></div>
