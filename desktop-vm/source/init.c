//
// Created by Jeremy S on 2018-03-18.
//

#include "../headers/init.h"
#include "../headers/types.h"
#include "../headers/error_t.h"
#include <signal.h>

void(*global_exit_func)(int) = nullptr;

system_interface global_system_interface = nullptr;

set *mem_log = nullptr;

bool begin_exit_proc = false;

int exit_code = 0;

void init_signal_handlers() {
    sigset(SIGSEGV, segmentation_fault_handler);
}

void init_error_handlers(void(*exit_func)(int)) {
    global_exit_func = exit_func;
}

void init_system_interface(system_interface f) {
    global_system_interface = f;
}

void init_memory_log() {
    mem_log = make_set(set_node_comparator);
}
