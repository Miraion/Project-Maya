//
// Created by Jeremy S on 2018-03-18.
//

#include "../headers/macro.h"
#include "../headers/instructions.h"
#include "../headers/operations.h"
#include "../headers/mem_io.h"
#include "../headers/init.h"

void instr_load(struct instruction_data *data) {
    void *address = (void *) data->imm.q + data->vpu->PC;
    reg_setm(data->reg_c, memload(address, data->modifier), data->modifier);
}


void instr_lfm(struct instruction_data *data) {
    void *address = (void *) reg_get_quad(data->reg_b);
    reg_setm(data->reg_c, memload(address, data->modifier), data->modifier);
}


void instr_store(struct instruction_data *data) {
    void *address = (void *) data->imm.q + data->vpu->PC;
    memstore(address, reg_get(data->reg_c, data->modifier), data->modifier);
}


void instr_stm(struct instruction_data *data) {
    void *address = (void *) reg_get_quad(data->reg_c);
    memstore(address, reg_get(data->reg_b, data->modifier), data->modifier);
}


void instr_move(struct instruction_data *data) {
    reg_setm(data->reg_c, reg_get(data->reg_b, data->modifier), data->modifier);
}


void instr_set(struct instruction_data *data) {
    reg_setm(data->reg_c, data->imm, data->modifier);
}


void instr_add(struct instruction_data *data) {
    integer_t result = reg_add(data->reg_a, data->reg_b, data->modifier, data->f_complex);
    reg_setm(data->reg_c, result, data->modifier);
}


void instr_sub(struct instruction_data *data) {
    integer_t result = reg_sub(data->reg_a, data->reg_b, data->modifier, data->f_complex);
    reg_setm(data->reg_c, result, data->modifier);
}


void instr_mul(struct instruction_data *data) {
    integer_t result = reg_mul(data->reg_a, data->reg_b, data->modifier, data->f_complex);
    reg_setm(data->reg_c, result, data->modifier);
}


void instr_div(struct instruction_data *data) {
    integer_t result = reg_div(data->reg_a, data->reg_b, data->modifier, data->f_complex);
    reg_setm(data->reg_c, result, data->modifier);
}


void instr_neg(struct instruction_data *data) {
    integer_t op = reg_get(data->reg_b, data->modifier);
    integer_t result;
    switch (data->modifier) {
    case byte_m:
        result.b = (uint8_t) -((int8_t) op.b) ;
        break;
    case word_m:
        result.w = (uint16_t) -((int16_t) op.w) ;
        break;
    case long_m:
        result.l = (uint32_t) -((int32_t) op.l) ;
        break;
    case quad_m:
        result.q = (uint64_t) -((int64_t) op.q) ;
        break;
    default:
        result.q = 0;
        break;
    }
    reg_setm(data->reg_c, result, data->modifier);
}


void instr_inc(struct instruction_data *data) {
    integer_t result = reg_add(data->reg_c,
                               (vreg_t) &data->imm,
                               data->modifier,
                               data->f_complex);
    reg_setm(data->reg_c, result, data->modifier);
}


void instr_dec(struct instruction_data *data) {
    integer_t result = reg_sub(data->reg_c,
                               (vreg_t) &data->imm,
                               data->modifier,
                               data->f_complex);
    reg_setm(data->reg_c, result, data->modifier);
}


void instr_zero(struct instruction_data *data) {
    reg_set(data->reg_c, 0);
}


void instr_and(struct instruction_data *data) {
    integer_t result;
    switch (data->modifier) {
    case byte_m:
        result.b = reg_get_byte(data->reg_a) & reg_get_byte(data->reg_b);
        break;
    case word_m:
        result.w = reg_get_word(data->reg_a) & reg_get_word(data->reg_b);
        break;
    case long_m:
        result.l = reg_get_long(data->reg_a) & reg_get_long(data->reg_b);
        break;
    case quad_m:
        result.q = reg_get_quad(data->reg_a) & reg_get_quad(data->reg_b);
        break;
    default:
        result.q = 0;
        break;
    }
    reg_setm(data->reg_c, result, data->modifier);
}


void instr_or(struct instruction_data *data) {
    integer_t result;
    switch (data->modifier) {
    case byte_m:
        result.b = reg_get_byte(data->reg_a) | reg_get_byte(data->reg_b);
        break;
    case word_m:
        result.w = reg_get_word(data->reg_a) | reg_get_word(data->reg_b);
        break;
    case long_m:
        result.l = reg_get_long(data->reg_a) | reg_get_long(data->reg_b);
        break;
    case quad_m:
        result.q = reg_get_quad(data->reg_a) | reg_get_quad(data->reg_b);
        break;
    default:
        result.q = 0;
        break;
    }
    reg_setm(data->reg_c, result, data->modifier);
}


void instr_xor(struct instruction_data *data) {
    integer_t result;
    switch (data->modifier) {
    case byte_m:
        result.b = reg_get_byte(data->reg_a) ^ reg_get_byte(data->reg_b);
        break;
    case word_m:
        result.w = reg_get_word(data->reg_a) ^ reg_get_word(data->reg_b);
        break;
    case long_m:
        result.l = reg_get_long(data->reg_a) ^ reg_get_long(data->reg_b);
        break;
    case quad_m:
        result.q = reg_get_quad(data->reg_a) ^ reg_get_quad(data->reg_b);
        break;
    default:
        result.q = 0;
        break;
    }
    reg_setm(data->reg_c, result, data->modifier);
}


