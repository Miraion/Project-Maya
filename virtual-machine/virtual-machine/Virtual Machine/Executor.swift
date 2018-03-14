//
//  Executer.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class Executor {
    var opcodeLookup = [Byte : Instruction]()
    let decoder: FileDecoder
    
    /// Initalization from a pointer to a compiled source file which is loaded in memory.
    ///
    /// During initalization, the `opcodeLookup` map is populated with
    init (basePtr: UnsafePointer<Byte>, size: Int) {
        self.decoder = FileDecoder(basePtr: basePtr, size: size)
        
        opcodeLookup[0x10] = LoadDirect()
        opcodeLookup[0x11] = LoadIndirect()
        opcodeLookup[0x12] = StoreDirect()
        opcodeLookup[0x13] = StoreIndirect()
        opcodeLookup[0x14] = Move()
        opcodeLookup[0x15] = Set()
        
        opcodeLookup[0x20] = IntegerAddition()
        opcodeLookup[0x21] = IntegerSubtraction()
        opcodeLookup[0x22] = IntegerMultiplication()
        opcodeLookup[0x23] = IntegerDivision()
        opcodeLookup[0x24] = IntegerNegation()
        opcodeLookup[0x25] = Increment()
        opcodeLookup[0x26] = Decrement()
        opcodeLookup[0x27] = Zero()
        opcodeLookup[0x28] = And()
        opcodeLookup[0x29] = Or()
        opcodeLookup[0x2a] = Xor()
        opcodeLookup[0x2b] = Not()
        opcodeLookup[0x2c] = ShiftLeft()
        opcodeLookup[0x2d] = ShiftRight()
        opcodeLookup[0x40] = IntegerModulo()
        
        opcodeLookup[0x30] = Call()
        opcodeLookup[0x31] = Return()
        opcodeLookup[0x32] = SystemCall()
        opcodeLookup[0x33] = LoadAddress()
        opcodeLookup[0x34] = TestZero()
        opcodeLookup[0x35] = Compare()
        opcodeLookup[0x36] = Push()
        opcodeLookup[0x37] = Pop()
        
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
        
    }
    
    /**
     Creates an instruction object from a given opcode by extracting operands from the internal `FileDecoder` object.
     
     - returns:
        An instruction object which is fully setup and ready to call its `run` method to execute the instruction. Or
        `nil` if unable to map the opcode to an instruction via the `opcodeLookup` map.
     */
    func generateInstruction(withOpcode opc: Byte) -> Instruction? {
        // Retrieve instruction from lookup table.
        if let instruction = opcodeLookup[opc] {
            
            // Process unary-address-type instruction.
            if let uai = instruction as? UnaryAddrInstruction {
                let operand = decoder.extractUnaryAddrInstruction()
                uai.setup(addr: operand)
                return uai
            }
            
            // Process binary-address-type instruction.
            else if let bai = instruction as? BinaryAddrInstruction {
                let operands = decoder.extractBinaryAddrInstruction()
                bai.setup(reg: decoder.decodeRegister(from: operands.reg), addr: operands.addr)
                
                let modifier = operands.mod
                if var modInstruction = instruction as? ModdableInstruction {
                    modInstruction.set(modifier: modifier)
                }
                return bai
            }
            
            // Process unary-type instruction.
            else if let ui = instruction as? UnaryInstruction {
                let operands = decoder.extractUnaryInstruction()
                let reg = decoder.decodeRegister(from: operands.reg)
                ui.setup(src: reg)
                
                let modifier = operands.mod
                if var modInstruction = instruction as? ModdableInstruction {
                    modInstruction.set(modifier: modifier)
                }
                return ui
            }
            
            // Process binary-type instruction.
            else if let bi = instruction as? BinaryInstruction {
                let operands = decoder.extractBinaryInstruction()
                let src = decoder.decodeRegister(from: operands.srcReg)
                let dst = decoder.decodeRegister(from: operands.dstReg)
                bi.setup(srca: src, dst: dst)
                
                let modifier = operands.mod
                if var modInstruction = instruction as? ModdableInstruction {
                    modInstruction.set(modifier: modifier)
                }
                return bi
            }
                
            // Process ternay-type instruction.
            else if let ti = instruction as? TernaryInstruction {
                let operands = decoder.extractTernaryInstruction()
                let srca = decoder.decodeRegister(from: operands.srcRegA)
                let srcb = decoder.decodeRegister(from: operands.srcRegB)
                let dst = decoder.decodeRegister(from: operands.dstReg)
                ti.setup(srca: srca, srcb: srcb, dst: dst)
                
                let modifier = operands.mod
                if var modInstruction = instruction as? ModdableInstruction {
                    modInstruction.set(modifier: modifier)
                }
                return ti
            }
            
            // Process void-type instruction.
            else if let vi = instruction as? VoidInstruction {
                return vi
            }
            
            // Process immediate-type instruction.
            else if let ii = instruction as? ImmediateInstruction {
                let operands = decoder.extractUnaryInstruction()
                let reg = decoder.decodeRegister(from: operands.reg)
                ii.setup(reg: reg, extractor: decoder)
                
                let modifier = operands.mod
                if var modInstruction = instruction as? ModdableInstruction {
                    modInstruction.set(modifier: modifier)
                }
                return ii
            }
            
        }
        return nil
    }
    
}
