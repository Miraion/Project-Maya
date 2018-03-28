//
// Created by Jeremy S on 2018-03-16.
//

#pragma once

#include <stdbool.h>
#include "types.h"
#include "virtual_register.h"
#include "virtual_cpu.h"


/**
 * Operation With Flags Functions
 *
 * Preforms an specific integer operation on given operands
 * an passes back the result along with the state of the
 * internal CPU flags after the operation is preformed.
 *
 * These functions are implemented in x86-64 assembly and
 * are optimized to give the best efficiency possible by
 * minimizing the number of memory accesses when computing
 * the result and the state of the flags.
 *
 * Note for multiplication of bytes:
 * x86-64 does not support this operation on single bytes.
 * We will support such an operation on single bytes; however,
 * since there is no way to get the state of the flags after
 * the operation, these functions will be implemented in C
 * with only the zero flag being set after the operation.
 *
 * Note for division and modulo:
 * The functions are writen in C and will only set the zero
 * flag based on the result of the operation. This may change
 * at a later date, but that is how it is for now.
 *
 * Argument Format:
 * (1) operand:         int_t
 * (2) operand:         int_t
 * (3) result:          int_t *
 * (4) flags:           struct flag_complex *
 */

#define OPERATION_WITH_FLAGS_ARG(TYPE) (TYPE a, TYPE b, TYPE * result, struct flag_complex *flags)

// Addition Operations
void adding_with_flags_byte OPERATION_WITH_FLAGS_ARG(uint8_t);
void adding_with_flags_word OPERATION_WITH_FLAGS_ARG(uint16_t);
void adding_with_flags_long OPERATION_WITH_FLAGS_ARG(uint32_t);
void adding_with_flags_quad OPERATION_WITH_FLAGS_ARG(uint64_t);

// Subtraction Operations
void subtracting_with_flags_byte OPERATION_WITH_FLAGS_ARG(uint8_t);
void subtracting_with_flags_word OPERATION_WITH_FLAGS_ARG(uint16_t);
void subtracting_with_flags_long OPERATION_WITH_FLAGS_ARG(uint32_t);
void subtracting_with_flags_quad OPERATION_WITH_FLAGS_ARG(uint64_t);

// Multiplication Operations
void multiplying_with_flags_byte OPERATION_WITH_FLAGS_ARG(uint8_t);
void multiplying_with_flags_word OPERATION_WITH_FLAGS_ARG(uint16_t);
void multiplying_with_flags_long OPERATION_WITH_FLAGS_ARG(uint32_t);
void multiplying_with_flags_quad OPERATION_WITH_FLAGS_ARG(uint64_t);

// Division Operations
void dividing_with_flags_byte OPERATION_WITH_FLAGS_ARG(uint8_t);
void dividing_with_flags_word OPERATION_WITH_FLAGS_ARG(uint16_t);
void dividing_with_flags_long OPERATION_WITH_FLAGS_ARG(uint32_t);
void dividing_with_flags_quad OPERATION_WITH_FLAGS_ARG(uint64_t);

// Modulo Operations
void modulo_with_flags_byte OPERATION_WITH_FLAGS_ARG(uint8_t);
void modulo_with_flags_word OPERATION_WITH_FLAGS_ARG(uint16_t);
void modulo_with_flags_long OPERATION_WITH_FLAGS_ARG(uint32_t);
void modulo_with_flags_quad OPERATION_WITH_FLAGS_ARG(uint64_t);



/**
 * Generic Register Operations
 *
 * These functions preform integer arithmetic operations
 * between two virtual registers. The modifier_t argument is
 * used to determine which integer types to preform the
 * operation on. The flag complex pointer should point to a
 * flag_complex structure located within the VPU core where
 * the operand registers are located. Co-responding flags are
 * set based on the result of the computation.
 *
 * The value of the argument registers is not overridden. The
 * result is returned as an integer_t union.
 */

integer_t reg_add(vreg_t, vreg_t, modifier_t, struct flag_complex *);
integer_t reg_sub(vreg_t, vreg_t, modifier_t, struct flag_complex *);
integer_t reg_mul(vreg_t, vreg_t, modifier_t, struct flag_complex *);
integer_t reg_div(vreg_t, vreg_t, modifier_t, struct flag_complex *);
integer_t reg_mod(vreg_t, vreg_t, modifier_t, struct flag_complex *);
