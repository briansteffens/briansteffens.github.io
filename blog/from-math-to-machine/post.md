From Math To Machine: Factorials
================================

In this post I'm going to explore how the same idea can be represented in
several ways and show how a mathematical concept can be redefined in
progressively more computer-oriented terms, all the way down to x86-64
assembly, almost ready for direct execution by a computer. To that end, I'm
going to define the same logic in several different formats:

1. **Math** - pure mathy goodness
2. **Haskell** - a functional programming language
3. **C** - an imperative programming language
4. **Assembly** - instructions a computer can execute (almost) directly

If you're interested in how language styles can differ or curious about what
your code might look like after being compiled, keep reading!

# Factorials in math

A factorial is the product of an integer and all smaller integers greater
than 0. For example, the factorial of 5 is:

```
5! = 1 * 2 * 3 * 4 * 5
```

Or:

```
5! = 120
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

Notice that, with the exception of 0! which is fixed at 1, each subsequent
value of n is n * the previous factorial. Example:

| n   | n!           |
|-----|--------------|
| 0!  | 1            |
| 1!  | 1 * 0! = 1   |
| 2!  | 2 * 1! = 2   |
| 3!  | 3 * 2! = 6   |
| 4!  | 4 * 3! = 24  |
| 5!  | 5 * 4! = 120 |

This is what's called a recursive definition: the value of each factorial
depends on the value of the previous factorial, which in turn depends on the
value of the factorial before that, and so on, until you reach 0!, where the
recursion stops. The point at which the recursion stops is called the base
case.

In math terms, this recursive definition can be stated many ways. One such way
is as follows:

```
0! = 1
n! = n * (n - 1)!
```

The above states that factorials follow two rules:

1. The factorial of 0 is always equal to 1.
2. The factorial of any other positive integer *n* is the product of *n* and
   the factorial of ```n - 1```.

So, applying these rules when *n* is 5 produces something like the following:

```
5! = 5 * (5 - 1) * (5 - 2) * (5 - 3) * (5 - 4) * 1
```

The integer *n* is multiplied by each smaller integer until it reaches the base
case of 1.

# Factorials in a functional language

Just like there are lots of ways to describe something mathematically, there
are also lots of ways to describe things to computers. Let's start with
Haskell, which among other useful features, happens to have a pretty cool
looking logo:

<img src="/blog/from-math-to-machine/haskell-logo.svg" />

Haskell is a purely functional language. In broad terms, this means that
instead of telling the computer *what to do*, a Haskell program tells the
computer *what things are*. Once a program has been written in Haskell, it's
up to the Haskell compiler to figure out how to translate those definitions
into actionable instructions which a computer can understand.

Because Haskell programs specify definitions of concepts, they can be
surprisingly similar to pure math representations. Take a look at the following
Haskell function, which calculates the factorial of the parameter provided to
it:

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
-- factorial is a function which takes an integer and returns another integer
factorial            ::                     Int          ->             Int
```

This first line is technically optional but it's usually good practice to
include it. Haskell is pretty smart so it can actually figure out type
signatures on its own most of the time, but it's still useful to document the
function signature for other programmers or your future self.

The second line defines the function body, which can be read as "the factorial
of n is equal to the product of all integers from 1 to n". Here's another
spaced out version to show which parts of the syntax match roughly:

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

So, once the *factorial* function above is defined, you can get the factorial
for a number by calling it with that number like this:

```haskell
factorial 0 -- This returns 1
factorial 3 -- This returns 6
factorial 5 -- This returns 120
```

# Factorials in an imperative language

We've seen how the mathematical idea of factorials can be expressed in the
style of a functional programming language. Now we'll go another level deeper
and see the same thing in an imperative language.

Programming in functional languages like Haskell generally works by defining
what things are and letting the language work out how to arrive at the answer.
Programming in an imperative language involves explaining to the computer how
to perform the calculations yourself, as a series of steps which change the
computer state and react to it by running different bits of code depending on
the state on the computer at the time.

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
just specified in a different way. But this time, rather than explaining the
definition of a factorial declaratively, we have to give C a series of steps
it can follow to produce the result we want.

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
*factorial* is a function which takes an integer called *n* returns another
integer. This doesn't break down into English quite as naturally as the
Haskell type signature, but we can try:

```c
// Returning an int, factorial is a function which takes an int named n
                int  factorial         (                    int       n)
```

The ordering of the syntax makes it a bit more awkward, but this line means
the exact same thing as the Haskell function signature.

```c
    int ret = 1;
```

This declares a new integer called *ret* and sets it to the value 1. This is
going to be the return value. We'll be repeatedly multiplying *n* against this
value and returning it when we're done.

```c
    while (n > 1)
    {
```

