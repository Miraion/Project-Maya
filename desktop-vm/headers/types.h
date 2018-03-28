//
// Created by Jeremy S on 2018-03-16.
//

#pragma once

#include <inttypes.h>
#include <stdbool.h>


#define nullptr 0


/**
 * Fixed-Width Integer Type Modifier Enumeration
 *
 * Used along with the below integer_t union to
 * preform generic computation with virtual registers.
 *
 * The raw values of the enumeration constants refer
 * to the number of bytes each type takes up.
 *
 * Functions that take a modifier_t argument are not
 * defined for any other integer input besides those
 * defined in the enumeration.
 */
typedef enum {
    byte_m = 1, word_m = 2, long_m = 4, quad_m = 8
} modifier_t;


/**
 * Decodes a byte into a modifier type. The function
 * mapping is like so:
 *
 * 1 -> byte_m
 * 2 -> word_m
 * 3 -> long_m
 * 4 -> quad_m
 *
 * Otherwise undefined.
 */
modifier_t as_modifier(int);


/**
 * Generic Integer Type Union
 *
 * A type that is used to store the value of some
 * fixed-width integer. This type is the primary type
 * used to interface with the virtual registers when
 * preforming computations and such.
 */
typedef union {
    uint8_t  b;
    uint16_t w;
    uint32_t l;
    uint64_t q;
} integer_t;


/**
 * Optional Integer
 *
 * A data type that may or may not store an
 * integer_t. If a value is present, then the
 * valid attribute will be true and the value
 * attribute will contain the value. If not then
 * the valid attribute will be set to false and
 * value will contain a garbage value.
 */
typedef struct {
    integer_t value;
    bool is_nil;
} optional_integer;

/**
 * Creates an optional_integer that does not contain
 * a valid value (i.e. the valid attribute is false).
 *
 * @return: An optional_integer object set to nil.
 */
optional_integer nil_integer();

/**
 * Creates an optional_integer that contains a given
 * value. The optional's valid attribute is set to
 * true and the given value is stored in the value
 * attribute.
 *
 * This function takes a 64-bit integer as an argument
 * but any other integer type will work as it will be
 * automatically up-cast and stored in the integer_t
 * union.
 *
 * @param value: The value of the optional.
 * @return: An optional_integer that contains a value.
 */
optional_integer make_integer(uint64_t value);
