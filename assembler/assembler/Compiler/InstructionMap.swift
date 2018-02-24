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
    
    instructionMap["setq"] = (0x36, TokenExtractionFormat(.register, .literal), .imm64)
    instructionMap["setl"] = (0x37, TokenExtractionFormat(.register, .literal), .imm32)
    instructionMap["setw"] = (0x38, TokenExtractionFormat(.register, .literal), .imm16)
    instructionMap["setb"] = (0x39, TokenExtractionFormat(.register, .literal), .imm8)
    
    instructionMap["inc"] = (0x31, TokenExtractionFormat(.register), .unary)
    instructionMap["dec"] = (0x32, TokenExtractionFormat(.register), .unary)
    instructionMap["mov"] = (0x33, TokenExtractionFormat(.register, .register), .binary)
    
    instructionMap["syscall"] = (0x42, TokenExtractionFormat(), .void)
    instructionMap["la"] = (0x45, TokenExtractionFormat(.keyword, .register), .binaryAddrFirst)
    
    instructionMap["jmp"] = (0x60, TokenExtractionFormat(.keyword), .unaryAddr)
}