This is a loop. This says to run the code inside the curly braces ```{ ... }```
over and over as long as *n* is greater than 1. If *n* is 0 or 1 at the start
of the function, this loop will never run at all.

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
jump back to the beginning of the loop and run it again.

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
5. *n* s 4 and 4 > 1, so the loop body runs again.
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
the actual machine code executed by a computer. For the most part, instructions
in assembly language map directly to machine code instructions.

Because of this, We can't state things in quite the same terms in assembly as
we did in C and Haskell: higher level languages do a lot to adapt their syntax
to how humans think, but in assembly we have to do some of that work ourselves
and adapt our thinking to the particulars of the hardware.

Here's a factorial function written in Intel-style syntax for an x86-64
computer:

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

Okay, what happened? The C and Haskell versions differed but there were some
pretty recognizable similarities. If you see many similarities this time,
you're either already familiar with assembly or you're a lot smarter than me.
But even though the style of code has changed substantially, the same logic is
here, in more or less the same order.

Take a look at this version with comments added showing roughly what each line
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

One critical difference between this assembly version and both the C and
Haskell versions is that there is no type signature. Nowhere does the
assembly version define what inputs and outputs the *factorial* function takes.
Instead, it expects that the input value *n* has been loaded into a register
called *rax* before the function was called. It calculates the factorial of the
value in *rax* and leaves the answer in *rdi* for the caller to use. Nowhere
in the code is this expressed in concrete terms: to use this function you
basically just have to know what it expects. Ideally it would be commented
with this information. Otherwise you'd have to read the function's code to try
and sort out how to use it.

When the function starts, it sets *rdi* to 1, which it will use as its return
value. Next, it repeatedly multiplies that return value by the value in *rax*,
subtracting 1 from *rax* each time. Once *rax* reaches 0 or 1, the function
ends and the return value is left in *rdi* for the caller to use. Assuming the
caller put an integer in *rax* before calling the *factorial* function, it will
find the factorial of that integer in *rdi* when the function returns.

If you're curious what these instructions really do beyond just seeing how
they could map to C-style syntax, read on!

# More detail on the assembly version

First, a quick primer. The CPU doesn't really think in terms of variables like
```int ret = 1;``` or expressions like ```ret *= n;```. Instead, it has a
number of *registers*, each of which can store a fixed amount of data. On a
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

The CPU can only perform calculations on data loaded into registers. So, in
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

So when the factorial function is called, this is where it starts. This
function, like the C and Haskell versions, takes an integer *n* and returns the
integer *n!*. However, we can't describe it that way. Functions in 64-bit
assembly usually accept parameters and return results through registers. This
function expects the value of *n* to be in a register called *rax*. When the
function returns, it will leave the answer *n!* in another register, called
*rdi*.

So at the beginning of the function, we can assume that the caller put *n* into
*rax*.

```nasm
    mov rdi, 1
```

We're going to return the result of the function in a register called *rdi*.
This instruction sets it to 1. We have no idea what this register is set to at
the beginning of the function because registers aren't automatically cleared
when functions are called.

```nasm
  .loop:
```

This is another label, marking the beginning of the loop. The dot at the front
makes it a local label, meaning it's local to the function we're in. We can
jump to ```.loop:``` anytime we want the loop to run.

```nasm
    cmp rax, 1
```

Each time the loop runs, the first thing we need to do is check if the loop
should end yet.

Remember *rax* is *n*.  This instruction compares the value in *rax* to 1. It
doesn't do anything with that information, it just sets things up so we can act
on it later.

```nasm
    jle .done
```

This instruction acts on the previous compare instruction. This means to
**j**ump if **l**ess than or **e**qual. So if *rax* is less than or equal to
1, execution will skip ahead to the *done:* label. Otherwise, execution will
continue to the next instruction, which will run the loop body.

```nasm
    imul rdi, rax
```

If the program didn't jump out of the loop to the *.done:* label, we know that
*n* must be 2 or higher. This instruction multiplies the values in *rdi* and
*rax* and stores the result in *rdi*.

```nasm
    dec rax
```

This instruction decrements *rax*, which means it subtracts 1 from it. If *rax*
is 5, this instruction will set it to 4.

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

The factorial result should be sitting in *rdi*. This instruction ends the
function, causing execution to jump back to wherever it left off when this
function was called. The return value of ```n!``` will be left in the *rdi*
register for the caller to use.

# Factorials in machine code

We've seen the assembly language version of a factorial function, but can a
computer run that directly? The answer is not quite. Assembly language is a
mnemonic for machine code, meaning that each instruction maps to a machine
code instruction, but is specified using bits of English words and numbers in
decimal notation in order to be easier for humans like me and (presumably) you.

