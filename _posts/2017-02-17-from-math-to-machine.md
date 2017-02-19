---
layout: default
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
</style>

<div class="markdown-body"><h1>From Math To Machine: Factorials</h1>
<p>In this post I'm going to explore how the same idea can be represented in
several ways and show how a mathematical concept can be redefined in
progressively more computer-oriented terms, all the way down to x86-64
assembly, almost ready for direct execution by a computer. To that end, I'm
going to define the same logic in several different formats:</p>
<ol>
<li><strong>Math</strong> - pure mathy goodness</li>
<li><strong>Haskell</strong> - a functional programming language</li>
<li><strong>C</strong> - an imperative programming language</li>
<li><strong>Assembly</strong> - instructions a computer can execute (almost) directly</li>
</ol>
<p>If you're interested in how language styles can differ or curious about what
your code might look like after being compiled, keep reading!</p>
<h1>Factorials in math</h1>
<p>A factorial is the product of an integer and all smaller integers greater
than 0. For example, the factorial of 5 is:</p>
<pre><code>5! = 1 * 2 * 3 * 4 * 5
</code></pre>
<p>Or:</p>
<pre><code>5! = 120
</code></pre>
<p>Here are the first few factorials:</p>
<table>
<thead>
<tr>
<th>n</th>
<th>n!</th>
</tr>
</thead>
<tbody>
<tr>
<td>0!</td>
<td>1</td>
</tr>
<tr>
<td>1!</td>
<td>1</td>
</tr>
<tr>
<td>2!</td>
<td>2</td>
</tr>
<tr>
<td>3!</td>
<td>6</td>
</tr>
<tr>
<td>4!</td>
<td>24</td>
</tr>
<tr>
<td>5!</td>
<td>120</td>
</tr></tbody></table>
<p>Notice that, with the exception of 0! which is fixed at 1, each subsequent
value of n is n * the previous factorial. Example:</p>
<table>
<thead>
<tr>
<th>n</th>
<th>n!</th>
</tr>
</thead>
<tbody>
<tr>
<td>0!</td>
<td>1</td>
</tr>
<tr>
<td>1!</td>
<td>1 * 0! = 1</td>
</tr>
<tr>
<td>2!</td>
<td>2 * 1! = 2</td>
</tr>
<tr>
<td>3!</td>
<td>3 * 2! = 6</td>
</tr>
<tr>
<td>4!</td>
<td>4 * 3! = 24</td>
</tr>
<tr>
<td>5!</td>
<td>5 * 4! = 120</td>
</tr></tbody></table>
<p>This is what's called a recursive definition: the value of each factorial
depends on the value of the previous factorial, which in turn depends on the
value of the factorial before that, and so on, until you reach 0!, where the
recursion stops. The point at which the recursion stops is called the base
case.</p>
<p>In math terms, this recursive definition can be stated many ways. One such way
is as follows:</p>
<pre><code>0! = 1
n! = n * (n - 1)!
</code></pre>
<p>The above states that factorials follow two rules:</p>
<ol>
<li>The factorial of 0 is always equal to 1.</li>
<li>The factorial of any other positive integer <em>n</em> is the product of <em>n</em> and
the factorial of <code>n - 1</code>.</li>
</ol>
<p>So, applying these rules when <em>n</em> is 5 produces something like the following:</p>
<pre><code>5! = 5 * (5 - 1) * (5 - 2) * (5 - 3) * (5 - 4) * 1
</code></pre>
<p>The integer <em>n</em> is multiplied by each smaller integer until it reaches the base
case of 1.</p>
<h1>Factorials in a functional language</h1>
<p>Just like there are lots of ways to describe something mathematically, there
are also lots of ways to describe things to computers. Let's start with
Haskell, which among other useful features, happens to have a pretty cool
looking logo:</p>
<p><a href="/blog/from-math-to-machine/haskell-logo.svg" target="_blank"><img src="/blog/from-math-to-machine/haskell-logo.svg" style="max-width:100%;"></a></p>
<p>Haskell is a purely functional language. In broad terms, this means that
instead of telling the computer <em>what to do</em>, a Haskell program tells the
computer <em>what things are</em>. Once a program has been written in Haskell, it's
up to the Haskell compiler to figure out how to translate those definitions
into actionable instructions which a computer can understand.</p>
<p>Because Haskell programs specify definitions of concepts, they can be
surprisingly similar to pure math representations. Take a look at the following
Haskell function, which calculates the factorial of the parameter provided to
it:</p>
<div class="highlight highlight-source-haskell"><pre><span class="pl-en">factorial</span> <span class="pl-k">::</span> <span class="pl-en"><span class="pl-c1">Int</span></span> <span class="pl-k">-&gt;</span> <span class="pl-en"><span class="pl-c1">Int</span></span>
factorial n <span class="pl-k">=</span> <span class="pl-c1">product</span> [<span class="pl-c1">1</span><span class="pl-k">..</span>n]</pre></div>
<p>If you haven't played around with functional languages yet, this probably looks
pretty strange.</p>
<p>The first line says that <em>factorial</em> is a function which takes an integer and
returns another integer. Here's an oddly-formatted version of that first line,
spaced out so you can see roughly which parts of the syntax mean what:</p>
<div class="highlight highlight-source-haskell"><pre><span class="pl-c"><span class="pl-c">--</span> factorial is a function which takes an integer and returns another integer</span>
<span class="pl-en">factorial</span>            <span class="pl-k">::</span>                     <span class="pl-en"><span class="pl-c1">Int</span></span>          <span class="pl-k">-&gt;</span>             <span class="pl-en"><span class="pl-c1">Int</span></span></pre></div>
<p>This first line is technically optional but it's usually good practice to
include it. Haskell is pretty smart so it can actually figure out type
signatures on its own most of the time, but it's still useful to document the
function signature for other programmers or your future self.</p>
<p>The second line defines the function body, which can be read as "the factorial
of n is equal to the product of all integers from 1 to n". Here's another
spaced out version to show which parts of the syntax match roughly:</p>
<div class="highlight highlight-source-haskell"><pre><span class="pl-c"><span class="pl-c">--</span> The factorial of n is equal to the product of all integers from 1 to n</span>
       factorial    n      <span class="pl-k">=</span>          <span class="pl-c1">product</span>                     [<span class="pl-c1">1</span> <span class="pl-k">..</span> n]</pre></div>
