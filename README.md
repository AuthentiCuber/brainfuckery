# Brainfuckery

A collection of simple [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) intepreters written in a variety of languages

## Why?

Mainly an excuse to get some experience in a bunch of languages.
Brainfuck intepreters are great for this because they are relatively simple while utilising a decent range of a languages features.

## Approach

The idea is to keep these implementations as simple as possible while implementing all of BFs features.
This means I will not be implementing any optimisations like collapsing repeated instructions.
The general design of the intepreters will be as follows: (at least for the procedural Languages)
        .bf file -> preprocessor -> intepreter -> output

The preprocessor is responsible for removing all non-syntax characters, which BF treats as comments, and matching brackets

Inspired by [Tsoding's BF JIT compiler](https://github.com/tsoding/bfjit).
(see also his [VOD](https://www.youtube.com/watch?v=mbFY3Rwv7XM) of its development)

## Languages

- [ ] python
- [ ] C
- [ ] Haskell
- [ ] Javascript

more to come ...
