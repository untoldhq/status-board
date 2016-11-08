//
//  Style.swift
//  status-board
//
//  Created by Sam Ingle on 9/17/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import UIKit

struct Style {
    enum Color {
        case primary
        case highlightedText
        case signage
        case dark
        
        fileprivate func color() -> UIColor {
            switch self {
            case .primary:
                return UIColor(red: 0.9215686275, green: 0.3254901961, blue: 0.4039215686, alpha: 1)
            case .highlightedText:
                return UIColor.white
            case .signage:
                return UIColor(red:0.29, green:0.66, blue:0.47, alpha:1.0)
            case .dark:
                return UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
            }
        }
    }
    
    enum Font {
        case body
        
        fileprivate func font() -> UIFont {
            switch self {
            case .body:
                return UIFont.systemFont(ofSize: 20)
            }
        }
    }
    
    static func color(_ color: Color) -> UIColor {
        return color.color()
    }
    static func font(_ font: Font) -> UIFont {
        return font.font()
    }
}
