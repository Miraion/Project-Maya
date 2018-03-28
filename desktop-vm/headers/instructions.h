//
// Created by Jeremy S on 2018-03-18.
//

#pragma once

#include "instruction_t.h"

/**
 * Instruction: load
 *
 * Opcode: 0x10
 *
 * Operands: reg_c, imm
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: load.<m> <imm>, <reg_c>
 *
 * Loads a set amount of bytes from memory at a specific
 * address supplied by a literal. The number of bytes
 * loaded depends on the modifier.
 */
void instr_load(struct instruction_data *);

/**
 * Instruction: lfm (Load From Memory)
 *
 * Opcode: 0x11
 *
 * Operands: reg_b, reg_c
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: lfm.<m> <reg_b>, <reg_c>
 *
 * Similar to load, but the memory address is supplied by
 * the value in the reg_b operand.
 */
void instr_lfm(struct instruction_data *);

/**
 * Instruction: store
 *
 * Opcode: 0x12
 *
 * Operands: reg_c, imm
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: store.<m> <reg_c>, <imm>
 *
 * Stores the value in reg_c into memory at an address
 * supplied by a literal. The complement instruction to
 * load.
 */
void instr_store(struct instruction_data *);

/**
 * Instruction: stm (Store To Memory)
 *
 * Opcode: 0x13
 *
 * Operands: reg_b, reg_c
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: stm.<m> <reg_b>, <reg_c>
 *
 * The complement instruction to lfm. Stores the value
 * in reg_b into memory at the address co-responding to
 * the value of reg_c.
 */
void instr_stm(struct instruction_data *);

/**
 * Instruction: move
 *
 * Opcode: 0x14
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: move.<m> <reg_b>, <reg_c>
 *
 * Moves the fixed width integer denoted by the modifier
 * from reg_b to reg_c. If the moved value will be
 * truncated if needed,
 */
void instr_move(struct instruction_data *);

/**
 * Instruction: set
 *
 * Opcode: 0x15
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: set.<m> <imm>, <reg_c>
 *
 * Sets the value of reg_c to a given immediate.
 */
void instr_set(struct instruction_data *);

/**
 * Instruction: add
 *
 * Opcode: 0x20
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: add.<m> <reg_a>, <reg_b>, <reg_c>
 *
 * Adds the the value of reg_a to the value in reg_b
 * and stores the result in reg_c.
 */
void instr_add(struct instruction_data *);

/**
 * Instruction: sub
 *
 * Opcode: 0x21
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: sub.<m> <reg_a>, <reg_b>, <reg_c>
 *
 * Subtracts the value in reg_b from the value in reg_a
 * and stores the result in reg_c.
 */
void instr_sub(struct instruction_data *);

/**
 * Instruction: mul (Integer Multiply)
 *
 * Opcode: 0x22
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: mul.<m> <reg_a>, <reg_b>, <reg_c>
 *
 * Multiplies the the value of reg_a to the value in
 * reg_b and stores the result in reg_c.
 */
void instr_mul(struct instruction_data *);

/**
 * Instruction: div (Integer Divide)
 *
 * Opcode: 0x23
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: div.<m> <reg_a>, <reg_b>, <reg_c>
 *
 * Divides the value in reg_a by the value in reg_b
 * storing the result in reg_c.
 */
void instr_div(struct instruction_data *);

/**
 * Instruction: neg (Integer Negate)
 *
 * Opcode: 0x24
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: neg.<m> <reg_b>, <reg_c>
 *
 * Negates the value in reg_b and stores the result
 * in reg_c. This instruction does not preform sign
 * extension. i.e. neg.b(0x1) -> 0xff where as
 * neg.w(0x1) -> 0xffff. If sign extension is needed,
 * use neg.q to negate the value as a quad word.
 */
void instr_neg(struct instruction_data *);

/**
 * Instruction: inc (Integer Increment)
 *
 * Opcode: 0x25
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: inc.<m> <imm>, <reg_c>
 *
 * Increments reg_c by a given value.
 */
void instr_inc(struct instruction_data *);

/**
 * Instruction: dec (Integer Decrement)
 *
 * Opcode: 0x26
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: dec.<m> <imm>, <reg_c>
 *
 * Decrements reg_c by a given value.
 */
void instr_dec(struct instruction_data *);

/**
 * Instruction: zero
 *
 * Opcode: 0x27
 *
 * Modifiers: none
 *
 * Asm. Format: zero <reg_c>
 *
 * Sets reg_c to zero.
 */
void instr_zero(struct instruction_data *);

/**
 * Instruction: and (Bitwise And)
 *
 * Opcode: 0x28
 *
 * Modifiers: b/w/l/a
 *
 * Asm. Format: and.<m> <reg_a>, <reg_b>, <reg_c>
 *
 * Computes a bitwise and using the values or reg_a
 * and reg_b then stores the result in reg_c.
 */
void instr_and(struct instruction_data *);

/**
 * Instruction: or (Bitwise Or)
 *
 * Opcode: 0x29
 *
 * Modifiers: b/w/l/a
 *
 * Asm. Format: or.<m> <reg_a>, <reg_b>, <reg_c>
 *
 * Computes a bitwise or using the values or reg_a
 * and reg_b then stores the result in reg_c.
 */
void instr_or(struct instruction_data *);

