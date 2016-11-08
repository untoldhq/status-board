//
//  DestinationLayout.swift
//  status-board
//
//  Created by Sam Ingle on 9/18/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import UIKit

class DestinationLayout: UICollectionViewFlowLayout {
    
    let sectionWidth = UIScreen.main.bounds.size.width / 2

    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
        layoutAttributes.frame = CGRect(x: CGFloat(indexPath.section) * sectionWidth, y: 0, width: sectionWidth, height: collectionViewContentSize.height)
        layoutAttributes.zIndex = -1
        return layoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else {
            return nil
        }
        var attributes = [UICollectionViewLayoutAttributes]()
        for i in 0..<collectionView.numberOfSections {
            if let attribute = layoutAttributesForDecorationView(ofKind: "signage", at: IndexPath(item: 0, section: i)) {
                attributes.append(attribute)
            }
        }
        for i in 0..<collectionView.numberOfSections {
            for j in 0..<collectionView.numberOfItems(inSection: i) {
                if let attribute = layoutAttributesForItem(at: IndexPath(item: j, section: i)) {
                    attributes.append(attribute)
                }
            }
        }
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else {
            return nil
        }
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let rect = CGRect(
            x: CGFloat(indexPath.section) * sectionWidth,
            y: 0,
            width: sectionWidth,
            height: collectionView.bounds.height)
        let inset = UIEdgeInsetsInsetRect(rect, DestinationDecorationView.layoutInsets)
        
        let itemHeight: CGFloat = inset.height / CGFloat(maxItemsPerSection(collectionView))
        attributes.frame = CGRect(
            x: inset.origin.x,
            y: inset.origin.y + CGFloat(indexPath.item) * itemHeight,
            width: inset.width,
            height: itemHeight)
        return attributes
    }
    
    func maxItemsPerSection(_ collectionView: UICollectionView) -> Int {
        let itemHeight = UIScreen.main.bounds.size.height / 6
        return Int(collectionView.bounds.size.height / itemHeight)
    }
    
    override var collectionViewContentSize : CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }
        return CGSize(width: sectionWidth * CGFloat(collectionView.numberOfSections), height: collectionView.bounds.height)
    }
}
