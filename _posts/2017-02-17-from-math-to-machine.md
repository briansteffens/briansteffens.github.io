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
Haskell, which can resemble math in some important ways.</p>
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
factorial <span class="pl-c1">0</span> <span class="pl-k">=</span> <span class="pl-c1">1</span>
factorial n <span class="pl-k">=</span> n <span class="pl-k">*</span> factorial (n <span class="pl-k">-</span> <span class="pl-c1">1</span>)</pre></div>
<p>You should see some similarities between the Haskell definition of a factorial
and the math definition given earlier. Here it is if you don't feel like
scrolling:</p>
<pre><code>0! = 1
n! = n * (n - 1)!
</code></pre>
<p>In the math definition, the <code>!</code> character represents the factorial function
and appears after the number. For example: <code>0!</code>, <code>n!</code>, and
<code>(n - 1)!</code>.</p>
<p>In the Haskell version, the word <em>factorial</em> is used in place of the
<code>!</code> character and it appears before the number instead of after. For
example: <code>factorial 0</code>, <code>factorial n</code>, and <code>factorial (n - 1)</code>.</p>
<p>The Haskell version is also a bit more specific about the types of values it
accepts. The first line specifies that <em>factorial</em> is a function which takes
an integer and returns another integer. Here's an oddly-formatted version of
that first line, spaced out so you can see roughly which parts of the syntax
mean what:</p>
<div class="highlight highlight-source-haskell"><pre><span class="pl-c"><span class="pl-c">--</span> factorial is a function which takes an integer and returns another integer</span>
<span class="pl-en">factorial</span>            <span class="pl-k">::</span>                     <span class="pl-en"><span class="pl-c1">Int</span></span>          <span class="pl-k">-&gt;</span>             <span class="pl-en"><span class="pl-c1">Int</span></span></pre></div>
<p>Haskell functions support a feature called pattern matching. When this
function is called, it walks down the patterns until it finds one
that the input parameter matches. So if <em>factorial</em> is called with a 0, as in
<code>factorial 0</code>, that matches the first pattern:</p>
<div class="highlight highlight-source-haskell"><pre>factorial <span class="pl-c1">0</span> <span class="pl-k">=</span> <span class="pl-c1">1</span></pre></div>
<p>In this case, the function simply returns the value 1 without doing any
calculations.</p>
<p>If <em>factorial</em> is called with a number other than 0, like in <code>factorial 5</code>,
the first pattern doesn't match. Instead, it will fall through to the next
pattern, which matches anything and binds that value to the name <em>n</em>:</p>
<div class="highlight highlight-source-haskell"><pre>factorial n <span class="pl-k">=</span> n <span class="pl-k">*</span> factorial (n <span class="pl-k">-</span> <span class="pl-c1">1</span>)</pre></div>
<p>This pattern takes the value for <code>n</code>, multiplies it by the factorial of
<code>n - 1</code>, and returns the result.</p>
<p>Notice that just like in the math definition, this is a recursive definition.
The <em>factorial</em> function calls itself to get the factorial of <code>n - 1</code>. The
function then in turn calls itself again, and on and on, until the base
case is reached, at which point the results begin to bubble back up.</p>
<p>Since this is Haskell, we don't have to tell the computer how to solve these
definitions, we just have to provide them, and the compiler will sort it all
out.</p>
<p>Here's what happens in order (logically, that is):</p>
<ol>
<li><code>factorial 5</code> calls <code>factorial (5 - 1)</code></li>
<li><code>factorial 4</code> calls <code>factorial (4 - 1)</code></li>
<li><code>factorial 3</code> calls <code>factorial (3 - 1)</code></li>
<li><code>factorial 2</code> calls <code>factorial (2 - 1)</code></li>
<li><code>factorial 1</code> calls <code>factorial (1 - 1)</code></li>
<li><code>factorial 0</code> returns <code>1</code></li>
<li><code>factorial 1</code> returns <code>1 * 1</code></li>
<li><code>factorial 2</code> returns <code>2 * 1</code></li>
<li><code>factorial 3</code> returns <code>3 * 2</code></li>
<li><code>factorial 4</code> returns <code>4 * 6</code></li>
<li><code>factorial 5</code> returns <code>5 * 24</code></li>
</ol>
<p>So, even though the syntax is a bit different, the two definitions are
otherwise identical: both specify the same two cases involved in calculating a
factorial: <code>0! = 1</code> and <code>n! = n * (n - 1)!</code>.</p>
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
    <span class="pl-k">if</span> (n == <span class="pl-c1">0</span>)
    {
        <span class="pl-k">return</span> <span class="pl-c1">1</span>;
    }

    <span class="pl-k">return</span> n * <span class="pl-c1">factorial</span>(n - <span class="pl-c1">1</span>);
}</pre></div>
<p>Again, you should see some similarities between this and both the Haskell and
math versions, but there are important differences in style.</p>
<p>Rather than defining the two different cases (the base case and the recursive
case) and letting Haskell figure out which to use, in C, we have to express
this logic ourselves.</p>
<p>Each time the C version of the <em>factorial</em> function is called, it performs the
following steps in order:</p>
<ol>
<li>Check if <em>n</em> is equal to 0. If so, this is the base case. Return 1.</li>
<li>Otherwise, make a recursive call to <code>factorial(n - 1)</code> and multiply the
result by <em>n</em>.</li>
</ol>
<p>Fundamentally, this is the same exact logic as in the other versions, it's just
specified in a different way. There is still a base case which states that
<code>0! = 1</code> and there's still a recursive case which states that
<code>n! = n * (n - 1)!</code>. But this time, rather than explaining those
relationships declaratively, we instead have to give C a series of steps
it can follow to produce the result.</p>
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
<span class="pl-en">    </span><span class="pl-k">cmp</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span>
<span class="pl-en">    </span><span class="pl-k">je</span><span class="pl-en"> base_case</span>

