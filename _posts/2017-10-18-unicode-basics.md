---
layout: default
title: Unicode basics
description: An overview of Unicode and how it relates to various encodings
---

<style>
    @import url('https://fonts.googleapis.com/earlyaccess/notosanstamil.css');
    @import url('https://fonts.googleapis.com/earlyaccess/notosansdevanagari.css');

    .tamil {
        font-family: "Noto Sans Tamil";
    }

    .devanagari {
        font-family: "Noto Sans Devanagari";
    }

    div.ascii-tables {
        display: flex;
        justify-content: center;
    }
</style>

<link rel="stylesheet" href="/css/posts.css" />

Unicode basics
==============

While doing some research on adding Unicode support to my toy compiler
<a href="https://github.com/briansteffens/bshift" target="_blank">bshift</a>,
I quickly realized just how little I understood about Unicode. This is
interesting, because I've been programming for awhile and nearly all text data
is Unicode these days. It's amazing (or maybe scary) how much code I've written
to process, store, and validate textual data without a great understanding of
the format that data is in.

There are a lot of great resources that go into the specifics of various
aspects of Unicode, but I had a hard time fitting all of the pieces together
in my mind. In this post, I'll try to summarize and connect the dots between
the primary high-level concepts.





# ASCII and the world without Unicode

First, let's talk about the problem Unicode solves. Before Unicode, there were
many different encodings for text. ASCII is a common one. ASCII is a mapping
between numerical values and text characters. Here's a small subset of the
ASCII table:

