//
// Created by Jeremy S on 2018-03-23.
//

#include "../headers/fetch.h"
#include "../headers/types.h"
#include "../headers/instruction_t.h"

void fetch(instruction *instr, binary_stream *stream, vpu_t vpu) {
    optional_integer optional_opcode = extract(stream, byte_m);
    stream->error = ERROR_NULL;

    // Get opcode, mark error and return in extraction results in nil.
    if (optional_opcode.is_nil) {
        stream->error = ERROR_EOF;
        return;
    }

    // Get instruction data for opcode, mark error and return if opcode
    // does not match an instruction.
    uint8_t opcode = optional_opcode.value.b;
    struct i_list_complex instruction_complex = instruction_list[opcode];
    if (instruction_complex.type == i_invalid) {
        stream->error = ERROR_INVALID_INSTRUCTION;
        return;
    }

    // Create instruction by extracting operands based on the instruction
    // type. If extraction results in nil at any point, mark an error and
    // return. Also increment the program counter based on the size of the
    // instruction.
    instr->run = instruction_complex.function;
    optional_integer operand_byte_alpha;
    optional_integer operand_byte_beta;
    optional_integer operand_immediate;

    switch (instruction_complex.type) {

    // Void type instructions have no operands so just increment the program counter.
    case i_void:
        ++vpu->PC;
        break;

    // Unary type instructions take an extra byte which contains the modifier and
    // a register id (reg_c). Size = 2 bytes.
    case i_unary:
        vpu->PC += 2;
        operand_byte_alpha = extract(stream, byte_m);
        if (operand_byte_alpha.is_nil) {
            stream->error = ERROR_EOF;
            return;
        } else {
            instr->modifier = as_modifier((operand_byte_alpha.value.b >> 4) & 0x0f);
            instr->reg_c_idx = (reg_index) (operand_byte_alpha.value.b & 0x0f);
            break;
        }

    // Binary type instructions take two extra bytes. The first byte is the same as
    // the unary type and the second byte contains the id for reg_b in the lower 4
    // bits. Size = 3 bytes.
    case i_binary:
        vpu->PC += 3;
        operand_byte_alpha = extract(stream, byte_m);
        operand_byte_beta = extract(stream, byte_m);
        if (operand_byte_alpha.is_nil || operand_byte_beta.is_nil) {
            stream->error = ERROR_EOF;
            return;
        } else {
            instr->modifier = as_modifier((operand_byte_alpha.value.b >> 4) & 0x0f);
            instr->reg_c_idx = (reg_index) (operand_byte_alpha.value.b & 0x0f);
            instr->reg_b_idx = (reg_index) (operand_byte_beta.value.b & 0x0f);
            break;
        }


    // Ternary type instructions take two bytes as well. The third register id is
    // encoded in the upper 4 bits for byte 2. Size = 3.
    case i_ternary:
        vpu->PC += 3;
        operand_byte_alpha = extract(stream, byte_m);
        operand_byte_beta = extract(stream, byte_m);
        if (operand_byte_alpha.is_nil || operand_byte_beta.is_nil) {
            stream->error = ERROR_EOF;
            return;
        } else {
            instr->modifier = as_modifier((operand_byte_alpha.value.b >> 4) & 0x0f);
            instr->reg_c_idx = (reg_index) (operand_byte_alpha.value.b & 0x0f);
            instr->reg_a_idx = (reg_index) ((operand_byte_beta.value.b >> 4) & 0x0f);
            instr->reg_b_idx = (reg_index) (operand_byte_beta.value.b & 0x0f);
            break;
        }


    // Address type instructions only contain a 8 byte address with no modifies.
    // Size = 9.
    case i_addr:
        vpu->PC += 9;
        operand_immediate = extract(stream, quad_m);
        if (operand_immediate.is_nil) {
            stream->error = ERROR_EOF;
            return;
        } else {
            instr->imm = operand_immediate.value;
            break;
        }


    // Unary Address type instructions are similar to Address type functions but
    // the also contain a register in their first byte.
    case i_unary_addr:
        vpu->PC += 10;
        operand_byte_alpha = extract(stream, byte_m);
        operand_immediate = extract(stream, quad_m);
        if (operand_byte_alpha.is_nil || operand_immediate.is_nil) {
            stream->error = ERROR_EOF;
            return;
        } else {
            instr->modifier = as_modifier((operand_byte_alpha.value.b >> 4)  & 0x0f);
            instr->reg_c_idx = (reg_index) (operand_byte_alpha.value.b & 0x0f);
            instr->imm = operand_immediate.value;
            break;
        }


    // Unary Immediate type instructions contain a modifier and register pair in
    // the first byte just like the regular Unary type, but they have a variable
    // sized immediate after them. The size of the immediate is determined by the
    // modifier so it is decoded first then the immediate is extracted.
    case i_unary_imm:
        ++vpu->PC; // for the opcode
        operand_byte_alpha = extract(stream, byte_m);
        ++vpu->PC; // for the modifier and reg_c
        if (operand_byte_alpha.is_nil) {
            stream->error = ERROR_EOF;
            return;
        } else {
            instr->modifier = as_modifier((operand_byte_alpha.value.b >> 4) & 0x0f);
            instr->reg_c_idx = (reg_index) (operand_byte_alpha.value.b & 0x0f);
            operand_immediate = extract(stream, instr->modifier);
            vpu->PC += instr->modifier; // for the immediate
            if (operand_immediate.is_nil) {
                stream->error = ERROR_EOF;
                return;
            }
            instr->imm = operand_immediate.value;
            break;
        }


    default:
        break;
    }
}