<p>Notice we're not telling Haskell how to calculate a factorial, we're defining
what a factorial is. This is one of the more important differences between
functional languages and imperative languages.</p>
<p>Let's break this definition down further. When this function is called with
some number <em>n</em>, the part after the equal sign is evaluated and returned:</p>
<div class="highlight highlight-source-haskell"><pre><span class="pl-c1">product</span> [<span class="pl-c1">1</span><span class="pl-k">..</span>n]</pre></div>
<p>First, let's look at the part in square brackets:</p>
<div class="highlight highlight-source-haskell"><pre>[<span class="pl-c1">1</span><span class="pl-k">..</span>n]</pre></div>
<p>This is a list range. A list in Haskell is kind of like an array in other
languages. That is, it's an ordered collection of values, all with the same
type. You can have lists of ints, floats, strings, custom types, or even lists
of lists.</p>
<p>The <code>..</code> makes this particular list a range. This creates a list of all
integers from 1 to <em>n</em>. So if <em>n</em> is equal to 5, this will make a list with 5
values:</p>
<div class="highlight highlight-source-haskell"><pre>[<span class="pl-c1">1</span>, <span class="pl-c1">2</span>, <span class="pl-c1">3</span>, <span class="pl-c1">4</span>, <span class="pl-c1">5</span>]</pre></div>
<p>Once the list range is evaluated, it's passed to the <em>product</em> function, like
so:</p>
<div class="highlight highlight-source-haskell"><pre><span class="pl-c1">product</span> [<span class="pl-c1">1</span>, <span class="pl-c1">2</span>, <span class="pl-c1">3</span>, <span class="pl-c1">4</span>, <span class="pl-c1">5</span>]</pre></div>
<p>The <em>product</em> function takes a list of numbers, multiplies them all together,
and returns the result. So this will evaluate to:</p>
<div class="highlight highlight-source-haskell"><pre><span class="pl-c1">1</span> <span class="pl-k">*</span> <span class="pl-c1">2</span> <span class="pl-k">*</span> <span class="pl-c1">3</span> <span class="pl-k">*</span> <span class="pl-c1">4</span> <span class="pl-k">*</span> <span class="pl-c1">5</span></pre></div>
<p>The answer turns out to be <em>120</em>, which just so happens to be <code>5!</code>, the
very number we were looking for. What a lucky coincidence!</p>
<p>So, once the <em>factorial</em> function above is defined, you can get the factorial
for a number by calling it with that number like this:</p>
<div class="highlight highlight-source-haskell"><pre>factorial <span class="pl-c1">0</span> <span class="pl-c"><span class="pl-c">--</span> This returns 1</span>
factorial <span class="pl-c1">3</span> <span class="pl-c"><span class="pl-c">--</span> This returns 6</span>
factorial <span class="pl-c1">5</span> <span class="pl-c"><span class="pl-c">--</span> This returns 120</span></pre></div>
<h1>Factorials in an imperative language</h1>
<p>We've seen how the mathematical idea of factorials can be expressed in the
style of a functional programming language. Now we'll go another level deeper
and see the same thing in an imperative language.</p>
<p>Programming in functional languages like Haskell generally works by defining
what things are and letting the language work out how to arrive at the answer.
Programming in an imperative language involves explaining to the computer how
to perform the calculations yourself, as a series of steps which change the
computer state and react to it by running different bits of code depending on
the state on the computer at the time.</p>
<p>Take a look at this factorial function written in C:</p>
<div class="highlight highlight-source-c"><pre><span class="pl-k">int</span> <span class="pl-en">factorial</span>(<span class="pl-k">int</span> n)
{
    <span class="pl-k">int</span> ret = <span class="pl-c1">1</span>;

    <span class="pl-k">while</span> (n &gt; <span class="pl-c1">1</span>)
    {
        ret *= n;
        n--;
    }

    <span class="pl-k">return</span> ret;
}</pre></div>
<p>Fundamentally, this is the same exact logic as in the Haskell version, it's
just specified in a different way. But this time, rather than explaining the
definition of a factorial declaratively, we have to give C a series of steps
it can follow to produce the result we want.</p>
<p>At a high level, this function does the following:</p>
<ol>
<li>Set <em>ret</em> to 1. This is going to be the return value.</li>
<li>Multiply <em>n</em> by <em>ret</em>.</li>
<li>Subtract 1 from <em>n</em>.</li>
<li>Repeat steps 2-3 as long as <em>n</em> is greater than 1.</li>
<li>Return the value in <em>ret</em>.</li>
</ol>
<p>Let's step through this line by line to see how this is done.</p>
<div class="highlight highlight-source-c"><pre><span class="pl-k">int</span> <span class="pl-en">factorial</span>(<span class="pl-k">int</span> n)
{</pre></div>
<p>This marks the beginning of the <em>factorial</em> function. It states that
<em>factorial</em> is a function which takes an integer called <em>n</em> returns another
integer. This doesn't break down into English quite as naturally as the
Haskell type signature, but we can try:</p>
<div class="highlight highlight-source-c"><pre><span class="pl-c"><span class="pl-c">//</span> Returning an int, factorial is a function which takes an int named n</span>
                <span class="pl-k">int</span>  <span class="pl-en">factorial</span>         (                    <span class="pl-k">int</span>       n)</pre></div>
<p>The ordering of the syntax makes it a bit more awkward, but this line means
the exact same thing as the Haskell function signature.</p>
<div class="highlight highlight-source-c"><pre>    <span class="pl-k">int</span> ret = <span class="pl-c1">1</span>;</pre></div>
<p>This declares a new integer called <em>ret</em> and sets it to the value 1. This is
going to be the return value. We'll be repeatedly multiplying <em>n</em> against this
value and returning it when we're done.</p>
<div class="highlight highlight-source-c"><pre>    <span class="pl-k">while</span> (n &gt; <span class="pl-c1">1</span>)
    {</pre></div>
<p>This is a loop. This says to run the code inside the curly braces <code>{ ... }</code>
over and over as long as <em>n</em> is greater than 1. If <em>n</em> is 0 or 1 at the start
of the function, this loop will never run at all.</p>
<div class="highlight highlight-source-c"><pre>        ret *= n;</pre></div>
<p>Each time the loop runs, we multiply <em>n</em> by <em>ret</em> and store the result in
<em>ret</em>.</p>
<div class="highlight highlight-source-c"><pre>        n--;</pre></div>
<p>Then we subtract 1 from <em>n</em>. This way, <em>n</em> will keep going down each time the
loop runs.</p>
<div class="highlight highlight-source-c"><pre>    }</pre></div>
<p>This is the end of the loop body. When execution reaches this point, it will
jump back to the beginning of the loop and run it again.</p>
<div class="highlight highlight-source-c"><pre>    <span class="pl-k">return</span> ret;
}</pre></div>
<p>Once the loop is finished, we return the value in <em>ret</em> and end the function.</p>
<p>This <em>factorial</em> function can be called like this:</p>
<div class="highlight highlight-source-c"><pre>    <span class="pl-en">factorial</span>(<span class="pl-c1">5</span>);</pre></div>
<p>When it's called with a 5, the following steps happen:</p>
<ol>
<li><em>ret</em> is set to 1.</li>
<li><em>n</em> is 5 and 5 &gt; 1, so the loop body runs.</li>
<li><em>ret</em> is multiplied by 5, changing it to 5.</li>
<li><em>n</em> is decremented, changing it to 4.</li>
<li><em>n</em> s 4 and 4 &gt; 1, so the loop body runs again.</li>
<li><em>ret</em> is multiplied by 4, changing it to 20.</li>
<li><em>n</em> is decremented, changing it to 3.</li>
<li><em>n</em> is 3 and 3 &gt; 1, so the loop body runs again.</li>
<li><em>ret</em> is multipled by 3, changing it to 60.</li>
<li><em>n</em> is decremented, changing it to 2.</li>
<li><em>n</em> is 2 and 2 &gt; 1, so the loop body runs again.</li>
<li><em>ret</em> is multiplied by 2, changing it to 120.</li>
<li><em>n</em> is decremented, changing it to 1.</li>
<li><em>n</em> is 1 and 1 is not greater than 1, so the loop ends.</li>
<li><em>ret</em>, with a value of 120, is returned to the caller.</li>
</ol>
<h1>Factorials in assembly language</h1>
<p>Despite differences in style, the C and Haskell functions are both relatively
high-level. That means you don't need to bother yourself much with the
particulars of the machine you're writing the code for: both the C and Haskell
compilers can handle turning code into something appropriate for the computer
being targeted. But what does the code they generate look like?</p>
<p>This gets us into assembly language. Assembly language is a symbolic form of
the actual machine code executed by a computer. For the most part, instructions
in assembly language map directly to machine code instructions.</p>
<p>Because of this, We can't state things in quite the same terms in assembly as
we did in C and Haskell: higher level languages do a lot to adapt their syntax
to how humans think, but in assembly we have to do some of that work ourselves
and adapt our thinking to the particulars of the hardware.</p>
<p>Here's a factorial function written in Intel-style syntax for an x86-64
computer:</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">factorial:</span>
<span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span>

