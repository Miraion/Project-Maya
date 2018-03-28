//
// Created by Jeremy S on 2018-03-16.
//

#include "../headers/types.h"

optional_integer nil_integer() {
    optional_integer byte;
    byte.is_nil = true;
    return byte;
}

optional_integer make_integer(uint64_t value) {
    optional_integer integer;
    integer.value.q = value;
    integer.is_nil = false;
    return integer;
}

modifier_t as_modifier(int x) {
    switch (x) {
    case 1: return byte_m;
    case 2: return word_m;
    case 3: return long_m;
    case 4: return quad_m;
    default: return (modifier_t) 0;
    }
}
