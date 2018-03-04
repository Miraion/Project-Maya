//
//  Linker.swift
//  assembler
//
//  Created by Jeremy S on 2018-02-28.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

/**
 Delegate responsable for linking compiled binary files into archives or executables.
 */
class Linker {
    
    private var initFile: ObjectFile? = nil
    
    
    /**
     Loads the precompiled executable initalization file.
     Must be called before attempting to call `linkToExecutable(_: [ObjectFiles])`.
     
     - parameter path: The path of the initalization file.
     
     - throws: `AssemberError.Default` if unable to open the given file.
     
     */
    func setInitFile(to path: String) throws {
        if let file = ObjectFile(open: path) {
            self.initFile = file
        } else {
            throw AssemblerError.Default(msg: "Unable to find executable initalization file.")
        }
    }
    
    
    /**
     Links a series of object files into a single object file merging all of their metadata.
     
     - parameter objFiles: An array of object files to link together.
     
     - returns:
        An `ObjectFile` containing all of the binary data and metadata from the
        original files.
     
     - throws:
        `AssemblerError.DuplicateSymbol` if two or more global labels with the
        same name are found while linking.
    */
    func linkToArchive(_ objFiles: [ObjectFile]) throws -> ObjectFile {
        let main = ObjectFile()
        var byteCount = 0
        for file in objFiles {
            byteCount = main.binary.length
            main.binary.append(file.binary)
            file.globalLabelMap = file.globalLabelMap.mapValues({ return $0 + byteCount })
            
            // Attempt to merge global label data.
            // Since no two global labels may have the same name, throw an error if such an instance occurs.
            try main.globalLabelMap.merge(file.globalLabelMap, uniquingKeysWith: { (current, _) throws in
                let key = main.globalLabelMap.first(where: { $0.value == current })!.key
                throw AssemblerError.DuplicateSymbol(symbol: key)
            })
            
            // Merge unprocessed label data.
            file.unprocessedLabelMap = file.unprocessedLabelMap.mapValues({ (value) in
                return value.map({ return $0 + byteCount })
            })
            main.unprocessedLabelMap.merge(file.unprocessedLabelMap, uniquingKeysWith: { (current, new) in
                var seq = current
                seq.append(contentsOf: new.map({ (_ pos: Int) -> Int in
                    return pos
                }))
                return seq
            })
        }
        
        // Try and fill in any unprocessed labels with labels from the global data.
        for upLabel in main.unprocessedLabelMap {
            if let globalLabelPos = main.globalLabelMap[upLabel.key] {
                for pos in upLabel.value {
                    main.binary.replace(at: pos, with: UInt64(bitPattern: Int64(globalLabelPos) - Int64(pos) - 8))
                    main.unprocessedLabelMap.removeValue(forKey: upLabel.key)
                }
            }
        }
        
        return main
    }
    
    
    /**
     Links a series of object files into a runnable exacutable.
     
     - parameter objFiles: An array of object files to link into an executable.
     
     - returns:
        An `Executable File` consisting of the linked binary data from the original object
        files along with some initalization data to allow execution.
     
     - throws:
        `AssemblerError.UndefinedSymbols` if there are any remaining unprocessed labels
        after linking.
     
     - requires: `setInitFile(to: String)` to be sucessfully called.
     
     */
    func linkToExecutable(_ objFiles: [ObjectFile]) throws -> ExecutableFile {
        let main = ExecutableFile()
        var filesToLink = [initFile!]
        filesToLink.append(contentsOf: objFiles)
        let linkedArchive = try linkToArchive(filesToLink)
        main.binary = linkedArchive.binary
        if linkedArchive.unprocessedLabelMap.count != 0 {
            throw AssemblerError.UndefinedSymbols(symbols: [String](linkedArchive.unprocessedLabelMap.keys))
        }
        return main
    }
    
}
