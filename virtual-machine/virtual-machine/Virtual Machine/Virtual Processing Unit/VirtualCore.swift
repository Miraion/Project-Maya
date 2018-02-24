//
//  VirtualCore.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-19.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

// Virtual CPU Core
// 16 General Puropse, 64-bit Registers
class VirtualCore {
    // Special Registers
    var rx = VirtualRegister()  // Return Register (Scratch)
    var rc = VirtualRegister()  // Count Register (Scratch)
    var rb = VirtualRegister()  // Base Pointer (Callee Saved)
    var rs = VirtualRegister()  // Stack Pointer (Callee Saved)
    
    /*
     Note about rb:
         When a program starts, rb will hold the address of the start of the call stack.
         Once the program ends, the machine will check if the value in rb is the same as
         when the program started. If it is not, a segmentation fault will occur.
     */
    
    // Callee Saved Registers
    var ra = VirtualRegister()
    var rd = VirtualRegister()
    
    // Scratch Registers
    var r0 = VirtualRegister()  // 1st Arg
    var r1 = VirtualRegister()  // 2nd Arg
    var r2 = VirtualRegister()  // 3rd Arg
    var r3 = VirtualRegister()  // 4th Arg
    var r4 = VirtualRegister()  // 5th Arg
    var r5 = VirtualRegister()  // 6th Arg
    var r6 = VirtualRegister()
    var r7 = VirtualRegister()
    var r8 = VirtualRegister()
    var r9 = VirtualRegister()
    
    // Flags
    var OF = false  // Overflow Flag
    var ZF = false  // Zero Flag
    var CF = false  // Carry Flag
    var SF = false  // Sign Flag
    
    var PC: Quad = 0
    
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
    
    func printHex() {
        printStatus(format: "%.016lx")
    }
    
    func printDec() {
        printStatus(format: "% 16ld")
    }
}
