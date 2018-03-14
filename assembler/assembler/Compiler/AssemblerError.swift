//
//  ErrorType.swift
//  assembler
//
//  Created by Jeremy S on 2018-02-28.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

/// Enumeration of error types.
enum AssemblerError : Error {
    case Default(msg: String)
    case LexerError(file: String, line: Int, msg: String)
    case ParserError(file: String, line: Int, msg: String)
    case InvalidOperand(file: String, line: Int, actual: Lexer.TokenType, expected: Lexer.TokenType)
    case UnexpectedEOF(file: String)
    case DuplicateSymbol(symbol: String)
    case UndefinedSymbols(symbols: [String])
}
