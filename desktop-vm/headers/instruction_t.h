//
// Created by Jeremy S on 2018-03-18.
//

#pragma once

#include "types.h"
#include "virtual_register.h"
#include "virtual_cpu.h"

typedef uint8_t reg_index;


enum i_encoding_type {
    i_void, i_unary, i_binary, i_ternary, i_unary_imm, i_addr, i_unary_addr, i_invalid
};


/**
 * A data structure that holds the raw data that is used when
 * executing an instruction. Any given instruction will not
 * use all of the attributes defined in this structure.
 */
struct instruction_data {
    vreg_t reg_a;
    vreg_t reg_b;
    vreg_t reg_c;
    integer_t imm;
    modifier_t modifier;
    struct flag_complex *f_complex;
    vpu_t vpu;
};


typedef void(*i_function)(struct instruction_data *);


/**
 * A data structure that represents a pair of instruction
 * function and the encoding type of the instruction.
 */
struct i_list_complex {
    i_function function;
    enum i_encoding_type type;
};


struct i_list_complex make_list_complex(i_function, enum i_encoding_type);


/**
 * A list of all of the instructions in the form of functions.
 * Each instruction is indexed by its opcode. For example, the
 * 'add' instruction (opcode 0x20) is located at index 32 (0x20).
 *
 * There are 256 possible instructions as each opcode is 1 byte.
 */
extern struct i_list_complex instruction_list[256];


/**
 * A data structure to represent an instruction to be executed.
 * The register index variables hold values that will be mapped
 * onto actual register objects once the cpu that will run the
 * instruction is determined.
 */
typedef struct {
    reg_index reg_a_idx;
    reg_index reg_b_idx;
    reg_index reg_c_idx;
    integer_t imm;
    modifier_t modifier;
    i_function run;
} instruction;


/**
 * Initializes the global instruction_list array by filling
 * in the co-responding functions with their designated
 * opcodes.
 */
void instruction_list_init();


/**
 * Runs a given instruction on a given cpu. The data from
 * the instruction object is translated into an instruction
 * data object and passed to the instruction's run function.
 *
 * Running the instruction will affect the state of the given
 * cpu whether it be modifying registers, setting flags, or
 * incrementing the program counter. The reason for passing
 * the cpu as a parameter is so that multiprocessing can be
 * implemented easier in the future.
 *
 * @param instr: The instruction to run.
 * @param vpu: The cpu to run the instruction on.
 */
void run_instruction(instruction *instr, vpu_t vpu);


/**
 * Returns a pointer to the register object which relates to
 * a given register index. This is done with no branches by
 * treating the virtual processing unit structure as an array
 * of register pointers.
 *
 * The function is not defined for any indices larger than 15.
 */
vreg_t register_from_index(reg_index idx, vpu_t vpu);
