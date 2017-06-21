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

    img.split {
    }

</style>

<script type="text/javascript" async
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

<div class="markdown-body"><h1>From math to machine: translating a function to machine code</h1>
<p>In this post I'm going to explore how a mathematical concept can be redefined
in progressively more computer-oriented terms, all the way from high level
languages down to machine code, ready for direct execution by a computer. To
that end, I'm going to define the same logic in several different but related
formats:</p>
<ol>
<li><strong>Math</strong> - pure mathy goodness</li>
<li><strong>Haskell</strong> - a functional programming language</li>
<li><strong>C</strong> - an imperative programming language</li>
<li><strong>Assembly</strong> - a more readable representation of machine code</li>
<li><strong>x86-64 machine code</strong> - the real deal</li>
</ol>
<p>If you're interested in how language styles can differ or curious about what
your code might look like after being compiled, keep reading!</p>
<h1>Factorials in math</h1>
<p>A factorial is the product of an integer and all smaller integers greater
than 0. There are lots of ways to describe a definition like this. One such way
is as follows:</p>
<p>$$n! = \prod_{k=1}^n k$$</p>
<p>This definition states that <em>n!</em> is the product of all integers from 1 to <em>n</em>.
For example, the factorial of 5 is:</p>
<pre><code>5! = 1 * 2 * 3 * 4 * 5 = 120
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
<p>One important use of factorials is calculating the total number of permutations
of a set. For example, the string "cat" can be rearranged in 6 possible ways:
"cat", "act", "atc", "tac", "tca", and "cta".  This string has 3 letters
and <code>3! = 6</code>.</p>
<p>The string "a", which has one character, can only be arranged in that one
way. You can't reorder the string "a", so it has only one permutation:
<code>1! = 1</code>.</p>
<p>This comes up a lot in algorithm analysis. An algorithm which has to consider
every possible permutation of its input is said to run in factorial time. In
Big O notation that looks like this: <code>O(n!)</code>. Algorithms of this type scale
very poorly, so it's useful to be able to recognize these kinds of algorithms,
if only so you know to try to find a faster way to solve the problem.</p>
<h1>Factorials in a functional language</h1>
<p>Just like there are lots of ways to describe something mathematically, there
are also lots of ways to describe things to computers. Let's start with
Haskell, which among other useful features, happens to have a pretty cool
looking logo:</p>
<p><a href="/blog/from-math-to-machine/haskell-logo.svg" target="_blank"><img width="50%" src="/blog/from-math-to-machine/haskell-logo.svg" style="max-width:100%;"></a></p>
<p>Haskell is a purely functional language. In broad terms, this means that
instead of telling the computer <em>what to do</em>, a Haskell program tells the
computer <em>what things are</em>. Once a program has been written in Haskell, it's
up to the Haskell compiler to figure out how to translate those definitions
into instructions which a computer can understand.</p>
<p>Take a look at the following Haskell function, which calculates the factorial
of the number provided to it:</p>
<div class="highlight highlight-source-haskell"><pre><span class="pl-en">factorial</span> <span class="pl-k">::</span> <span class="pl-en"><span class="pl-c1">Int</span></span> <span class="pl-k">-&gt;</span> <span class="pl-en"><span class="pl-c1">Int</span></span>
factorial n <span class="pl-k">=</span> <span class="pl-c1">product</span> [<span class="pl-c1">1</span><span class="pl-k">..</span>n]</pre></div>
<p>If you haven't played around with functional languages yet, this probably looks
pretty strange.</p>
<p>The first line says that <em>factorial</em> is a function which takes an integer and
returns another integer. Here's an oddly-formatted version of that first line,
spaced out so you can see roughly which parts of the syntax mean what:</p>
<div class="highlight highlight-source-haskell"><pre><span class="pl-c"><span class="pl-c">--</span> factorial is a function which takes an integer and returns an integer</span>
   <span class="pl-en">factorial</span> <span class="pl-k">::</span>                             <span class="pl-en"><span class="pl-c1">Int</span></span>          <span class="pl-k">-&gt;</span>        <span class="pl-en"><span class="pl-c1">Int</span></span></pre></div>
