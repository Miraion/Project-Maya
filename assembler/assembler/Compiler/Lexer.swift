//
//  Lexer.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-22.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

/**
 Delagate responsable for constructing tokens from the raw source code text.
 */
class Lexer {
    
    private let istream: InputStream
    
    /**
     Instance of the current token.
     
     - invariant:
        This variable will always hold the value of the next token to be returnd when
        `extract()` is called. It will only be `nil` if the end of the source file
        has been reached.
     
     */
    private var currentToken: BasicToken? = nil
    
    /// The number of the source line currently being processed.
    var lineNum: Int {
         return istream.lineNum
    }
    
    /// The name of the source file currently being processed.
    var filename: String {
        return istream.filename
    }
    
    /**
     Initalizes this object from an input stream which wraps around a source file.
     
     - throws: Throws an error if unable to construct the first token.
     */
    init (stream: InputStream) throws {
        self.istream = stream
        currentToken = try constructToken()
    }
    
    
    /**
     Extracts a token from the source file.
     
     Returns the current token and constructs a new one to take its place.
     
     - returns:
        The extracted token as a `BasicToken`. Only returns `nil` if there are no
        remaining tokens in the source file.
     
     - throws: Errors from `constructToken()` propagate through this method.
     
     */
    func extract() throws -> BasicToken? {
        if let token = currentToken {
            currentToken = try constructToken()
            return token
        } else {
            return nil
        }
    }
    
    /**
     Returns the current token without replacing it.
     
     - returns: The current token or `nil` if there is none.
     
     */
    func peek() -> BasicToken? {
        return currentToken
    }
    
    /**
     Does the main work of extracting characters from the source file and constructing
     tokens from them.
     
     This method removes comments and excess whitespace from the source file while
     constructing a token.
     
     - returns:
        A token constructed from the next characters from the source file or `nil` if
        there are no remaining characters from the source file.
     
     - throws:
        Throws an error if there is an invalid literal or it is unable to construct
        a valid token.
     
     
     */
    private func constructToken() throws -> BasicToken? {
        if istream.peek() != nil {
            
            // Remove any comments or leading whitespace.
            while isCommentMarker(istream.peek()) || isWhiteSpace(istream.peek()) {
                if isCommentMarker(istream.peek()) {
                    removeComment()
                } else {
                    removeTailingWhiteSpace()
                }
            }
            
            // Build a string of characters until a comment marker or whitespace
            // character is detected. Exceptions are made for string literals where
            // whitespace and comment markers are valid.
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
            
            // Create an actual string object using UTF-8 encoding.
            // If unable to do so, throw an error.
            if let str = String(bytes: strBuilder, encoding: .utf8) {
                
                // Is the string a register keyword?
                if str.first == "r" && str.count == 2 && str.last != ":" {
                    return WordToken(text: str, type: .register)
                }
                
                // Is the string an integer literal?
                // Valid formats are decimal (no prefix), hex (0x prefix), or binary (0b prefix).
                else if str.count != 0 && isNumber(strBuilder.first!) {
                    if let i = Int(str) {
                        return ImmToken(value: i)
                    } else if str.hasPrefix("0x") {
                        if let i = Int(str.replacingOccurrences(of: "x", with: "0"), radix: 16) {
                            return ImmToken(value: i)
                        } else {
                            throw AssemblerError.LexerError(file: filename, line: lineNum, msg: "Invalid hexadecimal literal \"\(str)\"")
                        }
                    } else if str.hasPrefix("0b") {
                        if let i = Int(str.replacingOccurrences(of: "b", with: "0"), radix: 2) {
                            return ImmToken(value: i)
                        } else {
                            throw AssemblerError.LexerError(file: filename, line: lineNum, msg: "Invalid binary literal \"\(str)\"")
                        }
                    } else {
                        throw AssemblerError.LexerError(file: filename, line: lineNum, msg: "Invalid integer literal \"\(str)\".")
                    }
                }
                
                // Is the string a string literal?
                else if str.first == "\"" {
                    if str.last == "\"" && str.count > 2 {
                        var text = str
                        text.removeFirst()
                        text.removeLast()
                        // Replace escaped characters with their desired values.
                        text = text.replacingOccurrences(of: "\\n", with: "\n")
                        text = text.replacingOccurrences(of: "\\t", with: "\t")
                        text = text.replacingOccurrences(of: "\\\"", with: "\"")
                        text = text.replacingOccurrences(of: "\\'", with: "'")
                        text.append("\0")
                        return StringLiteralToken(value: text)
                    } else {
                        throw AssemblerError.LexerError(file: filename,
                                                        line: lineNum,
                                                        msg: "Invalid string literal '\(str.replacingOccurrences(of: "\n", with: "\\"))'")
                    }
                }
                
                // Is the string an instruction?
                else if instructionMap.keys.contains(str) {
                    return WordToken(text: str, type: .instruction)
                }
                
                // Is the string a label declaration?
                else if str.last == ":" {
                    return WordToken(text: str, type: .label)
                }
                
                // If none of the above, and the string is not empty, then treat it as a keyword.
                // The parser will determine whether or not it is a valid keyword.
                else if str.count != 0 {
                    return WordToken(text: str, type: .keyword)
                }
                
                // If none of the above statements catch the string then throw an error.
                else {
                    throw AssemblerError.LexerError(file: filename, line: lineNum, msg: "Unable to construct token from \"\(str)\".")
                }
                
            } else {
                throw AssemblerError.LexerError(file: filename, line: lineNum, msg: "Unable to construct utf8 token.")
            }
        } else {
            return nil
        }
    }
    
    /// Returns true if the given character is a whitespace character.
    private func isWhiteSpace(_ c: UInt8?) -> Bool {
        return c == 0x20 // space
            || c == 0xa  // line feed
            || c == 0    // eof
            || c == 0x9  // tab
            || c == 0xd  // carriage return
            || c == 0x2c // ','
    }
    
    /// Returns true if the given character is a digit.
    private func isNumber(_ c: UInt8) -> Bool {
        return c >= 0x30 && c <= 0x39
    }
    
    /// Removes whitespace characters from the input stream until the next character is not whitespace.
    private func removeTailingWhiteSpace() {
        while isWhiteSpace(istream.peek()) {
            istream.extract()
        }
    }
    
    /// Returns true if the given character is either '#' or ';'.
    private func isCommentMarker(_ c: UInt8?) -> Bool {
        return c == 0x23 || c == 0x3b
    }
    
    /// Removes characters from the input stream until a '\n' character is found.
    private func removeComment() {
        while istream.peek() != 10 {
            istream.extract()
        }
    }
    
}
