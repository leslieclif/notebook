# General Syntax

> [MarkDown Cheat Sheet](http://assemble.io/docs/Cheatsheet-Markdown.html) 

1. Headings
    ``` # h1 Heading
      ## h2 Heading
      ### h3 Heading
      #### h4 Heading
      ##### h5 Heading
      ###### h6 Heading 
     ```
1. Horizontal Rule
     ```
    ___: three consecutive underscores
    ---: three consecutive dashes
    ***: three consecutive asterisks
    ```
1. Emphasis
    * Bold ```**rendered as bold text**```
    * Italics ```_rendered as italicized text_```
    * BlockQuote ```> Blockquotes```
    * Nested BlockQuote ```> First Level
                           >> Second Level
                           >>> Third Level```
1. List
    * Unordered ```* or + or -```
    * Ordered ``` 1. ```

1. Code Block ``` ` ``` or [```html] (3 backticks and follwed by the language)

1. Links
    * Inline Links ```[Text](http://text.io)```
    * Link titles ```[Text](https://github.com/site/ "Visit Site!")```

1. Images
    ```![Minion](http://octodex.github.com/images/minion.png)```

# Using Mkdocs formatting

- Tabbed Data

!!! example "Inline Examples"
    === "Output"
        $p(x|y) = \frac{p(y|x)p(x)}{p(y)}$, \(p(x|y) = \frac{p(y|x)p(x)}{p(y)}\).

    === "Markdown"
        ```tex
        $p(x|y) = \frac{p(y|x)p(x)}{p(y)}$, \(p(x|y) = \frac{p(y|x)p(x)}{p(y)}\).
        ```

- Adding Tips

!!! tip "Inline Configuration"
    This is an example of a tip. 
    Make the paragragh tabbed inline with the heading

- Adding Danger

!!! danger "Reminder"
    This is a call to action

- Adding Note

!!! Note "Note"
    Adding notes

- Adding Summary

!!! summary "Summary"
    This is to sumarize the information

- New Information
!!! new "New 7.1"
    New Info

- Adding Note Collapsible tab

??? note "Click Me!"
    Thanks!

- Success Collapsible tab

??? success 
    Content.

- Warning Collapsible tab

??? warning classes
    Content.

- Adding Settings Gear

??? settings "Basic Software Setup"
    ```console
    sudo apt install
    ```
- Adding multi-level collapisble tabs 

Details must contain a blank line before they start. Use ??? to start a details block or ???+ if you want to start a details block whose default state is 'open'. Follow the start of the block with an optional class or classes (separated with spaces) and the summary contained in quotes. Content is placed below the header and must be indented.

???+ note "Open styled details"

    ??? danger "Nested details!"
        And more content again.


- Adding checklist inside summary

!!! summary "Tasklist"

    - [x] eggs
    - [x] bread
    - [ ] milk

- Adding strikethrough and subscript

!!! summary "Tilde"
    Tilde is syntactically built around the `~` character. It adds support for inserting
    sub~scripts~ and adds an easy way to place ~~text~~ in a `#!html <del>` tag.

- Showing Critic changes

!!! summary "Critic"
    Added CSS changes in extra.css to activate `Critic` change higlights. <br>
    {--This is deleted--} {++This is added++}

- Showing Emojis

:smile: :heart: :thumbsup:

- Inline Code Highlighting

InlineHilite utilizes the following syntax to insert inline highlighted code: `` `:::language mycode` `` or
`` `#!language mycode` ``.

!!! example "Inline Highlighted Code Example"
    Here is some code: `#!py3 import pymdownx; pymdownx.__version__`.

    The mock shebang will be treated like text here: ` #!js var test = 0; `.

- Marking words

!!! example "Mark Example"
    ==mark me==

- Preserve Tab spaces

```
============================================================
T	Tp	Sp	D	Dp	S	D7	T
------------------------------------------------------------
A	F#m	Bm	E	C#m	D	E7	A
A#	Gm	Cm	F	Dm	D#	F7	A#
B♭	Gm	Cm	F	Dm	E♭m	F7	B♭
```

- Showing Line Number in code

``` {linenums="1"}
import foo.bar
import car
```
- Highlighting specific line numbers

```{.py3 hl_lines="1 3"}
"""Some file."""
import foo.bar
import boo.baz
import foo.bar.baz
```

- Highlighting line range and specific lines

```{.py3 hl_lines="1-2 5 7-8"}
import foo
import boo.baz
import foo.bar.baz

class Foo:
   def __init__(self):
       self.foo = None
       self.bar = None
       self.baz = None
```