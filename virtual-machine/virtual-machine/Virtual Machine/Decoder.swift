//
//  Decoder.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class FileDecoder {
    
    let data: UnsafePointer<Byte>
    
    /// Size of the file in bytes.
    let size: Int
    var cursor: UnsafePointer<Byte>? {
        return UnsafePointer<Byte>(bitPattern: UInt(VPU.PC))
    }
    
    var bytesLeft: Int {
        if let c = cursor {
            let l = size - data.distance(to: c)
            return l < 0 ? 0 : l
        } else {
            return 0
        }
    }
    
    init? (filename: String) {
        let optionalfile = NSData(contentsOfFile: filename)
        if let file = optionalfile {
            self.data = file.bytes.bindMemory(to: Byte.self, capacity: file.length)
            VPU.PC = Quad(UInt(bitPattern: data))
            self.size = file.length
        } else {
            return nil
        }
    }
    
    init (basePtr: UnsafePointer<Byte>, size: Int) {
        self.data = basePtr
        self.size = size
    }
    
    /// Extracts a single byte from the source file.
    /// Returns nil if no more bytes remain in the file.
    func extractByte() -> Byte? {
        if let c = cursor {
            if data.distance(to: c) >= size {
                return nil
            } else {
                let byte = c.pointee
                VPU.PC += 1
                return byte
            }
        } else {
            return nil
        }
    }
    
    /// Extracts 8 bytes from the file as a 64-bit integer.
    /// Returns nil if there are not enough bytes left in the file to extract the integer.
    func extract64BitLiteral() -> Quad? {
        if let c = cursor {
            if data.distance(to: c) > (size - 8) {
                return nil
            } else {
                let literal = c.withMemoryRebound(to: Quad.self, capacity: 1) {
                    return $0.pointee
                }
                VPU.PC += 8
                return literal.littleEndian
            }
        } else {
            return nil
        }
    }
    
    func extract<T: FixedWidthInteger>(as: T.Type) -> T? {
        if let c = cursor {
            let n = MemoryLayout<T>.size
            if data.distance(to: c) > (size - n) {
                return nil
            } else {
                let literal = c.withMemoryRebound(to: T.self, capacity: 1) {
                    return $0.pointee
                }
                VPU.PC += Quad(UInt(n))
                return literal.littleEndian
            }
        } else {
            return nil
        }
    }
    
    func decodeRegister(from byte: Byte) -> VirtualRegister {
        let vpu = VPU
        switch (byte) {
        case 0x0: return vpu.r0
        case 0x1: return vpu.r1
        case 0x2: return vpu.r2
        case 0x3: return vpu.r3
        case 0x4: return vpu.r4
        case 0x5: return vpu.r5
        case 0x6: return vpu.r6
        case 0x7: return vpu.r7
        case 0x8: return vpu.r8
        case 0x9: return vpu.r9
        case 0xa: return vpu.ra
        case 0xb: return vpu.rb
        case 0xc: return vpu.rc
        case 0xd: return vpu.rd
        case 0xe: return vpu.rs
        case 0xf: return vpu.rx
        default:
            print("Invalid register code: \(byte)")
            exit(97)
        }
    }
    
    func extractUnaryInstruction() -> Byte {
        let byte = extractByte()!
        return byte & 0x0f
    }
    
    func extractBinaryInstruction() -> (srcReg: Byte, dstReg: Byte) {
        let byte1 = extractByte()!
        let dst: Byte = byte1 & 0x0f
        let src: Byte = (byte1 >> 4) & 0x0f
        return (src, dst)
    }
    
    func extractTernaryInstruction() -> (srcRegA: Byte, srcRegB: Byte, dstReg: Byte) {
        let byte1 = extractByte()!
        let byte2 = extractByte()!
        let dst: Byte = byte1 & 0x0f
        let srca: Byte = (byte2 >> 4) & 0x0f
        let srcb: Byte = byte2 & 0x0f
        return (srca, srcb, dst)
    }
    
    func extractUnaryAddrInstruction() -> Quad {
        return extract64BitLiteral()!
    }
    
    func extractBinaryAddrInstruction() -> (reg: Byte, addr: Quad) {
        let byte1 = extractByte()!
        let dst: Byte = byte1 & 0xf
        let addr = extract64BitLiteral()!
        return (dst, addr)
    }
    
}
