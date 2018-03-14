//
//  Compiler.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-23.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

/**
 Delegate responsable for compiling source files into binary.
 
 Contains an internal `Lexer` and `Parser` delegate which are responsable for parsing the souce file
 and prefoming preliminary syntax checking.
 */
class Compiler {
    
    private enum CompilerMode : String {
        case text = "text"
        case data = "data"
        case null = "null"
    }
    
    private var byteCount: Int = 0
    private var labelMap = [String : (bytePos: Int, isGlobal: Bool)]()
    private var unprocessedLabels = [String : [Int]]()
    private var mode: CompilerMode = .null
    
    
    func compile(file: String) throws -> ObjectFile {
        guard let istream = InputStream(file: file) else {
            throw AssemblerError.Default(msg: "Unable to open \(file).")
        }
        return try compile(stream: istream, filename: file)
    }
    
    
    /**
     Attempts to compile a source file with a given path into a binary object file.
     
     This method wraps around the lexing and parsing subsystems of the assembler, providing a simple
     way to compile a single source file.
     
     - invariant:
        Internal state is reset at the begining of each call meaning that it is safe to call this
        method on multiple files repeatedly with no side-effects.
     
     - parameter file: The path of the source file to be compiled.
     
     - returns: An `ObjectFile` object consisting of a compiled binary along with relavent metadata.
     
     - throws:
        Multiple types of errors depending on where the error originated. Errors from the `Parser`,
        `Lexer`, and `InputStream` classes propagate through this method.
     
     */
    func compile(stream istream: InputStream, filename: String) throws -> ObjectFile {
        let lexer = try Lexer(stream: istream)
        let parser = Parser(lexer: lexer)
        let ostream = BinaryStream()
        
        byteCount = 0
        labelMap.removeAll()
        unprocessedLabels.removeAll()
        mode = .null
        
        // Continue extracting packages from the parser until there are none left, or an error occurs.
        while let package = try parser.extract() {
            
            // Package will either start with an instruction or a keyword.
            
            // Handle packages that start with an instruction.
            if package.tokens.first?.type == .instruction {
                
                // Expand the package, retrieving the relevent instruction data from the global instruction
                // map. It is safe to unwrap these optionals because the parser has already checked if the
                // instruction and its operands are valid.
                let text = (package.tokens.first! as! Lexer.WordToken).text
                let tokenData = instructionMap[text]!
                let opcode = tokenData.opc
                let encodeFormat = tokenData.encodingFormat
                
                // Write out the opcode.
                ostream.append(byte: opcode)
                byteCount += 1
                
                // Write out the operands.
                switch (encodeFormat) {
                // No operands for a void type instruction.
                case .void: continue
                    
                // Write out a single register and modifier.
                case .unary:
                    var mod: UInt8 = 0
                    var idx = 0
                    if let m = encodeModifier(package.tokens[1]) {
                        mod = m
                        idx = 1
                    }
                    let reg = encodeRegister(package.tokens[idx + 1])!
                    let byte = ((mod << 4) & 0xf0) | (reg & 0x0f)
                    ostream.append(byte: byte)
                    byteCount += 1
                    
                // Write out 2 registers and a modifier.
                case .binary:
                    var mod: UInt8 = 0
                    var idx = 0
                    if let m = encodeModifier(package.tokens[1]) {
                        mod = m
                        idx = 1
                    }
                    let dst = encodeRegister(package.tokens[idx + 2])!
                    let src = encodeRegister(package.tokens[idx + 1])!
                    let b = dst | ((mod << 4) & 0xf0)
                    ostream.append(bytes:[b, src])
                    byteCount += 2
                
                // Write out 3 registers and a modifier.
                case .ternay:
                    var mod: UInt8 = 0
                    var idx = 0
                    if let m = encodeModifier(package.tokens[1]) {
                        mod = m
                        idx = 1
                    }
                    let dst = encodeRegister(package.tokens[idx + 3])!
                    let srcA = encodeRegister(package.tokens[idx + 1])!
                    let srcB = encodeRegister(package.tokens[idx + 2])!
                    let srcByte = srcB | ((srcA << 4) & 0xf0)
                    let dstByte = dst | ((mod << 4) & 0xf0)
                    ostream.append(bytes: [dstByte, srcByte])
                    byteCount += 2
                
                // Write out a 64-bit address.
                case .unaryAddr:
                    let addr = encodeAddress(package.tokens[1])
                    ostream.append(addr, as: UInt64.self)
                    byteCount += 8
                    
                // Write out a register and a 64-bit address.
                case .binaryAddrFirst:
                    var mod: UInt8 = 0
                    var idx = 0
                    if let m = encodeModifier(package.tokens[1]) {
                        mod = m
                        idx = 1
                    }
                    let reg = encodeRegister(package.tokens[idx + 2])!
                    let regByte = (reg & 0x0f) | ((mod << 4) & 0xf0)
                    byteCount += 1
                    let addr = encodeAddress(package.tokens[idx + 1])
                    ostream.append(byte: regByte)
                    ostream.append(addr, as: UInt64.self)
                    byteCount += 8
                    
                // Same write-out format as the above case, but the operands are in different locations within the package.
                case .binaryAddrLast:
                    let reg = encodeRegister(package.tokens[1])!
                    byteCount += 1
                    let addr = encodeAddress(package.tokens[2])
                    ostream.append(byte: reg)
                    ostream.append(addr, as: UInt64.self)
                    byteCount += 8
                    
                // Write out a register and a literal of a given size.
                // Here there is no fixed location for each operand in the package so we extract them
                // based on their type. The write-out format is the same none the less.
                case .imm:
                    guard let mod = encodeModifier(package.tokens[1]) else {
                        throw AssemblerError.ParserError(file: filename, line: lexer.lineNum, msg: "Invalid instruction modifier")
                    }
                    let reg = encodeRegister(package.tokens.first(where: { $0.type == .register })!)!
                    let imm = (package.tokens.first(where: { $0.type == .literal }) as! Lexer.ImmToken).value
                    let byte = reg | ((mod << 4) & 0xf0)
                    ostream.append(byte: byte)
                    byteCount += 1
                    switch (mod) {
                    case 1:
                        ostream.append(UInt8(truncatingIfNeeded: imm), as: UInt8.self)
                        byteCount += 1
                    case 2:
                        ostream.append(UInt16(truncatingIfNeeded: imm), as: UInt16.self)
                        byteCount += 2
                    case 3:
                        ostream.append(UInt32(truncatingIfNeeded: imm), as: UInt32.self)
                        byteCount += 4
                    case 4:
                        ostream.append(UInt64(truncatingIfNeeded: imm), as: UInt64.self)
                        byteCount += 8
                    default:
                        throw AssemblerError.Default(msg: "Invalid modifier code \(mod).")
                    }
                    
                } // switch (encode format)
                
            } // if package.tokens.first?.type == .instruction
            
            // Handle packages that start with a keyword.
            else if package.tokens.first?.type == .keyword {
                
                let text = (package.tokens.first! as! Lexer.WordToken).text
                // Ensure that the keyword is actually a 'keyword' and not a label or something else.
                // This is done by attempting to create a `Keyword` object from the token text.
                guard let keyword = Keywords(rawValue: text) else {
                    throw AssemblerError.ParserError(file: filename, line: parser.lineNum, msg: "Unexpected keyword \"\(text)\"")
                }
                
                // Handle each keyword as a separate case.
                switch (keyword) {
                // Switchs the compiler mode.
                case .section:
                    let sectionType = package.tokens[1] as! Lexer.WordToken
                    if let type = CompilerMode(rawValue: sectionType.text) {
                        mode = type
                    } else {
                        throw AssemblerError.ParserError(file: filename, line: parser.lineNum, msg: "Invalid section type \"\(sectionType.text)\"")
                    }
                
                // Declares a global label.
                case .global:
                    let label = String((package.tokens[1] as! Lexer.WordToken).text.dropLast())
                    labelMap[label] = (byteCount, true)
                    if unprocessedLabels[label] != nil {
                        for pos in unprocessedLabels[label]! {
                            ostream.replace(at: pos, with: UInt64(bitPattern: Int64(byteCount) - Int64(pos) - 8))
                            unprocessedLabels.removeValue(forKey: label)
                        }
                    }
                    
                // Declares a local label.
                case .local:
                    let label = String((package.tokens[1] as! Lexer.WordToken).text.dropLast())
                    labelMap[label] = (byteCount, false)
                    if unprocessedLabels[label] != nil {
                        for pos in unprocessedLabels[label]! {
                            ostream.replace(at: pos, with: UInt64(bitPattern: Int64(byteCount) - Int64(pos) - 8))
                            unprocessedLabels.removeValue(forKey: label)
                        }
                    }
                    
                // Data keywords (may only be used when compiler mode is set to `data`).
                case .byte:
                    if mode != .data {
                        throw AssemblerError.ParserError(file: filename, line: parser.lineNum,
                                                         msg: "'byte' keyword is only allowed in the 'data' section.")
                    }
                    let literal = UInt8((package.tokens[1] as! Lexer.ImmToken).value)
                    ostream.append(byte: literal)
                    byteCount += 1
                    
                case .word:
                    if mode != .data {
                        throw AssemblerError.ParserError(file: filename, line: parser.lineNum,
                                                         msg: "'word' keyword is only allowed in the 'data' section.")
                    }
                    let literal = UInt16((package.tokens[1] as! Lexer.ImmToken).value)
                    ostream.append(literal, as: UInt16.self)
                    byteCount += 2
                    
                case .long:
                    if mode != .data {
                        throw AssemblerError.ParserError(file: filename, line: parser.lineNum,
                                                         msg: "'long' keyword is only allowed in the 'data' section.")
                    }
                    let literal = UInt32((package.tokens[1] as! Lexer.ImmToken).value)
                    ostream.append(literal, as: UInt32.self)
                    byteCount += 4
                    
                case .quad:
                    if mode != .data {
                        throw AssemblerError.ParserError(file: filename, line: parser.lineNum,
                                                         msg: "'quad' keyword is only allowed in the 'data' section.")
                    }
                    let literal = UInt64((package.tokens[1] as! Lexer.ImmToken).value)
                    ostream.append(literal, as: UInt64.self)
                    byteCount += 8
                    
                case .string:
                    if mode != .data {
                        throw AssemblerError.ParserError(file: filename, line: parser.lineNum,
                                                         msg: "'string' keyword is only allowed in the 'data' section.")
                    }
                    let literal = (package.tokens[1] as! Lexer.StringLiteralToken).bytes
                    ostream.append(bytes: literal)
                    byteCount += literal.count
                    
                }
            } // if package.tokens.first?.type == .keyword
            
            // If package neither starts with an instruction or keyword then throw an error.
            // The parser will probably throw an error before this point if it can't create
            // a valid package, but, for the sake of redundancy, we'll throw another error
            // here just incase something slips through.
            else {
                throw AssemblerError.Default(msg: "Invalid token.")
            }
        } // while let package = try parser.extract()
        
        // Create the `ObjectFile` along with its metadata.
        let objFile = ObjectFile()
        objFile.binary = ostream
        for label in labelMap {
            if label.value.isGlobal {
                objFile.globalLabelMap[label.key] = label.value.bytePos
            }
        }
        objFile.unprocessedLabelMap = unprocessedLabels
        return objFile
        
    } // func compile() throws -> ObjectFile
    
    
    /// Encodes a register from a token with type `.register`.
    private func encodeRegister(_ token: BasicToken) -> UInt8? {
        if let t = token as? Lexer.WordToken {
            return encodeRegister(t.text)
        } else {
            return nil
        }
    }
    
    
    /// Encodes a register from a string.
    private func encodeRegister(_ text: String) -> UInt8? {
        switch (text) {
        case "r0": return 0x0
        case "r1": return 0x1
        case "r2": return 0x2
        case "r3": return 0x3
        case "r4": return 0x4
        case "r5": return 0x5
        case "r6": return 0x6
        case "r7": return 0x7
        case "r8": return 0x8
        case "r9": return 0x9
        case "ra": return 0xa
        case "rb": return 0xb
        case "rc": return 0xc
        case "rd": return 0xd
        case "rs": return 0xe
        case "rx": return 0xf
        default: return nil
        }
    }
    
    
    /// Encodes an instruction modifier from a token.
    private func encodeModifier(_ token: BasicToken) -> UInt8? {
        if let t = token as? Lexer.WordToken {
            let text = t.text
            switch (text) {
            case "b": return 0x01
            case "w": return 0x02
            case "l": return 0x03
            case "q": return 0x04
            case "fs": return 0x05
            case "fd": return 0x06
            default: return nil
            }
        } else {
            return nil
        }
    }
    
    
    /**
     Encodes a 64-bit address from a label token.
     
     Trys to find the address of the label in the label map. If it is sucessful, the
     relative distance (i.e. the value that must be added to the PC to jump to the label
     is returned). If it is unable to locate the label, the label and the position where
     it is referenceed is added to the unprocessed labels map to be filled in later.
     
     - returns:
        The relative distance to the desired label if said label has already been defined
        in the current contex. Otherwise returns 0 and marks the location to be filled in
        either once the label appears in the current contex or by the linker.
     
     */
    private func encodeAddress(_ token: BasicToken) -> UInt64 {
        let t = token as! Lexer.WordToken
        let label = t.text
        if let bytePos = labelMap[label]?.bytePos {
            return UInt64(bitPattern: Int64(bytePos) - Int64(byteCount) - 8)
        } else {
            if unprocessedLabels[t.text] != nil {
                unprocessedLabels[t.text]!.append(byteCount)
            } else {
                unprocessedLabels[t.text] = [byteCount]
            }
            return UInt64(0)
        }
    }
    
    
    /// Encodes an integer value of a given size, truncating if needed.
    func encodeImm<T: FixedWidthInteger>(_ token: BasicToken, as: T.Type) -> T {
        let t = token as! Lexer.ImmToken
        return T(truncatingIfNeeded: t.value)
    }
    
}
