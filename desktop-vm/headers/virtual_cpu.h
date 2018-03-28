//
// Created by Jeremy S on 2018-03-15.
//

#pragma once

#include <stdbool.h>
#include "virtual_register.h"

/**
 * Data structure that represents a series of cpu flags
 * which are represented by boolean values.
 */
struct flag_complex {
    bool CF;
    bool OF;
    bool ZF;
    bool SF;
};


/**
 * Data structure that represents a virtual cpu.
 *
 * Each object contains 16 pointers to virtual registers
 * along with 4 flags and a program counter which is
 * represented by a 64-bit integer.
 */
struct virtual_processing_unit {

              /* --- registers --- */
    vreg_t r0;  vreg_t r1;  vreg_t r2;  vreg_t r3;
    vreg_t r4;  vreg_t r5;  vreg_t r6;  vreg_t r7;
    vreg_t r8;  vreg_t r9;  vreg_t ra;  vreg_t rb;
    vreg_t rc;  vreg_t rd;  vreg_t rs;  vreg_t rx;

              /* ----- flags ----- */
    struct flag_complex flags;

    uint64_t PC;

    // For optimal caching, all the registers are located
    // in the same chunk of memory which this pointer is
    // pointing to.
    struct virtual_register *__reg_complex_base;

};

/**
 * As with vreg_t, vpu_t refers to a pointer to the
 * virtual_processing_unit structure.
 */
typedef struct virtual_processing_unit *vpu_t;


/**
 * Creates a new virtual_processing_unit object on the
 * free store, initializing each of its registers and
 * other attributes, and returns a pointer to it.
 *
 * @return A pointer to the vpu object.
 */
vpu_t vpu_init();

/**
 * Frees a pointer to a virtual_processing_unit object
 * that was created using vpu_init(). This includes
 * calling reg_delete() on each of the objects's registers.
*/
void vpu_delete(vpu_t);

/**
 * Displays the state of a vpu for debugging.
 */
void print_vpu(vpu_t);
