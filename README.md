
# Sempl

A simple, line-based template system for the command line.
Useful for injecting command output, file contents,
and environment variables into arbitrary text.

Sempl was designed to be simple yet powerful.
This document was written with it.

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
    {# you might think
     # this would be
     # a multiline comment,
     # but you'd be wrong }
-->

## Basic Parameters

### Environment Variables: {$envvar}

    My shell is {$SHELL}

on my system, renders as

    My shell is /bin/bash

### Files: {/file} or {.file} or {~file}

Suppose we have a file in `/tmp` named `hello.txt`
with the following contents.

    Hello world,
    how are you?

In that case,

    ==> {/tmp/hello.txt} <==

renders as

    ==> Hello world, <==
    ==> how are you? <==

This also works with relative paths.

    {.dotfile}
    {./file}
    {./path/to/file}
<!--
    {~/path/to/file/in/home}
    {~user/path/to/file/in/user/home}
-->

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

    $ printf '%s\n' 'green eggs and ham.' 'them, Sam I am.' | sempl <(echo 'I do not like {-}')

## Frontmatter: #!sempl

Similar to other templating systems,
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
    var2='escaped quotes aren't pretty, but they're possible'

Quotes in quoted strings can be escaped in a way that the shell will understand.

    var2='escaped quotes aren'\t pretty, but they'\re possible'

## Loop: {<param} {N,N:,N:M,:M,...} {;<}

{<param} begins reading from {param},
but produces no output by itself.
A {;<} ends a {<param} statement.

Each line of {param}'s output is interpolated
into the text between {<param} and {;<} using a cut-like syntax.
{0} expands to the whole line.
{N} expands to the Nth field.
Field ranges can be selected using {N-}, {N-M}, and {-M}.
Multiple field ranges can be expanded using commas.
For example, {-3,5,7-} would expand to the first through third,
fifth, and seventh through last fields.

## Nesting

## Joins

TODO: explore different kinds of join-like expressions

## Full Examples

## Real World Examples

# vim: ft=markdown