<div class="ascii-tables">
    <table>
        <tr><th>Code</th><th>Character</th></tr>
        <tr><td>32</td><td><em>space</em></td></tr>
        <tr><td>33</td><td>!</td></tr>
        <tr><td>34</td><td>"</td></tr>
        <tr><td>35</td><td>#</td></tr>
        <tr><td>36</td><td>$</td></tr>
        <tr><td>37</td><td>%</td></tr>
        <tr><td>38</td><td>&</td></tr>
        <tr><td>39</td><td>'</td></tr>
        <tr><td>40</td><td>(</td></tr>
    </table>

    <table>
        <tr><th>Code</th><th>Character</th></tr>
        <tr><td>64</td><td>@</td></tr>
        <tr><td>65</td><td>A</td></tr>
        <tr><td>66</td><td>B</td></tr>
        <tr><td>67</td><td>C</td></tr>
        <tr><td>68</td><td>D</td></tr>
        <tr><td>69</td><td>E</td></tr>
        <tr><td>70</td><td>F</td></tr>
        <tr><td>71</td><td>G</td></tr>
        <tr><td>72</td><td>H</td></tr>
    </table>

    <table>
        <tr><th>Code</th><th>Character</th></tr>
        <tr><td>96</td><td>`</td></tr>
        <tr><td>97</td><td>a</td></tr>
        <tr><td>98</td><td>b</td></tr>
        <tr><td>99</td><td>c</td></tr>
        <tr><td>100</td><td>d</td></tr>
        <tr><td>101</td><td>e</td></tr>
        <tr><td>102</td><td>f</td></tr>
        <tr><td>103</td><td>g</td></tr>
        <tr><td>104</td><td>h</td></tr>
    </table>
</div>

Each number from 0 to 127 (or 255 in the case of extended ASCII) corresponds
to a character. 32 is a space, 97 is the letter `a`, 37 is the percent sign
`%`, and so on.

Consider the string `"Greetings!"`. To represent this string in ASCII, you
would look up each character in the table to get its ASCII code:

|  G  |  r  |  e  |  e  |  t  |  i  |  n  |  g  |  s  |  !  |
|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| 71  | 114 | 101 | 101 | 116 | 105 | 110 | 103 | 115 | 33  |

Notice the character `e` has the same code in both places: 101.

So we have a string of text and we've converted it into a series of ASCII
codes. The next question is how we should represent this in memory. ASCII codes
range from 0 to 127 (or 0 to 255 in the case of extended ASCII). Since a byte
can store up to 256 unique values, that makes it a pretty natural way to store
an ASCII character. So an ASCII string is frequently represented as a series of
sequential bytes in memory.

If we allocated the string `"Greetings!"` in C:

```c
int main()
{
    char* greeting = "Greetings!";

    return 0;
}
```

The string would be loaded into memory when we ran the program. The actual
address it gets isn't important, so let's imagine it shows up at address 1000.
The memory starting at address 1000 would look like this:

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

Starting at 1000, each address refers to a byte. Each of these bytes stores an
ASCII code, which corresponds to a character in the ASCII table.

The NULL character is a marker for the end of the string. In C, strings are
passed around as pointers to the first address of a string in memory. Since no
length information accompanies this pointer, a marker is necessary so you can
find the end of the string. C uses the NULL character as this marker and
automatically adds it to the end of string literals like `"Greetings!"`.

ASCII keeps things reasonably straightforward: each character (like `a`) can be
represented by a code (like `97`) which fits in a single byte. Okay, great.
You can write a bunch of text, including a few symbols.

But what happens when you want to use, say, a Korean character? In ASCII,
you're out of luck. You'll have to switch to an entirely different encoding
like EUC-KR. EUC-KR isn't just a different set of characters from ASCII, it
works quite differently. The number of character codes in EUC-KR doesn't fit
into a single byte, so some characters require more than one byte.

Writing code to support text becomes pretty complicated:

- Do you write special code to support each language and make the user choose
  the language they want to write in?
- Do you try to build some kind of meta-encoding where you can mix and match
  encodings within the same document?
- How do you detect which encoding you're looking at when parsing a file?

It's a pretty bad situation and led to a lot of programs only supporting a
single language.









# Unicode to the rescue

So now we have an idea of how text worked before Unicode and some of the
associated problems. Let's see how Unicode solves these problems.

There's a hint to how Unicode works right in the name: Unicode is a *unified*
character set. Whereas ASCII concerns itself mostly with Latin characters,
EUC-KR supports Korean text, EUC-JP support Japanese text, and so on, Unicode
defines a standard capable of supporting all written languages at once within a
single character set.

Here's a *tiny* subset of the characters in Unicode:

| Code point | Character | Category                 |
|------------|-----------|--------------------------|
| ...        | ...       | ...                      |
| U+0061     | a         | Latin                    |
| U+0062     | b         | Latin                    |
| ...        | ...       | ...                      |
| U+0056     | Ֆ         | Armenian                 |
| ...        | ...       | ...                      |
| U+05d0     | א         | Hebrew                   |
| U+05d1     | ב         | Hebrew                   |
| ...        | ...       | ...                      |
| U+22c7     | ⋇         | Mathematical Operators   |
| U+22c8     | ⋈         | Mathematical Operators   |
| ...        | ...       | ...                      |
| U+1F602    | &#x1F602; | Emoji                    |
| ...        | ...       | ...                      |

*For a full list, see
[http://www.unicode.org/charts/](http://www.unicode.org/charts/).*

We've got Latin, Armenian, Hebrew, symbols from math, and even emojis all in
the same character set. You no longer have to choose which set of characters or
languages you want to support: you can use them all at once.

Unicode essentially works the same as ASCII, except that the range of values is
much wider. In the chart above, the *code point* is the code that a character
corresponds to. Just like how the ASCII code 97 refers to the Latin character
`a`, the Unicode code point `U+05d0` refers to the Hebrew letter aleph `א`.

Let's break down the code point. The prefix `U+` is there to indicate that it's
a Unicode code point and not just a random hex value. After the prefix comes
the hexadecimal value `05d0`, which is `1488` in decimal. Code points are
usually given in hexadecimal, but they're still just integers which map to
elements of text like characters and symbols.







# Storing Unicode data in memory

ASCII codes range from 0 to 127, which means each code fits nicely into a
single byte. However, Unicode code points range from 000000 to 10ffff - that's
1,114,112 different codes! The minimum number of bits necessary to represent
1,114,112 different values is 21 (`2 ^ 21 = 2,097,152`). Unfortunately, no CPU
I'm aware of has instructions designed to operate on 21 bits at a time. For
x86 processors, the integer sizes that are easiest to work with are:

| Name        | Bytes | Bits |
|-------------|-------|------|
| byte        | 1     | 8    |
| word        | 2     | 16   |
| double word | 4     | 32   |
| quadword    | 8     | 64   |

Of these, the smallest one that can store at least 21 bits is the 4-byte /
32-bit integer. If we store each Unicode code point in a 32-bit integer, a
Unicode string will occupy 4 times the amount of memory as the same string
in ASCII. As a result, there is a lot of interest in finding more compact
ways to represent Unicode in memory. This brings us to encodings.







# Encoding Unicode data

Unicode itself is a character set: a mapping from numerical code points to
characters and other symbols. This tells us nothing about how to structure
those numeric values in memory. There are several different ways to store
Unicode in memory. Here are some of the more common encodings:

| Encoding name | Space per code point | Variable- or fixed-width |
|---------------|----------------------|--------------------------|
| UTF-8         | 1 to 4 bytes         | Variable                 |
| UTF-16        | 2 or 4 bytes         | Variable                 |
| UTF-32        | 4 bytes              | Fixed                    |

Variable-width encodings like UTF-8 and UTF-16 require different amounts of
space per code point. Fixed-width encodings like UTF-32 are generally simpler
to work with because each code point uses the same amount of space.






# UTF-32

UTF-32 is probably the most natural way to encode Unicode data. Each code point
is stored directly in memory with no attempt to save space. Let's take the
Unicode string "Բարեւ", which Google Translate assures me is Armenian for
"hello". These five Armenian characters correspond to the following five
Unicode code points:

| Code point | Character |
|------------|-----------|
| U+0532     | Բ         |
| U+0561     | ա         |
| U+0580     | ր         |
| U+0565     | ե         |
| U+0582     | ւ         |

Saving each of these code points directly into memory starting at address 1000,
we'd get something like this (assuming little-endian byte order):

| Address | Value (hex) | Character |
|---------|-------------|-----------|
| 1000    | 0x32        | Բ         |
| 1001    | 0x05        |           |
| 1002    | 0x00        |           |
| 1003    | 0x00        |           |
| 1004    | 0x61        | ա         |
| 1005    | 0x05        |           |
| 1006    | 0x00        |           |
| 1007    | 0x00        |           |
| 1008    | 0x80        | ր         |
| 1009    | 0x05        |           |
| 1010    | 0x00        |           |
| 1011    | 0x00        |           |
| 1012    | 0x65        | ե         |
| 1013    | 0x05        |           |
| 1014    | 0x00        |           |
| 1015    | 0x00        |           |
| 1016    | 0x82        | ւ         |
| 1017    | 0x05        |           |
| 1018    | 0x00        |           |
| 1019    | 0x00        |           |

The string is only 5 characters, but since each character is being encoded
as a 32-bit integer, it takes up 20 bytes of space.

Notice that only half of the bytes are set: these code points are all low
enough values that they could each be represented using only 2 bytes, as 16-bit
integers. So in a way, half of these bytes are wasted. This gets even worse
with Latin characters, which are small enough to need only 1 byte to store.

We can see that UTF-32 is not very space-efficient for these code points, so
why would anyone use it? The first benefit is the encoding is pretty simple:
code points map directly into memory with no complexity added by trying to save
space.

Another benefit is indexing into the string is fast because each code point
occupies a fixed amount of space. To find the nth code point in a UTF-32
string, add `4 * n` to the starting address of the string. This is a constant
time operation, which means that no matter what size the string is, indexing
any code point within it will take the same amount of time.

Finally, if your text is mostly higher-value code points that require 3 or 4
bytes each anyway, UTF-32 won't waste much space.







# UTF-8

UTF-8 is on the other end of the spectrum from UTF-32. While UTF-32 keeps
things simple at the expense of space, UTF-8 saves space at the expense of
simplicity.

In UTF-32, each code point occupies 32 bits of space. In UTF-8, each code point
occupies *at least* 8 bits of space. More specifically, a code point in UTF-8
can occupy 8, 16, 24, or 32 bits. This makes UTF-8 a variable-width encoding.
Different code points require different amounts of space:

|Code points       |Bytes|
|------------------|-----|
| 0x0000 - 0x007f  |  1  |
| 0x0080 - 0x07ff  |  2  |
| 0x0800 - 0xffff  |  3  |
|0x10000 - 0x10ffff|  4  |

The first 128 code points, from `0x0000` to `0x007f`, occupy one byte each.
The next 1920 code points, from `0x0080` to `0x07ff`, occupy two bytes each.
And so on, up to four bytes per code point. The goal here is to use as few
bytes as possible to store each code point.

But there's a problem! Since each code point can occupy 1, 2, 3, or 4 bytes,
how do you tell if a specific byte is meant to be interpreted as a single
1-byte code point or the third byte in a 4-byte code point or something else?

UTF-8 solves this by including some metadata along with the actual code point
data. The first bits in each byte tell you how to interpret the rest of the
byte:

|Code points       |Bytes| Byte 1 | Byte 2 | Byte 3 | Byte 4 | Bits encoded |
|------------------|-----|--------|--------|--------|--------|--------------|
| 0x0000 - 0x007f  |  1  |0xxxxxxx|        |        |        | 7            |
| 0x0080 - 0x07ff  |  2  |110xxxxx|10xxxxxx|        |        | 11           |
| 0x0800 - 0xffff  |  3  |1110xxxx|10xxxxxx|10xxxxxx|        | 16           |
|0x10000 - 0x10ffff|  4  |11110xxx|10xxxxxx|10xxxxxx|10xxxxxx| 21           |

*Copied from
[https://en.wikipedia.org/wiki/UTF-8](https://en.wikipedia.org/wiki/UTF-8).*

In the table above, you can see that the first byte starts with a different set
of bits depending on the number of bytes to follow. This way, no matter which
byte you're looking at in a UTF-8 string, you can tell what kind of byte it is
by checking the bits on the left:

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

In Unicode, U+0061 is the code point for 'a', which is 97 in decimal and
`1100001` in binary. Since this code point only requires 7 bits to store, it
can be encoded in 1 byte of UTF-8. To do that, we make a byte that starts with
a `0`, followed by the 7 bits `1100001`. The result is `01100001`:

<img src="/blog/unicode-basics/0061.svg" />

The gray bit is UTF-8 metadata indicating that this code point is 1 byte
long. The remaining 7 blue bits are the code point data: binary for `0x61`.

To decode this UTF-8 data, we can check the left-most bit. Since it's 0, we
know that this code point occupies one byte. The remaining 7 bits make up the
code point.

Something important to note is the ASCII code for 'a' is also `0x61` in hex. In
fact, the entire ASCII table from 0 to 127 is valid UTF-8. All unsigned 8-bit
integers below 128 have the left-most bit set to 0, which matches the UTF-8
metadata for a single-byte code point. This means that any non-extended ASCII
string is also a valid UTF-8 string.

Now let's encode a larger code point:

| Rendering | Code point | Code point in decimal | Code point in binary |
|-----------|------------|-----------------------|----------------------|
| ⋈         | U+22c8     | 8904                  | 10001011001000       |

The code point U+22c8 is `100010110001000` in binary, which requires 14 bits to
store. Based on the table above, this will require 3 bytes to encode. The 14
bits of U+22c8 will be broken up into 3 chunks and UTF-8 metadata will be
placed on the left side of each chunk to form 3 bytes of UTF-8 data:

<img src="/blog/unicode-basics/22c8.svg" />

In hex, these 3 bytes are `e2 8b 88`.

The original code point data has been broken up into 3 pieces: 2 bits are in
the first byte, 6 bits are in the second byte, and 6 bits are in the third
byte. The bits with gray backgrounds make up the UTF-8 metadata. The 2 white
bits in the first byte are unused, since we only need 14 bits to store this
value.

To decode this code point, we start by checking the first byte. Since it starts
with `1110`, we know this code point occupies 3 bytes. We take:

- 4 bits from the right side of the first byte
- 6 bits from the right side of the second byte
- 6 bits from the right side of the third byte

Combining these 16 bits together, we get the value 8904, or 0x22c8 in hex. The
code point has been successfully decoded from UTF-8.







# Grapheme clusters

Hopefully you're still with me and things are making some semblance of sense.
Unfortunately, things get a bit trickier.

Which code point do you think this is:

<h2 class="tamil center">&#x0BA8;&#x0BBF;</h2>

If you guessed that was a trick question because it's actually TWO code
points, you're right! This is called the Tamil ni, and it's an example
of a Unicode *grapheme cluster*: a group of multiple code points which
together produce one graphical character.

Here are the code points which make up the Tamil ni character:

| Rendering                           | Code point | Description              |
|-------------------------------------|------------|--------------------------|
| <span class="tamil">&#x0BA8;</span> | U+0BA8     | TAMIL LETTER NA          |
| <span class="tamil">&#x0BBF;</span> | U+0BBF     | TAMIL VOWEL SIGN I       |

Any time these two code points appear in sequence, they are rendered as a
single grapheme cluster.

In order to detect a grapheme cluster, we first need to figure out what the
*grapheme break property* is for each code point. Each Unicode code point has a
grapheme break property associated with it. This is a category that helps us
figure out how code points combine to produce grapheme clusters.

These grapheme break properties can be found in the data file at
[http://www.unicode.org/Public/10.0.0/ucd/auxiliary/GraphemeBreakProperty.txt](http://www.unicode.org/Public/10.0.0/ucd/auxiliary/GraphemeBreakProperty.txt).

In this file, each non-comment line gives a code point or range of code points
followed by a semi-colon, and finally the grapheme break property for that code
point (or range). Code points not listed in this file default to the grapheme
break property *Other*.

Consider the first code point in the Tamil ni:

| Rendering                           | Code point | Description              |
|-------------------------------------|------------|--------------------------|
| <span class="tamil">&#x0BA8;</span> | U+0BA8     | TAMIL LETTER NA          |

The code point U+0BA8 doesn't appear in the GraphemeBreakProperty.txt file, so
it defaults to the grapheme break property *Other*.

Next, consider the second code point:

| Rendering                           | Code point | Description              |
|-------------------------------------|------------|--------------------------|
| <span class="tamil">&#x0BBF;</span> | U+0BBF     | TAMIL VOWEL SIGN I       |

This is code point U+0BBF, which appears in the GraphemeBreakProperty.txt file
as:

```
0BBF          ; SpacingMark # Mc       TAMIL VOWEL SIGN I
```

This means the code point U+0BBF has a grapheme break property of
*SpacingMark*. Together, we have:

| Rendering                           | Code point | Grapheme break property  |
|-------------------------------------|------------|--------------------------|
| <span class="tamil">&#x0BA8;</span> | U+0BA8     | Other                    |
| <span class="tamil">&#x0BBF;</span> | U+0BBF     | SpacingMark              |

So we have an *Other* followed by a *SpacingMark*. How do we know this is a
grapheme cluster rather than two separate characters?

The Unicode standard defines a list of
[grapheme cluster boundary rules](http://unicode.org/reports/tr29/#Grapheme_Cluster_Boundary_Rules). Each rule defines how a pair of grapheme break properties
are related. The character `×` means to combine matching code points and `÷`
indicates that matching code points form a boundary between grapheme clusters.

In this case, we're interested in rule
[GB9a](http://unicode.org/reports/tr29/#GB9a), which looks like this:

```
GB9a                            x  SpacingMark
```

This means a *SpacingMark* code point should be combined with whatever comes
before it. In the Tamil ni character, an *Other* code point is
followed by a *SpacingMark* code point, which means they make up a single
grapheme cluster.

The rest of the rules can be interpreted similarly. For example, rules GB6,
GB7, and GB8 define how Hangul (the Korean alphabet) syllable sequences are
formed. GB1 states what may seem pretty obvious: that the start of text is
always the beginning of a new grapheme or grapheme cluster. GB2 states that the
last code point is always the end of a grapheme or grapheme cluster.






# Tailored grapheme clusters

Okay, so we can detect grapheme clusters now! Let's try it on a new set of
code points and see how many grapheme clusters we get:

| Rendering                                | Code point | Grapheme break property  |
|------------------------------------------|------------|--------------------------|
| <span class="devanagari">&#x0915;</span> | U+0915     | Other                    |
| <span class="devanagari">&#x094D;</span> | U+094D     | Extend                   |
| <span class="devanagari">&#x0937;</span> | U+0937     | Other                    |
| <span class="devanagari">&#x093F;</span> | U+093F     | SpacingMark              |

First, we have *Other* followed by *Extend*. According to rule GB9, we
shouldn't break before an *Extend* property. So the first two code points make
up a cluster. Next, we have a second *Other*. The only rule that matches here
is GB999, which says that if none of the other rules matched, break. So we
know the third code point starts a new grapheme cluster. Finally, we have a
*SpacingMark* code point. According to rule GB9a, we shouldn't break before a
*SpacingMark* code point. So we have 2 grapheme clusters: `U+0915 + U+094D` and
`U+0937 + U+093F`. Let's render these four code points and see if we're
right:

<h2 class="devanagari center">
    &#x0915;&#x094D;&#x0937;&#x093F;
</h2>

Whoops. That definitely looks and acts like a single character. Did we apply
the rules incorrectly? Unfortunately, no. It turns out that the 16
grapheme break rules defined by the Unicode spec can't cover all of the
intricacies of written human language (weird, right?). So the Unicode
specification allows writing systems to *tailor* the grapheme break rules to
their requirements.

<span class="devanagari">&#x0915;&#x094D;&#x0937;&#x093F;</span> is one such
*tailored grapheme cluster*. The rules for what constitutes a tailored grapheme
cluster vary greatly by writing system, and is far out of scope for this
post, but it's good to be aware that they exist.







# Putting it all together

Let's look at a complete example to tie these concepts together. We start with
6 bytes of UTF-8 data `E0 AE A8 E0 AE BF`:

<img src="/blog/unicode-basics/final-utf8.png" />

The gray bits are the UTF-8 metadata. We can decode this to extract the code
points:

<img src="/blog/unicode-basics/final-decoded.png" />

These bits correspond to 2 Unicode code points, `U+0BA8` and `U+0BBF`:

<img src="/blog/unicode-basics/final-codepoints.png" />

These 2 code points make up a grapheme cluster, so when they're rendered,
they produce one graphical character:

<img src="/blog/unicode-basics/final-grapheme-clusters.png" />






# So why do I see those empty boxes?

Unless you're pretty lucky, you've probably seen some empty boxes in place of
Unicode characters. This happens when a font doesn't contain glyphs necessary
to render given code points. Here are a bunch of random code points:

<h2 class="center">
    &#x0915;&#x094D;&#x0937;&#x093F;
    &#x26B8;
    &#x103B0;
    &#x109B4;
    &#x13E8;
    &#x10427;
    &#x1BAE;
    &#x07E8;
    &#x10151;
</h2>

Some or many of these will show up as rectangles, possibly with hex values
inside. If you have really, really good Unicode support, you might not see any.
Here's what that list of code points looks like on my Linux machine:

<img src="/blog/unicode-basics/final-linux.png" />

And here they are on my macOS laptop:

<img src="/blog/unicode-basics/final-macos.png" />

So you can see that support for Unicode varies quite a bit. What can you do if
you need to use a particular language or set of symbols in, say, a blog post
and you want to make sure everyone can see them? You can take a screenshot
and embed an image of the text you want to display, but then you lose the
ability to do things like copy/paste and search for the text on the page. A
better way to go is to use a webfont with support for the characters you
need.

Let's take the first character from above:

<h2 class="center">
    &#x0915;&#x094D;&#x0937;&#x093F;
</h2>

Chrome running on my Linux laptop can't display this. Interestingly, the
terminal on the same system *can*. Yet more proof of the superiority of
terminals!

To get it to show up in this blog post properly, regardless of the fonts
available on the computer viewing it, I used a Google Noto web font. Google
Noto is a project to build a font family supporting all of Unicode:

[https://www.google.com/get/noto/](https://www.google.com/get/noto/)

Since <span class="devanagari">&#x0915;&#x094D;&#x0937;&#x093F;<span> is part
of the Devanagari script, we can import it into an HTML page and then use it:

```html
<!doctype html>
<title>Devanagari example</title>

<style>
    @import url('https://fonts.googleapis.com/earlyaccess/notosansdevanagari.css');

    .devanagari {
        font-family: "Noto Sans Devanagari";
    }
</style>

<span class="devanagri">
    क्षि
</span>
```

Doing it this way makes it render properly on my system (and hopefully on yours
too):

<h2 class="devanagari center">
    &#x0915;&#x094D;&#x0937;&#x093F;
</h2>








# Escaping Unicode code points in HTML

Above, I pasted the Devanagari character directly into the HTML file. Even
though my terminal can display the character, Vim seems to get a bit confused
and it causes some minor rendering issues.

In order to prevent that, you can escape Unicode code points in HTML by putting
the code point (in hex) between `&#x` and `;`. So the letter 'a', which is
codepoint U+0061, can be escaped as `&#x0061;`.

In the case above, the character
<span class="devanagri">&#x0915;&#x094D;&#x0937;&#x093F;</span>
is actually made up of a whopping four code points: `U+0915`, `U+094D`,
`U+0937`, and `U+093F`. So we can adjust the HTML file above to be more
portable by escaping these four code points:

```html
<!doctype html>
<title>Devanagari example</title>

<style>
    @import url('https://fonts.googleapis.com/earlyaccess/notosansdevanagari.css');

    .devanagari {
        font-family: "Noto Sans Devanagari";
    }
</style>

<span class="devanagri">
    &#x0915;&#x094D;&#x0937;&#x093F;
</span>
```