<span class="pl-en">  .</span><span class="pl-k">loop</span><span class="pl-en">:</span>
<span class="pl-en">    </span><span class="pl-k">cmp</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span>
<span class="pl-en">    </span><span class="pl-k">jle</span><span class="pl-en"> .done</span>

<span class="pl-en">    </span><span class="pl-k">imul</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-v">rax</span>
<span class="pl-en">    </span><span class="pl-k">dec</span><span class="pl-en"> </span><span class="pl-v">rax</span>

<span class="pl-en">    </span><span class="pl-k">jmp</span><span class="pl-en"> .</span><span class="pl-k">loop</span>

<span class="pl-en">  .done:</span>
<span class="pl-en">    </span><span class="pl-k">ret</span></pre></div>
<p>Okay, what happened? The C and Haskell versions differed but there were some
pretty recognizable similarities. If you see many similarities this time,
you're either already familiar with assembly or you're a lot smarter than me.
But even though the style of code has changed substantially, the same logic is
here, in more or less the same order.</p>
<p>Take a look at this version with comments added showing roughly what each line
does in C:</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">factorial:</span><span class="pl-c">        ; int factorial(int n) {</span>
<span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span><span class="pl-c">    ;     int ret = 1;</span>

<span class="pl-en">  .</span><span class="pl-k">loop</span><span class="pl-en">:</span><span class="pl-c">          ; .loop:</span>
<span class="pl-en">    </span><span class="pl-k">cmp</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span><span class="pl-c">    ;     if (n &lt;= 1)</span>
<span class="pl-en">    </span><span class="pl-k">jle</span><span class="pl-en"> .done</span><span class="pl-c">     ;         goto .done;     // The dreaded goto!</span>

