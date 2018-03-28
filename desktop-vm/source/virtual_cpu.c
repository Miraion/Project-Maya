//
// Created by Jeremy S on 2018-03-15.
//

#include <stdlib.h>
#include <stdio.h>
#include "../headers/virtual_cpu.h"

vpu_t vpu_init() {
    vpu_t v = (vpu_t) malloc(sizeof(struct virtual_processing_unit));
    v->__reg_complex_base = (struct virtual_register *)
            malloc(sizeof(struct virtual_register) * 16);
    for (int i = 0; i < sizeof(struct virtual_register) * 16; ++i) {
        *((uint8_t *) v->__reg_complex_base) = 0;
    }
    v->r0 = &v->__reg_complex_base[0];
    v->r1 = &v->__reg_complex_base[1];
    v->r2 = &v->__reg_complex_base[2];
    v->r3 = &v->__reg_complex_base[3];
    v->r4 = &v->__reg_complex_base[4];
    v->r5 = &v->__reg_complex_base[5];
    v->r6 = &v->__reg_complex_base[6];
    v->r7 = &v->__reg_complex_base[7];
    v->r8 = &v->__reg_complex_base[8];
    v->r9 = &v->__reg_complex_base[9];
    v->ra = &v->__reg_complex_base[10];
    v->rb = &v->__reg_complex_base[11];
    v->rc = &v->__reg_complex_base[12];
    v->rd = &v->__reg_complex_base[13];
    v->rs = &v->__reg_complex_base[14];
    v->rx = &v->__reg_complex_base[15];
    v->flags.CF = false;
    v->flags.ZF = false;
    v->flags.SF = false;
    v->flags.OF = false;
    v->PC = 0;
    return v;
}

void vpu_delete(vpu_t v) {
    free(v->__reg_complex_base);
    free(v);
}

void print_vpu(vpu_t vpu) {
    vreg_t *as_register_array = (vreg_t *) vpu;
    for (int i = 0; i < 16; ++i) {
        if (i < 10) {
            printf("r%d: ", i);
        } else {
            if (i < 14) {
                printf("r%c: ", (i - 10) + 'a');
            } else {
                if (i == 14) {
                    printf("rs: ");
                } else {
                    printf("rx: ");
                }
            }
        }
        print_register_state_big_endian(as_register_array[i]);
    }

    printf("CF = %d, OF = %d, ZF = %d, SF = %d\n",
           vpu->flags.CF, vpu->flags.OF, vpu->flags.ZF, vpu->flags.SF);
    printf("PC = %lx\n", (unsigned long) vpu->PC);
}
