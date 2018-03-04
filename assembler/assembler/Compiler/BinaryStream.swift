//
//  BinaryFile.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-22.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class BinaryStream {
    
    private var data: NSMutableData
    
    private(set) var cursor: UnsafeMutableRawPointer
    
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
    
    /// Creates a new binary stream from a new NSMutableData object.
    init () {
        self.data = NSMutableData()
        self.cursor = data.mutableBytes
    }
    
    /// Direct initalization from a NSMutableData object.
    init (_ data: NSMutableData) {
        self.data = data
        self.cursor = data.mutableBytes
    }
    
    /// Attempts to create a binary stream from a given file.
    init? (open file: String) {
        if let file = NSMutableData(contentsOfFile: file) {
            self.data = file
            self.cursor = data.mutableBytes
        } else {
            return nil
        }
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
    
    /// Appends a single character using UTF-8 encoding.
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
    
    /// Appends a string using UTF-8 encoding.
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
    
    /// Appends the contents of another binary stream.
    func append(_ other: BinaryStream) {
        self.data.append(other.data as Data)
    }
    
    /// Appends an ordered array of bytes.
    func append(bytes: [UInt8]) {
        for byte in bytes {
            append(byte: byte)
        }
    }
    
    /// Replaces the bytes at a given location with a given integer.
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
    
    /// Extracts an integer of a given size from the stream.
    /// Returns `nil` if there is not enought bytes left in the stream.
    func extract<I: FixedWidthInteger>(as: I.Type) -> I? {
        if cursor.distance(to: mutablebytes) > (length - MemoryLayout<I>.stride) {
            return nil
        } else {
            let x = cursor.assumingMemoryBound(to: I.self).pointee
            cursor = cursor.advanced(by: MemoryLayout<I>.stride)
            return x
        }
    }
    
    /// Extracts a given number of bytes from the stream.
    /// Returns `nil` if there is not enought bytes left in the stream.
    func extractBytes(size: Int) -> [UInt8]? {
        if cursor.distance(to: mutablebytes) > (length - size) {
            return nil
        } else {
            let ptr = cursor.assumingMemoryBound(to: UInt8.self)
            var arr = [UInt8]()
            for i in 0..<size {
                arr.append(ptr.advanced(by: i).pointee)
            }
            return arr
        }
    }
    
    /// Extracts bytes from the stream until a byte with value 0x00 is encoutered.
    /// The null byte is also extracted from the stream.
    func extractNullTerminatingString(encoding: String.Encoding = .utf8) -> String? {
        var byteArray = [UInt8]()
        while let c = extract(as: UInt8.self), c != 0 {
            byteArray.append(c)
        }
        
        if byteArray.count == 0 {
            return nil
        } else {
            return String(bytes: byteArray, encoding: encoding)
        }
    }
    
}
