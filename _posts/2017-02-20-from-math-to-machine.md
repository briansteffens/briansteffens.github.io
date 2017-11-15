---
layout: default
title: From math to machine
description: Compare and contrast how a factorial function can be represented in math, Haskell, C, assembly, and machine code
---

<link rel="stylesheet" href="/css/posts.css" />

<script type="text/javascript" async src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML"></script>

From math to machine: translating a function to machine code
============================================================

In this post I'm going to explore how a mathematical concept can be redefined
in progressively more computer-oriented terms, all the way from high level
languages down to machine code, ready for direct execution by a computer. To
that end, I'm going to define the same logic in several different but related
formats:

1. **Math** - pure mathy goodness
2. **Haskell** - a functional programming language
3. **C** - an imperative programming language
4. **Assembly** - a more readable representation of machine code
5. **x86-64 machine code** - the real deal

If you're interested in how language styles can differ or curious about what
your code might look like after being compiled, keep reading!

# Factorials in math

A factorial is the product of an integer and all smaller integers greater
than 0. There are lots of ways to describe a definition like this. One such way
is as follows:

$$n! = \prod_{k=1}^n k$$

This definition states that *n!* is the product of all integers from 1 to *n*.
For example, the factorial of 5 is:

```
5! = 1 * 2 * 3 * 4 * 5 = 120
```

Here are the first few factorials:

| n   | n!  |
|-----|-----|
| 0!  | 1   |
| 1!  | 1   |
| 2!  | 2   |
| 3!  | 6   |
| 4!  | 24  |
| 5!  | 120 |

One important use of factorials is calculating the total number of permutations
of a set. For example, the string "cat" can be rearranged in 6 possible ways:
"cat", "act", "atc", "tac", "tca", and "cta".  This string has 3 letters
and ```3! = 6```.

The string "a", which has one character, can only be arranged in that one
way. You can't reorder the string "a", so it has only one permutation:
```1! = 1```.

This comes up a lot in algorithm analysis. An algorithm which has to consider
every possible permutation of its input is said to run in factorial time. In
Big O notation that looks like this: ```O(n!)```. Algorithms of this type scale
very poorly, so it's useful to be able to recognize these kinds of algorithms,
if only so you know to try to find a faster way to solve the problem.

# Factorials in a functional language

Just like there are lots of ways to describe something mathematically, there
are also lots of ways to describe things to computers. Let's start with
Haskell, which among other useful features, happens to have a pretty cool
looking logo:

<img width="50%" src="/blog/from-math-to-machine/haskell-logo.svg" />

Haskell is a purely functional language. In broad terms, this means that
instead of telling the computer *what to do*, a Haskell program tells the
computer *what things are*. Once a program has been written in Haskell, it's
up to the Haskell compiler to figure out how to translate those definitions
into instructions which a computer can understand.

Take a look at the following Haskell function, which calculates the factorial
of the number provided to it:

```haskell
factorial :: Int -> Int
factorial n = product [1..n]
```

If you haven't played around with functional languages yet, this probably looks
pretty strange.

The first line says that *factorial* is a function which takes an integer and
returns another integer. Here's an oddly-formatted version of that first line,
spaced out so you can see roughly which parts of the syntax mean what:

```haskell
-- factorial is a function which takes an integer and returns an integer
   factorial ::                             Int          ->        Int
```

This first line is technically optional but it's usually good practice to
include it. Haskell is pretty smart so it can figure out type signatures on its
own most of the time, but it's still useful to document the function signature
for other programmers or your future self.

The second line defines the function body, which can be read as "the factorial
of n is equal to the product of all integers from 1 to n". Here's another
spaced out version to show which parts of the syntax mean what:

```haskell
-- The factorial of n is equal to the product of all integers from 1 to n
       factorial    n      =          product                     [1 .. n]
```

Notice we're not telling Haskell how to calculate a factorial, we're defining
what a factorial is. This is one of the more important differences between
functional languages and imperative languages.

Let's break this definition down further. When this function is called with
some number *n*, the part after the equal sign is evaluated and returned:

```haskell
product [1..n]
```

First, let's look at the part in square brackets:

```haskell
[1..n]
```

This is a list range. A list in Haskell is kind of like an array in other
languages. That is, it's an ordered collection of values, all with the same
type. You can have lists of ints, floats, strings, custom types, or even lists
of lists.

