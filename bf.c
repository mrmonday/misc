/**
 * A rather stupid brainfuck interpreter
 * Seems to work for all programs I've tested.
 *
 * Copyright (C) Robert Clipsham <robert@octarineparrot.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
 */
#include <assert.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char array[30000];
char *p = array;

char *bf;
size_t bfLength;

// TODO Line/character numbers
void error(char *msg)
{
    fprintf(stderr, "%s\n", msg);
}

int act(char c)
{
    int open = 0;
    char newc;
    char *start = bf;
    char *end = bf;

    //printf("Handling char: %c\n", c);
    switch(c)
    {
        case '>':
            if (p + 1 >= array + 30000)
            {
                error("overflow at char >");
                return 1;
            }
            ++p;
            break;
        case '<':
            if (p - 1 < array)
            {
                error("underflow at char <");
                return 1;
            }
            --p;
            break;
        case '+':
            ++*p;
            break;
        case '-':
            --*p;
            break;
        case '.':
            putchar(*p);
            break;
        case ',':
            *p = getchar();
            break;
        case '[':
            while ((newc = *end++) != ']' || open)
            {
                if (newc == '[') open++;
                if (newc == ']') open--;
            }
            while (*p)
            {
                while (bf < end)
                {
                    if (act(*bf++))
                        return 1;
                }
                bf = start;
            }
            bf = end;
            break;
        default:
            break;
    }
    return 0;
}

// Returns != 0 on failure
int read_file(const char *f)
{
    FILE *file = fopen(f, "r");
    if (file == NULL)
    {
        perror("Unable to open file");
        return 1;
    }
    fseek(file, 0, SEEK_END);
    bfLength = ftell(file);
    bf = malloc(bfLength);
    if (bf == NULL)
    {
        fprintf(stderr, "Memory error\n");
        return 1;
    }
    rewind(file);

    if (fread(bf, 1, bfLength, file) != bfLength)
    {
        perror("Unable to read file");
        return 1;
    }
    fclose(file);
    return 0;
}

int main(int argc, const char *argv[])
{
    if (argc != 2)
    {
        fprintf(stderr, "Usage: %s <file>\n", argv[0]);
        return 1;
    }
    if (read_file(argv[1]))
        return 1;
    for (int i = 0; i < bfLength; i++)
    {
        if (act(*bf++))
            return 1;
    }
    return 0;
}
