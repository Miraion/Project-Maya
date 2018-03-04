//
//  KeywordMap.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-23.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

fileprivate(set) var keywordMap = [String : TokenExtractionFormat]()


/// Enumeration of all valid keywords and their syntatic definitions.
enum Keywords : String {
    case section = "section"
    case global = "global"
    case local = "local"
    case byte = "byte"
    case word = "word"
    case long = "long"
    case quad = "quad"
    case string = "string"
}

/// Map of keyword syntax definitions to their extraction format.
func initKeywordMap() {
    keywordMap[Keywords.section.rawValue]   = TokenExtractionFormat(.keyword)
    keywordMap[Keywords.global.rawValue]    = TokenExtractionFormat(.label)
    keywordMap[Keywords.local.rawValue]     = TokenExtractionFormat(.label)
    keywordMap[Keywords.byte.rawValue]      = TokenExtractionFormat(.literal)
    keywordMap[Keywords.word.rawValue]      = TokenExtractionFormat(.literal)
    keywordMap[Keywords.long.rawValue]      = TokenExtractionFormat(.literal)
    keywordMap[Keywords.quad.rawValue]      = TokenExtractionFormat(.literal)
    keywordMap[Keywords.string.rawValue]    = TokenExtractionFormat(.stringLiteral)
}
