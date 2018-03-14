//
//  ObjectFile.swift
//  assembler
//
//  Created by Jeremy S on 2018-02-28.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

// Object File Metadata Overview
// Header:
//  Number of global label declarations (x: UInt64)
//  Number of unprocessed label declarations (y: UInt64)
//
// Declarations:
// Global Label Map:
//  Exactly x map declarations in the format (loc: UInt64, name: UTF-8 Null Terminated String)
// Followed directly by,
// Unprocessed Label Map:
//  Exactly y map declarations in the format (count: UInt64, locs: [UInt64], name: UTF-8 Null Terminated String)
//  where count == the size of the array locs


/// File type for a compiled object file.
/// Contains the compiled binary, along with maps containing the name + location
/// of all the global, and unprocessed labels within the compiled binary.
class ObjectFile {
    
    /// Underlying BinaryStream attribute.
    var binary: BinaryStream
    
    /// The location of each global label in the binary mapped to the name of the label.
    var globalLabelMap = [String : Int]()
    
    /// The location of each unprocessed label in the binary mapped to the name of the label.
    var unprocessedLabelMap = [String : [Int]]()
    
    /// Creates an empty object file.
    init () {
        self.binary = BinaryStream()
    }
    
    /// Creates an object file from an existing `BinaryStream` object parsing out
    /// any metadata contained in the stream.
    init? (from binaryStream: BinaryStream) {
        self.binary = BinaryStream()
        if let stream = extractMetadata(from: binaryStream) {
            self.binary = stream
        } else {
            return nil
        }
    }
    
    /// Opens an existing object file from disk.
    /// Extracts the metadata from the binary file, initalizing the maps with it.
    /// The resulting binary stream will not contain the metadata.
    init? (open file: String) {
        if let stream = BinaryStream(open: file) {
            self.binary = BinaryStream()
            if let noMetaStream = extractMetadata(from: stream) {
                self.binary = noMetaStream
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    /// Writes the binary file to disk at a given path.
    func write(to name: String) {
        let stream = BinaryStream()
        stream.append(UInt64(globalLabelMap.count), as: UInt64.self)
        stream.append(UInt64(unprocessedLabelMap.count), as: UInt64.self)
        for mapItem in globalLabelMap {
            stream.append(UInt64(mapItem.value), as: UInt64.self)
            stream.append(string: mapItem.key)
        }
        for mapItem in unprocessedLabelMap {
            stream.append(UInt64(mapItem.value.count), as: UInt64.self)
            for loc in mapItem.value {
                stream.append(UInt64(loc), as: UInt64.self)
            }
            stream.append(string: mapItem.key)
        }
        stream.append(binary)
        stream.write(to: name)
    }
    
    
    private func extractMetadata(from stream: BinaryStream) -> BinaryStream? {
        guard let globalCount = stream.extract(as: UInt64.self) else { return nil }
        guard let unprocessedCount = stream.extract(as: UInt64.self) else { return nil }
        
        for _ in 0..<globalCount {
            guard let loc = stream.extract(as: UInt64.self) else { return nil }
            guard let name = stream.extractNullTerminatingString() else { return nil }
            globalLabelMap[name] = Int(loc)
        }
        
        for _ in 0..<unprocessedCount {
            guard let count = stream.extract(as: UInt64.self) else { return nil }
            var locs = [Int]()
            for _ in 0..<count {
                guard let loc = stream.extract(as: UInt64.self) else { return nil }
                locs.append(Int(loc))
            }
            guard let name = stream.extractNullTerminatingString() else { return nil }
            unprocessedLabelMap[name] = locs
        }
        
        return BinaryStream(NSMutableData(bytes: stream.cursor,
                                          length: stream .length - abs(stream.cursor.distance(to: stream.mutablebytes))))
    }
    
}
