//
// Created by Jeremy S on 2018-03-18.
//

#pragma once

#include "system_inteface.h"
#include "set.h"

/**
 * This file contains various functions that initialize parts
 * of the virtual machine. All of these functions must be call
 * prior to the main body of the program.
 */


/**
 * The function that will be called to exit the program being
 * run by the virtual machine.
 */
extern void(*global_exit_func)(int);


/**
 * This function is used during syscall instructions to interface
 * with the system. On desktop, this function wraps around the
 * x86-64 syscall instruction. However on iPad this function will
 * have to interface with the runtime app.
 */
extern system_interface global_system_interface;


/**
 * A collection addresses that have been allocated with the malloc
 * system call. If memory-log mode is enabled, upon program finish
 * any memory leaks will be reported.
 */
extern set *mem_log;


/**
 * When set to true, the main execution loop will begin the clean
 * shutdown procedure.
 */
extern bool begin_exit_proc;


/**
 * The exit code for the program when preforming a clean shutdown.
 */
extern int exit_code;


/**
 * Initializes the functions that are used to capture signals
 * like segmentation faults and such. We want to handle such
 * cases natively as when running the VM on the iPad we don't
 * want the app to crash when a segmentation fault occurs.
 */
void init_signal_handlers();

/**
 * Sets the global exit function variable to be a given function.
 * On desktop this will be the exit(int) function. On the iPad
 * version this will have to be some special function that
 * interfaces with the custom kernel. We'll figure out how that
 * will work once we get to that point.
 */
void init_error_handlers(void(*exit_func)(int));


/**
 * Sets teh global system interface function to a given function.
 */
void init_system_interface(system_interface);


/**
 * Initializes the memory log set.
 */
void init_memory_log();
