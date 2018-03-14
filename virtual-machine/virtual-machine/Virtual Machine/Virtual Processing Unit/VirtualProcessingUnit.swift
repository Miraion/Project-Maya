//
//  VirtualProcessingUnit.swift
//  ivm
//
//  Created by Jeremy S on 2018-02-20.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

/// Class to represent the virtual cpu.
///
/// - todo: Expand the VPU to provide multi core support.
class VirtualProcessingUnit {
    
    /// A single cpu core, containing all 16 registers.
    var core = VirtualCore()
    
}
