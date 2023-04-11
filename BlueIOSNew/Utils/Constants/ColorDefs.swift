//
//  ColorDefs.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit

class ColorDefs {
    
    // Color modes
    enum ColorMode: Int {
        case OFF, STATIC, RANDOM1, RANDOM2, SEQ1, SEQ2, BOOMERANG1, BOOMERANG2, CALEDOSCOPY, STROBE, CUSTOM
    }
    
    // Color statics
    enum ColorStatic: Int {
        case WHITE, CYAN, BLUE, PINK, MAGENTA, RED, ORANGE, YELLOW, GREEN, CUSTOM
    }
    
    // All colors Bright normalization
    static let HSBBrightScale: [Int] = [ 0, 3, 5, 8, 11, 13, 17, 21, 27, 35, 50 ]
    
}
