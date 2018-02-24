//
//  VirtualRegister.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-19.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

// Virtual CPU Register Class
class VirtualRegister {
    private var data: Quad

    init () {
        self.data = 0
    }

    func get<T: BinaryInteger>(as: T.Type) -> T {
        return T(truncatingIfNeeded: data)
    }
    
    func set(_ newValue: UInt64) {
        data = newValue
    }
    
    func set<T: BinaryInteger>(_ newValue: T) {
        data = UInt64(bitPattern: Int64(newValue))
    }
    
    func zero() {
        data = 0
    }
    
    func copy(_ other: VirtualRegister) {
        data = other.data
    }
}

// Interface Properties
extension VirtualRegister {
    
    var floats: SinglePrecisionFloat {
        get {
            return SinglePrecisionFloat(bitPattern: get(as: Long.self))
        }
        set {
            data = UInt64(newValue.bitPattern)
        }
    }
    
    var floatd: DoublePrecisionFloat {
        get {
            return DoublePrecisionFloat(bitPattern: data)
        }
        set {
            data = newValue.bitPattern
        }
    }
    
    var byte: Byte {
        get {
            return Byte(truncatingIfNeeded: data)
        }
        set {
            data = Quad(newValue)
        }
    }
    
    var word: Word {
        get {
            return Word(truncatingIfNeeded: data)
        }
        set {
            data = Quad(newValue)
        }
    }
    
    var long: Long {
        get {
            return Long(truncatingIfNeeded: data)
        }
        set {
            data = Quad(newValue)
        }
    }
    
    var quad: Quad {
        get {
            return data
        }
        set {
            data = newValue
        }
    }
    
}










