//
//  FixedWidthIntegerExtension.swift
//  virtual-machine
//
//  Created by Jeremy S on 2018-03-07.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation

extension FixedWidthInteger {
    /**
     Shift bits left, reporting if an overflow occurs.
     
     - parameter ammount: How far to shift the bytes.
     */
    func shiftingLeftReportingOverflow<I: FixedWidthInteger>(_ ammount: I) -> (partialValue: I, overflow: Bool) {
        let result = I(self) &<< ammount
        return (result, result.nonzeroBitCount != I(self).nonzeroBitCount)
    }
    
    /**
     Shift bits right, reporting if an overflow occurs.
    
     - parameter ammount: How far to shift the bytes.
     
     - warning: This function has yet to be tested to see if it works as intended.
     */
    func shiftingRightReportingOverflow<I: FixedWidthInteger>(_ ammount: I) -> (partialValue: I, overflow: Bool) {
        let result = I(self) &>> ammount
        return (result, result.nonzeroBitCount != I(self).nonzeroBitCount)
    }
    
}
