//
//  CGFloat+Trig.swift
//  status-board
//
//  Created by Sam Ingle on 9/17/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    
    func toRadians() -> CGFloat {
        return self * CGFloat(Float.pi) / 180
    }
    func toDegrees() -> CGFloat {
        return self * 180 / CGFloat(Float.pi)
    }
    
}
