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
| ------- | ----------- | --------- |
| 1004    | 0x61        | ա         |
| 1005    | 0x05        | ա         |
| 1006    | 0x00        | ա         |
| 1007    | 0x00        | ա         |
| ------- | ----------- | --------- |
| 1008    | 0x80        | ր         |
| 1009    | 0x05        | ր         |
| 1010    | 0x00        | ր         |
| 1011    | 0x00        | ր         |
| ------- | ----------- | --------- |
| 1012    | 0x65        | ե         |
| 1013    | 0x05        | ե         |
| 1014    | 0x00        | ե         |
| 1015    | 0x00        | ե         |
| ------- | ----------- | --------- |
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
starts with a different set of bits depending on the number of bytes to follow:

- Code points that can be encoded

