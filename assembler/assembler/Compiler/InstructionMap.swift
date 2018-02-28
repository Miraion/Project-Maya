//
//  InstructionMap.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-22.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

enum EncodingType {
    case void
    case unary;     case binary;    case ternay
    case unaryAddr; case binaryAddrFirst; case binaryAddrLast
    case imm64;     case imm32;     case imm16;     case imm8
//    case immFirst64;     case immFirst32;     case immFirst16;     case immFirst8
}

fileprivate(set) var instructionMap = [String : (opc: UInt8, extractionFormat: TokenExtractionFormat, encodingFormat: EncodingType)]()

func initInstructionMap() {
    
    instructionMap["add"] = (0x10, TokenExtractionFormat(.register, .register, .register), .ternay)
    instructionMap["sub"] = (0x11, TokenExtractionFormat(.register, .register, .register), .ternay)
    instructionMap["mul"] = (0x12, TokenExtractionFormat(.register, .register, .register), .ternay)
    instructionMap["div"] = (0x13, TokenExtractionFormat(.register, .register, .register), .ternay)
    instructionMap["neg"] = (0x14, TokenExtractionFormat(.register, .register), .binary)
    
    instructionMap["and"] = (0x20, TokenExtractionFormat(.register, .register, .register), .ternay)
    instructionMap["or"]  = (0x21, TokenExtractionFormat(.register, .register, .register), .ternay)
    instructionMap["xor"] = (0x22, TokenExtractionFormat(.register, .register, .register), .ternay)
    instructionMap["not"] = (0x23, TokenExtractionFormat(.register, .register), .binary)
    
    instructionMap["inc"] = (0x31, TokenExtractionFormat(.register), .unary)
    instructionMap["dec"] = (0x32, TokenExtractionFormat(.register), .unary)
    instructionMap["mov"] = (0x33, TokenExtractionFormat(.register, .register), .binary)
    instructionMap["push"] = (0x34, TokenExtractionFormat(.register), .unary)
    instructionMap["pop"] = (0x35, TokenExtractionFormat(.register), .unary)
    instructionMap["setq"] = (0x36, TokenExtractionFormat(.register, .literal), .imm64)
    instructionMap["setl"] = (0x37, TokenExtractionFormat(.register, .literal), .imm32)
    instructionMap["setw"] = (0x38, TokenExtractionFormat(.register, .literal), .imm16)
    instructionMap["setb"] = (0x39, TokenExtractionFormat(.register, .literal), .imm8)
    instructionMap["addq"] = (0x3a, TokenExtractionFormat(.literal, .register), .imm64)
    instructionMap["addl"] = (0x3b, TokenExtractionFormat(.literal, .register), .imm32)
    instructionMap["addw"] = (0x3c, TokenExtractionFormat(.literal, .register), .imm16)
    instructionMap["addb"] = (0x46, TokenExtractionFormat(.literal, .register), .imm8)
    instructionMap["subq"] = (0x3d, TokenExtractionFormat(.literal, .register), .imm64)
    instructionMap["subl"] = (0x3e, TokenExtractionFormat(.literal, .register), .imm32)
    instructionMap["subw"] = (0x3f, TokenExtractionFormat(.literal, .register), .imm16)
    instructionMap["subb"] = (0x47, TokenExtractionFormat(.literal, .register), .imm8)
    
    instructionMap["call"] = (0x40, TokenExtractionFormat(.keyword), .unaryAddr)
    instructionMap["ret"] = (0x41, TokenExtractionFormat(), .void)
    instructionMap["syscall"] = (0x42, TokenExtractionFormat(), .void)
    instructionMap["zero"] = (0x44, TokenExtractionFormat(.register), .unary)
    instructionMap["la"] = (0x45, TokenExtractionFormat(.keyword, .register), .binaryAddrFirst)
    
    instructionMap["cmp"] = (0x50, TokenExtractionFormat(.register, .register), .binary)
    
    instructionMap["testl"] = (0x53, TokenExtractionFormat(.register), .unary)
    instructionMap["testw"] = (0x54, TokenExtractionFormat(.register), .unary)
    instructionMap["testb"] = (0x55, TokenExtractionFormat(.register), .unary)
    instructionMap["testz"] = (0x56, TokenExtractionFormat(.register), .unary)
    
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
    
    instructionMap["lmq"] = (0x80, TokenExtractionFormat(.keyword, .register), .binaryAddrFirst)
    instructionMap["lml"] = (0x81, TokenExtractionFormat(.keyword, .register), .binaryAddrFirst)
    instructionMap["lmw"] = (0x82, TokenExtractionFormat(.keyword, .register), .binaryAddrFirst)
    instructionMap["lmb"] = (0x83, TokenExtractionFormat(.keyword, .register), .binaryAddrFirst)
    
    instructionMap["loadq"] = (0x88, TokenExtractionFormat(.register, .register), .binary)
    instructionMap["loadl"] = (0x89, TokenExtractionFormat(.register, .register), .binary)
    instructionMap["loadw"] = (0x8a, TokenExtractionFormat(.register, .register), .binary)
    instructionMap["loadb"] = (0x8b, TokenExtractionFormat(.register, .register), .binary)
    instructionMap["storeq"] = (0x8c, TokenExtractionFormat(.register, .register), .binary)
    instructionMap["storel"] = (0x8d, TokenExtractionFormat(.register, .register), .binary)
    instructionMap["storew"] = (0x8e, TokenExtractionFormat(.register, .register), .binary)
    instructionMap["storeb"] = (0x8f, TokenExtractionFormat(.register, .register), .binary)
    
}
