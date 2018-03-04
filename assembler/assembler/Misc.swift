//
//  Misc.swift
//  assembler
//
//  Created by Jeremy S on 2018-03-03.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

/// Prints usage information for the program.
func showUsage() {
    print("Usage: mia ([-c | -d] [input files ...]) | ([-a | -o] [output file] [input files ...])")
    exit(1)
}

/// Converts an 8-bit integer into a swift `Character` object.
func asChar(_ c: UInt8) -> Character? {
    if let s = String(bytes: [c], encoding: .utf8) {
        return Character(s)
    } else {
        return nil
    }
}

/// Removes a file extension from a given string.
/// Returns the same string if there is no file extension in the string.
func removeFileExtension(from str: String) -> String {
    if !str.contains(".") {
        return str
    }
    
    var s = str
    while s.last != "." {
        s.removeLast()
    }
    s.removeLast()
    return s
}
