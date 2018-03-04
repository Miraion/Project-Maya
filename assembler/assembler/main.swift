//
//  main.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-22.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

let executableInitFile = "__init__.mio"

if CommandLine.argc < 3 { showUsage() }

do {
    
    let compiler = Compiler()
    let linker = Linker()
    initInstructionMap()
    initKeywordMap()
    
    // "-c" flag tells the program to compile the input files (source files) into object files.
    if CommandLine.arguments[1] == "-c" {
        let files = [String](CommandLine.arguments.suffix(from: 2))
        for file in files {
            let obj = try compiler.compile(file: file)
            obj.write(to: removeFileExtension(from: file) + ".mio")
        }
    }
        
    // "-o" flag tells the program to link the input files (object files) into an exectuable.
    else if CommandLine.arguments[1] == "-o" {
        try linker.setInitFile(to: executableInitFile)
        if CommandLine.arguments.count < 4 {
            print("No input files proveded.")
            exit(1)
        }
        let outfile = CommandLine.arguments[2]
        let files = [String](CommandLine.arguments.suffix(from: 3))
        let objectFiles = try files.map({ (_ name: String) throws -> ObjectFile in
            guard let objfile = ObjectFile(open: name) else {
                throw AssemblerError.Default(msg: "Error reading object file \"\(name)\"")
            }
            return objfile
        })
        let exe = try linker.linkToExecutable(objectFiles)
        exe.write(to: outfile)
    }
        
    // "-a" flag tells the program to link the input files (object files) into an archive (a bigger object file).
    else if CommandLine.arguments[0] == "-a" {
        if CommandLine.arguments.count < 4 {
            print("No input files proveded.")
            exit(1)
        }
        let outfile = CommandLine.arguments[2]
        let files = [String](CommandLine.arguments.suffix(from: 3))
        let objectFiles = try files.map({ (_ name: String) throws -> ObjectFile in
            guard let objfile = ObjectFile(open: name) else {
                throw AssemblerError.Default(msg: "Error reading object file \"\(name)\"")
            }
            return objfile
        })
        let archive = try linker.linkToArchive(objectFiles)
        archive.write(to: outfile)
    }
        
    // "-d" flag tells the program to decompile a given object file.
    // *** Not Implement Yet ***
    else if CommandLine.arguments[1] == "-d" {
        print("Not implemented yet.")
    }
    
    else {
        showUsage()
    }
    
} catch AssemblerError.Default(let msg) {
    print("Error - " + msg)
    exit(20)
} catch AssemblerError.LexerError(let file, let line, let msg) {
    print("Syntax error in \(file):\(line) - \(msg).")
    exit(21)
} catch AssemblerError.ParserError(let file, let line, let msg) {
    print("Syntax error in \(file):\(line) - \(msg).")
    exit(22)
} catch AssemblerError.InvalidOperand(let file, let line, let actual, let expected) {
    print("Invalid operand in \(file):\(line) - Expected \(expected), found \(actual).")
    exit(23)
} catch AssemblerError.UnexpectedEOF(let file) {
    print("Unexpected  end of file in \(file).")
    exit(24)
} catch AssemblerError.DuplicateSymbol(let symbol) {
    print("Linker error - duplicate symbol \"\(symbol)\".")
    exit(25)
} catch AssemblerError.UndefinedSymbols(let symbols) {
    for symbol in symbols {
        print("Linker error - undefined symbol \"\(symbol)\"")
    }
    exit(26)
} catch {
    print("An unknown error occured: something went very wrong.")
    exit(101)
}














