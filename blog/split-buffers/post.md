Split buffers - a variation of the gap buffer data structure
============================================================

I've been working on a text editor component for a terminal-based SQL editor
called [prequel](https://github.com/briansteffens/prequel). In the process,
I've done some research on several common data structures used to manage the
text in text editors. While I still haven't quite decided on a favorite, one
particularly interesting data structure is called the gap buffer.

It has a couple of characteristics that I don't care for, so I started
experimenting with variations on it to address some of my concerns. I came up
with a variation with some pros and cons, which if not useful is perhaps at
least interesting. But before we jump into that, some background information on
gap buffers would probably be helpful.





# Gap buffers

A gap buffer stores the entire contents of a buffer (in this case, the text
being edited in a text editor) in one big array. Inside this array, a *gap*
section is placed where the cursor is. This gap is used to optimize the most
common operations performed in a text editor: moving the cursor around,
inserting text, and deleting text.

The gap buffer is used by quite a few text editors. One example is GNU Emacs.

A gap buffer stores a string of text in a single array in memory. Here's how
the string "a buffer" would look in memory:

<img src="/blog/split-buffer/gap-buffer-1.svg" />

Each character occupies one position within the array. In order to turn this
into a gap buffer, the array is divided into three sections:

<img src="/blog/split-buffer/gap-buffer-2.svg" />

In the diagram above, the cursor is sitting between the `b` and the `u`
characters. The sections are as follows:

- **pre** holds the characters before the cursor
- **gap** is the cursor itself, a sort of scratch area we can use to perform
  common text editor operations like inserting or deleting text
- **post** holds the characters after the cursor

These sections are not physical parts of the array, they're virtual: in a gap
buffer implementation we have to write code to keep track of which parts of the
array belong to which section. This is the main complication I wanted to solve.

To move the cursor, we have to move the gap within the buffer. If the user
presses the left arrow key to move the cursor one character to the left, we
move the last character from the *pre* section into last slot of the
*gap* section:

<img src="/blog/split-buffer/gap-buffer-3.svg" />

We have shrunken the *pre* section and grown the *post* section. The gap has
shifted to the left, meaning the cursor is now between the space and the `b`
character:

<img src="/blog/split-buffer/gap-buffer-4.svg" />

Inserting text is pretty simple too. To insert the character `g` at the
cursor's position, we expand the *pre* section and put the inserted character
in the new slot:

<img src="/blog/split-buffer/gap-buffer-5.svg" />

With only one slot left in the gap, we can only insert one more character:

<img src="/blog/split-buffer/gap-buffer-6.svg" />

The gap is still there, but it's empty. The cursor is between the `a` and the
`b`, but we have no more room to insert characters without overwriting
something else.

To insert more characters, we have to do something a bit more complicated than
the other operations:

1. Allocate a larger array
2. Copy the *pre* section into the beginning of the new array
3. Copy the *post* section into the end of the new array
4. Free the original array

We resize the array to expand the gap:

<img src="/blog/split-buffer/gap-buffer-7.svg" />

In this example, the array has been increased by two characters and the *post*
section has been moved to the end of the new array. This leaves two new slots
in the gap section we can use to insert up to two more characters:

<img src="/blog/split-buffer/gap-buffer-8.svg" />

The original string "a buffer" has been edited to become "a gap buffer".








# A gap buffer implementation

To demonstrate how this can be done, let's look at a very stripped down
implementation of a gap buffer in code. I chose Go over C so we can skip some
of the memory allocation boilerplate.

Here's all the information we need to store about a gap buffer:

```go
type GapBuffer struct {
	data    []rune
	preLen  int
	postLen int
}
```

The fields are:

- **data** is an array of runes. A rune in Go is a Unicode code point. For our
  purposes, you can think of it as a signle character. This is the array
  containing the *pre*, *gap*, and *post* sections.
- **preLen** keeps track of the size of the *pre* section.
- **postLen** keeps track of the size of the *post* section.

We also define a few convenience functions to make some of the calculations
elsewhere a little clearer:

```go
func (r *GapBuffer) gapStart() int {
	return r.preLen
}

func (r *GapBuffer) gapLen() int {
	return r.postStart() - r.preLen
}

func (r *GapBuffer) postStart() int {
	return len(r.data) - r.postLen
}
```

These convenience functions let us clearly refer to the beginning of the *gap*
section, the size of the *gap* section, and the beginning of the *post*
section. All three are derived values which we don't have to store directly.

We need a way to get a string of text into and out of our gap buffer. Let's
define a *SetText()* function to copy a string of text into the gap buffer:

```go
func (r *GapBuffer) SetText(s string) {
	r.data = []rune(s)
	r.preLen = 0
	r.postLen = len(r.data)
}
```

This converts the string into an array of runes and stores them in the *data*
array. It assumes the cursor starts at the beginning of the buffer, so *preLen*
is set to 0, which makes *pre* empty: there is no data before the cursor.
*postLen* is set to the length of the entire buffer, since the entire buffer is
after the cursor.

When we're done working with the data in the gap buffer, we'll want a way to
retrieve the complete string:

```go
func (r *GapBuffer) GetText() string {
	ret := make([]rune, r.preLen + r.postLen)

	copy(ret, r.data[:r.preLen])
	copy(ret[r.preLen:], r.data[r.postStart():])

	return string(ret)
}
```

Since there can be (and usually is) a gap of empty text somewhere inside the
buffer, we want to return only the *pre* and *post* sections. So we create a
new array, copy the *pre* section into the new array, and then copy the *post*
section after it. This skips the *gap* section entirely, which is really just
an internal tool of the data structure: consumers of this gap buffer
shouldn't care what's going on internally.

Now that we can get data into and out of our gap buffer, let's allow the
cursor to be moved around. Remember that the cursor in a gap buffer is
represented by the *gap* section itself. So all we have to do move the cursor
around is shift the *gap* left or right depending on the direction the cursor
should move:

```go
func (r *GapBuffer) CursorNext() {
	if r.postLen == 0 {
		return
	}

	r.data[r.preLen] = r.data[r.postStart()]
	r.preLen++
	r.postLen--
}
```

When *CursorNext()* is called, we first make sure the cursor isn't already at
the end of the buffer. If the *post* section is empty, there's nothing left
after the cursor, so there's nothing to do.

As long as the cursor isn't at the end of the buffer already, we can move the
cursor forward one character. We do this by copying the first character from
the *post* section to the end of the *pre* section. Then we grow the *pre*
section to absorb the newly-added character and shrink the *post* section
to release the removed character. The gap (and the cursor) has been moved to
the right.

Moving the cursor in the other direction is the exact inverse:

```go
func (r *GapBuffer) CursorPrevious() {
	if r.preLen == 0 {
		return
	}

	r.data[r.postStart() - 1] = r.data[r.preLen - 1]
	r.preLen--
	r.postLen++
}
```

Assuming we're not already at the beginning of the buffer, we copy the last
character from the *pre* section to the slot right before the beginning of the
*post* section. The *pre* section is shrunk and the *post* section is grown.
The gap has been shifted to the left.

We can also delete characters. Deleting a character from a gap buffer is
pretty slick:

```go
func (r *GapBuffer) Delete() {
	if r.postLen == 0 {
		return
	}

	r.postLen--
}
```

To delete the character immediately after the cursor, all we do is shrink the
*post* section. This effectively grows the *gap* section to include the deleted
character. We don't even need to overwrite the data: since it's part of the
*gap* section now, it's effectively gone from the text. Pretty magic, eh?

Deleting a character immediately before the cursor (like what happens when a
user presses the backspace key) is quite similar:

```go
func (r *GapBuffer) Backspace() {
	if r.preLen == 0 {
		return
	}

	r.preLen--
}
```

We just shrink the *pre* section, which grows the *gap* section to include
the deleted character in the opposite direction.

Destruction is obviously fun, but let's try some creation. Inserting text is
pretty straightforward, provided there is enough room in the *gap* section to
contain the new text. Things get a bit tricker if the *gap* section is empty:

```go
func (r *GapBuffer) Insert(c rune) {
	if r.gapLen() == 0 {
		newData := make([]rune, len(r.data) * 2)

		copy(newData, r.data[:r.preLen])
		copy(newData[r.postStart() + len(r.data):],
			r.data[r.postStart():])

		r.data = newData
	}

	r.data[r.gapStart()] = c
	r.preLen++
}
```

If the *gap* section is empty, we have to expand it before we can insert the
new character.

We first create a new array called *newData* and allocate twice the size of
our existing *data* array. We double it each time because this is an expensive
operation which, in the worst case, requires copying the entire buffer. By
doubling it each time, we make this costly operation occur less and less
frequently as the buffer gets larger.

Once we have the new array allocated, we copy the *pre* section into the
beginning of the new array and the *post* section into end of the new array.
This leaves a new *gap* section between them which now has at least one
slot available for the new character.

Finally, we insert the new character by copying it into the first slot in the
*gap* section and grow the *pre* section to absorb the new character.





# Gap buffer runtime analysis

In gap buffers, operations which take place around the cursor are extremely
fast, but seeking (moving the cursor a long distance) is relatively slow.

### Moving the cursor one position

Moving the cursor left or right by one position at a time requires moving a
single character from one side of the gap to the other and adjusting the sizes
of the *pre* and *post* sections. No matter how large the file you're editing
is, moving the cursor around like this will take the same amount of time. This
makes it a constant time *O(1)* operation.

### Deleting a character from before or after the cursor

Deleting a single character from before or after the cursor is also a cheap
operation: in both cases, either the *preLen* or *postLen* is decremented.
No matter how big the file is, this will take the same amount of time, making
it a constant time operation.

### Inserting a character at the cursor

Inserting a character where the cursor is requires a bit more analysis. When
the *gap* section has room for the new character, all we have to do is copy the
new character into the array and adjust *preLen* to absorb the new character.
This is a constant time operation.

However, when the gap runs out of space for new characters, we have to
allocate a new array and copy the entire buffer over to the new array. This has
a linear runtime *O(n)*, meaning that this operation will get slower as the
buffer being edited grows.

Luckily, there's a common strategy we can use to reduce the impact of this
occassionally slow operation. By growing the gap exponentionally each time, we
can make these costly operations occur less frequently as the buffer size
grows. Averaged out over time, the vast majority of insertions will run in
constant time with only the very occassional linear runtime operation. This is
known as amortized constant time.

### Long distance cursor movements

While gap buffers have very good performance for operations local to the
cursor, the biggest weakness is in long distance cursor movements. Moving the
cursor arbitrary distances requires continually copying characters from one
side of the gap to the other and adjusting the sizes of *pre* and *post*
repeatedly until the gap has shifted far enough. This makes it a linear
runtime operation in the worst case (example: seeking from the very beginning
to the very end of the buffer).





# Split buffers

The gap buffer is a really nice, simple data structure for a text editor. There
are only a couple of things about them I don't care for, and a major one is
having to manage the gap between *pre* and *post* sections.

As a possible improvement in this area, I came up with what I'm calling a split
buffer. It's basically a gap buffer with the data rearranged so there's no gap
to be managed.

Like before, let's take an initial value of "a buffer" and place the cursor
between the `b` and the `u`. To do this, we need to split the string into
*pre* and *post* arrays:

<img src="/blog/split-buffer/split-buffer-1.svg" />

Notice these are separate physical arrays in memory, not virtual sections in
one combined array.

Now we need to reverse the *post* array. This is done to improve the
performance of operations around the cursor. It's much cheaper to make changes
to the end of an array than to the beginning.

<img src="/blog/split-buffer/split-buffer-2.svg" />

Once the *post* array is reversed, the data should look like this:

<img src="/blog/split-buffer/split-buffer-3.svg" />

Notice the flow of characters wraps around. The first character in the buffer
is the first character in the *pre* array. The last character in the buffer
is the last character in the *post* array. So the buffer is chopped in half
where the cursor is.

<img src="/blog/split-buffer/split-buffer-4.svg" />

Unlike the gap buffer, there is no gap. Or another way to put it is that we
have an unlimited gap which is the "space" between arrays. Despite the data
being laid out differently, many operations remain very similar. For example,
to move the cursor to the left, move one character from the end of the *pre*
array to the end of the *post* array:

<img src="/blog/split-buffer/split-buffer-5.svg" />

Which produces:

<img src="/blog/split-buffer/split-buffer-6.svg" />

Moving the cursor to the right is done exactly opposite: move one character
from the end of the *post* array to the end of the *pre* array:

<img src="/blog/split-buffer/split-buffer-7.svg" />

To delete the character in front of the cursor (as in pressing the delete key),
remove a character from the end of the *post* array:

<img src="/blog/split-buffer/split-buffer-8.svg" />

And to delete the character behind the cursor (as in a backspace), remove a
character from the end of the *pre* array:

<img src="/blog/split-buffer/split-buffer-9.svg" />

Text insertions are improved quite a bit over the gap buffer version. To insert
text before the cursor, toss it onto the end of the *pre* array:

<img src="/blog/split-buffer/split-buffer-10.svg" />

The text "split bu" has been added to the buffer as if it was typed or pasted
in at the cursor's location. Notice we didn't have to check if the gap was
large enough, conditionally reallocate the array, then copy pieces of the array
around. We just appended the text to the end of the *pre* array.

To get the complete text back out, we first reverse the *post* array, putting
it back in normal order:

<img src="/blog/split-buffer/split-buffer-11.svg" />

Then we combine the *pre* and *post* arrays into the complete output:

<img src="/blog/split-buffer/split-buffer-12.svg" />






# A split buffer implementation

Let's implement a basic split buffer in Go! We need to store two arrays:

```go
type SplitBuffer struct {
	pre  []rune
	post []rune
}
```

The fields are:

- **pre** stores the characters before the cursor.
- **post** stores the characters after the cursor, in reverse order.

As with the gap buffer, we'll need a way to get data into the split buffer.
We'll assume that when *SetText()* is called, the cursor should be reset to
the beginning of the text. So the *pre* array should always start out empty.
The entire buffer should be in *post*, but in reverse order. We'll need to
start with a function to reverse an array of runes:

```go
func reverseRunes(src []rune) []rune {
	ret := []rune{}

	for i := len(src) - 1; i >= 0; i-- {
		ret = append(ret, src[i])
	}

	return ret
}
```

With that in place, we can can copy the data into the structure:

```go
func (r *SplitBuffer) SetText(s string) {
	r.pre = []rune{}
	r.post = reverseRunes([]rune(s))
}
```

We set *pre* to an empty array and set *post* to the entire buffer, reversed.

To get the text back out of the buffer after making some edits, we need to
reverse the order of the *post* array again to get it back in normal order,
then concatenate the *pre* and *post* arrays:

```
func (r *SplitBuffer) GetText() string {
	ret := make([]rune, len(r.pre) + len(r.post))

	copy(ret, r.pre)
	copy(ret[len(r.pre):], reverseRunes(r.post))

	return string(ret)
}
```

Moving the cursor around is a matter of moving characters from the end of
one array to the end of the other. To move the cursor to the right, we copy the
last character in the *post* array to the end of the *pre* array. Then we
chop the copied character off the end of the *post* array:

```go
func (r *SplitBuffer) CursorNext() {
	if len(r.post) == 0 {
		return
	}

	r.pre = append(r.pre, r.post[len(r.post) - 1])
	r.post = r.post[:len(r.post) - 1]
}
```

To move the cursor left, we do the opposite: we copy the last character in the
*pre* array to the end of the *post* array and shrink the *pre* array by 1:

```go
func (r *SplitBuffer) CursorPrevious() {
	if len(r.pre) == 0 {
		return
	}

	r.post = append(r.post, r.pre[len(r.pre) - 1])
	r.pre = r.pre[:len(r.pre) - 1]
}
```

Deleting the character in front of the cursor is done by chopping the last
character off the end of the *post* array:

```go
func (r *SplitBuffer) Delete() {
	if len(r.post) == 0 {
		return
	}

	r.post = r.post[:len(r.post) - 1]
}
```

Deleting the character before the cursor (as in a backspace keypress) is
done by chopping a character off the end of the *pre* array:

```go
func (r *SplitBuffer) Backspace() {
	if len(r.pre) == 0 {
		return
	}

	r.pre = r.pre[:len(r.pre) - 1]
}
```

Inserting some new text before the cursor can be done by adding the new
character to the end of the *pre* array:

```go
func (r *SplitBuffer) Insert(c rune) {
	r.pre = append(r.pre, c)
}
```

Notice that the insert is quite a bit simpler than in the gap buffer, since
we don't need to keep track of three sections within a single array or deal
with copying them around. It's just a straightforward append, since there's no
gap to manage explicitly.






# Split buffer runtime analysis

Just like with gap buffers, operations taking place around the cursor are
fast, but moving the cursor a long distance is pretty slow. The runtime
complexity of a split buffer is similar to that of a gap buffer, except for one
difference: while local cursor movements in a gap buffer run in constant time,
they run in amortized constant time in a split buffer.

### Moving the cursor one position

Moving the cursor left or right by one position at a time requires moving a
single character from one side of the gap to the other and adjusting the sizes
of the *pre* and *post* arrays. This is normally a constant time operation.
However, because *pre* and *post* in a split buffer are separate physical
arrays, they will occassionally need to be resized and have their contents
copied, which is a linear time operation. We can grow the arrays
exponentionally to get this down to an amortized constant time.

### Deleting a character from before or after the cursor

Deleting a single character from before or after the cursor requires deleting
one character from the end of either the *pre* or *post* array. This is always
a single operation, so it runs in constant time.

### Inserting a character at the cursor

Character insertions work by appending new characters to the end of either the
*pre* or *post* array. On average, this will run in constant time, but
occassionally a full reallocation and copy will be necessary. This makes it an
amortized constant time operation, the same as it is in the gap buffer.

### Long distance cursor movements

Moving the cursor long distances requires repeatedly moving each character
from one array to the other. This is a linear operation, just like the gap
buffer.





# Conclusion

The main thing still bothering me about both of these data structures is the
linear seek time.

I'm not sure if the split buffer is a net improvement over the gap buffer. By
choosing the split buffer you get simplified inserts and less moving parts when
performing cursor operations. However, the split buffer also has slightly worse
runtime complexity: in the case of local cursor movements, it trades constant
time for amortized constant time. Many people consider these to be effectively
the same runtime for practical purposes, but I don't really like the lack of
predictability that comes from occassional linear operations popping up among
otherwise constant operations, even if they're incredibly rare.

I'll probably continue to think about this and explore other stream data
structures. Feel free to get in touch, any suggestions or notes would be
great!