<p>This first line is technically optional but it's usually good practice to
include it. Haskell is pretty smart so it can figure out type signatures on its
own most of the time, but it's still useful to document the function signature
for other programmers or your future self.</p>
<p>The second line defines the function body, which can be read as "the factorial
of n is equal to the product of all integers from 1 to n". Here's another
spaced out version to show which parts of the syntax mean what:</p>
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
<p>Once the <em>factorial</em> function above is defined, you can get the factorial for a
number by calling like this:</p>
<div class="highlight highlight-source-haskell"><pre>factorial <span class="pl-c1">0</span> <span class="pl-c"><span class="pl-c">--</span> This returns 1</span>
factorial <span class="pl-c1">3</span> <span class="pl-c"><span class="pl-c">--</span> This returns 6</span>
factorial <span class="pl-c1">5</span> <span class="pl-c"><span class="pl-c">--</span> This returns 120</span></pre></div>
<h1>Factorials in an imperative language</h1>
<p>We've seen how the mathematical idea of factorials can be expressed in the
style of a functional programming language. Now we'll go another level deeper
and see the same thing in an imperative language called C, which I like quite a
bit, even though its logo is unfortunately not as cool as Haskell's:</p>
<p><a href="/blog/from-math-to-machine/c-logo.png" target="_blank"><img width="25%" src="/blog/from-math-to-machine/c-logo.png" style="max-width:100%;"></a></p>
<p>Programming in functional languages like Haskell generally works by defining
what things are and letting the language work out how to arrive at the answer.
Programming in an imperative language involves explaining to the computer how
to perform the calculations yourself, as a series of steps the computer can
follow.</p>
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
just specified in a different way.</p>
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
<em>factorial</em> is a function which takes an integer called <em>n</em> and returns another
integer. This doesn't map to English quite as naturally as the Haskell type
signature, but we can try:</p>
<div class="highlight highlight-source-c"><pre><span class="pl-c"><span class="pl-c">//</span> Returning an int, factorial is a function which takes an int named n</span>
                <span class="pl-k">int</span>  <span class="pl-en">factorial</span>         (                    <span class="pl-k">int</span>       n)</pre></div>