<span class="pl-en">    </span><span class="pl-k">push</span><span class="pl-en"> </span><span class="pl-v">rax</span>

<span class="pl-en">    </span><span class="pl-k">dec</span><span class="pl-en"> </span><span class="pl-v">rax</span>
<span class="pl-en">    </span><span class="pl-k">call</span><span class="pl-en"> factorial</span>

<span class="pl-en">    </span><span class="pl-k">pop</span><span class="pl-en"> </span><span class="pl-v">rax</span>
<span class="pl-en">    </span><span class="pl-k">imul</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-v">rax</span>

<span class="pl-en">    </span><span class="pl-k">ret</span>

<span class="pl-en">  base_case:</span>
<span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span>
<span class="pl-en">    </span><span class="pl-k">ret</span></pre></div>
<p>Okay, what happened? The C and Haskell versions differed but there were some
pretty recognizable similarities. If you see many similarities this time,
you're either already familiar with assembly or you're a lot smarter than me.
But even though the style of code has changed substantially, the same logic is
here, in more or less the same order.</p>
<p>Take a look at this version with comments added showing roughly what each line
does in C:</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">factorial:</span><span class="pl-c">          ; int factorial(int n) {</span>
<span class="pl-c">                    ;     int ret;</span>

<span class="pl-en">    </span><span class="pl-k">cmp</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">0</span><span class="pl-c">      ;     if (n == 0)             // Expects rax to be set to n</span>
<span class="pl-en">    </span><span class="pl-k">je</span><span class="pl-en"> base_case</span><span class="pl-c">    ;         goto base_case;     // The dreaded goto!</span>

<span class="pl-en">    </span><span class="pl-k">push</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-c">        ;     int original_n = n;     // Save n's original value</span>

<span class="pl-en">    </span><span class="pl-k">dec</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-c">         ;     n--;</span>
<span class="pl-en">    </span><span class="pl-k">call</span><span class="pl-en"> factorial</span><span class="pl-c">  ;     ret = factorial(n);</span>

<span class="pl-en">    </span><span class="pl-k">pop</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-c">         ;     n = original_n;         // Restore n</span>
<span class="pl-en">    </span><span class="pl-k">imul</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-c">   ;     ret *= n;</span>

<span class="pl-en">    </span><span class="pl-k">ret</span><span class="pl-c">             ;     return ret;</span>

