#!/usr/bin/env python3

import os
import sys
import requests

repo = 'repo'
endpoint = 'https://api.github.com/'
output_dir = 'introduction-to-64-bit-assembly'

index_template = '''---
layout: default
title: Introduction to 64-bit Assembly Language
---
<p>
    This is an introduction to x86-64 assembly language on Linux using the
    <a href="http://nasm.us">NASM assembler</a>. This is not complete yet, I'm
    just putting up a few sections as they become ready. Here is the current
    section list:
</p>
<ol>{}</ol>
'''

guide_template = '''---
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

<div class="markdown-body">{{ body }}</div>

<div class="next-guide">{{ next_guide }}</div>
'''

def process_guide(guide, next_guide):
    readme = os.path.join(repo, guide['name'], 'README.md')

    with open(readme) as f:
        source = f.read()

    res = requests.post(endpoint + 'markdown', json={
        "text": source,
        "mode": "gfm",
        "context": "briansteffens/" + repo
    })

    if res.status_code != 200:
        print('API error: {}'.format(res.status_code))
        sys.exit(2)

    output_path = os.path.join(output_dir, guide['name'])
    os.makedirs(output_path, exist_ok=True)

    body = res.text.replace('<br>', '')

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
    }
]

links = ''

for i in range(len(guides)):
    guide = guides[i]

    next_guide = guides[i + 1] if i < len(guides) - 1 else None

    process_guide(guide, next_guide)
    links += '<li><a href="{}">{}</a>'.format(guide['name'], guide['title'])

with open(os.path.join(output_dir, 'index.html'), 'w') as f:
    f.write(index_template.format(links))