<p>The ordering of the syntax makes it a bit more awkward, but this line means
the same thing as the Haskell function signature.</p>
<div class="highlight highlight-source-c"><pre>    <span class="pl-k">int</span> ret = <span class="pl-c1">1</span>;</pre></div>
<p>This declares a new integer called <em>ret</em> and gives it the value 1. This is
going to be the return value. We'll repeatedly multiply <em>n</em> against this
variable and return it when we're done.</p>
<div class="highlight highlight-source-c"><pre>    <span class="pl-k">while</span> (n &gt; <span class="pl-c1">1</span>)
    {</pre></div>
<p>This starts a loop. The <code>while (n &gt; 1)</code> part means to run the code inside
the curly braces <code>{ ... }</code> over and over as long as <em>n</em> is greater than 1.
If <em>n</em> is 0 or 1 at the start of the function, this loop will never run at all.</p>
<div class="highlight highlight-source-c"><pre>        ret *= n;</pre></div>
<p>Each time the loop runs, we multiply <em>n</em> by <em>ret</em> and store the result in
<em>ret</em>.</p>
<div class="highlight highlight-source-c"><pre>        n--;</pre></div>
<p>Then we subtract 1 from <em>n</em>. This way, <em>n</em> will keep going down each time the
loop runs.</p>
<div class="highlight highlight-source-c"><pre>    }</pre></div>
<p>This is the end of the loop body. When execution reaches this point, it will
jump back to the beginning of the loop and run it again, assuming the
conditional in the <em>where</em> line is still true.</p>
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
<li><em>n</em> is 4 and 4 &gt; 1, so the loop body runs again.</li>
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
machine code. For the most part, instructions in assembly language map directly
to machine code instructions.</p>
<p>Because of this, we can't state things in quite the same terms in assembly as
we did in C and Haskell: higher level languages do a lot to adapt their syntax
to how humans think, but in assembly we have to do some of that work ourselves
and adapt our thinking to the particulars of the hardware.</p>
<p>There are actually lots of assembly language syntaxes. In this case we'll be
using the <a href="nasm.us">Netwide Assembler</a>, also known as <em>nasm</em>. Before we move
on, let's get the truly important stuff out of the way. Here's nasm's logo:</p>
<p><a href="/blog/from-math-to-machine/nasm-logo.png" target="_blank"><img width="40%" src="/blog/from-math-to-machine/nasm-logo.png" style="max-width:100%;"></a></p>
<p>I'm afraid Haskell still wins, but this one isn't bad at all.</p>
<p>Here's a factorial function written in nasm syntax for an x86-64 computer:</p>
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
<p>Okay, what happened? If you can make any sense of this at all you're either
already familiar with assembly or you're a lot smarter than I am. The C and
Haskell versions at least have some complete words and some familiar-ish
expressions. However, even though the style of code has changed substantially,
the same logic is here, in more or less the same order.</p>
<p>Take a look at this version with comments added to show roughly what each line
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
<p>One critical difference between the assembly version and the C/Haskell
versions is that there is no type signature in assembly. Nowhere does the
assembly version define what inputs the <em>factorial</em> function accepts or what
outputs it returns. Instead, it expects that the input value <em>n</em> has been
loaded into a register called <em>rax</em> before the function was called. It
leaves its return value in <em>rdi</em> when it exits, again assuming that the caller
will know where to find that answer. Nowhere in the code is this expressed in
concrete terms: to use this function you basically have to already know how it
works. Ideally there would be comments in the code or external documentation
containing this information. If not, you'd have to read the function's code to
try and work out how to use it.</p>
<p>When the function starts, it sets <em>rdi</em> to 1, which will be the return value.
Next, it repeatedly multiplies that return value by the value in <em>rax</em>,
subtracting 1 from <em>rax</em> each time. Once <em>rax</em> reaches 0 or 1, the function
ends and the return value is left in <em>rdi</em> for the caller to use. Assuming the
caller put an integer in <em>rax</em> before calling the <em>factorial</em> function, it will
find the factorial of that integer in <em>rdi</em> when the function returns.</p>
<p>If you're curious what these instructions really do beyond just seeing how
they could map to C-style syntax, read on!</p>
<h1>More detail on the assembly version</h1>
<p>First, a quick primer. The CPU doesn't really think in terms of variables like
<code>int ret = 1;</code> or expressions like <code>ret *= n;</code>. Instead, it has a
number of <em>registers</em>. Each register can store a fixed amount of data. On a
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
<p>The CPU can only perform calculations on data loaded into registers. So in
order to add two numbers together, you first have to tell the computer to load
each number into a register, and then you can tell it to add the values in
those registers together.</p>
<p>Let's go through the assembly function line by line to see how it works in
more detail.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">factorial:</span></pre></div>
<p>This marks the beginning of the <em>factorial</em> function. A name followed by a
colon is called a <em>label</em>. We can tell the computer to <em>jump</em> to this label
whenever we want the code after the label to run.</p>
<p>At the beginning of the function, we assume that the caller set <em>rax</em> to
some integer <em>n</em>.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span></pre></div>
<p>We're going to return the result of the function in a register called <em>rdi</em>.
This instruction sets <em>rdi</em>'s initial value to 1. We have no idea what this
register is set to at the beginning of the function because registers aren't
automatically cleared when functions are called. We have to set it to
something before we use it.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">  .</span><span class="pl-k">loop</span><span class="pl-en">:</span></pre></div>
<p>This is another label, marking the beginning of the loop. The dot at the front
makes it a local label, making it local to the function we're in. We can jump
to <code>.loop:</code> anytime we want the loop to run.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">cmp</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span></pre></div>
<p>Each time the loop runs, the first thing we need to do is check if the loop
should end yet.</p>
<p>Remember <em>n</em> is stored in <em>rax</em>. This instruction compares the value in <em>rax</em>
to 1. It doesn't do anything with that information, it just sets things up so
we can act on it later.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">jle</span><span class="pl-en"> .done</span></pre></div>
<p>This instruction acts on the previous compare instruction. <em>jle</em> means to
<strong>j</strong>ump if <strong>l</strong>ess than or <strong>e</strong>qual to. So if <em>rax</em> is less than or equal to
1, execution will skip ahead to the <em>done:</em> label, ending the loop. Otherwise,
execution will continue to the next instruction, which will run the loop body.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">imul</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-v">rax</span></pre></div>
<p>If the program didn't jump out of the loop to the <em>.done:</em> label, we know that
<em>n</em> must be 2 or higher. This instruction multiplies <em>rdi</em> by <em>rax</em> and stores
the result in <em>rdi</em>.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">dec</span><span class="pl-en"> </span><span class="pl-v">rax</span></pre></div>
<p>This instruction decrements <em>rax</em>, which means to subtract 1. If <em>rax</em> is 5,
this instruction will set it to 4.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">jmp</span><span class="pl-en"> .</span><span class="pl-k">loop</span></pre></div>
<p>This instruction jumps back to the <em>.loop:</em> label, which starts the loop over
again.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">  .done:</span></pre></div>
<p>Once the loop is finished running, execution will jump here.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">ret</span></pre></div>
<p>The factorial result should now be sitting in <em>rdi</em>. This instruction ends the
function, causing execution to jump back to wherever it left off when this
function was called. The return value of <code>n!</code> will be left in the <em>rdi</em>
register for the caller to use.</p>
<p>So you can see that the logic is pretty similar to the C version. Implementing
higher-level constructs like C's <em>while</em> loop requires jumping around between
labels and separate comparison instructions but it works the same. The function
is much less self documented since it has no formal type definition, but
otherwise it takes the same input and provides the same output.</p>
<h1>Factorials in machine code</h1>
<p>We've seen the assembly language version of a factorial function, but can a
computer run that directly? The answer is.. almost. Assembly language is a
mnemonic for machine code, meaning that each instruction maps to a machine
code instruction. However, in assembly, the instructions are specified using
bits of English words and numbers in decimal notation in order to be easier for
humans like me and (presumably) you to read and write.</p>
<p>We can assemble code by hand using the convenient reference at
<a href="http://ref.x86asm.net/">ref.x86asm.net</a>. A detailed look at hand-assembling
code is probably a topic for another day, but just for fun, let's take a quick
look at how the assembly function could map to machine code.</p>
<p><em>Note: I'm going to leave out some common optimizations.</em></p>
<p>Behold!</p>
<pre><code>48 bf 01 00 00 00 00 00 00 00 48 3d 01 00 00 00 7e 0c 48 0f af f8 48 ff
c8 e9 ec ff ff ff c3
</code></pre>
<p>This is the factorial function in machine code. Makes sense, right? I'm glad
you understand, thanks for reading!</p>
<p>...</p>
<p>Yeah I can't read this very well either, but this is kind of how a computer
sees machine code. It's a big slab of bytes sitting somewhere in memory. The
<em>rip</em> register stores an address to one of those bytes. When the computer runs
an instruction it checks the value of <em>rip</em> to see where it's pointing and it
<em>decodes</em> the data it finds there. That means that according to a bunch of
rules it sorts out what instruction is meant by a series of bytes.</p>
<p>Once decoded, the CPU does whatever the instruction tells it to do. By default
<em>rip</em> is advanced to point to the next instruction after the one being run.
This way, the next time the CPU runs an instruction, <em>rip</em> will be pointing at
the next instruction in memory. This causes instructions to run in sequence.
However, in some cases (such as jumps) the instruction modifies the <em>rip</em>
register to point somewhere else, causing execution to jump around.</p>
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
own encoding format if you wanted, even though nobody else would know how to
read it.</p>
<p>Since this slab of hex bytes isn't very helpful, let's break it up into
instructions:</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-c1">48</span><span class="pl-en"> bf </span><span class="pl-c1">01</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en">   </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span>

