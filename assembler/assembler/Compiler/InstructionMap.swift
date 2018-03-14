//
//  InstructionMap.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-22.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

/// Enumeration of all valid encoding formats.
enum EncodingType {
    case void
    case unary;     case binary;    case ternay
    case unaryAddr; case binaryAddrFirst; case binaryAddrLast
    case imm
}

/// Map of instruction syntax definitions to 8-bit opcode, token extraction format, and encoding format.
fileprivate(set) var instructionMap = [String : (opc: UInt8, extractionFormat: TokenExtractionFormat, encodingFormat: EncodingType)]()

/**
 Initializes the global `instructionMap` variable.
 
 - warning: This function may only be called once per program execution.
 */
func initInstructionMap() {
    
    instructionMap["load"] = (0x10, TokenExtractionFormat(.modifier, .keyword, .register), .binaryAddrFirst)
    instructionMap["lfm"] = (0x11, TokenExtractionFormat(.modifier, .register, .register), .binary)
    instructionMap["store"] = (0x12, TokenExtractionFormat(.modifier, .keyword, .register), .binaryAddrFirst)
    instructionMap["stm"] = (0x13, TokenExtractionFormat(.modifier, .register, .register), .binary)
    instructionMap["move"] = (0x14, TokenExtractionFormat(.modifier, .register, .register), .binary)
    instructionMap["set"] = (0x15, TokenExtractionFormat(.modifier, .literal, .register), .imm)
    
    instructionMap["add"] = (0x20, TokenExtractionFormat(.modifier, .register, .register, .register), .ternay)
    instructionMap["sub"] = (0x21, TokenExtractionFormat(.modifier, .register, .register, .register), .ternay)
    instructionMap["mul"] = (0x22, TokenExtractionFormat(.modifier, .register, .register, .register), .ternay)
    instructionMap["div"] = (0x23, TokenExtractionFormat(.modifier, .register, .register, .register), .ternay)
    instructionMap["neg"] = (0x24, TokenExtractionFormat(.modifier, .register, .register), .binary)
    
    instructionMap["inc"] = (0x25, TokenExtractionFormat(.modifier, .literal, .register), .imm)
    instructionMap["dec"] = (0x26, TokenExtractionFormat(.modifier, .literal, .register), .imm)
    instructionMap["zero"] = (0x27, TokenExtractionFormat(.register), .unary)
    instructionMap["and"] = (0x28, TokenExtractionFormat(.modifier, .register, .register, .register), .ternay)
    instructionMap["or"]  = (0x29, TokenExtractionFormat(.modifier, .register, .register, .register), .ternay)
    instructionMap["xor"] = (0x2a, TokenExtractionFormat(.modifier, .register, .register, .register), .ternay)
    instructionMap["not"] = (0x2b, TokenExtractionFormat(.modifier, .register, .register), .binary)
    instructionMap["shl"] = (0x2c, TokenExtractionFormat(.modifier, .register, .register, .register), .ternay)
    instructionMap["shr"] = (0x2d, TokenExtractionFormat(.modifier, .register, .register, .register), .ternay)
    instructionMap["sal"] = (0x2e, TokenExtractionFormat(.modifier, .register, .register, .register), .ternay)
    instructionMap["sar"] = (0x2f, TokenExtractionFormat(.modifier, .register, .register, .register), .ternay)
    instructionMap["mod"] = (0x40, TokenExtractionFormat(.modifier, .register, .register, .register), .ternay)
    
    instructionMap["call"] = (0x30, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["ret"] = (0x31, TokenExtractionFormat(), .void)
    instructionMap["syscall"] = (0x32, TokenExtractionFormat(), .void)
    instructionMap["la"] = (0x33, TokenExtractionFormat(.keyword, .register), .binaryAddrFirst)
    instructionMap["testz"] = (0x34, TokenExtractionFormat(.register), .unary)
    instructionMap["cmp"] = (0x35, TokenExtractionFormat(.modifier, .register, .register), .binary)
    instructionMap["push"] = (0x36, TokenExtractionFormat(.modifier, .register), .unary)
    instructionMap["pop"] = (0x37, TokenExtractionFormat(.modifier, .register), .unary)
    
    instructionMap["jmp"] = (0x60, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["je"]  = (0x61, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jz"]  = (0x61, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jne"] = (0x62, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jnz"] = (0x62, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["js"]  = (0x63, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jns"] = (0x64, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jo"]  = (0x65, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jno"] = (0x66, TokenExtractionFormat(.keyword), .unaryAddr)
    
    instructionMap["jg"]    = (0x67, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jnle"]  = (0x67, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jge"]   = (0x68, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jnle"]  = (0x68, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jl"]    = (0x69, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jnge"]  = (0x69, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jle"]   = (0x6a, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jng"]   = (0x6a, TokenExtractionFormat(.keyword), .unaryAddr)
    
    instructionMap["ja"]    = (0x6b, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jnbe"]  = (0x6b, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jae"]   = (0x6c, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jnbe"]  = (0x6c, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jb"]    = (0x6d, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jnae"]  = (0x6d, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jbe"]   = (0x6e, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["jna"]   = (0x6e, TokenExtractionFormat(.keyword), .unaryAddr)
    
}
