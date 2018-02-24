//
//  main.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-22.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

func showUsage() {
    print("Usage: mia [-c / -d] [input file]")
    exit(1)
}

func asChar(_ c: UInt8) -> Character? {
    if let s = String(bytes: [c], encoding: .utf8) {
        return Character(s)
    } else {
        return nil
    }
}

if CommandLine.argc != 3 { showUsage() }

if CommandLine.arguments[1] == "-c" {
    
    let filename = CommandLine.arguments[2]
    initInstructionMap()
    initKeywordMap()
    
    guard let compiler = try Compiler(file: filename) else {
        print("Unable to open \(filename)")
        exit(7)
    }
    
    let ec = compiler.compile(into: filename + ".out")
    exit(Int32(ec))
    
} else if CommandLine.arguments[1] == "-d" {
    print("Not implemented yet.")
} else {
    showUsage()
}
