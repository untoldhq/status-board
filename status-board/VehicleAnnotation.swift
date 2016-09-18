//
//  VehicleAnnotation.swift
//  status-board
//
//  Created by Sam Ingle on 9/17/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import MapKit

class VehicleAnnotation: MKPointAnnotation {
    let vehicleId: Int
    init(id: Int) {
        vehicleId = id
        super.init()
    }
}

class VehicleAnnotationView: MKAnnotationView {
    var labelText = ""
    var routeType: Route.RouteType!

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        opaque = false
        frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let string = labelText as NSString
        let attributes = [
            NSForegroundColorAttributeName: Style.color(.HighlightedText),
            NSFontAttributeName: Style.font(.Body)
        ]

        var size = string.sizeWithAttributes(attributes)
        size = CGSize(width: size.width + 4, height: size.height + 4)
        let rect = CGRect(
        x: (bounds.width - size.width) / 2,
        y: (bounds.height - size.height) / 2,
        width: size.width,
        height: size.height
        )


        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        
        let length: CGFloat = routeType == .Bus ? 40 : 90
        
        let clipPath: CGPathRef = UIBezierPath(roundedRect: CGRect(x: (bounds.width - length) / 2, y: rect.origin.y, width: length, height: rect.size.height), cornerRadius: 6.0).CGPath
        CGContextSetShadow(context, CGSizeMake(0, 0), 5);

        CGContextAddPath(context, clipPath)
        CGContextSetFillColorWithColor(context, Style.color(.Primary).CGColor)
        
        CGContextClosePath(context)
        CGContextFillPath(context)
        string.drawInRect(rect, withAttributes: attributes)
    }

}
