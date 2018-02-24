//
//  Parser.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-23.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Parser {
    
    private let lexer: Lexer
    
    enum ParserError : Error {
        case InvalidOperand(line: Int, actual: Lexer.TokenType, expected: Lexer.TokenType)
        case General(line: Int, msg: String, exitcode: Int)
        case UnexpectedEOF
    }
    
    struct ParsedPackage {
        var tokens = [BasicToken]()
    }
    
    init (lexer: Lexer) {
        self.lexer = lexer
    }
    
    var lineNum: Int {
        return lexer.lineNum
    }
    
    /// Extracts tokens from the internal lexer and packages them together.
    /// Returns nil if there are no more tokens in the lexer.
    ///
    /// Forwards any errors thrown by the Lexer.
    func extract() throws -> ParsedPackage? {
        if let firstToken = try lexer.extract() {
            
            // If token is an instruction, extract operand tokens from lexer, ensuring
            // they are of the correct type and in the correct position.
            if firstToken.type == .instruction {
                var package = ParsedPackage()
                package.tokens.append(firstToken)
                guard let tokenData = instructionMap[(firstToken as! Lexer.WordToken).text] else {
                    throw ParserError.General(line: lineNum, msg: "Invalid Instruction \((firstToken as! Lexer.WordToken).text)", exitcode: 33)
                }
                let extractionFormat = tokenData.extractionFormat
                for expectedTokenType in extractionFormat.orderedTypes {
                    if let token = try lexer.extract() {
                        if token.type == expectedTokenType {
                            package.tokens.append(token)
                        } else {
                            throw ParserError.InvalidOperand(line: lineNum, actual: token.type, expected: expectedTokenType)
                        }
                    } else {
                        throw ParserError.UnexpectedEOF
                    }
                }
                return package
            }
            
            // If token is a keyword, consult the global keyword map an extract any
            // relevent tokens from the lexer. Throws an error if the initial token
            // is not in the keyword map, or the following tokens don't match.
            else if firstToken.type == .keyword {
                var package = ParsedPackage()
                guard let tokenData = keywordMap[(firstToken as! Lexer.WordToken).text] else {
                    throw ParserError.General(line: lineNum, msg: "Invalid keyword \"\(firstToken.description)\"", exitcode: 35)
                }
                package.tokens.append(firstToken)
                let extractionFromat = tokenData.orderedTypes
                for expectedTokenType in extractionFromat {
                    if let token = try lexer.extract() {
                        if token.type == expectedTokenType {
                            package.tokens.append(token)
                        } else {
                            throw ParserError.InvalidOperand(line: lineNum, actual: token.type, expected: expectedTokenType)
                        }
                    } else {
                        throw ParserError.UnexpectedEOF
                    }
                }
                return package
            }
            
            else {
                throw ParserError.General(line: lineNum, msg: "Unexpected token \"\(firstToken.description)\"", exitcode: 34)
            }
            
        } else {
            return nil
        }
    }
    
}
