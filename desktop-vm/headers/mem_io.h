//
// Created by Jeremy S on 2018-03-18.
//

#pragma once

#include "types.h"

/**
 * Loads a given integer type from memory and returns it.
 *
 * Any segfault errors resulting from calling this function
 * will be handled by the segfault handler which should have
 * been initialized at the start of the program.
 */
integer_t memload(void *, modifier_t);

/**
 * Stores a given integer type into memory.
 *
 * Like memload, any segfault errors resulting from calling
 * this function will be handled by the segfault handler.
 */
void memstore(void *, integer_t, modifier_t);
