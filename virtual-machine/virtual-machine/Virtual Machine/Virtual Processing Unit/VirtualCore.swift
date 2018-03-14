//
//  VirtualCore.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-19.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

/// Virtual CPU Core
///
/// 16 General Puropse, 64-bit Registers
class VirtualCore {
    
    /// Callee Saved Register
    var ra = VirtualRegister()
    
    /// Base Pointer (Callee Saved)
    var rb = VirtualRegister()
    
    /// Callee Saved Register
    var rc = VirtualRegister()
    
    /// Callee Saved Register
    var rd = VirtualRegister()
    
    /// Stack Pointer (Callee Saved)
    var rs = VirtualRegister()
    
    /// Return Register (Scratch)
    var rx = VirtualRegister()
    
    /// Scratch Register
    ///
    /// 1st Subroutine Argument
    var r0 = VirtualRegister()
    
    /// Scratch Register
    ///
    /// 2st Subroutine Argument
    var r1 = VirtualRegister()
    
    /// Scratch Register
    ///
    /// 3st Subroutine Argument
    var r2 = VirtualRegister()
    
    /// Scratch Register
    ///
    /// 4st Subroutine Argument
    var r3 = VirtualRegister()
    
    /// Scratch Register
    ///
    /// 5st Subroutine Argument
    var r4 = VirtualRegister()
    
    /// Scratch Register
    ///
    /// 6st Subroutine Argument
    var r5 = VirtualRegister()
    
    /// Scratch Register
    var r6 = VirtualRegister()
    
    /// Scratch Register
    var r7 = VirtualRegister()
    
    /// Scratch Register
    var r8 = VirtualRegister()
    
    /// Scratch Register
    var r9 = VirtualRegister()
    
    /// Overflow Flag
    var OF = false
    
    /// Zero Flag
    var ZF = false
    
    /// Carry Flag
    var CF = false
    
    /// Sign Flag
    var SF = false
    
    /// Program Counter
    var PC: Quad = 0
    
    /// Prints the status of all registers using a given printf style format.
    func printStatus(format f: String) {
        let l1 = String(format: "r0: \(f)    r4: \(f)    r8: \(f)    rc: \(f)", r0.quad, r4.quad, r8.quad, rc.quad)
        let l2 = String(format: "r1: \(f)    r5: \(f)    r9: \(f)    rd: \(f)", r1.quad, r5.quad, r9.quad, rd.quad)
        let l3 = String(format: "r2: \(f)    r6: \(f)    ra: \(f)    rs: \(f)", r2.quad, r6.quad, ra.quad, rs.quad)
        let l4 = String(format: "r3: \(f)    r7: \(f)    rb: \(f)    rx: \(f)", r3.quad, r7.quad, rb.quad, rx.quad)
        print(l1)
        print(l2)
        print(l3)
        print(l4)
        print()
    }
    
    /// Prints the status of all registers as 64 bits worth of hex.
    func printHex() {
        printStatus(format: "%.016lx")
    }
    
    /// Prints the status of all registers as 16 digits worth of decimal.
    func printDec() {
        printStatus(format: "% 16ld")
    }
}
