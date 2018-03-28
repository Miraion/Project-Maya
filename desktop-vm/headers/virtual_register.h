//
// Created by Jeremy S on 2018-03-15.
//

#pragma once

#include <inttypes.h>
#include "types.h"

/**
 * Data structure representing a 64-bit register
 * capable of storing integer and floating point values.
 *
 * Integer values are stored in a little endian format.
 */
struct virtual_register {
    uint8_t data[8];
};

/**
 * The vreg_t refers to a pointer to a virtual register
 * structure and not the actual structure itself.
 */
typedef struct virtual_register *vreg_t;

/**
 * Creates a new virtual_register object on the free store,
 * setting its initial state to 0 and returning a pointer
 * to it.
 *
 * @return A pointer to the newly object.
 */
vreg_t reg_init();

/**
 * Frees a pointer to a virtual_register object that was
 * created with reg_init();
 */
void reg_delete(vreg_t);

/**
 * Prints the current state of a given register in hex.
 *
 * State is printed in a little endian format like so:
 *          xx xx xx xx xx xx xx xx
 *
 * Example: register state = 0x1234
 * print:   34 12 00 00 00 00 00 00
 */
void print_register_state_little_endian(vreg_t);

/**
 * Prints the current state of a given register in hex.
 *
 * State is printed in big endian format.
 */
void print_register_state_big_endian(vreg_t);

/**
 * Sets all the bits in a given register to 0.
 */
void reg_set_null(vreg_t);

/**
 *              --- State Manipulation ---
 *
 * Sets the state of a given register to a given value.
 *
 * Setting the state will blow away any previous state
 * in the register even if setting a smaller type.
 *
 * For example, a register with the current state:
 *          01 00 03 00 a0 ff ff ff
 * calling reg_set_byte(&reg, 0xff) will set the state
 * of the register to be:
 *          ff 00 00 00 00 00 00 00
 *
 * This allows for easy up-scaling of integer types as
 * it is guaranteed that the upper bits will be 0.
 */
void reg_set_byte(vreg_t, uint8_t);
void reg_set_word(vreg_t, uint16_t);
void reg_set_long(vreg_t, uint32_t);
void reg_set_quad(vreg_t, uint64_t);
void reg_set_floatsp(vreg_t, float);
void reg_set_floatdp(vreg_t, double);

/**
 *                  --- Getters ---
 *
 * Returns the value of a given register as a specific
 * type. If the state of the register is larger than the
 * requested type, the value will be truncated.
 */
uint8_t reg_get_byte(vreg_t);
uint16_t reg_get_word(vreg_t);
uint32_t reg_get_long(vreg_t);
uint64_t reg_get_quad(vreg_t);
float reg_get_floatsp(vreg_t);
double reg_get_floatdp(vreg_t);


/**
 * A generalization of the above getter functions for
 * the integer types. Function is defined for all of
 * the modifier types defined in the modifier_t enum.
 *
 * @return The state of the register as an integer_t.
 */
integer_t reg_get(vreg_t, modifier_t);

/**
 * A simple setter for a virtual register which takes
 * any integer type as an argument. Since the current
 * state of a register is completely blown away when
 * setting the state to a new value, it is perfectly
 * safe to up-cast a smaller integer type before
 * storing it in the register.
 */
void reg_set(vreg_t, uint64_t);

/**
 * A more complex setter for a virtual register. This
 * setter ensures that the upper unused bits of the
 * register are 0 when storing a smaller value. Use
 * this setter when working with integer_t objects and
 * use the above one when working with literals and
 * regular integer types.
 */
void reg_setm(vreg_t, integer_t, modifier_t);
