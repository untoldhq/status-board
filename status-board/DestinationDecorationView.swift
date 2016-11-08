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
        backgroundColor = Style.color(.dark)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let contentInset = DestinationDecorationView.layoutInsets.top
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        let clipPath: CGPath = UIBezierPath(roundedRect: bounds.insetBy(dx: contentInset - 30, dy: contentInset - 30), cornerRadius: 10.0).cgPath
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 5);
        
        context.addPath(clipPath)
        context.setFillColor(Style.color(.signage).cgColor)
        
        context.closePath()
        context.fillPath()
        context.restoreGState()
        
        context.saveGState()
        let inset: CGPath = UIBezierPath(roundedRect: bounds.insetBy(dx: contentInset - 15, dy: contentInset - 15), cornerRadius: 8.0).cgPath
        context.addPath(inset)
        context.setFillColor(Style.color(.signage).cgColor)
        context.setLineWidth(5)
        context.setStrokeColor(UIColor.white.cgColor)
        context.closePath()
        context.strokePath()
        context.restoreGState()

    }
}