/**
 * Instruction: xor (Bitwise Xor)
 *
 * Opcode: 0x2a
 *
 * Modifiers: b/w/l/a
 *
 * Asm. Format: xor.<m> <reg_a>, <reg_b>, <reg_c>
 *
 * Computes a bitwise xor using the values or reg_a
 * and reg_b then stores the result in reg_c.
 */
void instr_xor(struct instruction_data *);

/**
 * Instruction: not (Bitwise Not)
 *
 * Opcode: 0x2b
 *
 * Modifiers: b/w/l/a
 *
 * Asm. Format: not.<m> <reg_b>, <reg_c>
 *
 * Computes the bitwise not (complement) of reg_b
 * and stores the result in reg_c.
 */
void instr_not(struct instruction_data *);

/**
 * Instruction: mod
 *
 * Opcode: 0x40
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: mod.<m> <reg_a>, <reg_b>, <reg_c>
 *
 * Equivalent to: reg_c = reg_a % reg_b
 */
void instr_mod(struct instruction_data *);

/**
 * Instruction: call (Subroutine Call)
 *
 * Opcode: 0x30
 *
 * Modifiers: none
 *
 * Asm. Format: call <label>
 *
 * Calls a subroutine located at a given label.
 */
void instr_call(struct instruction_data *);

/**
 * Instruction: ret (Subroutine Return)
 *
 * Opcode: 0x31
 *
 * Modifiers: none
 *
 * Asm. Format: ret
 *
 * Returns from a called subroutine.
 */
void instr_ret(struct instruction_data *);

/**
 * Instruction: syscall (System Call)
 *
 * Opcode: 0x32
 *
 * Modifiers: none
 *
 * Asm. Format syscall
 *
 * Triggers a system call. The value of rx will determine
 * what happens and the values in r0 through r9 are used
 * as parameters for the system call if needed.
 */
void instr_syscall(struct instruction_data *);

/**
 * Instruction: la (Load Address)
 *
 * Opcode: 0x33
 *
 * Modifiers: none
 *
 * Asm. Format: la <label>, <reg_c>
 *
 * Loads the absolute address denoted by a given label
 * and stores it in reg_c.
 */
void instr_la(struct instruction_data *);

/**
 * Instruction: testz (Test For Zero)
 *
 * Opcode: 0x34
 *
 * Modifiers: none
 *
 * Asm. Format: testz <reg_c>
 *
 * Sets the zero flag if the value in reg_c is zero.
 */
void instr_testz(struct instruction_data *);

/**
 * Instruction: cmp (Compare)
 *
 * Opcode: 0x35
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: cmp.<m> <reg_b>, <reg_c>
 *
 * Sets flags based on the subtraction reg_b - reg_c.
 */
void instr_cmp(struct instruction_data *);

/**
 * Instruction: push (Stack Push)
 *
 * Opcode: 0x36
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: push.<m> <reg_c>
 *
 * Pushes the value of reg_c onto the call stack,
 * decrementing rs by the size of the value to
 * be pushed (e.g. push.l -> decrements by 4).
 */
void instr_push(struct instruction_data *);

/**
 * Instruction: pop (Stack Pop)
 *
 * Opcode: 0x37
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: pop.<m> <reg_c>
 *
 * Pops a given integer type off the call stack
 * and increments rs by the size of the integer
 * type.
 */
void instr_pop(struct instruction_data *);

/**
 * Instruction: call* (Indirect Subroutine Call)
 *
 * Opcode: 0x38
 *
 * Modifiers: none
 *
 * Asm. Format: call* <reg_c>
 *
 * Calls a subroutine located at a given address which
 * is stored in reg_c as a 64-bit value.
 */
void instr_indirect_call(struct instruction_data *);


/**
 * Instruction: lea (Load Effective Address)
 *
 * Opcode: 0x39
 *
 * Modifiers: b/w/l/q
 *
 * Asm. Format: lea.<m> <reg_a>, <reg_b>, <reg_c>
 *
 * Used for fast multiplication and loading address
 * offsets. reg_a holds the base pointer, reg_b
 * contains the offset amount, and the modifier is
 * the stride length (b = 1, w = 2, l = 4, q = 8).
 * The resultant address is stored in reg_c.
 *
 * Equivalent to the following:
 *      reg_c := reg_a + (reg_b * m)
 */
void instr_lea(struct instruction_data *);

/**
 * Instruction: jmp (Jump)
 *
 * Opcode: 0x60
 *
 * Modifiers: none
 *
 * Asm. Format: jmp <label>
 *
 * Preforms an unconditional jump to a given
 * label.
 */
void instr_jmp(struct instruction_data *);

/**
 * Instruction: Conditional Jump
 *
 * Opcode: 0x61 - 0x6e
 *
 * Modifiers: none
 *
 * Asm. Format: j* <label>
 *
 * Jumps to a given label if specific flags
 * are set. See botton of instructions.c for
 * conditional flags.
 *
 * The g/l jumps are for signed comparisons
 * while the a/b jumps are for unsigned
 * comparisons.
 */
void instr_je(struct instruction_data *);
void instr_jne(struct instruction_data *);
void instr_js(struct instruction_data *);
void instr_jns(struct instruction_data *);
void instr_jo(struct instruction_data *);
void instr_jno(struct instruction_data *);
void instr_jg(struct instruction_data *);
void instr_jge(struct instruction_data *);
void instr_jl(struct instruction_data *);
void instr_jle(struct instruction_data *);
void instr_ja(struct instruction_data *);
void instr_jae(struct instruction_data *);
void instr_jb(struct instruction_data *);
void instr_jbe(struct instruction_data *);