The ```..``` makes this particular list a range. This creates a list of all
integers from 1 to *n*. So if *n* is equal to 5, this will make a list with 5
values:

```haskell
[1, 2, 3, 4, 5]
```

Once the list range is evaluated, it's passed to the *product* function, like
so:

```haskell
product [1, 2, 3, 4, 5]
```

The *product* function takes a list of numbers, multiplies them all together,
and returns the result. So this will evaluate to:

```haskell
1 * 2 * 3 * 4 * 5
```

The answer turns out to be *120*, which just so happens to be ```5!```, the
very number we were looking for. What a lucky coincidence!

Once the *factorial* function above is defined, you can get the factorial for a
number by calling like this:

```haskell
factorial 0 -- This returns 1
factorial 3 -- This returns 6
factorial 5 -- This returns 120
```

# Factorials in an imperative language

We've seen how the mathematical idea of factorials can be expressed in the
style of a functional programming language. Now we'll go another level deeper
and see the same thing in an imperative language called C, which I like quite a
bit, even though its logo is unfortunately not as cool as Haskell's:

<img width="25%" src="/blog/from-math-to-machine/c-logo.png" />

Programming in functional languages like Haskell generally works by defining
what things are and letting the language work out how to arrive at the answer.
Programming in an imperative language involves explaining to the computer how
to perform the calculations yourself, as a series of steps the computer can
follow.

Take a look at this factorial function written in C:

```c
int factorial(int n)
{
    int ret = 1;

    while (n > 1)
    {
        ret *= n;
        n--;
    }

    return ret;
}
```

Fundamentally, this is the same exact logic as in the Haskell version, it's
just specified in a different way.

At a high level, this function does the following:

1. Set *ret* to 1. This is going to be the return value.
2. Multiply *n* by *ret*.
3. Subtract 1 from *n*.
4. Repeat steps 2-3 as long as *n* is greater than 1.
5. Return the value in *ret*.

Let's step through this line by line to see how this is done.

```c
int factorial(int n)
{
```

This marks the beginning of the *factorial* function. It states that
*factorial* is a function which takes an integer called *n* and returns another
integer. This doesn't map to English quite as naturally as the Haskell type
signature, but we can try:

```c
// Returning an int, factorial is a function which takes an int named n
                int  factorial         (                    int       n)
```

The ordering of the syntax makes it a bit more awkward, but this line means
the same thing as the Haskell function signature.

```c
    int ret = 1;
```

This declares a new integer called *ret* and gives it the value 1. This is
going to be the return value. We'll repeatedly multiply *n* against this
variable and return it when we're done.

```c
    while (n > 1)
    {
```

This starts a loop. The ```while (n > 1)``` part means to run the code inside
the curly braces ```{ ... }``` over and over as long as *n* is greater than 1.
If *n* is 0 or 1 at the start of the function, this loop will never run at all.

```c
        ret *= n;
```

Each time the loop runs, we multiply *n* by *ret* and store the result in
*ret*.

```c
        n--;
```

Then we subtract 1 from *n*. This way, *n* will keep going down each time the
loop runs.

```c
    }
```

This is the end of the loop body. When execution reaches this point, it will
jump back to the beginning of the loop and run it again, assuming the
conditional in the *where* line is still true.

```c
    return ret;
}
```

Once the loop is finished, we return the value in *ret* and end the function.

This *factorial* function can be called like this:

```c
    factorial(5);
```

When it's called with a 5, the following steps happen:

1. *ret* is set to 1.
2. *n* is 5 and 5 > 1, so the loop body runs.
3. *ret* is multiplied by 5, changing it to 5.
4. *n* is decremented, changing it to 4.
5. *n* is 4 and 4 > 1, so the loop body runs again.
6. *ret* is multiplied by 4, changing it to 20.
7. *n* is decremented, changing it to 3.
8. *n* is 3 and 3 > 1, so the loop body runs again.
9. *ret* is multipled by 3, changing it to 60.
10. *n* is decremented, changing it to 2.
11. *n* is 2 and 2 > 1, so the loop body runs again.
12. *ret* is multiplied by 2, changing it to 120.
13. *n* is decremented, changing it to 1.
14. *n* is 1 and 1 is not greater than 1, so the loop ends.
15. *ret*, with a value of 120, is returned to the caller.

