//
//  ExecutableInitalizationHeader.swift
//  assembler
//
//  Created by Jeremy S on 2018-03-09.
//  Copyright © 2018 Jeremy S. All rights reserved.
//

import Foundation


let executableInitalizationHeader: String =
"""
section text
    call    main
    move.l  rx, r0
    set.b   7, rx
    syscall
"""
