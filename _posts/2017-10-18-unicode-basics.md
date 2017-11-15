---
layout: default
title: Unicode basics
description: An overview of Unicode and how it relates to various encodings
---

<style>
    table {
        border-collapse: collapse;
        margin-bottom: 16px;
        margin-left: auto;
        margin-right: auto;
    }

    th {
        font-weight: bold;
    }

    td, th {
        border: solid 1px #ddd;
        padding: 6px 13px 6px 13px;
    }

    tr:nth-child(even) {
        background-color: #f8f8f8;
    }

    h1 {
        border-bottom: solid 1px #eee;
        margin-top: 24px;
        font-weight: 600;
    }

    img {
        display: block;
        margin-left: auto;
        margin-right: auto;
    }

    code.highlighter-rouge, pre.highlight, pre.highlight * {
        background-color: #f3f3f3 !important;
    }
</style>

Unicode basics
==============

In doing research about potentially adding Unicode support to my toy compiler
<a href="https://github.com/briansteffens/bshift" target="_blank">bshift</a>,
I quickly realized just how little I understood about Unicode. This is
interesting, because I've been programming for a decently long time and nearly
all text data is in Unicode these days. It's amazing how much code I've
written to process text, save, validate, and retrieve textual data without
really understanding the format that data is in.

There are a lot of great resources that go into the specifics of various
aspects of Unicode, but I had a hard time fitting all of the pieces together
in my mind. In this post, I'll try to summarize and connect the dots between
the primary concepts.




# ASCII and the world without Unicode

First, let's talk about the problem Unicode solves. Before Unicode, there were
many different encodings for text. ASCII is a common one. ASCII is a mapping
between text characters and numerical values used to represent those
characters:

*ASCII table here*

Each number from 0 to 127 (or 255, in the case of extended ASCII) corresponds
to a character. 32 is a space, 97 is the letter *a*, 61 is the equal sign *=*,
and so on.

For example, consider the string "Greetings!". To represent this string in
ASCII, you would look up each character in the table to get its ASCII code:

|  G  |  r  |  e  |  e  |  t  |  i  |  n  |  g  |  s  |  !  |
|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| 71  | 114 | 101 | 101 | 116 | 105 | 110 | 103 | 115 | 33  |

Notice that the character *e* has the same code in both places: 101.

So now that we have a string of text and we've converted it into a series of
codes, the next question is how we should represent this in memory. Notice that
ASCII codes range from 0 to 127 (or 0 to 255 in the case of extended ASCII).
What luck, those are the exact values a single byte stores! Okay, it's not
luck, it was by design. ASCII codes translate to memory very easily: each code
fits in one byte. So an ASCII string is usually represented as a series of
sequential bytes in memory.

If we allocated the string "Greetings!" in C:

```c
int main()
{
    char* greeting = "Greetings!";

    return 0;
}
```

The string would end up located in memory when we ran the program. The actual
address it appears at isn't important. Let's imagine it shows up at the
address 1000. Then, that subset of memory would look like this:

| Address | Byte value in memory | ASCII character |
|---------|----------------------|-----------------|
| 1000    | 71                   | G               |
| 1001    | 114                  | r               |
| 1002    | 101                  | e               |
| 1003    | 101                  | e               |
| 1004    | 116                  | t               |
| 1005    | 105                  | i               |
| 1006    | 110                  | n               |
| 1007    | 103                  | g               |
| 1008    | 115                  | s               |
| 1009    | 33                   | !               |
| 1010    | 0                    | NULL            |

So each address, starting at 1000, stores a single byte. Each of these bytes is
an ASCII code, which corresponds to a character in the ASCII table. Bu what's
that NULL character at the end? In C, a string's length is not stored anywhere.
The way that C's string functions (like *strlen()*) find the end of a string
is by starting at the first byte of the string and checking each byte in order
until encountering the ASCII code 0, which stands for NULL. This is a
null-terminated string because the string is terminated by the NULL character.

ASCII keeps things reasonably straightforward: each character (like *a*) can be
represented by a code (like *97*) which can be stored in a single byte
(like *01100001*). Okay, great. You can write all kinds of text, including a
few symbols. But what happens when you want to use, say, a Korean character?
You're out of luck. You'll have to switch to a different encoding, for example
EUC-KR. EUC-KR isn't just a different set of characters from ASCII, it works
quite differently. The number of character codes in EUC-KR don't fit in a
single byte, so it's a variable-width encoding. Writing code to support text
becomes pretty complicated. Do you write special code to support each language
and make the user choose the language they want to write in? Do you try to
build some kind of meta-encoding where you can mix and match encodings within
the same document? It's a pretty bad situation and led to a lot of programs
only supporting a single language.









