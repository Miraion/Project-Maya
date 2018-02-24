//
//  Compiler.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-23.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Compiler {
    
    enum CompilerError : Error {
        case InitalizationError(msg: String)
        case Default
    }
    
    enum CompilerMode : String {
        case text = "text"
        case data = "data"
        case null = "null"
    }
    
    private let infile: String
    private let istream: InputStream
    private let lexer: Lexer
    private let parser: Parser
    private let ostream: BinaryStream
    
    private var byteCount: Int = 0
    private var labelMap = [String : (bytePos: Int, isGlobal: Bool)]()
    private var unprocessedLabels = [String : [Int]]()
    private var mode: CompilerMode = .null
    
    init? (file: String) throws {
        self.infile = file
        if let i = InputStream(file: file) {
            self.istream = i
        } else {
            return nil
        }
        self.lexer = try Lexer(stream: istream)
        self.parser = Parser(lexer: lexer)
        self.ostream = BinaryStream()
    }
    
    /// Attempts to compile the input file into machine code and store it in a file with a given name.
    /// Returns the exit value for the program. A return value of 0 means a successful compilation.
    func compile(into outfile: String) -> Int {
        do {
            while let package = try parser.extract() {
                
                if package.tokens.first?.type == .instruction {
                    
                    let text = (package.tokens.first! as! Lexer.WordToken).text
                    let tokenData = instructionMap[text]!
                    let opcode = tokenData.opc
                    let encodeFormat = tokenData.encodingFormat
                    
                    ostream.append(byte: opcode)
                    byteCount += 1
                    
                    switch (encodeFormat) {
                    case .void: continue
                        
                    case .unary:
                        ostream.append(byte: encodeRegister(package.tokens[1])!)
                        byteCount += 1
                        
                    case .binary:
                        let dst = encodeRegister(package.tokens[2])!
                        let src = encodeRegister(package.tokens[1])!
                        let b = dst & ((src << 4) & 0xf0)
                        ostream.append(byte: b)
                        byteCount += 2
                    
                    case .ternay:
                        let dst = encodeRegister(package.tokens[3])!
                        let srcA = encodeRegister(package.tokens[1])!
                        let srcB = encodeRegister(package.tokens[2])!
                        let srcByte = srcB & ((srcA << 4) & 0xf0)
                        ostream.append(bytes: [dst, srcByte])
                        byteCount += 3
                    
                    case .unaryAddr:
                        let addr = encodeAddress(package.tokens[1])
                        ostream.append(addr, as: UInt64.self)
                        byteCount += 8
                        
                    case .binaryAddrFirst:
                        let reg = encodeRegister(package.tokens[2])!
                        byteCount += 1
                        let addr = encodeAddress(package.tokens[1])
                        ostream.append(byte: reg)
                        ostream.append(addr, as: UInt64.self)
                        byteCount += 8
                        
                    case .binaryAddrLast:
                        let reg = encodeRegister(package.tokens[1])!
                        byteCount += 1
                        let addr = encodeAddress(package.tokens[2])
                        ostream.append(byte: reg)
                        ostream.append(addr, as: UInt64.self)
                        byteCount += 8
                        
                    case .imm64:
                        let reg = encodeRegister(package.tokens[1])!
                        let imm = encodeImm(package.tokens[2], as: UInt64.self)
                        ostream.append(byte: reg)
                        ostream.append(imm, as: UInt64.self)
                        byteCount += 9
                        
                    case .imm32:
                        let reg = encodeRegister(package.tokens[1])!
                        let imm = encodeImm(package.tokens[2], as: UInt32.self)
                        ostream.append(byte: reg)
                        ostream.append(imm, as: UInt32.self)
                        byteCount += 5
                        
                    case .imm16:
                        let reg = encodeRegister(package.tokens[1])!
                        let imm = encodeImm(package.tokens[2], as: UInt16.self)
                        ostream.append(byte: reg)
                        ostream.append(imm, as: UInt16.self)
                        byteCount += 3
                        
                    case .imm8:
                        let reg = encodeRegister(package.tokens[1])!
                        let imm = encodeImm(package.tokens[2], as: UInt8.self)
                        ostream.append(byte: reg)
                        ostream.append(imm, as: UInt8.self)
                        byteCount += 2
                        
                    }
                }
                
                else if package.tokens.first?.type == .keyword {
                    
                    let text = (package.tokens.first! as! Lexer.WordToken).text
                    guard let keyword = Keywords(rawValue: text) else {
                        throw Parser.ParserError.General(line: parser.lineNum, msg: "Unexpected keyword \"\(text)\"", exitcode: 36)
                    }
                    
                    switch (keyword) {
                    case .section:
                        let sectionType = package.tokens[1] as! Lexer.WordToken
                        if let type = CompilerMode(rawValue: sectionType.text) {
                            mode = type
                        } else {
                            throw Parser.ParserError.General(line: parser.lineNum, msg: "Invalid section type \"\(sectionType.text)\"", exitcode: 35)
                        }
                        
                    case .global:
                        let label = String((package.tokens[1] as! Lexer.WordToken).text.dropLast())
                        labelMap[label] = (byteCount, true)
                        if unprocessedLabels[label] != nil {
                            for pos in unprocessedLabels[label]! {
                                ostream.replace(at: pos, with: UInt64(byteCount))
                            }
                        }
                        
                    case .local:
                        let label = String((package.tokens[1] as! Lexer.WordToken).text.dropLast())
                        labelMap[label] = (byteCount, false)
                        if unprocessedLabels[label] != nil {
                            for pos in unprocessedLabels[label]! {
                                ostream.replace(at: pos, with: UInt64(byteCount))
                            }
                        }
                        
                    case .byte:
                        if mode != .data {
                            throw Parser.ParserError.General(line: parser.lineNum, msg: "'byte' keyword is only allowed in the 'data' section.", exitcode: 39)
                        }
                        let literal = UInt8((package.tokens[1] as! Lexer.ImmToken).value)
                        ostream.append(byte: literal)
                        byteCount += 1
                        
                    case .word:
                        if mode != .data {
                            throw Parser.ParserError.General(line: parser.lineNum, msg: "'word' keyword is only allowed in the 'data' section.", exitcode: 39)
                        }
                        let literal = UInt16((package.tokens[1] as! Lexer.ImmToken).value)
                        ostream.append(literal, as: UInt16.self)
                        byteCount += 2
                        
                    case .long:
                        if mode != .data {
                            throw Parser.ParserError.General(line: parser.lineNum, msg: "'long' keyword is only allowed in the 'data' section.", exitcode: 39)
                        }
                        let literal = UInt32((package.tokens[1] as! Lexer.ImmToken).value)
                        ostream.append(literal, as: UInt32.self)
                        byteCount += 4
                        
                    case .quad:
                        if mode != .data {
                            throw Parser.ParserError.General(line: parser.lineNum, msg: "'quad' keyword is only allowed in the 'data' section.", exitcode: 39)
                        }
                        let literal = UInt64((package.tokens[1] as! Lexer.ImmToken).value)
                        ostream.append(literal, as: UInt64.self)
                        byteCount += 8
                        
                    case .string:
                        if mode != .data {
                            throw Parser.ParserError.General(line: parser.lineNum, msg: "'string' keyword is only allowed in the 'data' section.", exitcode: 39)
                        }
                        let literal = (package.tokens[1] as! Lexer.StringLiteralToken).bytes
                        ostream.append(bytes: literal)
                        byteCount += literal.count
                        
                    }
                } else {
                    throw CompilerError.Default
                }
            }
            
            ostream.write(to: outfile)
            return 0
        } catch Parser.ParserError.General(let line, let msg, let ec) {
            print("Syntax error at \(infile):\(line) - \(msg).")
            return ec
        } catch Lexer.CompilerError.LexicalError(let line, let msg) {
            print("Sytax error at \(infile):\(line) - \(msg)")
            return 8
        } catch Lexer.CompilerError.InvalidLiteral(let line, let msg) {
            print("Syntax error at \(infile):\(line) - \(msg)")
            return 9
        } catch {
            print("An unhandled error occured.")
            return -1
        }
    }
    
    func encodeRegister(_ token: BasicToken) -> UInt8? {
        if let t = token as? Lexer.WordToken {
            return encodeRegister(t.text)
        } else {
            return nil
        }
    }
    
    func encodeRegister(_ text: String) -> UInt8? {
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
    
    func encodeAddress(_ token: BasicToken) -> UInt64 {
        let t = token as! Lexer.WordToken
        let label = t.text
        if let bytePos = labelMap[label]?.bytePos {
            return UInt64(bytePos)
        } else {
            if unprocessedLabels[t.text] != nil {
                unprocessedLabels[t.text]!.append(byteCount)
            } else {
                unprocessedLabels[t.text] = [byteCount]
            }
            return UInt64(0)
        }
    }
    
    func encodeImm<T: FixedWidthInteger>(_ token: BasicToken, as: T.Type) -> T {
        let t = token as! Lexer.ImmToken
        return T(truncatingIfNeeded: t.value)
    }
    
}
