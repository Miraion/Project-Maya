//
// Created by Jeremy S on 2018-03-17.
//
#pragma once

typedef int error_t;

#define ERROR_NULL                  0
#define ERROR_FILE                  1
#define ERROR_EOF                   2
#define ERROR_INVALID_INSTRUCTION   3
#define ERROR_DEFAULT               4

#define EC_SEGFAULT 11
#define EC_DIVZERO  12
#define EC_BADFREE  13

/**
 * Terminates the program because of a segmentation
 * fault. Prints a message to stderr saying such.
 *
 * Is also used as the handler for SIGSEGV signals
 * from the OS.
 *
 * The integer parameter is unused.
 */
void segmentation_fault_handler(int);

/**
 * Prints a message to stderr before terminating the
 * program with a given exit code.
 */
void fatal_error(const char *msg, int exit_code);


/**
 * Terminates the program because an attempt to free
 * unallocated memory was made.
 */
void bad_free(void *p);


/**
 * Displays all un-freed pointers stored in the
 * mem_log set.
 */
void mem_log_display_leaks();