# Unicode to the rescue

So now we know what text looked like before Unicode. Let's see how Unicode
attempts to solve this problem. There's a hint to how Unicode works right in
the name: Unicode is a *unified* character set. Whereas ASCII concerns itself
mostly with Latin characters, EUC-KR supports Korean text, EUC-JP support
Japanese text, and so on, Unicode defines a standard capable of supporting all
written languages at once, within a single character set.

| Code point | Character | Category                 |
|------------|-----------|--------------------------|
| ...        | ...       | ...                      |
| 0061       | a         | Latin                    |
| 0062       | b         | Latin                    |
| ...        | ...       | ...                      |
| 0056       | Ֆ         | Armenian                 |
| ...        | ...       | ...                      |
| 05d0       | א         | Hebrew                   |
| 05d1       | ב         | Hebrew                   |
| ...        | ...       | ...                      |
| 22c7       | ⋇         | Mathematical Operators   |
| 22c8       | ⋈         | Mathematical Operators   |
| ...        | ...       | ...                      |

This is a tiny subset of the characters in Unicode. We've got Latin characters,
Armenian, Hebrew, even symbols from math, all in the same character set. You
no longer have to choose which set of characters or languages you want to
support, you can have them all, including mixing and matching them.

Unicode basically works the same as ASCII, except that the range of values is
much wider. In the chart above, *code point* is the code that a character
corresponds to. Just like how the ASCII code 97 refers to the Latin character
*a*, code point 05d0 refers to the Hebrew letter aleph *א*. Notice that the
Unicode code points are given in hexadecimal. This is how they're usually
rendered, but they're still just numbers which map to characters.






# Storing Unicode in memory

ASCII codes range from 0 to 127, which means each code fits nicely in a single
byte. However, Unicode code points range from 000000 to 10ffff - that's
1,114,112 different codes! The minimum number of bits necessary to represent
1,114,112 different values is 21 (`2 ^ 21 = 2,097,152`). Unfortunately, no CPU
I've heard of has instructions designed to operate on 21 bits at a time. For
x86 processors, the integer sizes that are best-supported are:

| Bytes | Bits | Assembly name  | C type    | MySQL type |
|-------|------|----------------|-----------|------------|
| 1     | 8    | byte           | byte      | TINYINT    |
| 2     | 16   | word           | short     | SMALLINT   |
| 4     | 32   | double word    | int\*     | INT        |
| 8     | 64   | quadruple word | long long | BIGINT     |

*Note: the C types aren't very precise. They differ quite a bit across
implementations and architectures. For example, an int can be 2 or 4 bytes.*

So the smallest integer size that an x86 CPU has good support for, which also
stores at least 21 bits, is the 4-byte, 32-bit integer. This means that if we
try to store Unicode data the same way we store ASCII, that is, directly saving
code points into memory, the same text in Unicode will occupy 4 times the
amount of memory. As a result, there is a lot of interest in finding more
compact ways of representing Unicode in memory, which brings us to encodings.







# Ways of encoding Unicode data

Unicode itself is primarily a character set: a mapping from numerical code
points to characters. This tells us nothing about how to structure those
numeric values in memory. It turns out, there are several. Here are some of
the more common ones:

| Encoding name | Storage per code point | Variable- or fixed-width |
|---------------|------------------------|--------------------------|
| UTF-8         | 1 to 4 bytes           | Variable                 |
| UTF-16        | 2 or 4 bytes           | Variable                 |
| UTF-32        | 4 bytes                | Fixed                    |




# UTF-32

UTF-32 is probably the most natural way to encode Unicode data. Each code point
is simply saved right into memory. Let's take the Unicode string "Բարեւ", which
Google Translate assures me is Armenian for "hello". These five Armenian
characters correspond to the following five Unicode code points:

| Code point | Character |
|------------|-----------|
| 0532       | Բ         |
| 0561       | ա         |
| 0580       | ր         |
| 0565       | ե         |
| 0582       | ւ         |

Saving each of these code points in sequence directly into memory starting at
address 1000, we'd get something like this (assuming little-endian):

| Address | Value (hex) | Character |
|---------|-------------|-----------|
| 1000    | 0x32        | Բ         |
| 1001    | 0x05        | Բ         |
| 1002    | 0x00        | Բ         |
| 1003    | 0x00        | Բ         |
| ...     | ...         | ...       |
| 1004    | 0x61        | ա         |
| 1005    | 0x05        | ա         |
| 1006    | 0x00        | ա         |
| 1007    | 0x00        | ա         |
| ...     | ...         | ...       |
| 1008    | 0x80        | ր         |
| 1009    | 0x05        | ր         |
| 1010    | 0x00        | ր         |
| 1011    | 0x00        | ր         |
| ...     | ...         | ...       |
| 1012    | 0x65        | ե         |
| 1013    | 0x05        | ե         |
| 1014    | 0x00        | ե         |
| 1015    | 0x00        | ե         |
| ...     | ...         | ...       |
| 1016    | 0x82        | ւ         |
| 1017    | 0x05        | ւ         |
| 1018    | 0x00        | ւ         |
| 1019    | 0x00        | ւ         |

