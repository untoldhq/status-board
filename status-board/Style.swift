//
//  Style.swift
//  status-board
//
//  Created by Sam Ingle on 9/17/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import UIKit

struct Brand {
    enum Color {
        case Primary
        case HighlightedText
        
        private func color() -> UIColor {
            switch self {
            case .Primary:
                return UIColor(red: 0.9215686275, green: 0.3254901961, blue: 0.4039215686, alpha: 1)
            case .HighlightedText:
                return UIColor.whiteColor()
            }
        }
    }
    
    enum Font {
        case Body
        
        private func font() -> UIFont {
            switch self {
            case .Body:
                return UIFont.systemFontOfSize(20)
            }
        }
    }
    
    static func color(color: Color) -> UIColor {
        return color.color()
    }
    static func font(font: Font) -> UIFont {
        return font.font()
    }
}
