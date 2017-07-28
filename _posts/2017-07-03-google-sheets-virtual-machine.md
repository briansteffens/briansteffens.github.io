---
layout: default
title: Google Sheets virtual machine
description: A simple virtual machine demonstration inside a spreadsheet
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

<div class="markdown-body"><h1>Making a virtual machine in Google Sheets</h1>
<p>I recently noticed that Google Docs has a pretty full-featured scripting system
called <a href="https://developers.google.com/apps-script/">Apps Script</a>. It lets you
write JavaScript to do some pretty useful things:</p>
<ul>
<li>Run code in response to events like documents opening or cells changing</li>
<li>Make custom Google Sheets spreadsheet functions for formulas</li>
<li>Use services like Google Translate to translate text or Gmail to send email</li>
<li>Add new menu items to the Google Docs interface with your custom features</li>
</ul>
<p>So naturally I had to do something weird with it. Behold: the Google Sheets
Virtual Machine generating fibonacci numbers!</p>
<p><a href="/blog/google-sheets-virtual-machine/fibonacci.gif" target="_blank"><img src="/blog/google-sheets-virtual-machine/fibonacci.gif" style="max-width:100%;"></a></p>
<h1>How it works</h1>
<p>The VM has a memory area of 100 cells, indexed as 0-99. Each cell can contain
an instruction or an integer value.</p>
<p>There's also a stack, which starts at the bottom of the memory area and grows
upward.</p>
<p>Here's how the VM sheet looks when it's empty:</p>
<p><a href="/blog/google-sheets-virtual-machine/blank.png" target="_blank"><img src="/blog/google-sheets-virtual-machine/blank.png" style="max-width:100%;"></a></p>
<p>Notice the following:</p>
<ul>
<li><strong>RA</strong>, <strong>RB</strong>, <strong>RC</strong>, and <strong>RD</strong> are general purpose registers.</li>
<li><strong>RI</strong> is the instruction pointer. It points to the next instruction to be
executed in the memory area, which lights up green.</li>
<li><strong>RS</strong> is the stack pointer. It points to the memory cell at the top of the
stack. This lights up blue.</li>
<li><strong>Output</strong> displays the output of a program.</li>
<li><strong>Error</strong> displays any errors encountered in parsing or executing an
instruction.</li>
<li><strong>Memory</strong> is a region of 100 cells of memory.</li>
</ul>
<p>To run an instruction, the Apps Script in the background checks the value
of <strong>RI</strong> to see which instruction to execute next. It reads the instruction
in the cell <strong>RI</strong> is pointing to and parses it.</p>
<p>There are instructions to move data around between memory and registers,
manipulate the stack, or perform conditionals.</p>
<p>After the instruction has been executed, the value of <strong>RI</strong> is
incremented to point to the next cell in memory.</p>
<h1>Usage</h1>
<p>There is a custom menu called <em>Computer</em> with some functions used to control
the VM:</p>
<p><a href="/blog/google-sheets-virtual-machine/menu.png" target="_blank"><img src="/blog/google-sheets-virtual-machine/menu.png" style="max-width:100%;"></a></p>
<ul>
<li><strong>Run</strong> will run the current program until it ends or an error is
encountered.</li>
<li><strong>Step</strong> runs one instruction and then pauses.</li>
<li><strong>Reset</strong> clears all registers and the output field, which makes the program
ready to run again.</li>
<li><strong>Load Factorial Program</strong> loads the factorial example from another sheet.</li>
<li><strong>Load Fibonacci Program</strong> loads the fibonacci example from another sheet.</li>
</ul>
<h1>Instructions</h1>
<p>There are a few instructions implemented.</p>
<h3>General</h3>
<ul>
<li><strong>mov dst src</strong> copies a value from <em>src</em> to <em>dst</em>.</li>
</ul>
<h3>Math</h3>
<ul>
<li>
<p><strong>add dst src</strong> adds <em>dst</em> to <em>src</em> and stores the result in <em>dst</em>.</p>
</li>
<li>
<p><strong>sub dst src</strong> subtracts <em>src</em> from <em>dst</em> and stores the result in <em>dst</em>.</p>
</li>
<li>
<p><strong>mul dst src</strong> multiplies <em>dst</em> by <em>src</em> and stores the result in <em>dst</em>.</p>
</li>
</ul>
<h3>Stack operations</h3>
<ul>
<li>
<p><strong>push src</strong> pushes <em>src</em> onto the stack.</p>
</li>
<li>
<p><strong>pop dst</strong> pops a value off the top of the stack and stores it in <em>dst</em>.</p>
</li>
</ul>
<h3>Jumps and conditionals</h3>
<ul>
<li>
<p><strong>jmp target</strong> jumps to the instruction in the cell referenced by <em>target</em>.</p>
</li>
<li>
<p><strong>jl cmp1 cmp2 target</strong> compares <em>cmp1</em> to <em>cmp2</em>. If <em>cmp1</em> is less than
<em>cmp2</em>, execution jumps to <em>target</em>.</p>
</li>
</ul>
<h3>Functions</h3>
<ul>
<li>
<p><strong>call target</strong> is a function call. It pushes the current instruction pointer
onto the stack so it can be returned to later, and then jumps to <em>target</em>.</p>
</li>
<li>
<p><strong>ret</strong> returns from a function. It pops a value off the stack and jumps to
it.</p>
</li>
</ul>
<h3>Assorted</h3>
<ul>
<li>
<p><strong>output src</strong> writes <em>src</em> to the <em>Output:</em> section of the interface.</p>
</li>
<li>
<p><strong>end</strong> ends the program.</p>
</li>
</ul>
<h1>Addressing modes</h1>
<p>The operands in the instructions above can take a few forms:</p>
<p><strong>Immediates</strong> are literal values embedded into the instruction. Examples are:
<code>7</code> and <code>123</code>. So to copy the value 7 into the register <em>ra</em>:</p>
<pre><code>mov ra 7
</code></pre>
<p><strong>Registers</strong> refer to registers by name. Examples are: <code>ra</code>, <code>rb</code>, <code>rc</code>. To
copy the value from <em>rc</em> into <em>rb</em>:</p>
<pre><code>mov rb rc
</code></pre>
<p><strong>Memory</strong> refers to a value inside a cell of the memory area. Examples are:
<code>$0</code>, <code>$10</code>, <code>$99</code>. To copy the value from <em>ra</em> into the first memory cell:</p>
<pre><code>mov $0 ra
</code></pre>
<p>To copy the value from the last memory cell into <em>rd</em>:</p>
<pre><code>mov rd $99
</code></pre>
<p><strong>Indirect</strong> refers to the value a cell of memory is pointing to. Examples are:
<code>@15</code>, <code>@50</code>. So if memory cell 10 contained the value 20 and memory cell 20
contained the value 30, you could copy the value 30 into <em>ra</em> like this:</p>
<pre><code>mov ra @10
</code></pre>
<p>It looks at memory cell 10 to find the value 20. Then it looks at memory cell
20 to find the value 30 and copies that value into <em>ra</em>.</p>
<h1>Recursion</h1>
<p>You can use the stack and the <em>call</em> and <em>ret</em> instructions to make recursive
calls. Here's an example which uses recursion to generate the factorial of
the number 5:</p>
<p><a href="/blog/google-sheets-virtual-machine/factorial.gif" target="_blank"><img src="/blog/google-sheets-virtual-machine/factorial.gif" style="max-width:100%;"></a></p>
<p>The code starting at <code>jl ra 2 50</code> is a function which takes an input in <em>ra</em>
and returns a result in <em>rd</em>. It calls itself recursively to calculate the
factorial of the value in <em>ra</em>.</p>
<h1>Getting a copy</h1>
<p>If you want to play around with this yourself, you can make a copy of it
<a href="https://docs.google.com/spreadsheets/d/1385V2Mu2yZOMSJcSz9JrV6r8X0_JGzHZZRdPhaAdwWY/edit?usp=sharing">here</a>.</p>
<p>You can see the Apps Script code by going to Tools and then Script Editor.</p></div>
