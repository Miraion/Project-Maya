//
//  SystemCall.swift
//  virtual-machine
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class SystemCall : VoidInstruction {
    func run() throws {
        
        // The value in rx determins what will happen on a system call
        
        switch(VPU.rx.quad) {
        
        case 0x1:
            // System write format:
            // r0: output device (0 for stdin, 1 for stdout, 2 for stderr)
            // r1: buffer address
            // r2: number of bytes to write
            // rx: return value of the system call
            let x = try VM.system.write(outputDevice: VPU.r0.quad, bufferAddr: VPU.r1.quad, size: VPU.r2.quad)
            VPU.rx.set(x)
            
        case 0x2:
            // System read format:
            // r0: input device (0 for stdin, 1 for stdout, 2 for stderr)
            // r1: buffer address
            // r2: number of bytes to read
            // rx: return value of the system call
            let x = try VM.system.read(inputDevice: VPU.r0.quad, bufferAddr: VPU.r1.quad, capacity: VPU.r2.quad)
            VPU.rx.set(x)
            
        case 0x5:
            let addr = try VM.system.allocate(capacity: VPU.r0.quad)
            VPU.rx.quad = addr
            
        case 0x6:
            try VM.system.deallocate(addr: VPU.r0.quad)
            
        case 0x7:
            // System finish execution format:
            // r0: exit code
            VM.system.finishExecution(exitCode: VPU.r0.quad)
            
        case 0x8:
            // System abort format:
            // r0: exit code
            VM.system.abortExecution(exitCode: VPU.r0.long)
            
        case 0x9:
            // System open format:
            // r0: file path as C-syle string
            // r1: open flags
            // rx <- file descriptor or -1 if error
            guard let path = UnsafeRawPointer(bitPattern: UInt(VPU.r0.quad)) else {
                throw SystemInterface.RuntimeError.BadAccess(addr: VPU.r0.quad)
            }
            let mode = Int32(bitPattern: VPU.r1.long)
            let x = VM.system.open(path: path, mode: mode)
            VPU.rx.set(x)
            
        case 0xa:
            let x = VM.system.close(fd: Int32(bitPattern: VPU.r0.long))
            VPU.rx.set(x)
            
        case 0x42:
            // System debug cpu status format:
            // r0: mode (0 for decimal, 1 for hex)
            let x = VM.system.debugVPUStatus(mode: 0)
            VPU.rx.set(x)
            
        case 0x43:
            // System debug cpu status format:
            // r0: mode (0 for decimal, 1 for hex)
            let x = VM.system.debugVPUStatus(mode: 1)
            VPU.rx.set(x)
            
        case 0x44:
            let x = VM.system.debugStackState(size: VPU.r0.quad)
            VPU.rx.set(x)
            
        default: break
            
        }
    }
}