# Factorials in assembly language

Despite differences in style, the C and Haskell functions are both relatively
high-level. That means you don't need to bother yourself much with the
particulars of the machine you're writing the code for: both the C and Haskell
compilers can handle turning code into something appropriate for the computer
being targeted. But what does the code they generate look like?

This gets us into assembly language. Assembly language is a symbolic form of
machine code. For the most part, instructions in assembly language map directly
to machine code instructions.

Because of this, we can't state things in quite the same terms in assembly as
we did in C and Haskell: higher level languages do a lot to adapt their syntax
to how humans think, but in assembly we have to do some of that work ourselves
and adapt our thinking to the particulars of the hardware.

There are actually lots of assembly language syntaxes. In this case we'll be
using the [Netwide Assembler](nasm.us), also known as *nasm*. Before we move
on, let's get the truly important stuff out of the way. Here's nasm's logo:

<img width="40%" src="/blog/from-math-to-machine/nasm-logo.png" />

I'm afraid Haskell still wins, but this one isn't bad at all.

Here's a factorial function written in nasm syntax for an x86-64 computer:

```nasm
factorial:
    mov rdi, 1

  .loop:
    cmp rax, 1
    jle .done

    imul rdi, rax
    dec rax

    jmp .loop

  .done:
    ret
```

Okay, what happened? If you can make any sense of this at all you're either
already familiar with assembly or you're a lot smarter than I am. The C and
Haskell versions at least have some complete words and some familiar-ish
expressions. However, even though the style of code has changed substantially,
the same logic is here, in more or less the same order.

Take a look at this version with comments added to show roughly what each line
does in C:

```nasm
factorial:        ; int factorial(int n) {
    mov rdi, 1    ;     int ret = 1;

  .loop:          ; .loop:
    cmp rax, 1    ;     if (n <= 1)
    jle .done     ;         goto .done;     // The dreaded goto!

    imul rdi, rax ;     ret *= n;
    dec rax       ;     n--;

    jmp .loop     ;     goto .loop;         // Oh god it's another one!

  .done:          ; .done:
    ret           ;     return ret;
                  ; }
```

The mapping isn't perfect, but with the comments in place, this code should
look a little less odd.

Even though it's described differently, the basic logic is the same as the C
version. This is no accident: C is a fairly thin layer over assembly and most
of its constructs can map pretty directly to a wide variety of machines.

One critical difference between the assembly version and the C/Haskell
versions is that there is no type signature in assembly. Nowhere does the
assembly version define what inputs the *factorial* function accepts or what
outputs it returns. Instead, it expects that the input value *n* has been
loaded into a register called *rax* before the function was called. It
leaves its return value in *rdi* when it exits, again assuming that the caller
will know where to find that answer. Nowhere in the code is this expressed in
concrete terms: to use this function you basically have to already know how it
works. Ideally there would be comments in the code or external documentation
containing this information. If not, you'd have to read the function's code to
try and work out how to use it.

When the function starts, it sets *rdi* to 1, which will be the return value.
Next, it repeatedly multiplies that return value by the value in *rax*,
subtracting 1 from *rax* each time. Once *rax* reaches 0 or 1, the function
ends and the return value is left in *rdi* for the caller to use. Assuming the
caller put an integer in *rax* before calling the *factorial* function, it will
find the factorial of that integer in *rdi* when the function returns.

If you're curious what these instructions really do beyond just seeing how
they could map to C-style syntax, read on!

# More detail on the assembly version

First, a quick primer. The CPU doesn't really think in terms of variables like
```int ret = 1;``` or expressions like ```ret *= n;```. Instead, it has a
number of *registers*. Each register can store a fixed amount of data. On a
64-bit processor, the general-purpose registers store 64 bits each.

By executing instructions, a program can load data into these registers and
then do math on that data.

Since registers are tiny chunks of memory inside the CPU hardware, performing
operations on registers is lightning-fast because the CPU doesn't need to wait
on data to move to or from system memory.

A few of the more commonly-used registers are:

| Register | Description                                                      |
|----------|------------------------------------------------------------------|
| rax      | General-purpose                                                  |
| rbx      | General-purpose                                                  |
| rcx      | General-purpose                                                  |
| rdx      | General-purpose                                                  |
| rdi      | General-purpose                                                  |
| rsi      | General-purpose                                                  |
| rbp      | Often used to keep track of the start of a stack call frame      |
| rsp      | Always points to the top of the stack                            |
| rip      | Always points to the next instruction to be executed             |

