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
Haskell, which can resemble math in some important ways.

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
factorial 0 = 1
factorial n = n * factorial (n - 1)
```

You should see some similarities between the Haskell definition of a factorial
and the math definition given earlier. Here it is if you don't feel like
scrolling:

```
0! = 1
n! = n * (n - 1)!
```

In the math definition, the ```!``` character represents the factorial function
and appears after the number. For example: ```0!```, ```n!```, and
```(n - 1)!```.

In the Haskell version, the word *factorial* is used in place of the
```!``` character and it appears before the number instead of after. For
example: ```factorial 0```, ```factorial n```, and ```factorial (n - 1)```.

The Haskell version is also a bit more specific about the types of values it
accepts. The first line specifies that *factorial* is a function which takes
an integer and returns another integer. Here's an oddly-formatted version of
that first line, spaced out so you can see roughly which parts of the syntax
mean what:

```haskell
-- factorial is a function which takes an integer and returns another integer
factorial            ::                     Int          ->             Int
```

Haskell functions support a feature called pattern matching. When this
function is called, it walks down the patterns until it finds one
that the input parameter matches. So if *factorial* is called with a 0, as in
```factorial 0```, that matches the first pattern:

```haskell
factorial 0 = 1
```

In this case, the function simply returns the value 1 without doing any
calculations.

If *factorial* is called with a number other than 0, like in ```factorial 5```,
the first pattern doesn't match. Instead, it will fall through to the next
pattern, which matches anything and binds that value to the name *n*:

```haskell
factorial n = n * factorial (n - 1)
```

This pattern takes the value for ```n```, multiplies it by the factorial of
```n - 1```, and returns the result.

Notice that just like in the math definition, this is a recursive definition.
The *factorial* function calls itself to get the factorial of ```n - 1```. The
function then in turn calls itself again, and on and on, until the base
case is reached, at which point the results begin to bubble back up.

Since this is Haskell, we don't have to tell the computer how to solve these
definitions, we just have to provide them, and the compiler will sort it all
out.

Here's what happens in order (logically, that is):

1. ```factorial 5``` calls ```factorial (5 - 1)```
2. ```factorial 4``` calls ```factorial (4 - 1)```
3. ```factorial 3``` calls ```factorial (3 - 1)```
4. ```factorial 2``` calls ```factorial (2 - 1)```
5. ```factorial 1``` calls ```factorial (1 - 1)```
6. ```factorial 0``` returns ```1```
7. ```factorial 1``` returns ```1 * 1```
8. ```factorial 2``` returns ```2 * 1```
9. ```factorial 3``` returns ```3 * 2```
10. ```factorial 4``` returns ```4 * 6```
11. ```factorial 5``` returns ```5 * 24```

So, even though the syntax is a bit different, the two definitions are
otherwise identical: both specify the same two cases involved in calculating a
factorial: ```0! = 1``` and ```n! = n * (n - 1)!```.

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
    if (n == 0)
    {
        return 1;
    }

    return n * factorial(n - 1);
}
```

Again, you should see some similarities between this and both the Haskell and
math versions, but there are important differences in style.

Rather than defining the two different cases (the base case and the recursive
case) and letting Haskell figure out which to use, in C, we have to express
this logic ourselves.

Each time the C version of the *factorial* function is called, it performs the
following steps in order:

1. Check if *n* is equal to 0. If so, this is the base case. Return 1.
2. Otherwise, make a recursive call to ```factorial(n - 1)``` and multiply the
   result by *n*.

Fundamentally, this is the same exact logic as in the other versions, it's just
specified in a different way. There is still a base case which states that
```0! = 1``` and there's still a recursive case which states that
```n! = n * (n - 1)!```. But this time, rather than explaining those
relationships declaratively, we instead have to give C a series of steps
it can follow to produce the result.

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
    cmp rax, 1
    je base_case

    push rax

    dec rax
    call factorial

    pop rax
    imul rdi, rax

    ret

  base_case:
    mov rdi, 1
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
factorial:          ; int factorial(int n) {
                    ;     int ret;

    cmp rax, 0      ;     if (n == 0)             // Expects rax to be set to n
    je base_case    ;         goto base_case;     // The dreaded goto!

    push rax        ;     int original_n = n;     // Save n's original value

    dec rax         ;     n--;
    call factorial  ;     ret = factorial(n);

    pop rax         ;     n = original_n;         // Restore n
    imul rdi, rax   ;     ret *= n;

    ret             ;     return ret;

  base_case:        ; base_case:
    mov rdi, 1      ;     ret = 1;
    ret             ;     return ret;
                    ; }