void instr_not(struct instruction_data *data) {
    integer_t result;
    switch (data->modifier) {
    case byte_m:
        result.b = ~reg_get_byte(data->reg_b);
        break;
    case word_m:
        result.w = ~reg_get_word(data->reg_b);
        break;
    case long_m:
        result.l = ~reg_get_long(data->reg_b);
        break;
    case quad_m:
        result.q = ~reg_get_quad(data->reg_b);
        break;
    default:
        result.q = 0;
        break;
    }
    reg_setm(data->reg_c, result, data->modifier);
}


void instr_mod(struct instruction_data *data) {
    integer_t result = reg_mod(data->reg_a, data->reg_b, data->modifier, data->f_complex);
    reg_setm(data->reg_c, result, data->modifier);
}


void instr_call(struct instruction_data *data) {
    reg_set(data->vpu->rs, reg_get_quad(data->vpu->rs) - 8);
    *((uint64_t *) reg_get_quad(data->vpu->rs)) = data->vpu->PC;
    data->vpu->PC += data->imm.q;
}


void instr_ret(struct instruction_data *data) {
    integer_t x = memload((void *) reg_get_quad(data->vpu->rs), quad_m);
    data->vpu->PC = x.q;
    reg_set(data->vpu->rs, reg_get_quad(data->vpu->rs) + 8);
}


void instr_syscall(struct instruction_data *data) {
    global_system_interface((int) reg_get_word(data->vpu->rx), data->vpu);
}


void instr_la(struct instruction_data *data) {
    reg_set(data->reg_c, data->imm.q + data->vpu->PC);
}


void instr_testz(struct instruction_data *data) {
    data->f_complex->ZF = reg_get_quad(data->reg_c) == 0;
}


void instr_cmp(struct instruction_data *data) {
    reg_sub(data->reg_b, data->reg_c, data->modifier, data->f_complex);
}


void instr_push(struct instruction_data *data) {
    reg_set(data->vpu->rs, reg_get_quad(data->vpu->rs) - data->modifier);
    memstore((void *) reg_get_quad(data->vpu->rs),
             reg_get(data->reg_c, data->modifier),
             data->modifier);
}


void instr_pop(struct instruction_data *data) {
    integer_t x = memload((void *) reg_get_quad(data->vpu->rs), data->modifier);
    reg_set(data->vpu->rs, reg_get_quad(data->vpu->rs) + data->modifier);

    reg_setm(data->reg_c, x, data->modifier);
}


void instr_indirect_call(struct instruction_data *data) {
    reg_set(data->vpu->rs, reg_get_quad(data->vpu->rs) - 8);
    *((uint64_t *) reg_get_quad(data->vpu->rs)) = data->vpu->PC;
    data->vpu->PC = reg_get_quad(data->reg_c);
}


uint64_t leab(uint64_t a, uint64_t b) {
    uint64_t c;
    asm(
    "leaq (%1, %2, 1), %0"
    : "=r" (c)
    : "r" (a), "r" (b)
    );
    return c;
}


uint64_t leaw(uint64_t a, uint64_t b) {
    uint64_t c;
    asm(
    "leaq (%1, %2, 2), %0"
    : "=r" (c)
    : "r" (a), "r" (b)
    );
    return c;
}


uint64_t leal(uint64_t a, uint64_t b) {
    uint64_t c;
    asm(
    "leaq (%1, %2, 4), %0"
    : "=r" (c)
    : "r" (a), "r" (b)
    );
    return c;
}


uint64_t leaq(uint64_t a, uint64_t b) {
    uint64_t c;
    asm(
    "leaq (%1, %2, 8), %0"
    : "=r" (c)
    : "r" (a), "r" (b)
    );
    return c;
}


void instr_lea(struct instruction_data *data) {
    switch (data->modifier) {
    case byte_m:
        reg_set(data->reg_c, leab(reg_get_quad(data->reg_a), reg_get_quad(data->reg_b)));
        break;

    case word_m:
        reg_set(data->reg_c, leaw(reg_get_quad(data->reg_a), reg_get_quad(data->reg_b)));
        break;

    case long_m:
        reg_set(data->reg_c, leal(reg_get_quad(data->reg_a), reg_get_quad(data->reg_b)));
        break;

    case quad_m:
        reg_set(data->reg_c, leaq(reg_get_quad(data->reg_a), reg_get_quad(data->reg_b)));
        break;

    default:
        break;
    }
}


void instr_jmp(struct instruction_data *data) {
    data->vpu->PC += data->imm.q;
}


#define CONDITIONAL_JUMP(NAME, CONDITION)                           \
void TOKENPASTE(instr_, NAME) (struct instruction_data *data) {     \
    struct flag_complex *flags = &data->vpu->flags;                    \
    if ( CONDITION ) {                                              \
        data->vpu->PC += data->imm.q;                               \
    }                                                               \
}


CONDITIONAL_JUMP(je, flags->ZF);
CONDITIONAL_JUMP(jne, !flags->ZF);
CONDITIONAL_JUMP(js, flags->SF);
CONDITIONAL_JUMP(jns, !flags->SF);
CONDITIONAL_JUMP(jo, flags->OF);
CONDITIONAL_JUMP(jno, !flags->OF);
CONDITIONAL_JUMP(jg, !(flags->SF ^ flags->OF) && !flags->ZF);
CONDITIONAL_JUMP(jge, !(flags->SF ^ flags->OF));
CONDITIONAL_JUMP(jl, flags->SF ^ flags->OF);
CONDITIONAL_JUMP(jle, (flags->SF ^ flags->OF) || flags->ZF);
CONDITIONAL_JUMP(ja, !flags->CF && !flags->ZF);
CONDITIONAL_JUMP(jae, !flags->CF);
CONDITIONAL_JUMP(jb, flags->CF);
CONDITIONAL_JUMP(jbe, flags->CF || flags->ZF);
