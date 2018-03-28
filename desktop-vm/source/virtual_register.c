//
// Created by Jeremy S on 2018-03-15.
//

#include <stdio.h>
#include <stdlib.h>
#include "../headers/virtual_register.h"

vreg_t reg_init() {
    vreg_t reg = (vreg_t ) malloc(sizeof(struct virtual_register));
    reg_set_null(reg);
    return reg;
}

void reg_delete(vreg_t vr) {
    free(vr);
}


void print_register_state_little_endian(vreg_t vr) {
    for (int i = 0; i < 8; ++i) {
        printf("%02x ", vr->data[i]);
    }
    putchar('\n');
}


void print_register_state_big_endian(vreg_t vr) {
    for (int i = 8; i != 0; --i) {
        printf("%02x ", vr->data[i - 1]);
    }
    putchar('\n');
}


void reg_set_null(vreg_t vr) {
    *((uint64_t *) vr->data) = 0;
}

void reg_set_byte(vreg_t vr, uint8_t value) {
    *((uint64_t *) vr->data) = value;
}

void reg_set_word(vreg_t vr, uint16_t value) {
    *((uint64_t *) vr->data) = value;
}

void reg_set_long(vreg_t vr, uint32_t value) {
    *((uint64_t *) vr->data) = value;
}

void reg_set_quad(vreg_t vr, uint64_t value) {
    *((uint64_t *) vr->data) = value;
}

void reg_set_floatsp(vreg_t vr, float value) {
    reg_set_null(vr);
    *((float *) vr->data) = value;
}

void reg_set_floatdp(vreg_t vr, double value) {
    reg_set_null(vr);
    *((double *) vr->data) = value;
}


uint8_t reg_get_byte(vreg_t vr) {
    return *((uint8_t *) vr->data);
}

uint16_t reg_get_word(vreg_t vr) {
    return *((uint16_t *) vr->data);
}

uint32_t reg_get_long(vreg_t vr) {
    return *((uint32_t *) vr->data);
}

uint64_t reg_get_quad(vreg_t vr) {
    return *((uint64_t *) vr->data);
}

float reg_get_floatsp(vreg_t vr) {
    return  *((float *) vr->data);
}

double reg_get_floatdp(vreg_t vr) {
    return  *((double *) vr->data);
}

integer_t reg_get(vreg_t vr, modifier_t modifier) {
    integer_t rt;
    switch (modifier) {
    case byte_m:
        rt.b = reg_get_byte(vr);
        return rt;
    case word_m:
        rt.w = reg_get_word(vr);
        return rt;
    case long_m:
        rt.l = reg_get_long(vr);
        return rt;
    case quad_m:
        rt.q = reg_get_quad(vr);
        return rt;
    default:
        rt.q = 0;
        return rt;
    }
}

void reg_set(vreg_t vr, uint64_t value) {
    reg_set_quad(vr, value);
}

void reg_setm(vreg_t vr, integer_t value, modifier_t modifier) {
    switch(modifier) {
    case byte_m:
        reg_set(vr, (uint64_t) value.b);
        break;
    case word_m:
        reg_set(vr, (uint64_t) value.w);
        break;
    case long_m:
        reg_set(vr, (uint64_t) value.l);
        break;
    case quad_m:
        reg_set(vr, (uint64_t) value.q);
        break;
    default:
        break;
    }
}
