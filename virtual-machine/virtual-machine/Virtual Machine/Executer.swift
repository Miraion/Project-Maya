//
//  Executer.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Executer {
    var opcodeLookup = [Byte : Instruction]()
    let decoder: FileDecoder
    
    init (basePtr: UnsafePointer<Byte>, size: Int) {
        self.decoder = FileDecoder(basePtr: basePtr, size: size)
        
        opcodeLookup[0x10] = Add()
        opcodeLookup[0x11] = Sub()
        opcodeLookup[0x12] = Mul()
        opcodeLookup[0x13] = Div()
        opcodeLookup[0x14] = Neg()
        
        opcodeLookup[0x20] = And()
        opcodeLookup[0x21] = Or()
        opcodeLookup[0x22] = Xor()
        opcodeLookup[0x23] = Not()
        
        opcodeLookup[0x31] = Inc()
        opcodeLookup[0x32] = Dec()
        opcodeLookup[0x33] = Mov()
        opcodeLookup[0x34] = Push()
        opcodeLookup[0x35] = Pop()
        opcodeLookup[0x36] = Set<Quad>()
        opcodeLookup[0x37] = Set<Long>()
        opcodeLookup[0x38] = Set<Word>()
        opcodeLookup[0x39] = Set<Byte>()
        opcodeLookup[0x3a] = ImmAdd<Quad>()
        opcodeLookup[0x3b] = ImmAdd<Long>()
        opcodeLookup[0x3c] = ImmAdd<Word>()
        opcodeLookup[0x46] = ImmAdd<Byte>()
        opcodeLookup[0x3d] = ImmSub<Quad>()
        opcodeLookup[0x3e] = ImmSub<Long>()
        opcodeLookup[0x3f] = ImmSub<Word>()
        opcodeLookup[0x47] = ImmSub<Byte>()
        
        opcodeLookup[0x40] = Call()
        opcodeLookup[0x41] = Return()
        opcodeLookup[0x42] = SystemCall()
        opcodeLookup[0x44] = Zero()
        opcodeLookup[0x45] = LoadAddress()
        
        opcodeLookup[0x50] = Cmp()
        opcodeLookup[0x53] = Cast<Long>()
        opcodeLookup[0x54] = Cast<Word>()
        opcodeLookup[0x55] = Cast<Byte>()
        opcodeLookup[0x56] = TestZ()
        
        opcodeLookup[0x60] = Jmp()
        opcodeLookup[0x61] = ConditionalJump({ return  VPU.ZF })
        opcodeLookup[0x62] = ConditionalJump({ return !VPU.ZF })
        opcodeLookup[0x63] = ConditionalJump({ return  VPU.SF })
        opcodeLookup[0x64] = ConditionalJump({ return !VPU.SF })
        opcodeLookup[0x65] = ConditionalJump({ return  VPU.OF })
        opcodeLookup[0x66] = ConditionalJump({ return !VPU.OF })
        opcodeLookup[0x67] = ConditionalJump({ return !(VPU.SF ^ VPU.OF) && !VPU.ZF })
        opcodeLookup[0x68] = ConditionalJump({ return !(VPU.SF ^ VPU.OF) })
        opcodeLookup[0x69] = ConditionalJump({ return VPU.SF ^ VPU.OF })
        opcodeLookup[0x6a] = ConditionalJump({ return (VPU.SF ^ VPU.OF) || VPU.ZF })
        opcodeLookup[0x6b] = ConditionalJump({ return !VPU.CF && !VPU.ZF })
        opcodeLookup[0x6c] = ConditionalJump({ return !VPU.CF })
        opcodeLookup[0x6d] = ConditionalJump({ return VPU.CF })
        opcodeLookup[0x6e] = ConditionalJump({ return VPU.CF || VPU.ZF })
        
        opcodeLookup[0x80] = LoadFromImmediate<Quad>()
        opcodeLookup[0x81] = LoadFromImmediate<Long>()
        opcodeLookup[0x82] = LoadFromImmediate<Word>()
        opcodeLookup[0x83] = LoadFromImmediate<Byte>()
        
        opcodeLookup[0x88] = Load<Quad>()
        opcodeLookup[0x89] = Load<Long>()
        opcodeLookup[0x8a] = Load<Word>()
        opcodeLookup[0x8b] = Load<Byte>()
        opcodeLookup[0x8c] = Store<Quad>()
        opcodeLookup[0x8d] = Store<Long>()
        opcodeLookup[0x8e] = Store<Word>()
        opcodeLookup[0x8f] = Store<Byte>()
    }
    
    func generateInstruction(withOpcode opc: Byte) -> Instruction? {
        if let instruction = opcodeLookup[opc] {
            
            if let uai = instruction as? UnaryAddrInstruction {
                let operand = decoder.extractUnaryAddrInstruction()
                uai.setup(addr: operand)
                return uai
            }
            
            else if let bai = instruction as? BinaryAddrInstruction {
                let operands = decoder.extractBinaryAddrInstruction()
                bai.setup(reg: decoder.decodeRegister(from: operands.reg), addr: operands.addr)
                return bai
            }
            
            else if let ui = instruction as? UnaryInstruction {
                let operand = decoder.extractUnaryInstruction()
                let reg = decoder.decodeRegister(from: operand)
                ui.setup(src: reg)
                return ui
            }
            
            else if let bi = instruction as? BinaryInstruction {
                let operands = decoder.extractBinaryInstruction()
                let src = decoder.decodeRegister(from: operands.srcReg)
                let dst = decoder.decodeRegister(from: operands.dstReg)
                bi.setup(srca: src, dst: dst)
                return bi
            }
                
            else if let ti = instruction as? TernaryInstruction {
                let operands = decoder.extractTernaryInstruction()
                let srca = decoder.decodeRegister(from: operands.srcRegA)
                let srcb = decoder.decodeRegister(from: operands.srcRegB)
                let dst = decoder.decodeRegister(from: operands.dstReg)
                ti.setup(srca: srca, srcb: srcb, dst: dst)
                return ti
            }
            
            else if let vi = instruction as? VoidInstruction {
                return vi
            }
            
            else if let ii = instruction as? ImmediateInstruction {
                let operand = decoder.extractUnaryInstruction()
                let reg = decoder.decodeRegister(from: operand)
                ii.setup(reg: reg, extractor: decoder)
                return ii
            }
            
        }
        return nil
    }
    
}