```

With the comments in place, this should look a little less odd. When the
function starts, it checks if *n* is equal to 0. If it is, it jumps over most
of the function body and returns 1, satisfying the rule ```0! = 1```.
Otherwise, it calls itself recursively and returns ```n * (n - 1)!```.

If you're curious what these instructions really do beyond just seeing how
they could map to C-style syntax, read on!

# More detail on the assembly version

First, a quick primer. The CPU doesn't think in terms of variables like
```int n``` or expressions like ```n * factorial(n - 1)```. Instead, it has a
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
    cmp rax, 0
```

Remember *rax* is *n*. The first thing we do is check if this is the base case.
This instruction compares the value in *rax* to 0. It doesn't do anything with
that information, it just sets things up so we can act on it later.

```nasm
    je base_case
```

This instruction acts on the previous compare instruction. This means to
**j**ump if **e**qual to the *base_case* label. So if *n* is 0, this will
jump ahead to the *base_case:* label, which will handle returning 1 (for
```0! = 1```. If not, execution will continue to the next instruction.

```nasm
    push rax
```

If the program didn't jump ahead to the *base_case:* label, we know that
*n* must not be 0. That means we need to handle the recursive case.

Like usual, we need to call the function we're already in, but with `rax` set
to a value of ```n - 1```. When it returns, *rdi* will be set to the answer
```(n - 1)!```. We will then need to multiply that answer by the original value
in *rax*.

There's just one problem: we're calling the same function again, which requires
*rax* to be set to the input parameter *n*. We're going to end up destroying
the original value of *n* in order to make the recursive call! We need some way
to save the original value of *n* for later.

This is where the stack comes in. When you *push* something onto the stack,
it's saved there for later. The instruction above copies the value of *n* onto
the stack. Now we can destroy the data in *rax* and still restore its original
value by *pop*ing it back off the stack later on. Of course, we have to make
sure we *pop* data off the stack in the same order we *push*ed it on, or we'll
end up with the wrong data.

```nasm
    dec rax
```

Now that we've saved *rax*'s original value on the stack, we can mess up the
value in *rax*. This instruction *dec*rements the value in *rax*. So if *rax*
is 5, this instruction will change it to 4.

```nasm
    call factorial
```

We have ```n - 1``` sitting in *rax*, so we're all set to make the recursive
call. The *call* instruction does two things:

1. It pushes the current instruction pointer onto the stack so that the line
   we're on can be returned to when the recursive call is done.
2. It jumps to the *factorial:* label to run this function again, now with a
   different value for *n* in *rax*.

```nasm
    pop rax
```

After the recursive call is finished, execution will resume where it left off.
Since the *factorial* function leaves its answer in the register *rdi*, we can
assume that the answer to ```(n - 1)!``` is now sitting in *rdi*. We need to
multiply it by *n* before we can return the answer to ```n!```.
But we destroyed the value in *rax* in order to make the recursive call.

Before that can be done, we need to restore the original value that was in
*rax*. This instruction will *pop* the value we previously saved back off the
stack and into *rax*, restoring *rax* to its original value. *rax* should be
set to *n* again, just as it was at the beginning of the function.

```nasm
    imul rdi, rax
```

So *rax* is set to ```n``` and *rdi* is set to ```(n - 1)!```. Let's multiply
them together! In this instruction, the two values are multiplied together, and
the answer is saved in *rdi*.

```nasm
    ret
```

The result of ```n * (n - 1)!```, which is ```n!```, is sitting in *rdi*.
We're ready to end the function. This instruction pops a value off the stack
and jumps to it. Since a call was made to start this function, assuming we
didn't mess up the ordering of *push*es and *pop*s, there should be a return
instruction address sitting on the top of the stack right now. When this
instruction executes, that address will be popped off and stored in *rip*.
*rip* is a special register that controls what instruction runs next. This
means execution will resume wherever it left off when this function was called,
now with the return value of ```n!``` waiting in *rdi* for the caller to use.

```nasm
  base_case:
```

This marks the start of the handling for the base case. If *n* was 0 at the
beginning of the function, the *cmp* and *je* instructions would have sent
execution here, skipping the recursive section. All we need to do here is
return 1.

```nasm
    mov rdi, 1
```

This instruction sets *rdi* to the integer value 1, where the caller will
expect the return value to be.

```nasm
    ret
```

Now the function returns to the caller, with the answer to ```0!``` in *rdi*.