We can hand assemble code using the handy reference at
[ref.x86asm.net](http://ref.x86asm.net/). A detailed look at hand-assembling
code is probably a topic for another day, but just for fun, let's look at how
the assembly function could map to machine code.

*Note: I'm going to leave out some common optimizations*

Behold!

```
48 bf 01 00 00 00 00 00 00 00 48 3d 01 00 00 00 7e 0c 48 0f af f8 48 ff c8 e9
ec ff ff ff c3
```

This is the factorial function in machine code. Makes sense, right? I'm glad
you understand, thanks for reading!

...

Yeah I can't read this very well either, but this is kind of how a computer
sees machine code. It's a big slab of bytes sitting somewhere in memory. The
*rip* register stores an address to one of those bytes. When the computer runs
an instruction it checks the value of *rip* to see where it's pointing and it
*decodes* the data it finds there.  That means that according to a bunch of
rules it sorts out what instruction is meant by a series of bytes. It does
whatever the instruction tells it to. By default it moves *rip* to point to the
next byte after the end of the instruction it decoded so that the next time it
tries to run an instruction it will be pointing at the next instruction in
memory. This causes each instruction to run sequentially. However, in some
cases (like jump instructions) the instruction modifies the *rip* register to
point somewhere else, causing execution to jump around.

The code above is represented as hex. Each pair of hex digits is one byte. This
could just as easily be represented as a series of 0s and 1s (8 per byte) or in
decimal (a number from 0-255 for each byte). For example:

| Decimal | Hex | Binary   |
|---------|-----|----------|
| 72      | 48  | 01001000 |

The way the data is represented isn't really important. You could make up your
own encoding of the data if you wanted, even though nobody would know what it
meant.

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

Probably the biggest difference (other than vaguely English-inspired words
turning into a soup of hex digits) is the lack of labels. That's because labels
like *factorial:* and *.done:* are a convenience provided by assemblers. In
machine code, jumps work by jumping to relative offsets.

Take a look at the assembled version of ```jle .done```:

```nasm
7e 0c                           jle .done       ; Jump ahead 12 bytes
```

In this instruction, each byte has a meaning:

| Hex | Role    | Meaning                               |
|-----|---------|---------------------------------------|
| 7e  | Opcode  | *jle* - jump if less than or equal to |
| 0c  | Operand | 12 bytes forward                      |

So the *7e* tells the computer the opcode, or the type of instruction to
execute. *0c* is the value telling it where to jump. *0c* is hex for *12*.
All together, this means to jump forward 12 bytes.

When an instruction is executed, *rip* will be pointing to the next byte after
that instruction. So when ```7e 0c``` is executed, *rip* will be pointing to
the ```48 0f af f8``` that comes after it. If *rax* is less than or equal to
1, causing the jump to occur, *rip* will be advanced 12 bytes, which will leave
it pointing at the ```c3``` all the way at the end. The next instruction to
run will therefore be ```c3 - ret```.

How about jumping backwards? It works the same. Take a look at the code for
```jmp .loop```, which jumps back to the start of the loop:

```nasm
e9 ec ff ff ff                  jmp .loop       ; Jump back 20 bytes
```

This instruction can be broken into two pieces like the previous one:

| Hex         | Role    | Meaning                                 |
|-------------|---------|-----------------------------------------|
| e9          | Opcode  | *jmp* - unconditional jump              |
| ec ff ff ff | Operand | *-20* in signed two's complement format |

So ```e9``` tells the CPU to jump and ```ec ff ff ff``` tells it to jump
backwards 20 bytes. When this instruction is executed, *rip* will be pointing
to the ```c3 - ret``` at the end of the function. Applying a delta of -20 to
the *rip* will cause execution to jump back 20 bytes to
```48 3d 01 00 00 00 - cmp rax, 1``` which will run the loop again.

This is a very convenient feature provided by assemblers. Without it, you'd
have to count bytes back and forth to implement control structures like
conditionals and loops. Every time you changed instructions inside a loop
or added a bit more code you'd have to recalculate all your jump offsets. So
assemblers help out a lot more than just translating pseudo-English like
*jmp* or *rax* to their binary equivalents.

# Conclusion

We've seen an idea traced gradually down through several ways of describing it,
showing how some logic can be translated from a format optimized for processing
by the human brain down to a format appropriate for a machine, with plenty of
stops along the way:

1. **English** - a way of describing ideas to us filthy humans
2. **Math** - a better way of describing ideas to us filthy humans
3. **Haskell** - a high level functional language
4. **C** - a pretty high level imperative language
5. **Assembly** - a mnemonic for machine code
6. **x86-64 code** - instructions a CPU can directly process

Hopefully this has been interesting and possibly even enlightening. Thanks for
reading!
