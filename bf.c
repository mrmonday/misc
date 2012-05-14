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

char *array;
int array_length = 30000;
char *p;

char *bf;
char *bf_start;
size_t bf_length;

static void get_location(size_t *line, size_t *character)
{
    *line = 1;
    char *cursor = bf_start;
    char *last_line = cursor;
    for (; cursor < bf; cursor++)
    {
        if (*cursor == '\n')
        {
            (*line)++;
            last_line = cursor + 1;
        }
    }
    *character = bf - last_line;
}

static void error_aux(const char *msg, const char *aux)
{
    size_t line, character;
    get_location(&line, &character);
    fprintf(stderr, "error(%zu, %zu): %s\n", line, character, msg);
    if (aux != NULL)
    {
        fprintf(stderr, "              %s\n", aux);
    }
}

static void error(const char *msg)
{
    error_aux(msg, NULL);
}

static int act(char c)
{
    int open = 0;
    char newc;
    char *start = bf;
    char *end = bf;

    //printf("Handling char: %c\n", c);
    switch(c)
    {
        case '>':
            if (p + 1 >= array + array_length)
            {
                char try[128];
                sprintf(try, "try using --memory with a value greater than %d", array_length);
                error_aux("overflow at char >", try);
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
                if (newc == '\0')
                {
                    error("unmatched [");
                    return 1;
                }
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
static int read_file(const char *f)
{
    FILE *file = fopen(f, "r");
    if (file == NULL)
    {
        perror("Unable to open file");
        return 1;
    }
    fseek(file, 0, SEEK_END);
    bf_length = ftell(file);
    bf = malloc(bf_length + 1);
    if (bf == NULL)
    {
        fprintf(stderr, "Memory error\n");
        return 1;
    }
    rewind(file);

    if (fread(bf, 1, bf_length, file) != bf_length)
    {
        perror("Unable to read file");
        return 1;
    }
    fclose(file);
    bf[bf_length] = '\0';
    bf_start = bf;
    return 0;
}

static int show_help(const char *program_name)
{
    fprintf(stderr, "Usage: %s [options] <file>\n", program_name);
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "   --help              Print this help message\n");
    fprintf(stderr, "   --memory=<number>   Memory to allocate. Defaults to 30000.\n");
    return 1;
}

static int alloc_memory(void)
{
    array = malloc(array_length);
    if (array == NULL)
    {
        fprintf(stderr, "Memory error\n");
        return 1;
    }
    p = array;
    return 0;
}

int main(int argc, const char *argv[])
{
    if (argc > 3 || argc < 2)
        return show_help(argv[0]);
    
    if (argc >= 2)
    {
        if (strcmp(argv[1], "--help") == 0) return show_help(argv[0]);
        else if (strncmp(argv[1], "--memory=", 9) == 0)
        {
            if (argc != 3)
            {
                return show_help(argv[0]);
            }
            int memory = atoi(argv[1] + 9);
            if (memory < 1)
            {
                fprintf(stderr, "error: available memory must be > 0\n");
                return 1;
            }
            array_length = memory;
        }
    }

    if (alloc_memory()) return 1;

    if (read_file(argv[argc == 2 ? 1 : 2]))
        return 1;
    for (size_t i = 0; i < bf_length; i++)
    {
        if (act(*bf++))
            return 1;
    }
    return 0;
}
