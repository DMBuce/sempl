
# Sempl

A simple, line-oriented template utility for the command line.
Useful for injecting command output, file contents,
and environment variables into arbitrary text.

Requires perl and bash shell.

## Comments: {#comment}

    Want to know a secret? {#This text won't render}

renders as

    Want to know a secret? 

Sempl templates are evaluated line by line,
and parameters such as the comment above must begin and end on the same line,
so the following would be rendered as-is:

    {# you might think
     # this would be
     # a multiline comment,
     # but you'd be wrong }

<!-- test
    <# you might think
     # this would be
     # a multiline comment,
     # but you'd be wrong >
-->

## Basic Parameters

### Environment Variables: {$envvar}

    My shell is {$SHELL}

on my system, renders as

    My shell is /bin/bash

### Files: {/file} or {.file}

Suppose we have a file in `/tmp` named `hello.txt`
with the following contents.

    Hello world,
    how are you?

In that case,

    ==> {/tmp/hello.txt} <==

renders as

    ==> Hello world, <==
    ==> how are you? <==

This also works with relative paths that start with `.` .

    {.dotfile}
    {./file}
    {./path/to/file}



Note that each line of the file is interpolated into the line in the template.
All basic parameters -- `{$envvar} {/file} {!command} {-}` --
undergo line interpolation.

### Commands: {!command}

    > {!grep -x s.mple /usr/share/dict/words | sed 'p; s/$/r/'}

on my system, renders as

    > sample
    > sampler
    > simple
    > simpler

Only stdin is captured.
To capture stderr, use shell redirection.

### Stdin: {-}

	$ echo -e 'en\nid\nic' | sempl 'V{-}i,'
	Veni,
	Vidi,
	Vici,

## Fields: {<$envvar} {<!command} {</file} {<.file} {<-} {N,N:,N:M,:M,...}

`{<param}` produces no output by itself.
Instead, it interpolates fields from each line of `{param}`
into the template's current line using a cut-like syntax.

For example, suppose we have the following in `./madlibs.dat`:

    little	cat	feared	big	dog	made a run for it
    fast	dog	chased	slow	cat	caught it

In that case,

    {<./madlibs.dat}The {:2} {3} the {4:5} and {6:}.

renders as

    The little cat feared the big dog and made a run for it.
    The fast dog chased the slow cat and caught it.

`{0}` expands to the whole line.
`{N}` expands to the Nth field.
Field ranges can be selected using `{N:}`, `{N:M}`, and `{:M}`.
Multiple field ranges can be expanded using commas.
For example, `{:3,5,7:}` would expand to the first through third,
fifth, and seventh through last fields.

## Frontmatter: #!sempl

Similar to some other templating systems,
sempl templates can include a front matter at the beginning.
The front matter's first and last lines must start with `#!` and contain `sempl`.
Every other line between them either defines an environment variable,
or is a comment starting with `#`.
For example:

    #!/usr/bin/env sempl
    # export value to $var
    var = value
    #!end sempl env

The above example exports `value` to the `$var` environment variable.
The template can then reference it with `{$var}`
or in commands with e.g. `{!command $var}`.

To ease copying and pasting between shell scripts,
you can wrap the value in single quotes.
Unlike in shell, quotes in the middle of unquoted values are interpreted literally.

    var1='value'
    var2='this value's got a quote in the middle'

Quotes in quoted strings can be escaped in a way that the shell will understand.

    var3='escaped quotes aren'\''t pretty, but they'\''re possible'

## Continuation

### Statement Continuation: {\\}

If a line ends with `{\}`, that line and the following one are processed together.

    #!/usr/bin/env sempl
    bar='==='
    #!end sempl env
    {!echo -e 'one\ntwo\nthree'}{\}
    {$bar}

renders as

    one
    ===
    two
    ===
    three
    ===

If the `{\}` were not in the template, instead it would render as

    one
    two
    three
    ===

### Line Continuation: {\\\\} and {\\\\\\}

To continue a line, use `{\\}`.
To also clobber leading whitespace on the next line, use `{\\\}`.

    {$SHELL}> {!echo -e 'a\nb\nc'}. {./hello.txt}

can be rewritten as

    {$SHELL}> {\\}
    {!echo -e 'a\nb\nc'}. {\\}
    {./hello.txt}

and also as

    {$SHELL}> {\\\}
        {!echo -e 'a\nb\nc'}. {\\\}
        {./hello.txt}

All three render as

    /bin/bash> a. Hello world,
    /bin/bash> a. how are you?
    /bin/bash> b. Hello world,
    /bin/bash> b. how are you?
    /bin/bash> c. Hello world,
    /bin/bash> c. how are you?
<!--
    /bin/bash> a. Hello world,
    /bin/bash> a. how are you?
    /bin/bash> b. Hello world,
    /bin/bash> b. how are you?
    /bin/bash> c. Hello world,
    /bin/bash> c. how are you?

    /bin/bash> a. Hello world,
    /bin/bash> a. how are you?
    /bin/bash> b. Hello world,
    /bin/bash> b. how are you?
    /bin/bash> c. Hello world,
    /bin/bash> c. how are you?
-->

## Line Interpolation

Note that in the example above,
Sempl renders every combination of lines from each parameter
due to line interpolation.
Sempl reads and expands parameters from left to right, so

    {$SHELL}> {!echo -e 'a\nb\nc'}. {./hello.txt}

expands to

    /bin/bash> {!echo -e 'a\nb\nc'}. {./hello.txt}

then to

    /bin/bash> a. {./hello.txt}
    /bin/bash> b. {./hello.txt}
    /bin/bash> c. {./hello.txt}

before rendering the final form shown in the previous example.

The end result could be thought of as a
[cross join](https://en.wikipedia.org/wiki/Join_(SQL)#Cross_join) from SQL
or a [cartesian product](https://en.wikipedia.org/wiki/Cartesian_product)
from mathematics.

If several parameters each have a lot of lines,
it can take a lot of time to interpolate them.
The end result is also often not what you want.
An alternative is to use the `{!command}` parameter to process the data.
For example, the following two statements

    {$SHELL}> {!echo -e 'a\nb\nc' | paste -d" " - hello.txt}
    {$SHELL}> {<!echo -e 'a\nb\nc' | cat -n | join - <(cat -n hello.txt)}{2:}

respectively render as

    /bin/bash> a Hello world,
    /bin/bash> b how are you?
    /bin/bash> c

and

    /bin/bash> a Hello world,
    /bin/bash> b how are you?

## Braces: {{}} </> [] @@ ...

If your template contains curly braces,
you can set the `$SEMPL_BRACES` environment variable
to avoid ambiguities.

    $ export SEMPL_BRACES='{{}}'
    $ sempl 'My {$SHELL} is {{$SHELL}}'
    My {$SHELL} is /bin/bash

    $ export SEMPL_BRACES='</>'
    $ sempl 'My {$SHELL} is <$SHELL/>'
    My {$SHELL} is /bin/bash

    $ export SEMPL_BRACES='[]'
    $ sempl 'My {$SHELL} is [$SHELL]'
    My {$SHELL} is /bin/bash

    $ export SEMPL_BRACES='@' # same as '@@'
    $ sempl 'My {$SHELL} is @$SHELL@'
    My {$SHELL} is /bin/bash

Sempl internally sets the `$LB` and `$RB` environment variables
from the left and right braces of `$SEMPL_BRACES`,
so you can use those to avoid ambiguity as well.

    $ unset SEMPL_BRACES
    $ sempl 'My {$LB}$SHELL} is {$SHELL}'
    My {$SHELL} is /bin/bash

## Running Sempl

Basic usage:

    sempl SOURCE DEST

Read a template on stdin and render it on stdout:

    echo 'My shell is {$SHELL}' | sempl - -

By default, SOURCE and DEST are both "-",
so the above example is the same as

    echo 'My shell is {$SHELL}' | sempl

If SOURCE contains "{" followed by "}",
it is interpreted as a template

    sempl 'My shell is {$SHELL}'

Otherwise, it's interpreted as a file

    sempl file.txt.sempl

Write the output to a file

    echo 'My shell is {$SHELL}' | sempl - file.txt
    sempl 'My shell is {$SHELL}' file.txt
    sempl file.txt.sempl file.txt

### Environment

Sempl sets certain environment variables that can be used within templates.
Other environment variables can be used to control Sempl's behavior.

#### $SRC, $DEST

These environment variables refer to the SRC and DEST passed to Sempl on the command line.
They default to "-" and can't be overriden in the frontmatter,
nor by passing them in from the environment of the process that launches sempl.

#### $SEMPL_BRACES

Sets the braces that surround parameters.
See the "Braces" section above for details.

#### $SEMPL_DUMP

Normally, Sempl works by generating and running a shell script to produce output.
If `$SEMPL_DUMP` is set to anything other than "0" or "",
Sempl will instead write the shell script to DEST.sh without running it.

<!--
## Examples
-->

<!-- vim: ft=markdown
-->
