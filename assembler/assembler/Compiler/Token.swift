//
//  Token.swift
//  assembler
//
//  Created by Jeremy S on 2018-03-03.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

/// Protocol which all tokens must conform to.
protocol BasicToken {
    var type : Lexer.TokenType { get }
    var description: String { get }
}

extension Lexer {
    
    /// Enumeration of token types.
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
    
}
