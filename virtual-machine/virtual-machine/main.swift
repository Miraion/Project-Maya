//
//  main.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-18.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

if CommandLine.argc != 2 {
    print("Requires an input file.")
    exit(1)
}

let filename = CommandLine.arguments[1]

VM.debugMode = false
do {
    let exitCode = try VM.execute(file: filename)
//    VPU.printDec()
//    VPU.printHex()
    exit(Int32(exitCode))
    
} catch VirtualMachine.RuntimeError.UnableToOpenFile {
    print("Unable to open \(filename): terminating execution with error code 100.")
    exit(101)
} catch VirtualMachine.RuntimeError.InvalidOpcode(let opc) {
    print("Invalid instruction (\(String(format: "%#.02x", opc))): terminating execution with error code 99.")
    exit(99)
} catch VirtualMachine.RuntimeError.SegmentationFault {
    print("Segmentation Fault: terminating execution with error code 11.")
    exit(11)
} catch VirtualMachine.RuntimeError.FailedToExtractOpcode {
    print("Error reading file: terminating execution with error code 98.")
    exit(98)
} catch SystemInterface.RuntimeError.BadAccess(let addr) {
    print("Bad Access (\(addr)): terminating execution with error code 6.")
    exit(6)
} catch {
    print("Unexpected error \(error).")
    exit(404)
}
