//
//  HeadquartersAnnotation.swift
//  status-board
//
//  Created by Grady Shelton 4/17/19
//  Copyright © 2019 Untold. All rights reserved.
//

import Foundation
import MapKit

class HeadquartersAnnotation: MKPointAnnotation {
}

class HeadquartersAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        isOpaque = false
        frame = CGRect(x: 0, y: 0, width: 102, height: 102)
        transform = transform.scaledBy(x: 0.35, y: 0.35)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let image = UIImage(named: "blue-bolt-annotation")
        image?.draw(at: CGPoint.zero)
    }
}
