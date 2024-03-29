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
    var routeType: Route.RouteType?
    var routeColor: UIColor?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        isOpaque = false
        frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if routeType == .lightRail {
            let context: CGContext = UIGraphicsGetCurrentContext()!
            
            let arrowPath = CGMutablePath()
            arrowPath.move(to: CGPoint(x: 20, y: 30))
            arrowPath.addLine(to: CGPoint(x: 36, y: 20))
            arrowPath.addLine(to: CGPoint(x: 20, y: 10))
//            arrowPath.addLine(to: CGPoint(x: 20, y: 14))
            arrowPath.addArc(center: CGPoint(x: 20, y: 20), radius: 10, startAngle: 3 * .pi / 2, endAngle: .pi / 2, clockwise: true)
            arrowPath.closeSubpath()
            context.addPath(arrowPath)
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(1)
            context.setFillColor((routeColor ?? UIColor.black).cgColor)
            context.drawPath(using: .fillStroke)


            
            
            return
        }
        let string = labelText as NSString
        let attributes = [
            NSAttributedStringKey.foregroundColor: Style.color(.highlightedText),
            NSAttributedStringKey.font: Style.font(.body)
        ]

        var size = string.size(withAttributes: attributes)
        size = CGSize(width: size.width + 4, height: size.height + 4)
        let rect = CGRect(
        x: (bounds.width - size.width) / 2,
        y: (bounds.height - size.height) / 2,
        width: size.width,
        height: size.height
        )


        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        let length: CGFloat = routeType == .bus ? 40 : 90
        
        let clipPath: CGPath = UIBezierPath(roundedRect: CGRect(x: (bounds.width - length) / 2, y: rect.origin.y, width: length, height: rect.size.height), cornerRadius: 6.0).cgPath
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 5);

        context.addPath(clipPath)
        context.setFillColor(Style.color(.primary).cgColor)
        
        context.closePath()
        context.fillPath()
        string.draw(in: rect, withAttributes: attributes)
    }

}
