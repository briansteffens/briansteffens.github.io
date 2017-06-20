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

<script type="text/javascript" async
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

<div class="markdown-body"><h1>Split buffers - a variation of the gap buffer data structure</h1>
<p>I've been working on a text editor component for a terminal-based SQL editor
called <a href="https://github.com/briansteffens/prequel">prequel</a>. In the process,
I've done some research on several common data structures used to manage the
text in text editors. While I still haven't quite decided on a favorite, one
particularly interesting data structure is called the gap buffer.</p>
<p>It has a couple of characteristics that I don't care for, so I started
experimenting with variations on it to address some of my concerns. I came up
with a variation with some pros and cons, which if not useful is perhaps at
least interesting. But before we jump into that, some background information on
gap buffers would probably be helpful.</p>
<h1>Gap buffers</h1>
<p>A gap buffer stores the entire contents of a buffer (in this case, the text
being edited in a text editor) in one big array. Inside this array, a <em>gap</em>
section is placed where the cursor is. This gap is used to optimize the most
common operations performed in a text editor: moving the cursor around,
inserting text, and deleting text.</p>
<p>The gap buffer is used by quite a few text editors. One example is GNU Emacs.</p>
<p>A gap buffer stores a string of text in a single array in memory. Here's how
the string "a buffer" would look in memory:</p>
<p><a href="/blog/split-buffer/gap-buffer-1.svg" target="_blank"><img src="/blog/split-buffer/gap-buffer-1.svg" style="max-width:100%;"></a></p>
<p>Each character occupies one position within the array. In order to turn this
into a gap buffer, the array is divided into three sections:</p>
<p><a href="/blog/split-buffer/gap-buffer-2.svg" target="_blank"><img src="/blog/split-buffer/gap-buffer-2.svg" style="max-width:100%;"></a></p>
<p>In the diagram above, the cursor is sitting between the <code>b</code> and the <code>u</code>
characters. The sections are as follows:</p>
<ul>
<li><strong>pre</strong> holds the characters before the cursor</li>
<li><strong>gap</strong> is the cursor itself, a sort of scratch area we can use to perform
common text editor operations like inserting or deleting text</li>
<li><strong>post</strong> holds the characters after the cursor</li>
</ul>
<p>These sections are not physical parts of the array, they're virtual: in a gap
buffer implementation we have to write code to keep track of which parts of the
array belong to which section. This is the main complication I wanted to solve.</p>
<p>To move the cursor, we have to move the gap within the buffer. If the user
presses the left arrow key to move the cursor one character to the left, we
move the last character from the <em>pre</em> section into last slot of the
<em>gap</em> section:</p>
<p><a href="/blog/split-buffer/gap-buffer-3.svg" target="_blank"><img src="/blog/split-buffer/gap-buffer-3.svg" style="max-width:100%;"></a></p>
<p>We have shrunken the <em>pre</em> section and grown the <em>post</em> section. The gap has
shifted to the left, meaning the cursor is now between the space and the <code>b</code>
character:</p>
<p><a href="/blog/split-buffer/gap-buffer-4.svg" target="_blank"><img src="/blog/split-buffer/gap-buffer-4.svg" style="max-width:100%;"></a></p>
<p>Inserting text is pretty simple too. To insert the character <code>g</code> at the
cursor's position, we expand the <em>pre</em> section and put the inserted character
in the new slot:</p>
<p><a href="/blog/split-buffer/gap-buffer-5.svg" target="_blank"><img src="/blog/split-buffer/gap-buffer-5.svg" style="max-width:100%;"></a></p>
<p>With only one slot left in the gap, we can only insert one more character:</p>
<p><a href="/blog/split-buffer/gap-buffer-6.svg" target="_blank"><img src="/blog/split-buffer/gap-buffer-6.svg" style="max-width:100%;"></a></p>
<p>The gap is still there, but it's empty. The cursor is between the <code>a</code> and the
<code>b</code>, but we have no more room to insert characters without overwriting
something else.</p>
<p>To insert more characters, we have to do something a bit more complicated than
the other operations:</p>
<ol>
<li>Allocate a larger array</li>
<li>Copy the <em>pre</em> section into the beginning of the new array</li>
<li>Copy the <em>post</em> section into the end of the new array</li>
<li>Free the original array</li>
</ol>
<p>We resize the array to expand the gap:</p>
<p><a href="/blog/split-buffer/gap-buffer-7.svg" target="_blank"><img src="/blog/split-buffer/gap-buffer-7.svg" style="max-width:100%;"></a></p>
<p>In this example, the array has been increased by two characters and the <em>post</em>
section has been moved to the end of the new array. This leaves two new slots
in the gap section we can use to insert up to two more characters:</p>
<p><a href="/blog/split-buffer/gap-buffer-8.svg" target="_blank"><img src="/blog/split-buffer/gap-buffer-8.svg" style="max-width:100%;"></a></p>
<p>The original string "a buffer" has been edited to become "a gap buffer".</p>
<h1>A gap buffer implementation</h1>
<p>To demonstrate how this can be done, let's look at a very stripped down
implementation of a gap buffer in code. I chose Go over C so we can skip some
of the memory allocation boilerplate.</p>
<p>Here's all the information we need to store about a gap buffer:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">type</span> <span class="pl-v">GapBuffer</span> <span class="pl-k">struct</span> {
	data    []rune
	preLen  <span class="pl-k">int</span>
	postLen <span class="pl-k">int</span>
}</pre></div>
<p>The fields are:</p>
<ul>
<li><strong>data</strong> is an array of runes. A rune in Go is a Unicode code point. For our
purposes, you can think of it as a signle character. This is the array
containing the <em>pre</em>, <em>gap</em>, and <em>post</em> sections.</li>
<li><strong>preLen</strong> keeps track of the size of the <em>pre</em> section.</li>
<li><strong>postLen</strong> keeps track of the size of the <em>post</em> section.</li>
</ul>
<p>We also define a few convenience functions to make some of the calculations
elsewhere a little clearer:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">GapBuffer</span>) <span class="pl-en">gapStart</span></span>() <span class="pl-v">int</span> {
	<span class="pl-k">return</span> r.<span class="pl-smi">preLen</span>
}

