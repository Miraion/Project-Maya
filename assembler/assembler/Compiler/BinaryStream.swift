//
//  BinaryFile.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-22.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class BinaryStream {
    
    private var data = NSMutableData()
    
    /// Readonly access to the raw bytes stored in the file.
    var bytes: UnsafeRawPointer {
        return data.bytes
    }
    
    /// Mutable access to the raw bytes stored in the file.
    var mutablebytes: UnsafeMutableRawPointer {
        return data.mutableBytes
    }
    
    /// The number of bytes in the file.
    var length: Int {
        return data.length
    }
    
    /// Appends the byte representation of an integer literal to the binary file.
    func append<I: FixedWidthInteger>(_ n: I, as: I.Type) {
        let ptr = UnsafeMutablePointer<I>.allocate(capacity: 1)
        ptr.pointee = n
        let raw = UnsafeRawPointer(ptr)
        data.append(raw, length: MemoryLayout<I>.size)
        ptr.deinitialize()
        ptr.deallocate(capacity: 1)
    }
    
    /// Appends a single byte to the binary file.
    func append(byte: UInt8) {
        append(byte, as: UInt8.self)
    }
    
    @discardableResult
    func append(char: Character) -> Bool {
        let str = String(char)
        let byteMap: [UInt8] =  str.utf8.map{ UInt8($0) }
        if byteMap.count == 0 {
            return false
        } else {
            append(byte: byteMap[0])
            return true
        }
    }
    
    @discardableResult
    func append(string: String) -> Bool {
        if let cstr = string.cString(using: .utf8) {
            for c in cstr {
                append(c, as: Int8.self)
            }
            return true
        } else {
            return false
        }
    }
    
    func append(bytes: [UInt8]) {
        for byte in bytes {
            append(byte: byte)
        }
    }
    
    func replace<I: FixedWidthInteger>(at index: Int, with n: I) {
        let ptr = UnsafeMutablePointer<I>.allocate(capacity: 1)
        ptr.pointee = n
        let raw = UnsafeRawPointer(ptr)
        data.replaceBytes(in: NSMakeRange(index, MemoryLayout<I>.size), withBytes: raw)
        ptr.deinitialize()
        ptr.deallocate(capacity: 1)
    }
    
    /// Writes the data stream to an external file.
    func write(to file: String) {
        let url = URL(fileURLWithPath: file)
        data.write(to: url, atomically: true)
    }
    
}
