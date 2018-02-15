//
//  JBFont.swift
//  Pods
//
//  Created by Joost van Breukelen on 07-02-17.
//
//

import UIKit

public final class JBFont: NSObject {
    
    var fontName: String
    var fontSize: JBFontSize
    
    public init(name: String = "", size: JBFontSize = .medium) {
        
        self.fontName = name
        self.fontSize = size
    }
    

    
}