The string is only 5 characters, but since each character is being encoded
as a 32-bit integer, it takes up 20 bytes of space. Notice that only half of
the bytes are set: these code points are all low enough values that they could
each be represented using only 2 bytes, as 16-bit integers.

We can see that UTF-32 is not very space-efficient, so why would anyone use it?
The first benefit is that the encoding is pretty simple: code points map
directly into memory with no complexity added by trying to save space. The
second benefit is, because each code point occupies a fixed amount of space,
indexing into the string is easy. To find the nth code point from a UTF-32
string, add `4 * n` to the starting address of the string. This is a constant
time operation, which means that no matter the size of the string, indexing
any code point within it will take the same amount of time.







# UTF-8

UTF-8 is on the other end of the spectrum from UTF-32. While UTF-32 keeps
things simple at the expense of space, UTF-8 saves space at the expense of
simplicity.

The name UTF-8 confuses people sometimes, especially when compared to UTF-32.
UTF-32 is named because each code point occupies 32 bits of space. So does that
mean that in UTF-8 each code point occupies 8 bits? Nope, or we'd be right back
in ASCII territory. UTF-8 means each code point occupies at least 8 bits. More
specifically, a code point in UTF-8 can occupy 8, 16, 24, or 32 bits:

|Code points       |Bytes| Byte 1 | Byte 2 | Byte 3 | Byte 4 | Bits encoded |
|------------------|-----|--------|--------|--------|--------|--------------|
| 0x0000 - 0x007f  |  1  |0xxxxxxx|        |        |        | 7            |
| 0x0080 - 0x07ff  |  2  |110xxxxx|10xxxxxx|        |        | 11           |
| 0x0800 - 0xffff  |  3  |1110xxxx|10xxxxxx|10xxxxxx|        | 16           |
|0x10000 - 0x10ffff|  4  |11110xxx|10xxxxxx|10xxxxxx|10xxxxxx| 21           |

*Copied from https://en.wikipedia.org/wiki/UTF-8*

The goal here is to only use as many bytes as are needed to encode each code
point. The problem with that is when you're reading the data back, how do you
tell if the code point you're looking at is supposed to be just 1 byte or 4?
The solution is to put some meta-data in place along with the actual code
point data being saved. In the table above, you can see that the first byte
starts with a different set of bits depending on the number of bytes to follow.

This way, no matter what byte you're looking at in a UTF-8 string, you can tell
what kind of byte it is by checking the bits on the left:

- A byte that starts with `0` is a complete code point that uses only 1 byte.
- A byte that starts with `110` is the first byte in a code point that uses 2
  bytes.
- A byte that starts with `1110` is the first byte in a code point that uses
  3 bytes.
- A byte that starts with `11110` is the first byte in a code point that uses
  4 bytes.
- A byte that starts with `10` is a continuation byte belonging to a code point
  that uses 2, 3, or 4 bytes.

Let's encode a Unicode code point with UTF-8. We'll start with 'a':

| Rendering | Code point | Code point in decimal | Code point in binary |
|-----------|------------|-----------------------|----------------------|
| a         | U+0061     | 97                    | 1100001              |

In Unicode, U+0061 is the code point 'a', which is 97 in decimal and 1100001
in binary. Since this code point is in the range 0000 - 007f (less than or
equal to 127), it only needs 1 byte to be encoded as UTF-8. To do that, we make
a byte that starts with a `0`, followed by the 7 bits `1100001` for the decimal
value 97. The final result is `01100001`:

<img src="/blog/unicode-basics/0061.svg" />

The gray bit is the UTF-8 mask indicating that this code point is 1 byte long.
The remaining 7 blue bits are the code point data: binary for 0x61.

To decode this UTF-8 data, we can check the left-most bit. Since it's 0, that
means the remaining 7 bits make up the code point.

Something important to note here is that the ASCII code for 'a' is also 97 in
decimal. In fact, the entire ASCII table from 0 to 127 is valid UTF-8. All
integers below 128 have the left-most bit set to 0, which matches the mask for
a single byte code point. This means that any non-extended ASCII string is also
a valid UTF-8 string.

Now let's encode a larger code point.