<span class="pl-c1">48</span><span class="pl-en"> 3d </span><span class="pl-c1">01</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en"> </span><span class="pl-c1">00</span><span class="pl-en">               </span><span class="pl-k">cmp</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span>
<span class="pl-en">7e 0c                           </span><span class="pl-k">jle</span><span class="pl-en"> .done</span><span class="pl-c">       ; Jump ahead 12 bytes</span>

<span class="pl-c1">48</span><span class="pl-en"> 0f af f8                     </span><span class="pl-k">imul</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-v">rax</span>
<span class="pl-c1">48</span><span class="pl-en"> ff c8                        </span><span class="pl-k">dec</span><span class="pl-en"> </span><span class="pl-v">rax</span>

<span class="pl-en">e9 ec ff ff ff                  </span><span class="pl-k">jmp</span><span class="pl-en"> .</span><span class="pl-k">loop</span><span class="pl-c">       ; Jump back 20 bytes</span>

<span class="pl-en">c3                              </span><span class="pl-k">ret</span></pre></div>
<p>Probably the biggest difference between this and the assembly version (other
than vaguely English-inspired words turning into a soup of hex digits) is the
lack of labels. That's because labels like <em>factorial:</em> and <em>.done:</em> are a
convenience provided by assemblers. In machine code, jumps work by changing
the value in <em>rip</em> to point somewhere else.</p>
<p>Take a look at the assembled version of <code>jle .done</code>:</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">7e 0c                           </span><span class="pl-k">jle</span><span class="pl-en"> .done</span><span class="pl-c">       ; Jump ahead 12 bytes</span></pre></div>
<p>In this instruction, each byte has a meaning:</p>
<table>
<thead>
<tr>
<th>Hex</th>
<th>Role</th>
<th>Value</th>
<th>Meaning</th>
</tr>
</thead>
<tbody>
<tr>
<td>7e</td>
<td>Opcode</td>
<td>jle</td>
<td>Jump if less than or equal to</td>
</tr>
<tr>
<td>0c</td>
<td>Operand</td>
<td>12</td>
<td>Jump 12 bytes forward</td>
</tr></tbody></table>
<p>So the <em>7e</em> tells the computer to jump depending on a previous <em>cmp</em>
instruction. <em>0c</em> tells it exactly where to jump, assuming the jump happens.
<em>0c</em> is hex for <em>12</em>. All together, this means to jump forward 12 bytes from
the current position.</p>
<p>When an instruction is executed, <em>rip</em> will be pointing to the next byte after
that instruction. So when <code>7e 0c (jle .done)</code> is executed, <em>rip</em> will be
pointing to <code>48 0f af f8 (imul rdi, rax)</code>. If the jump occurs, <em>rip</em> will
be increased by a value of 12, making it point to the <code>c3 (ret)</code> all the
way at the end. The next instruction to run will therefore be either <code>48 0f af f8 (imul rdi, rax)</code> or <code>c3 (ret)</code>, depending on the outcome of the
comparison being performed.</p>
<p>How about jumping backwards? It works the same, except it uses a negative
offset. Take a look at the code for <code>jmp .loop</code>, which jumps back to the
start of the loop:</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">e9 ec ff ff ff                  </span><span class="pl-k">jmp</span><span class="pl-en"> .</span><span class="pl-k">loop</span><span class="pl-c">       ; Jump back 20 bytes</span></pre></div>
<p>This instruction can be broken into two pieces like the previous one:</p>
<table>
<thead>
<tr>
<th>Hex</th>
<th>Role</th>
<th>Value</th>
<th>Meaning</th>
</tr>
</thead>
<tbody>
<tr>
<td>e9</td>
<td>Opcode</td>
<td>jmp</td>
<td>Jump no matter what (unconditional jump)</td>
</tr>
<tr>
<td>ec ff ff ff</td>
<td>Operand</td>
<td>-20</td>
<td>Jump 20 bytes backward</td>
</tr></tbody></table>
<p>So <code>e9</code> tells the CPU to jump and <code>ec ff ff ff</code> tells it to jump
backward 20 bytes. When this instruction is executed, <em>rip</em> will be pointing to
<code>c3 (ret)</code> at the end of the function. Applying a delta of -20 to <em>rip</em>
will cause execution to jump back 20 bytes to
<code>48 3d 01 00 00 00 (cmp rax, 1)</code>, which will run the loop again.</p>
<p>Providing labels and letting us jump to labels instead of offsets is a very
convenient feature provided by assemblers. Without it, you'd have to count
bytes to implement control structures like conditionals and loops. Every time
you added, removed, or even changed instructions, you'd have to recalculate all
your jump offsets. So assemblers help out a lot more than just translating
pseudo-English like <em>jmp</em> or <em>rax</em> to their binary equivalents.</p>
<p>Other than the labels being replaced by relative offsets and everything being
converted into a binary format, it's the same logic as the assembly version,
which is nearly the same as the C version. It's almost like all these languages
and formats are somehow related to each other. Spooky!</p>
<h1>Conclusion</h1>
<p>We've seen an idea translated gradually down through several languages, ending
up with machine code. Hopefully this has been interesting and possibly even
enlightening. If you enjoyed this, feel free to send me millions of dollars.
Thanks for reading!</p></div>
