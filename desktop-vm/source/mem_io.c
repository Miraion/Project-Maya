//
// Created by Jeremy S on 2018-03-18.
//

#include <signal.h>
#include "../headers/mem_io.h"

integer_t memload(void *address, modifier_t modifier) {
    integer_t value;
    switch(modifier) {
    case byte_m:
        value.b = *((uint8_t *) address);
        break;
    case word_m:
        value.w = *((uint16_t *) address);
        break;
    case long_m:
        value.l = *((uint32_t *) address);
        break;
    case quad_m:
        value.q = *((uint64_t *) address);
        break;
    default:
        value.q = 0;
    }
    return value;
}

void memstore(void *address, integer_t value, modifier_t modifier) {
    switch(modifier) {
    case byte_m:
        *((uint8_t *) address) = value.b;
        break;
    case word_m:
        *((uint16_t *) address) = value.w;
        break;
    case long_m:
        *((uint32_t *) address) = value.l;
        break;
    case quad_m:
        *((uint64_t *) address) = value.q;
        break;
    default:
        break;
    }
}
