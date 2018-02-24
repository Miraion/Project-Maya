//
//  VirtualMachine.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class VirtualMachine {
    
    static var instance = VirtualMachine()
    
    enum RuntimeError : Error {
        case UnableToOpenFile
        case FailedToExtractOpcode
        case InvalidOpcode(opc: Byte)
        case SegmentationFault
        case FileError(filename: String)
    }

    let vpu = VirtualProcessingUnit()
    let system = SystemInterface()
    
    var memorySpace: UnsafeMutablePointer<Byte>?
    var codeAddress: Quad = 0
    var stackAddress: Quad {
        return codeAddress - 1
    }
    
    var bottomOfCallStackAddr: Quad {
        return Quad(UInt(bitPattern: memorySpace))
    }
    
    
    var debugMode: Bool = false
    var continueExecution = true
    var exitCode = 0
    
    var endOfMemorySpace: Quad {
        return stackAddress + memorySpaceSize
    }
    
    let memorySpaceSize: Quad = 0x4000  // 16 killobytes
    
    let callStackSize: Int = 0x8000
    
    init() {
        self.memorySpace = nil
    }
    
    func execute(file: String) throws -> Int {
        let executor: Executer
        let fileBytes: UnsafePointer<Byte>
        let fileSize: Int
        
        let optionalfile = NSData(contentsOfFile: filename)
        if let file = optionalfile {
            fileBytes = file.bytes.bindMemory(to: Byte.self, capacity: file.length)
            fileSize = file.length
        } else {
            throw RuntimeError.FileError(filename: filename)
        }
        
        memorySpace = UnsafeMutablePointer<Byte>.allocate(capacity: callStackSize + fileSize)
        let memorySpaceStart = memorySpace!
        let codeSectionStart = memorySpaceStart.advanced(by: callStackSize)
        
        codeSectionStart.initialize(from: fileBytes, count: fileSize)
        
        executor = Executer(basePtr: codeSectionStart, size: fileSize)
        codeAddress = Quad(UInt(bitPattern: codeSectionStart))
        
        // Initalize registers
        VPU.rb.quad = codeAddress  // rb gets the starting address for the code
        VPU.PC = codeAddress
        VPU.rs.quad = stackAddress // rs gets the starting address for the stack
        
        // Runtime loop
        while executor.decoder.bytesLeft != 0 && continueExecution {
            if VPU.PC < codeAddress {
                throw RuntimeError.SegmentationFault
            }
            
            if let opc = executor.decoder.extractByte() {
                if let instruction = executor.generateInstruction(withOpcode: opc) {
                    try instruction.run()
                    if debugMode {
                        VPU.printHex()
                        print()
                    }
                } else {
                    throw RuntimeError.InvalidOpcode(opc: opc)
                }
            } else {
                throw RuntimeError.FailedToExtractOpcode
            }
            
            if VPU.PC > codeAddress + Quad(UInt(fileSize)) + 1 {
                throw RuntimeError.SegmentationFault
            }
        }
        
        // Clean up, rb and rs must have their original values when the program ends.
        if VPU.rb.quad != codeAddress || VPU.rs.quad != stackAddress {
            throw RuntimeError.SegmentationFault
        }
        
        memorySpace?.deallocate(capacity: Int(memorySpaceSize))
        
        return exitCode
    } // func execute
    
} // class VirtualMachine

let VM = VirtualMachine.instance
let VPU = VirtualMachine.instance.vpu.core
