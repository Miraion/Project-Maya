//
//  FileTypes.swift
//  assembler
//
//  Created by Jeremy S on 2018-02-28.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

/// File type for an input source file.
typealias InputFile = InputStream

/// File type for a fully compiled and linked binary file.
class ExecutableFile {
    
    /// Underlying BinaryStream attribute.
    var binary = BinaryStream()
    
    /// Writes the binary file to disk at a given path.
    func write(to name: String) {
        binary.write(to: name)
    }
    
}
