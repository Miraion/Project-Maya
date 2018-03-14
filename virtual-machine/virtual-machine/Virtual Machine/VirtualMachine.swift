//
//  VirtualMachine.swift
//  virtual-machine
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
        case StackOverflow
        case InvalidModifier(mod: Byte)
        case UnableToAllocateMemory
        case FreeUnallocatedAddress(addr: Quad)
    }

    let vpu = VirtualProcessingUnit()
    let system = SystemInterface()
    
    var memorySpace: UnsafeMutablePointer<Byte>?
    var codeAddress: Quad = 0
    var stackAddress: Quad {
        return codeAddress - 1
    }
    
    var initialStackPointer: Quad {
        return stackAddress + 1
    }
    
    var bottomOfCallStackAddr: Quad {
        return Quad(UInt(bitPattern: memorySpace))
    }
    
    var debugMode: Bool = false
    var continueExecution = true
    var exitCode = 0
    
    let callStackSize: Int = 0x8000  // 32 KB call stack
    
    init() {
        self.memorySpace = nil
    }
    
    func execute(file: String) throws -> Int {
        let executor: Executor
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
        
        executor = Executor(basePtr: codeSectionStart, size: fileSize)
        codeAddress = Quad(UInt(bitPattern: codeSectionStart))
        
        // Initalize registers
        VPU.rb.quad = stackAddress
        VPU.PC = codeAddress
        VPU.rs.quad = initialStackPointer
        
        // Runtime loop
        while executor.decoder.bytesLeft != 0 && continueExecution {
            if VPU.PC < codeAddress {
                print("PC is too low.")
                throw RuntimeError.SegmentationFault
            }
            
            if let opc = executor.decoder.extractByte() {
                if let instruction = executor.generateInstruction(withOpcode: opc) {
                    try instruction.run()
                    if debugMode {
                        print("Byte #: \(VPU.PC - codeAddress) - \(String(format: "%#.02x", executor.decoder.cursor!.pointee))")
                        VPU.printHex()
                        print()
                    }
                } else {
                    print("Byte count: \(VPU.PC - codeAddress)")
                    throw RuntimeError.InvalidOpcode(opc: opc)
                }
            } else {
                throw RuntimeError.FailedToExtractOpcode
            }
            
            if VPU.PC > codeAddress + Quad(UInt(fileSize)) + 1 {
                print("PC is too high.")
                throw RuntimeError.SegmentationFault
            }
        }
        
        // Clean up, rb and rs must have their original values when the program ends.
        if VPU.rb.quad != stackAddress || VPU.rs.quad != initialStackPointer {
            print("Invalid values for rs or rb.")
            throw RuntimeError.SegmentationFault
        }
        
        memorySpace?.deallocate(capacity: callStackSize + fileSize)
        
        return exitCode
    } // func execute
    
} // class VirtualMachine

/// Global instance of the virtual machine.
let VM = VirtualMachine.instance

/// Global instance of the single core located within the virtual machine's cpu.
let VPU = VirtualMachine.instance.vpu.core
