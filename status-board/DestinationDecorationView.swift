//
//  DestinationDecorationView.swift
//  status-board
//
//  Created by Sam Ingle on 9/18/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import UIKit

class DestinationDecorationView: UICollectionReusableView {
    
    static let layoutInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Style.color(.Dark)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let contentInset = DestinationDecorationView.layoutInsets.top
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSaveGState(context)
        let clipPath: CGPathRef = UIBezierPath(roundedRect: CGRectInset(bounds, contentInset - 30, contentInset - 30), cornerRadius: 10.0).CGPath
        CGContextSetShadow(context, CGSizeMake(0, 0), 5);
        
        CGContextAddPath(context, clipPath)
        CGContextSetFillColorWithColor(context, Style.color(.Signage).CGColor)
        
        CGContextClosePath(context)
        CGContextFillPath(context)
        CGContextRestoreGState(context)
        
        CGContextSaveGState(context)
        let inset: CGPathRef = UIBezierPath(roundedRect: CGRectInset(bounds, contentInset - 15, contentInset - 15), cornerRadius: 8.0).CGPath
        CGContextAddPath(context, inset)
        CGContextSetFillColorWithColor(context, Style.color(.Signage).CGColor)
        CGContextSetLineWidth(context, 5)
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextClosePath(context)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)

    }
}
