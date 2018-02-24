//
//  SystemInterface.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation
import Darwin.C

class SystemInterface {
    
    enum RuntimeError : Error {
        case BadAccess(addr: Quad)
    }
    
    func write(outputDevice: Quad, bufferAddr: Quad, size: Quad) throws -> Int {
        if let charPtr = UnsafeRawPointer(bitPattern: UInt(bufferAddr)) {
            return Darwin.write(Int32(outputDevice), charPtr, Int(size))
        } else {
            throw RuntimeError.BadAccess(addr: bufferAddr)
        }
    }
    
    func debugVPUStatus(mode: Quad) -> Int {
        if mode == 0 {
            VPU.printDec()
            return 0
        } else if mode == 1 {
            VPU.printHex()
            return 0
        } else {
            return -1
        }
    }
    
    func killExecution(exitCode: Quad) {
        VM.continueExecution = false
        VM.exitCode = Int(bitPattern: UInt(exitCode))
    }
    
}