<span class="pl-en">    </span><span class="pl-k">imul</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-c"> ;     ret *= n;</span>
<span class="pl-en">    </span><span class="pl-k">dec</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-c">       ;     n--;</span>

<span class="pl-en">    </span><span class="pl-k">jmp</span><span class="pl-en"> .</span><span class="pl-k">loop</span><span class="pl-c">     ;     goto .loop;         // Oh god it's another one!</span>

<span class="pl-en">  .done:</span><span class="pl-c">          ; .done:</span>
<span class="pl-en">    </span><span class="pl-k">ret</span><span class="pl-c">           ;     return ret;</span>
<span class="pl-c">                  ; }</span></pre></div>
<p>The mapping isn't perfect, but with the comments in place, this code should
look a little less odd.</p>
<p>Even though it's described differently, the basic logic is the same as the C
version. This is no accident: C is a fairly thin layer over assembly and most
of its constructs can map pretty directly to a wide variety of machines.</p>
<p>One critical difference between this assembly version and both the C and
Haskell versions is that there is no type signature. Nowhere does the
assembly version define what inputs and outputs the <em>factorial</em> function takes.
Instead, it expects that the input value <em>n</em> has been loaded into a register
called <em>rax</em> before the function was called. It calculates the factorial of the
value in <em>rax</em> and leaves the answer in <em>rdi</em> for the caller to use. Nowhere
in the code is this expressed in concrete terms: to use this function you
basically just have to know what it expects. Ideally it would be commented
with this information. Otherwise you'd have to read the function's code to try
and sort out how to use it.</p>
<p>When the function starts, it sets <em>rdi</em> to 1, which it will use as its return
value. Next, it repeatedly multiplies that return value by the value in <em>rax</em>,
subtracting 1 from <em>rax</em> each time. Once <em>rax</em> reaches 0 or 1, the function
ends and the return value is left in <em>rdi</em> for the caller to use. Assuming the
caller put an integer in <em>rax</em> before calling the <em>factorial</em> function, it will
find the factorial of that integer in <em>rdi</em> when the function returns.</p>
<p>If you're curious what these instructions really do beyond just seeing how
they could map to C-style syntax, read on!</p>
<h1>More detail on the assembly version</h1>
<p>First, a quick primer. The CPU doesn't really think in terms of variables like
<code>int ret = 1;</code> or expressions like <code>ret *= n;</code>. Instead, it has a
number of <em>registers</em>, each of which can store a fixed amount of data. On a
64-bit processor, the general-purpose registers store 64 bits each.</p>
<p>By executing instructions, a program can load data into these registers and
then do math on that data.</p>
<p>Since registers are tiny chunks of memory inside the CPU hardware, performing
operations on registers is lightning-fast because the CPU doesn't need to wait
on data to move to or from system memory.</p>
<p>A few of the more commonly-used registers are:</p>
<table>
<thead>
<tr>
<th>Register</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>rax</td>
<td>General-purpose</td>
</tr>
<tr>
<td>rbx</td>
<td>General-purpose</td>
</tr>
<tr>
<td>rcx</td>
<td>General-purpose</td>
</tr>
<tr>
<td>rdx</td>
<td>General-purpose</td>
</tr>
<tr>
<td>rdi</td>
<td>General-purpose</td>
</tr>
<tr>
<td>rsi</td>
<td>General-purpose</td>
</tr>
<tr>
<td>rbp</td>
<td>Often used to keep track of the start of a stack call frame</td>
</tr>
<tr>
<td>rsp</td>
<td>Always points to the top of the stack</td>
</tr>
<tr>
<td>rip</td>
<td>Always points to the next instruction to be executed</td>
</tr></tbody></table>
<p>The general-purpose registers can mostly be used however you want. Other
registers have specific purposes with rules about how they can be used or
modified.</p>
<p>The CPU can only perform calculations on data loaded into registers. So, in
order to add two numbers together, you first have to tell the computer to load
each number into a register, and then you can tell it to add the values in
those registers together.</p>
<p>Let's go through the assembly function line by line to see how it works in
more detail.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">factorial:</span></pre></div>
<p>This marks the beginning of the <em>factorial</em> function. A name followed by a
colon is called a <em>label</em>. We can tell the computer to <em>jump</em> to this label
whenever we want the code after the label to run.</p>
<p>So when the factorial function is called, this is where it starts. This
function, like the C and Haskell versions, takes an integer <em>n</em> and returns the
integer <em>n!</em>. However, we can't describe it that way. Functions in 64-bit
assembly usually accept parameters and return results through registers. This
function expects the value of <em>n</em> to be in a register called <em>rax</em>. When the
function returns, it will leave the answer <em>n!</em> in another register, called
<em>rdi</em>.</p>
<p>So at the beginning of the function, we can assume that the caller put <em>n</em> into
<em>rax</em>.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span></pre></div>
<p>We're going to return the result of the function in a register called <em>rdi</em>.
This instruction sets it to 1. We have no idea what this register is set to at
the beginning of the function because registers aren't automatically cleared
when functions are called.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">  .</span><span class="pl-k">loop</span><span class="pl-en">:</span></pre></div>
<p>This is another label, marking the beginning of the loop. The dot at the front
makes it a local label, meaning it's local to the function we're in. We can
jump to <code>.loop:</code> anytime we want the loop to run.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">cmp</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span></pre></div>
<p>Each time the loop runs, the first thing we need to do is check if the loop
should end yet.</p>
<p>Remember <em>rax</em> is <em>n</em>.  This instruction compares the value in <em>rax</em> to 1. It
doesn't do anything with that information, it just sets things up so we can act
on it later.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">jle</span><span class="pl-en"> .done</span></pre></div>
<p>This instruction acts on the previous compare instruction. This means to
<strong>j</strong>ump if <strong>l</strong>ess than or <strong>e</strong>qual. So if <em>rax</em> is less than or equal to
1, execution will skip ahead to the <em>done:</em> label. Otherwise, execution will
continue to the next instruction, which will run the loop body.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">imul</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-v">rax</span></pre></div>
<p>If the program didn't jump out of the loop to the <em>.done:</em> label, we know that
<em>n</em> must be 2 or higher. This instruction multiplies the values in <em>rdi</em> and
<em>rax</em> and stores the result in <em>rdi</em>.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">dec</span><span class="pl-en"> </span><span class="pl-v">rax</span></pre></div>
<p>This instruction decrements <em>rax</em>, which means it subtracts 1 from it. If <em>rax</em>
is 5, this instruction will set it to 4.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">jmp</span><span class="pl-en"> .</span><span class="pl-k">loop</span></pre></div>
<p>This instruction jumps back to the <em>.loop:</em> label, which starts the loop over
again.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">  .done:</span></pre></div>
<p>Once the loop is finished running, execution will jump here.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">ret</span></pre></div>
<p>The factorial result should be sitting in <em>rdi</em>. This instruction ends the
function, causing execution to jump back to wherever it left off when this
function was called. The return value of <code>n!</code> will be left in the <em>rdi</em>
register for the caller to use.</p>
<h1>Factorials in machine code</h1>
<p>We've seen the assembly language version of a factorial function, but can a
computer run that directly? The answer is not quite. Assembly language is a
mnemonic for machine code, meaning that each instruction maps to a machine
code instruction, but is specified using bits of English words and numbers in
decimal notation in order to be easier for humans like me and (presumably) you.</p>
<p>We can hand assemble code using the handy reference at
<a href="http://ref.x86asm.net/">ref.x86asm.net</a>. A detailed look at hand-assembling
code is probably a topic for another day, but just for fun, let's look at how
the assembly function could map to machine code.</p>
<p><em>Note: I'm going to leave out some common optimizations</em></p>
<p>Behold!</p>
<pre><code>48 bf 01 00 00 00 00 00 00 00 48 3d 01 00 00 00 7e 0c 48 0f af f8 48 ff c8 e9
ec ff ff ff c3
</code></pre>
<p>This is the factorial function in machine code. Makes sense, right? I'm glad
you understand, thanks for reading!</p>
<p>...</p>
<p>Yeah I can't read this very well either, but this is kind of how a computer
sees machine code. It's a big slab of bytes sitting somewhere in memory. The
<em>rip</em> register stores an address to one of those bytes. When the computer runs
an instruction it checks the value of <em>rip</em> to see where it's pointing and it
<em>decodes</em> the data it finds there.  That means that according to a bunch of
rules it sorts out what instruction is meant by a series of bytes. It does
whatever the instruction tells it to. By default it moves <em>rip</em> to point to the
next byte after the end of the instruction it decoded so that the next time it
tries to run an instruction it will be pointing at the next instruction in
memory. This causes each instruction to run sequentially. However, in some
cases (like jump instructions) the instruction modifies the <em>rip</em> register to
point somewhere else, causing execution to jump around.</p>
<p>The code above is represented as hex. Each pair of hex digits is one byte. This
could just as easily be represented as a series of 0s and 1s (8 per byte) or in
decimal (a number from 0-255 for each byte). For example:</p>
<table>
<thead>
<tr>
<th>Decimal</th>
<th>Hex</th>
<th>Binary</th>
</tr>
</thead>
<tbody>
<tr>
<td>72</td>
<td>48</td>
<td>01001000</td>
</tr></tbody></table>
<p>The way the data is represented isn't really important. You could make up your
own encoding of the data if you wanted, even though nobody would know what it
meant.</p>
<p>Since this slab of hex bytes isn't very helpful, let's break it up into
instructions:</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-c1">48</span><span class="pl-en"> bf </span><span class="pl-c1">01</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en">   </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span>