<span class="pl-en">  base_case:</span><span class="pl-c">        ; base_case:</span>
<span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span><span class="pl-c">      ;     ret = 1;</span>
<span class="pl-en">    </span><span class="pl-k">ret</span><span class="pl-c">             ;     return ret;</span>
<span class="pl-c">                    ; }</span></pre></div>
<p>With the comments in place, this should look a little less odd. When the
function starts, it checks if <em>n</em> is equal to 0. If it is, it jumps over most
of the function body and returns 1, satisfying the rule <code>0! = 1</code>.
Otherwise, it calls itself recursively and returns <code>n * (n - 1)!</code>.</p>
<p>If you're curious what these instructions really do beyond just seeing how
they could map to C-style syntax, read on!</p>
<h1>More detail on the assembly version</h1>
<p>First, a quick primer. The CPU doesn't think in terms of variables like
<code>int n</code> or expressions like <code>n * factorial(n - 1)</code>. Instead, it has a
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
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">cmp</span><span class="pl-en"> </span><span class="pl-v">rax</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">0</span></pre></div>
<p>Remember <em>rax</em> is <em>n</em>. The first thing we do is check if this is the base case.
This instruction compares the value in <em>rax</em> to 0. It doesn't do anything with
that information, it just sets things up so we can act on it later.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">je</span><span class="pl-en"> base_case</span></pre></div>
<p>This instruction acts on the previous compare instruction. This means to
<strong>j</strong>ump if <strong>e</strong>qual to the <em>base_case</em> label. So if <em>n</em> is 0, this will
jump ahead to the <em>base_case:</em> label, which will handle returning 1 (for
<code>0! = 1</code>. If not, execution will continue to the next instruction.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">push</span><span class="pl-en"> </span><span class="pl-v">rax</span></pre></div>
<p>If the program didn't jump ahead to the <em>base_case:</em> label, we know that
<em>n</em> must not be 0. That means we need to handle the recursive case.</p>
<p>Like usual, we need to call the function we're already in, but with <code>rax</code> set
to a value of <code>n - 1</code>. When it returns, <em>rdi</em> will be set to the answer
<code>(n - 1)!</code>. We will then need to multiply that answer by the original value
in <em>rax</em>.</p>
<p>There's just one problem: we're calling the same function again, which requires
<em>rax</em> to be set to the input parameter <em>n</em>. We're going to end up destroying
the original value of <em>n</em> in order to make the recursive call! We need some way
to save the original value of <em>n</em> for later.</p>
<p>This is where the stack comes in. When you <em>push</em> something onto the stack,
it's saved there for later. The instruction above copies the value of <em>n</em> onto
the stack. Now we can destroy the data in <em>rax</em> and still restore its original
value by <em>pop</em>ing it back off the stack later on. Of course, we have to make
sure we <em>pop</em> data off the stack in the same order we <em>push</em>ed it on, or we'll
end up with the wrong data.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">dec</span><span class="pl-en"> </span><span class="pl-v">rax</span></pre></div>
<p>Now that we've saved <em>rax</em>'s original value on the stack, we can mess up the
value in <em>rax</em>. This instruction <em>dec</em>rements the value in <em>rax</em>. So if <em>rax</em>
is 5, this instruction will change it to 4.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">call</span><span class="pl-en"> factorial</span></pre></div>
<p>We have <code>n - 1</code> sitting in <em>rax</em>, so we're all set to make the recursive
call. The <em>call</em> instruction does two things:</p>
<ol>
<li>It pushes the current instruction pointer onto the stack so that the line
we're on can be returned to when the recursive call is done.</li>
<li>It jumps to the <em>factorial:</em> label to run this function again, now with a
different value for <em>n</em> in <em>rax</em>.</li>
</ol>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">pop</span><span class="pl-en"> </span><span class="pl-v">rax</span></pre></div>
<p>After the recursive call is finished, execution will resume where it left off.
Since the <em>factorial</em> function leaves its answer in the register <em>rdi</em>, we can
assume that the answer to <code>(n - 1)!</code> is now sitting in <em>rdi</em>. We need to
multiply it by <em>n</em> before we can return the answer to <code>n!</code>.
But we destroyed the value in <em>rax</em> in order to make the recursive call.</p>
<p>Before that can be done, we need to restore the original value that was in
<em>rax</em>. This instruction will <em>pop</em> the value we previously saved back off the
stack and into <em>rax</em>, restoring <em>rax</em> to its original value. <em>rax</em> should be
set to <em>n</em> again, just as it was at the beginning of the function.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">imul</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-v">rax</span></pre></div>
<p>So <em>rax</em> is set to <code>n</code> and <em>rdi</em> is set to <code>(n - 1)!</code>. Let's multiply
them together! In this instruction, the two values are multiplied together, and
the answer is saved in <em>rdi</em>.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">ret</span></pre></div>
<p>The result of <code>n * (n - 1)!</code>, which is <code>n!</code>, is sitting in <em>rdi</em>.
We're ready to end the function. This instruction pops a value off the stack
and jumps to it. Since a call was made to start this function, assuming we
didn't mess up the ordering of <em>push</em>es and <em>pop</em>s, there should be a return
instruction address sitting on the top of the stack right now. When this
instruction executes, that address will be popped off and stored in <em>rip</em>.
<em>rip</em> is a special register that controls what instruction runs next. This
means execution will resume wherever it left off when this function was called,
now with the return value of <code>n!</code> waiting in <em>rdi</em> for the caller to use.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">  base_case:</span></pre></div>
<p>This marks the start of the handling for the base case. If <em>n</em> was 0 at the
beginning of the function, the <em>cmp</em> and <em>je</em> instructions would have sent
execution here, skipping the recursive section. All we need to do here is
return 1.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">mov</span><span class="pl-en"> </span><span class="pl-v">rdi</span><span class="pl-s1">,</span><span class="pl-en"> </span><span class="pl-c1">1</span></pre></div>
<p>This instruction sets <em>rdi</em> to the integer value 1, where the caller will
expect the return value to be.</p>
<div class="highlight highlight-source-assembly"><pre><span class="pl-en">    </span><span class="pl-k">ret</span></pre></div>
<p>Now the function returns to the caller, with the answer to <code>0!</code> in <em>rdi</em>.</p></div>
