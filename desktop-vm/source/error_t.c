//
// Created by Jeremy S on 2018-03-17.
//

#include "../headers/error_t.h"
#include "../headers/init.h"
#include "../headers/set.h"
#include <stdio.h>
#include <stdlib.h>

void segmentation_fault_handler(int signo) {
    fprintf(stderr, "Segmentation Fault - Terminating program with exit code 11.\n");
    global_exit_func(EC_SEGFAULT);
}

void fatal_error(const char *msg, int exit_code) {
    fprintf(stderr, "Fatal Error - %s.\n", msg);
    global_exit_func(exit_code);
}

void bad_free(void *p) {
    fprintf(stderr, "Memory Log: Critical Error - Bad free at %p.\n", p);
}


void __mem_log_print_leak(void *p) {
    printf("Memory Log: Leak - %p\n", p);
}

void mem_log_display_leaks() {
    if (mem_log->count == 0) {
        printf("\nMemory Log: No leaks detected.\n");
    } else {
        printf("\nMemory Log: %ld leak%sdetected.\n",
               mem_log->count,
               mem_log->count == 1 ? " " : "s ");
        set_traverse(mem_log, __mem_log_print_leak);
    }
}
