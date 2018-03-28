//
// Created by Jeremy S on 2018-03-18.
//

#include "../headers/instruction_t.h"
#include "../headers/instructions.h"

struct i_list_complex instruction_list[256];

struct i_list_complex make_list_complex(i_function f, enum i_encoding_type e) {
    struct i_list_complex c;
    c.function = f;
    c.type = e;
    return c;
}

void run_instruction(instruction *instr, vpu_t vpu) {
    struct instruction_data data;
    data.reg_c = register_from_index(instr->reg_c_idx, vpu);
    data.reg_a = register_from_index(instr->reg_a_idx, vpu);
    data.reg_b = register_from_index(instr->reg_b_idx, vpu);
    data.imm = instr->imm;
    data.modifier = instr->modifier;
    data.vpu = vpu;
    data.f_complex = &vpu->flags;
    instr->run(&data);
}

vreg_t register_from_index(reg_index idx, vpu_t vpu) {
    vreg_t *vpu_as_reg_array = (vreg_t *) vpu;
    return vpu_as_reg_array[idx];
}


void instruction_list_init() {
    // Set all types to be invalid to start.
    // This will let us know if we attempt to
    // execute an invalid instruction.
    for (int i = 0; i < 256; ++i) {
        instruction_list[i].type = i_invalid;
    }

    instruction_list[0x10] = make_list_complex(instr_load, i_unary_addr);
    instruction_list[0x11] = make_list_complex(instr_lfm, i_binary);
    instruction_list[0x12] = make_list_complex(instr_store, i_unary_addr);
    instruction_list[0x13] = make_list_complex(instr_stm, i_binary);
    instruction_list[0x14] = make_list_complex(instr_move, i_binary);
    instruction_list[0x15] = make_list_complex(instr_set, i_unary_imm);
    instruction_list[0x20] = make_list_complex(instr_add, i_ternary);
    instruction_list[0x21] = make_list_complex(instr_sub, i_ternary);
    instruction_list[0x22] = make_list_complex(instr_mul, i_ternary);
    instruction_list[0x23] = make_list_complex(instr_div, i_ternary);
    instruction_list[0x24] = make_list_complex(instr_neg, i_binary);
    instruction_list[0x25] = make_list_complex(instr_inc, i_unary_imm);
    instruction_list[0x26] = make_list_complex(instr_dec, i_unary_imm);
    instruction_list[0x27] = make_list_complex(instr_zero, i_unary);
    instruction_list[0x28] = make_list_complex(instr_and, i_ternary);
    instruction_list[0x29] = make_list_complex(instr_or, i_ternary);
    instruction_list[0x2a] = make_list_complex(instr_xor, i_ternary);
    instruction_list[0x2b] = make_list_complex(instr_not, i_binary);
    instruction_list[0x40] = make_list_complex(instr_mod, i_ternary);

    instruction_list[0x30] = make_list_complex(instr_call, i_addr);
    instruction_list[0x31] = make_list_complex(instr_ret, i_void);
    instruction_list[0x32] = make_list_complex(instr_syscall, i_void);
    instruction_list[0x33] = make_list_complex(instr_la, i_unary_addr);
    instruction_list[0x34] = make_list_complex(instr_testz, i_unary);
    instruction_list[0x35] = make_list_complex(instr_cmp, i_binary);
    instruction_list[0x36] = make_list_complex(instr_push, i_unary);
    instruction_list[0x37] = make_list_complex(instr_pop, i_unary);
    instruction_list[0x38] = make_list_complex(instr_indirect_call, i_unary);
    instruction_list[0x39] = make_list_complex(instr_lea, i_ternary);

    instruction_list[0x60] = make_list_complex(instr_jmp, i_addr);
    instruction_list[0x61] = make_list_complex(instr_je, i_addr);
    instruction_list[0x62] = make_list_complex(instr_jne, i_addr);
    instruction_list[0x63] = make_list_complex(instr_js, i_addr);
    instruction_list[0x64] = make_list_complex(instr_jns, i_addr);
    instruction_list[0x65] = make_list_complex(instr_jo, i_addr);
    instruction_list[0x66] = make_list_complex(instr_jno, i_addr);
    instruction_list[0x67] = make_list_complex(instr_jg, i_addr);
    instruction_list[0x68] = make_list_complex(instr_jge, i_addr);
    instruction_list[0x69] = make_list_complex(instr_jl, i_addr);
    instruction_list[0x6a] = make_list_complex(instr_jle, i_addr);
    instruction_list[0x6b] = make_list_complex(instr_ja, i_addr);
    instruction_list[0x6c] = make_list_complex(instr_jae, i_addr);
    instruction_list[0x6d] = make_list_complex(instr_jb, i_addr);
    instruction_list[0x6e] = make_list_complex(instr_jbe, i_addr);
}
