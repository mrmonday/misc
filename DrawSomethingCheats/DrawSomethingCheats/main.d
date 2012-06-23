/**
 * A handy little tool for when you get stuck with DrawSomething
 *
 * To build it you need a standard unix dictionary, which can usually
 * be found in /usr/share/dict/words.
 *
 * Copyright (C) 2012, Robert Clipsham <robert@octarineparrot.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
 */
module main;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.stdio;

immutable string[] words;
immutable string _words = import("words");
static this()
{
    // OOM when doing this in CTFE
    words = _words.split("\n").idup;
}

bool matchesPattern(string word, string availableLetters)
{
    foreach (letter; word)
    {
        size_t idx = availableLetters.countUntil(letter);
        if (idx != -1)
        {
            availableLetters = availableLetters[0..idx] ~ availableLetters[idx+1..$];
        }
        else
        {
            return false;
        }
    }
    return true;
}

int main(string[] args)
{
    string availableLetters;
    int noLetters;
    if (args.length == 3)
    {
        noLetters = to!int(args[1]);
        availableLetters = args[2];
    }
    else
    {
        write("Number of letters: ");
        readf("%d", &noLetters);
        readln();
        write("Available letters: ");
        availableLetters = readln();
    }

    writeln(words.filter!( word => word.length == noLetters && word.matchesPattern(availableLetters))());

    readln();
    return 0;
}
