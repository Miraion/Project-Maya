//
//  Parser.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-23.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

/**
 Delagate responsable for taking tokens from the lexer and combining them into valid instructions.
 */
class Parser {
    
    private let lexer: Lexer
    
    struct ParsedPackage {
        var tokens = [BasicToken]()
    }
    
    init (lexer: Lexer) {
        self.lexer = lexer
    }
    
    /// The current line number in the source file being parsed.
    var lineNum: Int {
        return lexer.lineNum
    }
    
    /// The name of the source file being parsed.
    var filename: String {
        return lexer.filename
    }
    
    
    /**
     Extracts tokens from the internal lexer delegate and packages them together.
     
     - returns:
        A package of tokens from the lexer or `nil` if there are no remaining tokens
        in the lexer.
     
     - throws:
        A myriad of errors regarding invalid syntax along with any errors throw by the
        lexer while trying to extract tokens.
     
     */
    func extract() throws -> ParsedPackage? {
        if let firstToken = try lexer.extract() {
            
            // If token is an instruction, extract operand tokens from lexer, ensuring
            // they are of the correct type and in the correct position.
            if firstToken.type == .instruction {
                var package = ParsedPackage()
                package.tokens.append(firstToken)
                guard let tokenData = instructionMap[(firstToken as! Lexer.WordToken).text] else {
                    throw AssemblerError.ParserError(file: filename, line: lineNum,
                                                     msg: "Invalid Instruction \((firstToken as! Lexer.WordToken).text)")
                }
                // Extraction format for each instruction is defined in the global `instructionMap` dictionary.
                let extractionFormat = tokenData.extractionFormat
                for expectedTokenType in extractionFormat.orderedTypes {
                    if let token = try lexer.extract() {
                        if token.type == expectedTokenType {
                            package.tokens.append(token)
                        } else {
                            throw AssemblerError.InvalidOperand(file: filename, line: lineNum,
                                                                actual: token.type, expected: expectedTokenType)
                        }
                    } else {
                        throw AssemblerError.UnexpectedEOF(file: filename)
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
                    throw AssemblerError.ParserError(file: filename, line: lineNum,
                                                     msg: "Invalid keyword \"\(firstToken.description)\"")
                }
                package.tokens.append(firstToken)
                let extractionFromat = tokenData.orderedTypes
                for expectedTokenType in extractionFromat {
                    if let token = try lexer.extract() {
                        if token.type == expectedTokenType {
                            package.tokens.append(token)
                        } else {
                            throw AssemblerError.InvalidOperand(file: filename, line: lineNum,
                                                                actual: token.type, expected: expectedTokenType)
                        }
                    } else {
                        throw AssemblerError.UnexpectedEOF(file: filename)
                    }
                }
                return package
            }
            
            else {
                throw AssemblerError.ParserError(file: filename, line: lineNum,
                                                 msg: "Unexpected token \"\(firstToken.description)\"")
            }
            
        } else {
            return nil
        }
    } // func extract() throws -> ParsedPackage?
    
} // class Parser
