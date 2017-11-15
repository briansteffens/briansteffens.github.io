#!/usr/bin/env python3

import os
import sys
import requests


guide_repo = 'repo'
endpoint = 'https://api.github.com/'
guide_output_dir = 'introduction-to-64-bit-assembly'


guide_index_template = '''---
layout: default
title: Introduction to 64-bit Assembly Language
hide: 1
---
<p>
    This is an introduction to x86-64 assembly language on Linux using the
    <a href="http://nasm.us">NASM assembler</a>. This is not complete yet, I'm
    just putting up a few sections as they become ready. Here is the current
    section list:
</p>
<ol>{}</ol>
'''


post_template = '''---
layout: default
title: {{ title }}
description: {{ description }}
---
<link rel="stylesheet" type="text/css" href="/css/github-markdown.css" />

<link href="https://fonts.googleapis.com/css?family=Gentium+Basic"
      rel="stylesheet">

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

    h3 {
        font-family: Gentium Basic, serif;
    }
</style>

<script type="text/javascript" async
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

<div class="markdown-body">{{ body }}</div>
'''


split_img_hack = '''
<style>
    img {
        padding-top: 20px;
        padding-bottom: 20px;
    }
</style>
'''


guide_template = post_template + \
        '\n\n<div class="next-guide">{{ next_guide }}</div>'


def convert_markdown(source):
    res = requests.post(endpoint + 'markdown', json={
        "text": source,
        "mode": "gfm",
        "context": "briansteffens/" + guide_repo
    })

    if res.status_code != 200:
        print('API error: {}'.format(res.status_code))
        sys.exit(2)

    return res.text.replace('<br>', '')


def process_post(source_fn, destination_fn, title, description):
    with open(source_fn) as f:
        body = convert_markdown(f.read())

    output = post_template

    if 'split-buffers' in destination_fn:
        output += split_img_hack

    output = output.replace('{{ body }}', body)
    output = output.replace('{{ title }}', title)
    output = output.replace('{{ description }}', description)

    with open(destination_fn, 'w') as f:
        f.write(output)


#process_post('blog/from-math-to-machine/post.md',
#             '_posts/2017-02-20-from-math-to-machine.md',
#             'From math to machine',
#             'Compare and contrast how a factorial function can be '
#             'represented in math, Haskell, C, assembly, and machine code')
#
#process_post('blog/split-buffers/post.md',
#             '_posts/2017-06-19-split-buffers.md',
#             'Split buffers',
#             'A variation of the gap buffer data structure for text editors')
#
#process_post('blog/google-sheets-virtual-machine/post.md',
#             '_posts/2017-07-03-google-sheets-virtual-machine.md',
#             'Google Sheets virtual machine',
#             'A simple virtual machine demonstration inside a spreadsheet')

#process_post('blog/unicode-basics/post.md',
#             '_posts/2017-10-18-unicode-basics.md',
#             'Unicode basics',
#             'An overview of Unicode and how it relates to various encodings')


def process_guide(guide, next_guide):
    readme = os.path.join(guide_repo, guide['name'], 'README.md')

    with open(readme) as f:
        body = convert_markdown(f.read())

    output_path = os.path.join(guide_output_dir, guide['name'])
    os.makedirs(output_path, exist_ok=True)

    next_guide_link = ''
    if next_guide is not None:
        next_guide_link = 'Next section: <a href="../{}">{}</a>'.format(
                next_guide['name'], next_guide['title'])

    output = guide_template.replace('{{ body }}', body) \
                           .replace('{{ next_guide }}', next_guide_link)

    with open(os.path.join(output_path, 'index.html'), 'w') as f:
        f.write(output)


guides = [
    {
        'title': 'Hello, world!',
        'name': '01-hello-world'
    },
    {
        'title': 'Run script',
        'name': '02-run-script'
    },
    {
        'title': 'User input',
        'name': '03-user-input'
    },
    {
        'title': 'Basic math',
        'name': '04-basic-math'
    },
    {
        'title': 'Conditional branching',
        'name': '05-conditional-branching'
    },
    {
        'title': 'Looping',
        'name': '06-looping'
    }
]

#links = ''
#
#for i in range(len(guides)):
#    guide = guides[i]
#
#    next_guide = guides[i + 1] if i < len(guides) - 1 else None
#
#    process_guide(guide, next_guide)
#    links += '<li><a href="{}">{}</a>'.format(guide['name'], guide['title'])
#
#with open(os.path.join(guide_output_dir, 'index.html'), 'w') as f:
#    f.write(guide_index_template.format(links))
