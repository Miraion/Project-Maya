//
//  VirtualRegister.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-19.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

/// Virtual CPU Register Class
class VirtualRegister {
    /// Internal state, stored as a 64-bit unsigned integer.
    private var data: Quad

    /// Initalizes the internal state to 0.
    init () {
        self.data = 0
    }

    /// Returns the internal state as a given type, truncating the data if needed.
    func get<T: BinaryInteger>(as: T.Type) -> T {
        return T(truncatingIfNeeded: data)
    }
    
    /// Override of the generic `set` method. Does not preform any type casting.
    func set(_ newValue: UInt64) {
        data = newValue
    }
    
    /// Sets the internal state from a given binary integer type.
    func set<T: BinaryInteger>(_ newValue: T) {
        data = UInt64(bitPattern: Int64(clamping: newValue))
    }
    
    /// Sets the internal state to 0.
    func zero() {
        data = 0
    }
    
    /// Copies the state of one register into this register.
    func copy<T: FixedWidthInteger>(_ other: VirtualRegister, as: T.Type) {
        set(other.get(as: T.self))
    }
}

// Interface Properties
extension VirtualRegister {
    
    /// Single precision floating point register interface.
    var floats: SinglePrecisionFloat {
        get {
            return SinglePrecisionFloat(bitPattern: get(as: Long.self))
        }
        set {
            data = UInt64(newValue.bitPattern)
        }
    }
    
    /// Double precision floating point register interface.
    var floatd: DoublePrecisionFloat {
        get {
            return DoublePrecisionFloat(bitPattern: data)
        }
        set {
            data = newValue.bitPattern
        }
    }
    
    /// 8-bit unsigned integer register interface.
    var byte: Byte {
        get {
            return Byte(truncatingIfNeeded: data)
        }
        set {
            data = Quad(newValue)
        }
    }
    
    /// 16-bit unsigned integer register interface.
    var word: Word {
        get {
            return Word(truncatingIfNeeded: data)
        }
        set {
            data = Quad(newValue)
        }
    }
    
    /// 32-bit unsigned integer register interface.
    var long: Long {
        get {
            return Long(truncatingIfNeeded: data)
        }
        set {
            data = Quad(newValue)
        }
    }
    
    /// 64-bit unsigned integer register interface.
    var quad: Quad {
        get {
            return data
        }
        set {
            data = newValue
        }
    }
    
}










