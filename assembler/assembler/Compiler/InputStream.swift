//
//  InputStream.swift
//  mia_assembler
//
//  Created by Jeremy S on 2018-02-22.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

class InputStream {
    
    let filename: String
    private let contents: [UInt8]
    private var index = 0
    private(set) var lineNum = 0
    
    /// Attempts to create an input stream from a given file.
    /// Will return nil if unable to do so.
    init? (file: String) {
        self.filename = file
        do {
            self.contents = try String(contentsOfFile: filename).utf8.map { $0 }
        } catch {
            return nil
        }
    }
    
    /// Extracts a single utf8 character from the stream.
    /// Returns nil if there are no remaining characters in the stream.
    @discardableResult
    func extract() -> UInt8? {
        if index < contents.count {
            let c = contents[index]
            index += 1
            if c == 10 {
                lineNum += 1
            }
            return c
        } else {
            return nil
        }
    }
    
    /// Returns the next character in the stream without removing it.
    /// Returns nil if there are not more characters in the stream.
    func peek() -> UInt8? {
        if index < contents.count {
            let c = contents[index]
            return c
        } else {
            return nil
        }
    }
    
}