The general-purpose registers can mostly be used however you want. Other
registers have specific purposes with rules about how they can be used or
modified.

The CPU can only perform calculations on data loaded into registers. So in
order to add two numbers together, you first have to tell the computer to load
each number into a register, and then you can tell it to add the values in
those registers together.

Let's go through the assembly function line by line to see how it works in
more detail.

```nasm
factorial:
```

This marks the beginning of the *factorial* function. A name followed by a
colon is called a *label*. We can tell the computer to *jump* to this label
whenever we want the code after the label to run.

At the beginning of the function, we assume that the caller set *rax* to
some integer *n*.

```nasm
    mov rdi, 1
```

We're going to return the result of the function in a register called *rdi*.
This instruction sets *rdi*'s initial value to 1. We have no idea what this
register is set to at the beginning of the function because registers aren't
automatically cleared when functions are called. We have to set it to
something before we use it.

```nasm
  .loop:
```

This is another label, marking the beginning of the loop. The dot at the front
makes it a local label, making it local to the function we're in. We can jump
to ```.loop:``` anytime we want the loop to run.

```nasm
    cmp rax, 1
```

Each time the loop runs, the first thing we need to do is check if the loop
should end yet.

Remember *n* is stored in *rax*. This instruction compares the value in *rax*
to 1. It doesn't do anything with that information, it just sets things up so
we can act on it later.

```nasm
    jle .done
```

This instruction acts on the previous compare instruction. *jle* means to
**j**ump if **l**ess than or **e**qual to. So if *rax* is less than or equal to
1, execution will skip ahead to the *done:* label, ending the loop. Otherwise,
execution will continue to the next instruction, which will run the loop body.

```nasm
    imul rdi, rax
```

If the program didn't jump out of the loop to the *.done:* label, we know that
*n* must be 2 or higher. This instruction multiplies *rdi* by *rax* and stores
the result in *rdi*.

```nasm
    dec rax
```

This instruction decrements *rax*, which means to subtract 1. If *rax* is 5,
this instruction will set it to 4.

```nasm
    jmp .loop
```

This instruction jumps back to the *.loop:* label, which starts the loop over
again.

```nasm
  .done:
```

Once the loop is finished running, execution will jump here.

```nasm
    ret
```

The factorial result should now be sitting in *rdi*. This instruction ends the
function, causing execution to jump back to wherever it left off when this
function was called. The return value of ```n!``` will be left in the *rdi*
register for the caller to use.

So you can see that the logic is pretty similar to the C version. Implementing
higher-level constructs like C's *while* loop requires jumping around between
labels and separate comparison instructions but it works the same. The function
is much less self documented since it has no formal type definition, but
otherwise it takes the same input and provides the same output.

# Factorials in machine code

We've seen the assembly language version of a factorial function, but can a
computer run that directly? The answer is.. almost. Assembly language is a
mnemonic for machine code, meaning that each instruction maps to a machine
code instruction. However, in assembly, the instructions are specified using
bits of English words and numbers in decimal notation in order to be easier for
humans like me and (presumably) you to read and write.

