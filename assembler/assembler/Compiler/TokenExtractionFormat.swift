//
//  TokenExtractionFormat.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-23.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class TokenExtractionFormat {
    let orderedTypes: [Lexer.TokenType]
    
    init (_ types: Lexer.TokenType...) {
        self.orderedTypes = types
    }
}
