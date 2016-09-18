//
//  ViewController.swift
//  status-board
//
//  Created by Sam Ingle on 9/6/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import UIKit
import RealmSwift

class TrimetViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!

    lazy var dataSource: Results<WatchedDestination>! = {
        return Data.objects(WatchedDestination.self)
    }()
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = collectionView.collectionViewLayout as! DestinationLayout
        layout.registerClass(DestinationDecorationView.self, forDecorationViewOfKind: "signage")
        
        notificationToken = dataSource.addNotificationBlock { [weak self] changes in
            guard let collectionView = self?.collectionView else {
                return
            }
            switch changes {
            case .Initial:
                collectionView.reloadData()
            case .Update(_, let deletions, let insertions, let modifications):
                collectionView.performBatchUpdates({
                    if let strongSelf = self {
                        collectionView.insertItemsAtIndexPaths(insertions.map(strongSelf.transformIndexPath))
                        collectionView.deleteItemsAtIndexPaths(deletions.map(strongSelf.transformIndexPath))
                    }
                }, completion: nil)
                if let strongSelf = self {
                    self?.updateRowsAtIndexPaths(modifications.map(strongSelf.transformIndexPath))
                }
            case .Error(let error):
                print(error)
            }
        }
    }

    func transformIndexPath(index: Int) -> NSIndexPath {
        let item = index % maxItemsPerSection()
        let section = index / maxItemsPerSection()
        return NSIndexPath(forItem: item, inSection: section)
    }
    
    func reverseTransformIndexPath(indexPath: NSIndexPath) -> Int {
        return indexPath.section * maxItemsPerSection() + indexPath.row
    }
    func updateRowsAtIndexPaths(paths: [NSIndexPath]) {
        for indexPath in paths {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TrimetDestinationCell {
                updateLabelsForCell(cell, indexPath: indexPath)
            }
        }
    }
    
    func updateLabelsForCell(cell: TrimetDestinationCell, indexPath: NSIndexPath) {
        let destination = dataSource[reverseTransformIndexPath(indexPath)]
        cell.routeLabel.text = destination.route.name
        cell.stopLabel.text = destination.stop.name
        if let arrival = destination.nextArrival?.timeIntervalSince1970 {
            let now = NSDate().timeIntervalSince1970
            let difference = arrival - now
            if difference > 0 {
                cell.timeLabel.text = "\(Int(difference / 60))m"
            }
            else {
                cell.timeLabel.text = "Unknown"
            }
            cell.directionLabel.text = destination.stop.directionality
            cell.vehicleImageView.image = destination.route.routeType == .Bus ? UIImage(named: "bus") : UIImage(named: "rail")
//            if destination.route.routeType == .Bus {
//                cell.routeNumberLabel.text = destination.route.compactLabel
//            }
//            else {
//                cell.routeNumberLabel.text = ""
//            }
        }
        else {
            cell.timeLabel.text = "Unknown"
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func maxItemsPerSection() -> Int {
        let layout = collectionView.collectionViewLayout as! DestinationLayout
        return layout.maxItemsPerSection(collectionView)
    }

}

extension TrimetViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! TrimetDestinationCell
        updateLabelsForCell(cell, indexPath: indexPath)
        return cell
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        maxItemsPerSection()
        let sections = numberOfSectionsInCollectionView(collectionView)
        if section != sections - 1 {
            return maxItemsPerSection()
        }
        let fullSections = dataSource.count / maxItemsPerSection()
        return dataSource.count - fullSections * maxItemsPerSection()
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return Int(ceil(CGFloat(dataSource.count) / CGFloat(maxItemsPerSection())))
    }
}