| Rendering | Code point | Code point in decimal | Code point in binary |
|-----------|------------|-----------------------|----------------------|
| ⋈         | U+22c8     | 8904                  | 10001011001000       |

The code point U+22c8 is 100010110001000 in binary, which is 14 bits. Based on
the table above, this will require 3 bytes to encode. The 14 bits of U+22c8
will be broken up into 3 chunks and UTF-8 bit masks will be placed on the left
side of each chunk to form a UTF-8 code point:

<img src="/blog/unicode-basics/22c8.svg" />

In hex, these 3 bytes are `e2 8b 88`.

The original code point data has been broken up into 3 pieces: 2 bits are in
the first byte, 6 bits are in the second byte, and 6 bits are in the third
byte. The bits with gray backgrounds are the UTF-8 bitmask values. The 2 white
bits in the first byte are unused. If the code point needed 15 or 16 bits to
encode, they would have been used.

To decode this code point, we'd check the first byte. Since it starts with
`1110`, we know to take 4 bits from the right side of the first byte, and 6
bits from the right side of the next 2 bytes. Combining these bits together,
we're back at the value 8904, or 22c8 in hex.







# Grapheme clusters

Hopefully you're still with me and things are making some semblance of sense.
If so, I'm going to wreck that right now. What code point do you think this is:

<h3>&#x0BA8;&#x0BBF;</h3>

If you guessed that this was a trick question because it's actually TWO code
points, you're right! This is called the Tamil ni, and it's an example
of a Unicode *grapheme cluster*: a cluster of code points which together
produce one character.

Here are the code points which make up the Tamil ni character:

| Rendering | Code point | Description                                        |
|-----------|------------|----------------------------------------------------|
| &#x0BA8;  | U+0BA8     | TAMIL LETTER NA                                    |
| &#x0BBF;  | U+0BBF     | TAMIL VOWEL SIGN I                                 |

Any time these two code points appear in sequence, they are rendered as a
single grapheme cluster.

In order to detect a grapheme cluster, we first need to figure out what the
*grapheme break property* is for each code point. Each Unicode code point has a
grapheme break property associated with it.  This is basically a category
that helps in figuring out what role a code point plays with regard to several
kinds of text boundaries:

- Grapheme boundaries (characters)
- Word boundaries
- Newline boundaries

These grapheme break properties can be found at:

http://www.unicode.org/Public/10.0.0/ucd/auxiliary/GraphemeBreakProperty.txt

The # character starts a comment. Each non-comment line gives a code point
or range of code points followed by a semi-colon, and then the grapheme break
property for that code point (or code points). Code points not listed in this
file default to the grapheme break property *Other*.

For example, consider the first code point:

| Rendering | Code point | Description                                        |
|-----------|------------|----------------------------------------------------|
| &#x0BA8;  | U+0BA8     | TAMIL LETTER NA                                    |

The code point 0BA8 doesn't appear in the GraphemeBreakProperty.txt file, so it
defaults to the grapheme break property *Other*.

Next, consider the second code point:

| Rendering | Code point | Description                                        |
|-----------|------------|----------------------------------------------------|
| &#x0BBF;  | U+0BBF     | TAMIL VOWEL SIGN I                                 |

This is code point 0BBF, which appears in the GraphemeBreakProperty.txt as:

```
0BBF          ; SpacingMark # Mc       TAMIL VOWEL SIGN I
```

This means that the code point ந has a grapheme break property of
*SpacingMark*. Together, we have:

| Rendering | Code point | Grapheme break property                            |
|-----------|------------|----------------------------------------------------|
| &#x0BA8;  | U+0BA8     | Other                                              |
| &#x0BBF;  | U+0BBF     | SpacingMark                                        |

So we have a code point with a grapheme break property of *Other* followed by
a code point with *SpacingMark*. How do we know this is a grapheme cluster and
not just 2 normal code points?

There are a list of rules described here:

http://unicode.org/reports/tr29/#Grapheme_Cluster_Boundary_Rules

In this case, we're interested in rule GB9a:

http://unicode.org/reports/tr29/#GB9a

The important text is "Do not break before SpacingMarks, or after Prepend
characters." So anytime a *SpacingMark* appears, it should be combined with
whatever comes before it.







# Putting it all together

Let's look at a complete example to tie these concepts together:

<img src="/blog/unicode-basics/all.svg" />

We start with 6 bytes of UTF-8 data: `E0 AE A8 E0 AE BF`. We decode this UTF-8
data to get 2 Unicode code points: `0BA8 0BBF`. Finally, when these code points
are rendered, they are detected as a single grapheme cluster.

So the UTF-8 data is 6 bytes, which is 2 code points, and one rendered
character.
