//
//  SystemCall.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class SystemCall : VoidInstruction {
    func run() throws {
        
        // The value in rx determins what will happen on a system call
        
        // rx: 0x1 -> system write
        if VPU.rx.quad == 0x1 {
            // System write format:
            // r0: output device (0 for stdin, 1 for stdout, 2 for stderr)
            // r1: buffer address
            // r2: number of bytes to write
            // rx: return value of the system call
            let x = try VM.system.write(outputDevice: VPU.r0.quad, bufferAddr: VPU.r1.quad, size: VPU.r2.quad)
            VPU.rx.set(x)
        }
        
        // rx: 0x42 -> print cpu status
        else if VPU.rx.quad == 0x42 {
            // System debug cpu status format:
            // r0: mode (0 for decimal, 1 for hex)
            let x = VM.system.debugVPUStatus(mode: VPU.r0.quad)
            VPU.rx.set(x)
        }
        
        // rx: 0x7 -> kill program
        else if VPU.rx.quad == 0x7 {
            // System kill program format:
            // r0: exit code
            VM.system.killExecution(exitCode: VPU.r0.quad)
        }
    }
}