We can assemble code by hand using the convenient reference at
[ref.x86asm.net](http://ref.x86asm.net/). A detailed look at hand-assembling
code is probably a topic for another day, but just for fun, let's take a quick
look at how the assembly function could map to machine code.

*Note: I'm going to leave out some common optimizations.*

Behold!

```
48 bf 01 00 00 00 00 00 00 00 48 3d 01 00 00 00 7e 0c 48 0f af f8 48 ff
c8 e9 ec ff ff ff c3
```

This is the factorial function in machine code. Makes sense, right? I'm glad
you understand, thanks for reading!

...

Yeah I can't read this very well either, but this is kind of how a computer
sees machine code. It's a big slab of bytes sitting somewhere in memory. The
*rip* register stores an address to one of those bytes. When the computer runs
an instruction it checks the value of *rip* to see where it's pointing and it
*decodes* the data it finds there. That means that according to a bunch of
rules it sorts out what instruction is meant by a series of bytes.

Once decoded, the CPU does whatever the instruction tells it to do. By default
*rip* is advanced to point to the next instruction after the one being run.
This way, the next time the CPU runs an instruction, *rip* will be pointing at
the next instruction in memory. This causes instructions to run in sequence.
However, in some cases (such as jumps) the instruction modifies the *rip*
register to point somewhere else, causing execution to jump around.

The code above is represented as hex. Each pair of hex digits is one byte. This
could just as easily be represented as a series of 0s and 1s (8 per byte) or in
decimal (a number from 0-255 for each byte). For example:

| Decimal | Hex | Binary   |
|---------|-----|----------|
| 72      | 48  | 01001000 |

The way the data is represented isn't really important. You could make up your
own encoding format if you wanted, even though nobody else would know how to
read it.

Since this slab of hex bytes isn't very helpful, let's break it up into
instructions:

```nasm
48 bf 01 00 00 00 00 00 00 00   mov rdi, 1

48 3d 01 00 00 00               cmp rax, 1
7e 0c                           jle .done       ; Jump ahead 12 bytes

48 0f af f8                     imul rdi, rax
48 ff c8                        dec rax

e9 ec ff ff ff                  jmp .loop       ; Jump back 20 bytes

c3                              ret
```

Probably the biggest difference between this and the assembly version (other
than vaguely English-inspired words turning into a soup of hex digits) is the
lack of labels. That's because labels like *factorial:* and *.done:* are a
convenience provided by assemblers. In machine code, jumps work by changing
the value in *rip* to point somewhere else.

Take a look at the assembled version of ```jle .done```:

```nasm
7e 0c                           jle .done       ; Jump ahead 12 bytes
```

In this instruction, each byte has a meaning:

| Hex | Role    | Value | Meaning                       |
|-----|---------|-------|-------------------------------|
| 7e  | Opcode  | jle   | Jump if less than or equal to |
| 0c  | Operand | 12    | Jump 12 bytes forward         |

So the *7e* tells the computer to jump depending on a previous *cmp*
instruction. *0c* tells it exactly where to jump, assuming the jump happens.
*0c* is hex for *12*. All together, this means to jump forward 12 bytes from
the current position.

When an instruction is executed, *rip* will be pointing to the next byte after
that instruction. So when ```7e 0c (jle .done)``` is executed, *rip* will be
pointing to ```48 0f af f8 (imul rdi, rax)```. If the jump occurs, *rip* will
be increased by a value of 12, making it point to the ```c3 (ret)``` all the
way at the end. The next instruction to run will therefore be either ```48 0f
af f8 (imul rdi, rax)``` or ```c3 (ret)```, depending on the outcome of the
comparison being performed.

How about jumping backwards? It works the same, except it uses a negative
offset. Take a look at the code for ```jmp .loop```, which jumps back to the
start of the loop:

```nasm
e9 ec ff ff ff                  jmp .loop       ; Jump back 20 bytes
```

This instruction can be broken into two pieces like the previous one:

| Hex         | Role    | Value |Meaning                                   |
|-------------|---------|-------|------------------------------------------|
| e9          | Opcode  | jmp   | Jump no matter what (unconditional jump) |
| ec ff ff ff | Operand | -20   | Jump 20 bytes backward                   |

So ```e9``` tells the CPU to jump and ```ec ff ff ff``` tells it to jump
backward 20 bytes. When this instruction is executed, *rip* will be pointing to
```c3 (ret)``` at the end of the function. Applying a delta of -20 to *rip*
will cause execution to jump back 20 bytes to
```48 3d 01 00 00 00 (cmp rax, 1)```, which will run the loop again.

Providing labels and letting us jump to labels instead of offsets is a very
convenient feature provided by assemblers. Without it, you'd have to count
bytes to implement control structures like conditionals and loops. Every time
you added, removed, or even changed instructions, you'd have to recalculate all
your jump offsets. So assemblers help out a lot more than just translating
pseudo-English like *jmp* or *rax* to their binary equivalents.

Other than the labels being replaced by relative offsets and everything being
converted into a binary format, it's the same logic as the assembly version,
which is nearly the same as the C version. It's almost like all these languages
and formats are somehow related to each other. Spooky!

# Conclusion

We've seen an idea translated gradually down through several languages, ending
up with machine code. Hopefully this has been interesting and possibly even
enlightening. If you enjoyed this, feel free to send me millions of dollars.
Thanks for reading!
