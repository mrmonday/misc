/**
 * A half-baked effort to port bf.c to d.
 * I actually prefer the C version, this is a complete hack
 * and not remotely D-ish.
 *
 * Copyright (C) Robert Clipsham <robert@octarineparrot.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
 */
module bf;

import core.stdc.stdio : getchar, putchar;

import std.algorithm;
import std.conv;
import std.file;
import std.getopt;
import std.range;
import std.stdio;

char[] array;
size_t arrayIdx;

string bf;
size_t bfIdx;

void getLocation(out size_t line, out size_t character)
{
    line = 1 + bf[0 .. bfIdx].count('\n');
    character = bfIdx - retro(bf[0 .. bfIdx]).countUntil('\n') - 1;
}

void error(string msg, string aux)
{
    throw new Exception(msg ~ "\n" ~ "              " ~ aux);
}

void error(string msg)
{
    throw new Exception(msg);
}

void act()
{
    char c = bf[bfIdx];
    //printf("Handling char: %c\n", c);
    switch(c)
    {
        case '>':
            if (arrayIdx + 1 >= array.length)
            {
                error("overflow at char >", "try using --memory with a value greater than " ~ to!string(array.length));
            }
            ++arrayIdx;
            break;
        case '<':
            if (arrayIdx == 0)
            {
                error("underflow at char <");
            }
            --arrayIdx;
            break;
        case '+':
            ++array[arrayIdx];
            break;
        case '-':
            --array[arrayIdx];
            break;
        case '.':
            putchar(array[arrayIdx]);
            break;
        case ',':
            array[arrayIdx] = cast(char)getchar();
            break;
        case '[':
            size_t open;
            size_t start = bfIdx;
            size_t end;
            if (!bf.balancedParens('[', ']'))
                error("unmatched [");
            foreach (i; bfIdx .. bf.length)
            {
                if (bf[i] == '[') open++;
                else if (bf[i] == ']') open--;
                if (open == 0)
                {
                    end = i;
                    break;
                }
            }
            //writefln("%s %s %s %s", bfIdx, bf[bfIdx], end, bf[end]);
            while (array[arrayIdx])
            {
                while (bfIdx++ < end)
                {
                    act();
                }
                bfIdx = start;
            }
            bfIdx = end;
            break;
        default:
            break;
    }
        
}

int realmain(string[] args)
{
    int exit;
    void showHelp()
    {
        exit = 1;
        stderr.writefln("Usage: %s [options] <file>", args[0]);
        stderr.writeln("Options:");
        stderr.writeln("   --help              Print this help message");
        stderr.writeln("   --memory=<number>   Memory to allocate. Defaults to 30000.");
    }
    getopt(args,
            "help", &showHelp,
            "memory", (string option, string value)
                      {
                          size_t mem = to!size_t(value);
                          if (mem < 1)
                          {
                            stderr.writeln("error: available memory must be > 0");
                            exit = 1;
                          }
                          array.length = mem;
                      }
        );
    if (exit)
        return exit;

    if (args.length != 2)
    {
        showHelp();
        return 1;
    }

    if (!array)
        array.length = 30_000;
    array[] = 0;

    bf = readText(args[1]);

    for (; bfIdx < bf.length; bfIdx++)
    {
        act();
    }

    return 0;
}

int main(string[] args)
{
    try
    {
        return realmain(args);
    }
    catch (Exception e)
    {
        size_t line, character;
        getLocation(line, character);
        if (line)
            stderr.writefln("error(%s, %s): %s", line, character, e.msg);
        else
            stderr.writefln("error: %s", e.msg);
        return 1;
    }
}
