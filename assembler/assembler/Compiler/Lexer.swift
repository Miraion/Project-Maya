//
//  Lexer.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-22.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

protocol BasicToken {
    var type : Lexer.TokenType { get }
    var description: String { get }
}

class Lexer {
    
    enum CompilerError : Error {
        case InvalidLiteral(line: Int, msg: String)
        case LexicalError(line: Int, msg: String)
    }
    
    enum TokenType {
        case literal
        case stringLiteral
        case register
        case keyword
        case label
        case instruction
    }
    
    struct WordToken : BasicToken {
        let text: String
        let type: TokenType
        var description: String {
            return text
        }
    }
    
    struct ImmToken : BasicToken {
        let value: Int
        let type: TokenType = .literal
        var description: String {
            return value.description
        }
    }
    
    struct StringLiteralToken : BasicToken {
        let value: String
        let type: TokenType = .stringLiteral
        var bytes: [UInt8] {
            return value.utf8.map { UInt8($0) }
        }
        var description: String {
            return value
        }
    }
    
    struct CharacterLiteralToken : BasicToken {
        let value: UInt8
        let type: TokenType = .literal
        var description: String {
            return String(bytes: [value], encoding: .utf8) ?? "Error"
        }
    }
    
    private let istream: InputStream
    private var currentToken: BasicToken? = nil
    
    var lineNum: Int {
         return istream.lineNum
    }
    
    init (stream: InputStream) throws {
        self.istream = stream
        currentToken = try constructToken()
    }
    
    func extract() throws -> BasicToken? {
        if let token = currentToken {
            currentToken = try constructToken()
            return token
        } else {
            return nil
        }
    }
    
    func peek() -> BasicToken? {
        return currentToken
    }
    
    private func constructToken() throws -> BasicToken? {
        if istream.peek() != nil {
            
            while isCommentMarker(istream.peek()) || isWhiteSpace(istream.peek()) {
                if isCommentMarker(istream.peek()) {
                    removeComment()
                } else {
                    removeTailingWhiteSpace()
                }
            }
            
            var strBuilder = [UInt8]()
            var isConstructingStringLiteral = false
            var isEscaped = false
            while let char = istream.extract() {
                if char == 0x5c && !isEscaped {
                    isEscaped = true
                    strBuilder.append(char)
                    continue
                } else if char == 0x22 && !isEscaped {
                    isConstructingStringLiteral = !isConstructingStringLiteral
                } else if isWhiteSpace(char) && !isConstructingStringLiteral {
                    removeTailingWhiteSpace()
                    break
                } else if isCommentMarker(char) && !isConstructingStringLiteral {
                    removeComment()
                    removeTailingWhiteSpace()
                    break
                }
                isEscaped = false
                strBuilder.append(char)
            }
            
            if let str = String(bytes: strBuilder, encoding: .utf8) {
                
                if str.first == "r" && str.count == 2 && str.last != ":" {
                    return WordToken(text: str, type: .register)
                }
                
                else if str.count != 0 && isNumber(strBuilder.first!) {
                    if let i = Int(str) {
                        return ImmToken(value: i)
                    } else if str.hasPrefix("0x") {
                        if let i = Int(str.replacingOccurrences(of: "x", with: "0"), radix: 16) {
                            return ImmToken(value: i)
                        } else {
                            throw CompilerError.InvalidLiteral(line: istream.lineNum, msg: "Invalid hexadecimal literal \"\(str)\"")
                        }
                    } else if str.hasPrefix("0b") {
                        if let i = Int(str.replacingOccurrences(of: "b", with: "0"), radix: 2) {
                            return ImmToken(value: i)
                        } else {
                            throw CompilerError.InvalidLiteral(line: istream.lineNum, msg: "Invalid binary literal \"\(str)\"")
                        }
                    } else {
                        throw CompilerError.InvalidLiteral(line: istream.lineNum, msg: "Invalid integer literal \"\(str)\".")
                    }
                }
                
                else if str.first == "\"" {
                    if str.last == "\"" && str.count > 2 {
                        var text = str
                        text.removeFirst()
                        text.removeLast()
                        text = text.replacingOccurrences(of: "\\n", with: "\n")
                        text = text.replacingOccurrences(of: "\\t", with: "\t")
                        text.append("\0")
                        return StringLiteralToken(value: text)
                    } else {
                        throw CompilerError.InvalidLiteral(line: istream.lineNum, msg: "Invalid string literal '\(str.replacingOccurrences(of: "\n", with: "\\"))'")
                    }
                }
                
                else if instructionMap.keys.contains(str) {
                    return WordToken(text: str, type: .instruction)
                }
                
                else if str.last == ":" {
                    return WordToken(text: str, type: .label)
                }
                
                else if str.count != 0 {
                    return WordToken(text: str, type: .keyword)
                }
                
                else {
                    throw CompilerError.LexicalError(line: istream.lineNum, msg: "Unable to construct token from \"\(str)\".")
                }
                
            } else {
                throw CompilerError.LexicalError(line: istream.lineNum, msg: "Unable to construct utf8 token.")
            }
        } else {
            return nil
        }
    }
    
    private func isWhiteSpace(_ c: UInt8?) -> Bool {
        return c == 0x20 // space
            || c == 0xa  // line feed
            || c == 0    // eof
            || c == 0x9  // tab
            || c == 0xd  // carriage return
            || c == 0x2c // ','
    }
    
    private func isNumber(_ c: UInt8) -> Bool {
        return c >= 0x30 && c <= 0x39
    }
    
    private func removeTailingWhiteSpace() {
        while isWhiteSpace(istream.peek()) {
            istream.extract()
        }
    }
    
    private func isCommentMarker(_ c: UInt8?) -> Bool {
        return c == 0x23 || c == 0x3b
    }
    
    private func removeComment() {
        while istream.peek() != 10 {
            istream.extract()
        }
    }
    
}