<span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">GapBuffer</span>) <span class="pl-en">gapLen</span></span>() <span class="pl-v">int</span> {
	<span class="pl-k">return</span> r.<span class="pl-c1">postStart</span>() - r.<span class="pl-smi">preLen</span>
}

<span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">GapBuffer</span>) <span class="pl-en">postStart</span></span>() <span class="pl-v">int</span> {
	<span class="pl-k">return</span> <span class="pl-c1">len</span>(r.<span class="pl-smi">data</span>) - r.<span class="pl-smi">postLen</span>
}</pre></div>
<p>These convenience functions let us clearly refer to the beginning of the <em>gap</em>
section, the size of the <em>gap</em> section, and the beginning of the <em>post</em>
section. All three are derived values which we don't have to store directly.</p>
<p>We need a way to get a string of text into and out of our gap buffer. Let's
define a <em>SetText()</em> function to copy a string of text into the gap buffer:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">GapBuffer</span>) <span class="pl-en">SetText</span></span>(<span class="pl-v">s</span> <span class="pl-v">string</span>) {
	r.<span class="pl-smi">data</span> = []<span class="pl-c1">rune</span>(s)
	r.<span class="pl-smi">preLen</span> = <span class="pl-c1">0</span>
	r.<span class="pl-smi">postLen</span> = <span class="pl-c1">len</span>(r.<span class="pl-smi">data</span>)
}</pre></div>
<p>This converts the string into an array of runes and stores them in the <em>data</em>
array. It assumes the cursor starts at the beginning of the buffer, so <em>preLen</em>
is set to 0, which makes <em>pre</em> empty: there is no data before the cursor.
<em>postLen</em> is set to the length of the entire buffer, since the entire buffer is
after the cursor.</p>
<p>When we're done working with the data in the gap buffer, we'll want a way to
retrieve the complete string:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">GapBuffer</span>) <span class="pl-en">GetText</span></span>() <span class="pl-v">string</span> {
	<span class="pl-smi">ret</span> <span class="pl-k">:=</span> <span class="pl-c1">make</span>([]rune, r.<span class="pl-smi">preLen</span> + r.<span class="pl-smi">postLen</span>)

	<span class="pl-c1">copy</span>(ret, r.<span class="pl-smi">data</span>[:r.<span class="pl-smi">preLen</span>])
	<span class="pl-c1">copy</span>(ret[r.<span class="pl-smi">preLen</span>:], r.<span class="pl-smi">data</span>[r.<span class="pl-c1">postStart</span>():])

	<span class="pl-k">return</span> <span class="pl-c1">string</span>(ret)
}</pre></div>
<p>Since there can be (and usually is) a gap of empty text somewhere inside the
buffer, we want to return only the <em>pre</em> and <em>post</em> sections. So we create a
new array, copy the <em>pre</em> section into the new array, and then copy the <em>post</em>
section after it. This skips the <em>gap</em> section entirely, which is really just
an internal tool of the data structure: consumers of this gap buffer
shouldn't care what's going on internally.</p>
<p>Now that we can get data into and out of our gap buffer, let's allow the
cursor to be moved around. Remember that the cursor in a gap buffer is
represented by the <em>gap</em> section itself. So all we have to do move the cursor
around is shift the <em>gap</em> left or right depending on the direction the cursor
should move:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">GapBuffer</span>) <span class="pl-en">CursorNext</span></span>() {
	<span class="pl-k">if</span> r.<span class="pl-smi">postLen</span> == <span class="pl-c1">0</span> {
		<span class="pl-k">return</span>
	}

	r.<span class="pl-smi">data</span>[r.<span class="pl-smi">preLen</span>] = r.<span class="pl-smi">data</span>[r.<span class="pl-c1">postStart</span>()]
	r.<span class="pl-smi">preLen</span>++
	r.<span class="pl-smi">postLen</span>--
}</pre></div>
<p>When <em>CursorNext()</em> is called, we first make sure the cursor isn't already at
the end of the buffer. If the <em>post</em> section is empty, there's nothing left
after the cursor, so there's nothing to do.</p>
<p>As long as the cursor isn't at the end of the buffer already, we can move the
cursor forward one character. We do this by copying the first character from
the <em>post</em> section to the end of the <em>pre</em> section. Then we grow the <em>pre</em>
section to absorb the newly-added character and shrink the <em>post</em> section
to release the removed character. The gap (and the cursor) has been moved to
the right.</p>
<p>Moving the cursor in the other direction is the exact inverse:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">GapBuffer</span>) <span class="pl-en">CursorPrevious</span></span>() {
	<span class="pl-k">if</span> r.<span class="pl-smi">preLen</span> == <span class="pl-c1">0</span> {
		<span class="pl-k">return</span>
	}

	r.<span class="pl-smi">data</span>[r.<span class="pl-c1">postStart</span>() - <span class="pl-c1">1</span>] = r.<span class="pl-smi">data</span>[r.<span class="pl-smi">preLen</span> - <span class="pl-c1">1</span>]
	r.<span class="pl-smi">preLen</span>--
	r.<span class="pl-smi">postLen</span>++
}</pre></div>
<p>Assuming we're not already at the beginning of the buffer, we copy the last
character from the <em>pre</em> section to the slot right before the beginning of the
<em>post</em> section. The <em>pre</em> section is shrunk and the <em>post</em> section is grown.
The gap has been shifted to the left.</p>
<p>We can also delete characters. Deleting a character from a gap buffer is
pretty slick:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">GapBuffer</span>) <span class="pl-en">Delete</span></span>() {
	<span class="pl-k">if</span> r.<span class="pl-smi">postLen</span> == <span class="pl-c1">0</span> {
		<span class="pl-k">return</span>
	}

	r.<span class="pl-smi">postLen</span>--
}</pre></div>
<p>To delete the character immediately after the cursor, all we do is shrink the
<em>post</em> section. This effectively grows the <em>gap</em> section to include the deleted
character. We don't even need to overwrite the data: since it's part of the
<em>gap</em> section now, it's effectively gone from the text. Pretty magic, eh?</p>
<p>Deleting a character immediately before the cursor (like what happens when a
user presses the backspace key) is quite similar:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">GapBuffer</span>) <span class="pl-en">Backspace</span></span>() {
	<span class="pl-k">if</span> r.<span class="pl-smi">preLen</span> == <span class="pl-c1">0</span> {
		<span class="pl-k">return</span>
	}

	r.<span class="pl-smi">preLen</span>--
}</pre></div>
<p>We just shrink the <em>pre</em> section, which grows the <em>gap</em> section to include
the deleted character in the opposite direction.</p>
<p>Destruction is obviously fun, but let's try some creation. Inserting text is
pretty straightforward, provided there is enough room in the <em>gap</em> section to
contain the new text. Things get a bit tricker if the <em>gap</em> section is empty:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">GapBuffer</span>) <span class="pl-en">Insert</span></span>(<span class="pl-v">c</span> <span class="pl-v">rune</span>) {
	<span class="pl-k">if</span> r.<span class="pl-c1">gapLen</span>() == <span class="pl-c1">0</span> {
		<span class="pl-smi">newData</span> <span class="pl-k">:=</span> <span class="pl-c1">make</span>([]rune, <span class="pl-c1">len</span>(r.<span class="pl-smi">data</span>) * <span class="pl-c1">2</span>)

		<span class="pl-c1">copy</span>(newData, r.<span class="pl-smi">data</span>[:r.<span class="pl-smi">preLen</span>])
		<span class="pl-c1">copy</span>(newData[r.<span class="pl-c1">postStart</span>() + <span class="pl-c1">len</span>(r.<span class="pl-smi">data</span>):],
			r.<span class="pl-smi">data</span>[r.<span class="pl-c1">postStart</span>():])

		r.<span class="pl-smi">data</span> = newData
	}

	r.<span class="pl-smi">data</span>[r.<span class="pl-c1">gapStart</span>()] = c
	r.<span class="pl-smi">preLen</span>++
}</pre></div>
<p>If the <em>gap</em> section is empty, we have to expand it before we can insert the
new character.</p>
<p>We first create a new array called <em>newData</em> and allocate twice the size of
our existing <em>data</em> array. We double it each time because this is an expensive
operation which, in the worst case, requires copying the entire buffer. By
doubling it each time, we make this costly operation occur less and less
frequently as the buffer gets larger.</p>
<p>Once we have the new array allocated, we copy the <em>pre</em> section into the
beginning of the new array and the <em>post</em> section into end of the new array.
This leaves a new <em>gap</em> section between them which now has at least one
slot available for the new character.</p>
<p>Finally, we insert the new character by copying it into the first slot in the
<em>gap</em> section and grow the <em>pre</em> section to absorb the new character.</p>
<h1>Gap buffer runtime analysis</h1>
<p>In gap buffers, operations which take place around the cursor are extremely
fast, but seeking (moving the cursor a long distance) is relatively slow.</p>
<h3>Moving the cursor one position</h3>
<p>Moving the cursor left or right by one position at a time requires moving a
single character from one side of the gap to the other and adjusting the sizes
of the <em>pre</em> and <em>post</em> sections. No matter how large the file you're editing
is, moving the cursor around like this will take the same amount of time. This
makes it a constant time <em>O(1)</em> operation.</p>
<h3>Deleting a character from before or after the cursor</h3>
<p>Deleting a single character from before or after the cursor is also a cheap
operation: in both cases, either the <em>preLen</em> or <em>postLen</em> is decremented.
No matter how big the file is, this will take the same amount of time, making
it a constant time operation.</p>
<h3>Inserting a character at the cursor</h3>
<p>Inserting a character where the cursor is requires a bit more analysis. When
the <em>gap</em> section has room for the new character, all we have to do is copy the
new character into the array and adjust <em>preLen</em> to absorb the new character.
This is a constant time operation.</p>
<p>However, when the gap runs out of space for new characters, we have to
allocate a new array and copy the entire buffer over to the new array. This has
a linear runtime <em>O(n)</em>, meaning that this operation will get slower as the
buffer being edited grows.</p>
<p>Luckily, there's a common strategy we can use to reduce the impact of this
occassionally slow operation. By growing the gap exponentionally each time, we
can make these costly operations occur less frequently as the buffer size
grows. Averaged out over time, the vast majority of insertions will run in
constant time with only the very occassional linear runtime operation. This is
known as amortized constant time.</p>
<h3>Long distance cursor movements</h3>
<p>While gap buffers have very good performance for operations local to the
cursor, the biggest weakness is in long distance cursor movements. Moving the
cursor arbitrary distances requires continually copying characters from one
side of the gap to the other and adjusting the sizes of <em>pre</em> and <em>post</em>
repeatedly until the gap has shifted far enough. This makes it a linear
runtime operation in the worst case (example: seeking from the very beginning
to the very end of the buffer).</p>
<h1>Split buffers</h1>
<p>The gap buffer is a really nice, simple data structure for a text editor. There
are only a couple of things about them I don't care for, and a major one is
having to manage the gap between <em>pre</em> and <em>post</em> sections.</p>
<p>As a possible improvement in this area, I came up with what I'm calling a split
buffer. It's basically a gap buffer with the data rearranged so there's no gap
to be managed.</p>
<p>Like before, let's take an initial value of "a buffer" and place the cursor
between the <code>b</code> and the <code>u</code>. To do this, we need to split the string into
<em>pre</em> and <em>post</em> arrays:</p>
<p><a href="/blog/split-buffer/split-buffer-1.svg" target="_blank"><img src="/blog/split-buffer/split-buffer-1.svg" style="max-width:100%;"></a></p>
<p>Notice these are separate physical arrays in memory, not virtual sections in
one combined array.</p>
<p>Now we need to reverse the <em>post</em> array. This is done to improve the
performance of operations around the cursor. It's much cheaper to make changes
to the end of an array than to the beginning.</p>
<p><a href="/blog/split-buffer/split-buffer-2.svg" target="_blank"><img src="/blog/split-buffer/split-buffer-2.svg" style="max-width:100%;"></a></p>
<p>Once the <em>post</em> array is reversed, the data should look like this:</p>
<p><a href="/blog/split-buffer/split-buffer-3.svg" target="_blank"><img src="/blog/split-buffer/split-buffer-3.svg" style="max-width:100%;"></a></p>
<p>Notice the flow of characters wraps around. The first character in the buffer
is the first character in the <em>pre</em> array. The last character in the buffer
is the last character in the <em>post</em> array. So the buffer is chopped in half
where the cursor is.</p>
<p><a href="/blog/split-buffer/split-buffer-4.svg" target="_blank"><img src="/blog/split-buffer/split-buffer-4.svg" style="max-width:100%;"></a></p>
<p>Unlike the gap buffer, there is no gap. Or another way to put it is that we
have an unlimited gap which is the "space" between arrays. Despite the data
being laid out differently, many operations remain very similar. For example,
to move the cursor to the left, move one character from the end of the <em>pre</em>
array to the end of the <em>post</em> array:</p>
<p><a href="/blog/split-buffer/split-buffer-5.svg" target="_blank"><img src="/blog/split-buffer/split-buffer-5.svg" style="max-width:100%;"></a></p>
<p>Which produces:</p>
<p><a href="/blog/split-buffer/split-buffer-6.svg" target="_blank"><img src="/blog/split-buffer/split-buffer-6.svg" style="max-width:100%;"></a></p>
<p>Moving the cursor to the right is done exactly opposite: move one character
from the end of the <em>post</em> array to the end of the <em>pre</em> array:</p>
<p><a href="/blog/split-buffer/split-buffer-7.svg" target="_blank"><img src="/blog/split-buffer/split-buffer-7.svg" style="max-width:100%;"></a></p>
<p>To delete the character in front of the cursor (as in pressing the delete key),
remove a character from the end of the <em>post</em> array:</p>
<p><a href="/blog/split-buffer/split-buffer-8.svg" target="_blank"><img src="/blog/split-buffer/split-buffer-8.svg" style="max-width:100%;"></a></p>
<p>And to delete the character behind the cursor (as in a backspace), remove a
character from the end of the <em>pre</em> array:</p>
<p><a href="/blog/split-buffer/split-buffer-9.svg" target="_blank"><img src="/blog/split-buffer/split-buffer-9.svg" style="max-width:100%;"></a></p>
<p>Text insertions are improved quite a bit over the gap buffer version. To insert
text before the cursor, toss it onto the end of the <em>pre</em> array:</p>
<p><a href="/blog/split-buffer/split-buffer-10.svg" target="_blank"><img src="/blog/split-buffer/split-buffer-10.svg" style="max-width:100%;"></a></p>
<p>The text "split bu" has been added to the buffer as if it was typed or pasted
in at the cursor's location. Notice we didn't have to check if the gap was
large enough, conditionally reallocate the array, then copy pieces of the array
around. We just appended the text to the end of the <em>pre</em> array.</p>
<p>To get the complete text back out, we first reverse the <em>post</em> array, putting
it back in normal order:</p>
<p><a href="/blog/split-buffer/split-buffer-11.svg" target="_blank"><img src="/blog/split-buffer/split-buffer-11.svg" style="max-width:100%;"></a></p>
<p>Then we combine the <em>pre</em> and <em>post</em> arrays into the complete output:</p>
<p><a href="/blog/split-buffer/split-buffer-12.svg" target="_blank"><img src="/blog/split-buffer/split-buffer-12.svg" style="max-width:100%;"></a></p>
<h1>A split buffer implementation</h1>
<p>Let's implement a basic split buffer in Go! We need to store two arrays:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">type</span> <span class="pl-v">SplitBuffer</span> <span class="pl-k">struct</span> {
	pre  []rune
	post []rune
}</pre></div>
<p>The fields are:</p>
<ul>
<li><strong>pre</strong> stores the characters before the cursor.</li>
<li><strong>post</strong> stores the characters after the cursor, in reverse order.</li>
</ul>
<p>As with the gap buffer, we'll need a way to get data into the split buffer.
We'll assume that when <em>SetText()</em> is called, the cursor should be reset to
the beginning of the text. So the <em>pre</em> array should always start out empty.
The entire buffer should be in <em>post</em>, but in reverse order. We'll need to
start with a function to reverse an array of runes:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">reverseRunes</span>(<span class="pl-v">src</span> []<span class="pl-v">rune</span>) []<span class="pl-v">rune</span> {
	<span class="pl-smi">ret</span> <span class="pl-k">:=</span> []rune{}

	<span class="pl-k">for</span> <span class="pl-smi">i</span> <span class="pl-k">:=</span> <span class="pl-c1">len</span>(src) - <span class="pl-c1">1</span>; i &gt;= <span class="pl-c1">0</span>; i-- {
		ret = <span class="pl-c1">append</span>(ret, src[i])
	}

	<span class="pl-k">return</span> ret
}</pre></div>
<p>With that in place, we can can copy the data into the structure:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">SplitBuffer</span>) <span class="pl-en">SetText</span></span>(<span class="pl-v">s</span> <span class="pl-v">string</span>) {
	r.<span class="pl-smi">pre</span> = []rune{}
	r.<span class="pl-smi">post</span> = <span class="pl-c1">reverseRunes</span>([]<span class="pl-c1">rune</span>(s))
}</pre></div>
<p>We set <em>pre</em> to an empty array and set <em>post</em> to the entire buffer, reversed.</p>
<p>To get the text back out of the buffer after making some edits, we need to
reverse the order of the <em>post</em> array again to get it back in normal order,
then concatenate the <em>pre</em> and <em>post</em> arrays:</p>
<pre><code>func (r *SplitBuffer) GetText() string {
	ret := make([]rune, len(r.pre) + len(r.post))

	copy(ret, r.pre)
	copy(ret[len(r.pre):], reverseRunes(r.post))

	return string(ret)
}
</code></pre>
<p>Moving the cursor around is a matter of moving characters from the end of
one array to the end of the other. To move the cursor to the right, we copy the
last character in the <em>post</em> array to the end of the <em>pre</em> array. Then we
chop the copied character off the end of the <em>post</em> array:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">SplitBuffer</span>) <span class="pl-en">CursorNext</span></span>() {
	<span class="pl-k">if</span> <span class="pl-c1">len</span>(r.<span class="pl-smi">post</span>) == <span class="pl-c1">0</span> {
		<span class="pl-k">return</span>
	}

	r.<span class="pl-smi">pre</span> = <span class="pl-c1">append</span>(r.<span class="pl-smi">pre</span>, r.<span class="pl-smi">post</span>[<span class="pl-c1">len</span>(r.<span class="pl-smi">post</span>) - <span class="pl-c1">1</span>])
	r.<span class="pl-smi">post</span> = r.<span class="pl-smi">post</span>[:<span class="pl-c1">len</span>(r.<span class="pl-smi">post</span>) - <span class="pl-c1">1</span>]
}</pre></div>
<p>To move the cursor left, we do the opposite: we copy the last character in the
<em>pre</em> array to the end of the <em>post</em> array and shrink the <em>pre</em> array by 1:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">SplitBuffer</span>) <span class="pl-en">CursorPrevious</span></span>() {
	<span class="pl-k">if</span> <span class="pl-c1">len</span>(r.<span class="pl-smi">pre</span>) == <span class="pl-c1">0</span> {
		<span class="pl-k">return</span>
	}

	r.<span class="pl-smi">post</span> = <span class="pl-c1">append</span>(r.<span class="pl-smi">post</span>, r.<span class="pl-smi">pre</span>[<span class="pl-c1">len</span>(r.<span class="pl-smi">pre</span>) - <span class="pl-c1">1</span>])
	r.<span class="pl-smi">pre</span> = r.<span class="pl-smi">pre</span>[:<span class="pl-c1">len</span>(r.<span class="pl-smi">pre</span>) - <span class="pl-c1">1</span>]
}</pre></div>
<p>Deleting the character in front of the cursor is done by chopping the last
character off the end of the <em>post</em> array:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">SplitBuffer</span>) <span class="pl-en">Delete</span></span>() {
	<span class="pl-k">if</span> <span class="pl-c1">len</span>(r.<span class="pl-smi">post</span>) == <span class="pl-c1">0</span> {
		<span class="pl-k">return</span>
	}

	r.<span class="pl-smi">post</span> = r.<span class="pl-smi">post</span>[:<span class="pl-c1">len</span>(r.<span class="pl-smi">post</span>) - <span class="pl-c1">1</span>]
}</pre></div>
<p>Deleting the character before the cursor (as in a backspace keypress) is
done by chopping a character off the end of the <em>pre</em> array:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">SplitBuffer</span>) <span class="pl-en">Backspace</span></span>() {
	<span class="pl-k">if</span> <span class="pl-c1">len</span>(r.<span class="pl-smi">pre</span>) == <span class="pl-c1">0</span> {
		<span class="pl-k">return</span>
	}

	r.<span class="pl-smi">pre</span> = r.<span class="pl-smi">pre</span>[:<span class="pl-c1">len</span>(r.<span class="pl-smi">pre</span>) - <span class="pl-c1">1</span>]
}</pre></div>
<p>Inserting some new text before the cursor can be done by adding the new
character to the end of the <em>pre</em> array:</p>
<div class="highlight highlight-source-go"><pre><span class="pl-k">func</span> <span class="pl-en">(<span class="pl-v">r</span> *<span class="pl-v">SplitBuffer</span>) <span class="pl-en">Insert</span></span>(<span class="pl-v">c</span> <span class="pl-v">rune</span>) {
	r.<span class="pl-smi">pre</span> = <span class="pl-c1">append</span>(r.<span class="pl-smi">pre</span>, c)
}</pre></div>
<p>Notice that the insert is quite a bit simpler than in the gap buffer, since
we don't need to keep track of three sections within a single array or deal
with copying them around. It's just a straightforward append, since there's no
gap to manage explicitly.</p>
<h1>Split buffer runtime analysis</h1>
<p>Just like with gap buffers, operations taking place around the cursor are
fast, but moving the cursor a long distance is pretty slow. The runtime
complexity of a split buffer is similar to that of a gap buffer, except for one
difference: while local cursor movements in a gap buffer run in constant time,
they run in amortized constant time in a split buffer.</p>
<h3>Moving the cursor one position</h3>
<p>Moving the cursor left or right by one position at a time requires moving a
single character from one side of the gap to the other and adjusting the sizes
of the <em>pre</em> and <em>post</em> arrays. This is normally a constant time operation.
However, because <em>pre</em> and <em>post</em> in a split buffer are separate physical
arrays, they will occassionally need to be resized and have their contents
copied, which is a linear time operation. We can grow the arrays
exponentionally to get this down to an amortized constant time.</p>
<h3>Deleting a character from before or after the cursor</h3>
<p>Deleting a single character from before or after the cursor requires deleting
one character from the end of either the <em>pre</em> or <em>post</em> array. This is always
a single operation, so it runs in constant time.</p>
<h3>Inserting a character at the cursor</h3>
<p>Character insertions work by appending new characters to the end of either the
<em>pre</em> or <em>post</em> array. On average, this will run in constant time, but
occassionally a full reallocation and copy will be necessary. This makes it an
amortized constant time operation, the same as it is in the gap buffer.</p>
<h3>Long distance cursor movements</h3>
<p>Moving the cursor long distances requires repeatedly moving each character
from one array to the other. This is a linear operation, just like the gap
buffer.</p>
<h1>Conclusion</h1>
<p>The main thing still bothering me about both of these data structures is the
linear seek time.</p>
<p>I'm not sure if the split buffer is a net improvement over the gap buffer. By
choosing the split buffer you get simplified inserts and less moving parts when
performing cursor operations. However, the split buffer also has slightly worse
runtime complexity: in the case of local cursor movements, it trades constant
time for amortized constant time. Many people consider these to be effectively
the same runtime for practical purposes, but I don't really like the lack of
predictability that comes from occassional linear operations popping up among
otherwise constant operations, even if they're incredibly rare.</p>
<p>I'll probably continue to think about this and explore other stream data
structures. Feel free to get in touch, any suggestions or notes would be
great!</p></div>
