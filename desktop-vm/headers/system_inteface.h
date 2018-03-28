//
// Created by Jeremy S on 2018-03-21.
//

#pragma once

#include <unistd.h>
#include "virtual_cpu.h"

typedef void(*system_interface)(int, vpu_t);

void system_call(int, ...);

enum system_commands {
    sys_exit    = 0x0001,   // r0: err_code
    sys_read    = 0x0003,   // r0: fd, r1: buf, r2: size
    sys_write   = 0x0004,   // r0: fd, r1: buf, r2: size
    sys_open    = 0x0005,   // r0: filename, r1: flags, r2: mode
    sys_close   = 0x0006,   // r0: fd

    usr_malloc  = 0x8000,   // r0: count
    usr_free    = 0x8001,   // r0: ptr
    dbg_vpudec  = 0xc000,
    dbg_vpuhex  = 0xc001,
    dbg_stack   = 0xc002,   // r0: count
};

/**
 * Interprets a system call by wrapping around the C library.
 */
void desktop_system_interface(int x, vpu_t vpu);
