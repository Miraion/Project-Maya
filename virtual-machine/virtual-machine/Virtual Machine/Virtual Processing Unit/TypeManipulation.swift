//
//  TypeManipulation.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-19.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

typealias Byte = UInt8
typealias Word = UInt16
typealias Long = UInt32
typealias Quad = UInt64

typealias SignedByte = Int8
typealias SignedWord = Int16
typealias SignedLong = Int32
typealias SignedQuad = Int64

typealias SinglePrecisionFloat = Float32
typealias DoublePrecisionFloat = Float64

func isolateHighestBit<T: BinaryInteger>(from x: T) -> Bool {
    return (x >> ((MemoryLayout<T>.size * 8) - 1)) != 0
}

func printHex(_ n: Quad) {
    print(String(format: "%#.016lx", n))
}

func printHex(_ n: Long) {
    print(String(format: "%#.08x", n))
}

func printHex(_ n: Word) {
    print(String(format: "%#.04x", n))
}

func printHex(_ n: Byte) {
    print(String(format: "%#.02x", n))
}
