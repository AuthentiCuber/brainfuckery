# Brainfuckery

A collection of simple [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) interpreters written in a variety of languages

## Why?

Mainly an excuse to get some experience in a bunch of languages.
Brainfuck interpreters are great for this because they are relatively simple while utilising a decent range of a languages features.
Such features include:

- (file) IO
- structs/enums/objects to represent tokens
- several data types: strings, characters, arrays, integers/bytes
- control structures: different kinds of loops, if, switch-case, pattern matching

## Approach

The idea is to keep these implementations as simple as possible while implementing all of BFs features.
This means I will not be implementing any fancy optimisations or tricks.
I am implementing these interpreters in the most straightforward way I can think of.
The general design is as follows:

    .bf file -> tokenisation -> parsing -> interpreter -> output

The tokeniser converts the plaintext input into a list of symbolic tokens, ignoring any characters
that are not one of Brainfuck's 8 commands. The parser collapses any repeated data or data-pointer commands
into singular commands, and also associates matching bracket pairs with each other. Finally, the interpreter
executes this intermediate representation.

Inspired by [Tsoding's BF JIT compiler](https://github.com/tsoding/bfjit).
(see also his [VOD](https://www.youtube.com/watch?v=mbFY3Rwv7XM) of its development)

## Languages

- [ ] python
- [ ] C
- [ ] Haskell
- [ ] Javascript

more to come ...