<span class="pl-c1">48</span><span class="pl-en"> 3d </span><span class="pl-c1">01</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en">               </span><span class="pl-k">cmp</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span>
<span class="pl-en">7e 0c                           </span><span class="pl-k">jle</span><span class="pl-en"> .done</span><span class="pl-c">       ; Jump ahead 12 bytes</span>

<span class="pl-c1">48</span><span class="pl-en"> 0f af f8                     </span><span class="pl-k">imul</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-v">rax</span>
<span class="pl-c1">48</span><span class="pl-en"> ff c8                        </span><span class="pl-k">dec</span><span class="pl-en"> </span><span class="pl-v">rax</span>

<span class="pl-en">e9 ec ff ff ff                  </span><span class="pl-k">jmp</span><span class="pl-en"> .</span><span class="pl-k">loop</span><span class="pl-c">       ; Jump back 20 bytes</span>

<span class="pl-en">c3                              </span><span class="pl-k">ret</span></pre></div>
<p>Probably the biggest difference (other than vaguely English-inspired words
turning into a soup of hex digits) is the lack of labels. That's because labels
like <em>factorial:</em> and <em>.done:</em> are a convenience provided by assemblers. In
machine code, jumps work by jumping to relative offsets.</p>
<p>Take a look at the assembled version of <code>jle .done</code>:</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">7e 0c                           </span><span class="pl-k">jle</span><span class="pl-en"> .done</span><span class="pl-c">       ; Jump ahead 12 bytes</span></pre></div>
<p>In this instruction, each byte has a meaning:</p>
<table>
<thead>
<tr>
<th>Hex</th>
<th>Role</th>
<th>Meaning</th>
</tr>
</thead>
<tbody>
<tr>
<td>7e</td>
<td>Opcode</td>
<td><em>jle</em> - jump if less than or equal to</td>
</tr>
<tr>
<td>0c</td>
<td>Operand</td>
<td>12 bytes forward</td>
</tr></tbody></table>
<p>So the <em>7e</em> tells the computer the opcode, or the type of instruction to
execute. <em>0c</em> is the value telling it where to jump. <em>0c</em> is hex for <em>12</em>.
All together, this means to jump forward 12 bytes.</p>
<p>When an instruction is executed, <em>rip</em> will be pointing to the next byte after
that instruction. So when <code>7e 0c</code> is executed, <em>rip</em> will be pointing to
the <code>48 0f af f8</code> that comes after it. If <em>rax</em> is less than or equal to
1, causing the jump to occur, <em>rip</em> will be advanced 12 bytes, which will leave
it pointing at the <code>c3</code> all the way at the end. The next instruction to
run will therefore be <code>c3 - ret</code>.</p>
<p>How about jumping backwards? It works the same. Take a look at the code for
<code>jmp .loop</code>, which jumps back to the start of the loop:</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">e9 ec ff ff ff                  </span><span class="pl-k">jmp</span><span class="pl-en"> .</span><span class="pl-k">loop</span><span class="pl-c">       ; Jump back 20 bytes</span></pre></div>
<p>This instruction can be broken into two pieces like the previous one:</p>
<table>
<thead>
<tr>
<th>Hex</th>
<th>Role</th>
<th>Meaning</th>
</tr>
</thead>
<tbody>
<tr>
<td>e9</td>
<td>Opcode</td>
<td><em>jmp</em> - unconditional jump</td>
</tr>
<tr>
<td>ec ff ff ff</td>
<td>Operand</td>
<td><em>-20</em> in signed two's complement format</td>
</tr></tbody></table>
<p>So <code>e9</code> tells the CPU to jump and <code>ec ff ff ff</code> tells it to jump
backwards 20 bytes. When this instruction is executed, <em>rip</em> will be pointing
to the <code>c3 - ret</code> at the end of the function. Applying a delta of -20 to
the <em>rip</em> will cause execution to jump back 20 bytes to
<code>48 3d 01 00 00 00 - cmp rax, 1</code> which will run the loop again.</p>
<p>This is a very convenient feature provided by assemblers. Without it, you'd
have to count bytes back and forth to implement control structures like
conditionals and loops. Every time you changed instructions inside a loop
or added a bit more code you'd have to recalculate all your jump offsets. So
assemblers help out a lot more than just translating pseudo-English like
<em>jmp</em> or <em>rax</em> to their binary equivalents.</p>
<h1>Conclusion</h1>
<p>We've seen an idea traced gradually down through several ways of describing it,
showing how some logic can be translated from a format optimized for processing
by the human brain down to a format appropriate for a machine, with plenty of
stops along the way:</p>
<ol>
<li><strong>English</strong> - a way of describing ideas to us filthy humans</li>
<li><strong>Math</strong> - a better way of describing ideas to us filthy humans</li>
<li><strong>Haskell</strong> - a high level functional language</li>
<li><strong>C</strong> - a pretty high level imperative language</li>
<li><strong>Assembly</strong> - a mnemonic for machine code</li>
<li><strong>x86-64 code</strong> - instructions a CPU can directly process</li>
</ol>
<p>Hopefully this has been interesting and possibly even enlightening. Thanks for
reading!</p></div>
