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
        return Data.objects(ofType: WatchedDestination.self)
    }()
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = collectionView.collectionViewLayout as! DestinationLayout
        layout.register(DestinationDecorationView.self, forDecorationViewOfKind: "signage")
        
        notificationToken = dataSource.addNotificationBlock { [weak self] changes in
            guard let collectionView = self?.collectionView else {
                return
            }
            switch changes {
            case .initial:
                collectionView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                collectionView.performBatchUpdates({
                    if let strongSelf = self {
                        collectionView.insertItems(at: insertions.map(strongSelf.transformIndexPath))
                        collectionView.deleteItems(at: deletions.map(strongSelf.transformIndexPath))
                    }
                }, completion: nil)
                if let strongSelf = self {
                    self?.updateRowsAtIndexPaths(modifications.map(strongSelf.transformIndexPath))
                }
            case .error(let error):
                print(error)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performSegue(withIdentifier: "showMonitor", sender: nil)
    }
    func transformIndexPath(_ index: Int) -> IndexPath {
        let item = index % maxItemsPerSection()
        let section = index / maxItemsPerSection()
        return IndexPath(item: item, section: section)
    }
    
    func reverseTransformIndexPath(_ indexPath: IndexPath) -> Int {
        return indexPath.section * maxItemsPerSection() + indexPath.row
    }
    func updateRowsAtIndexPaths(_ paths: [IndexPath]) {
        for indexPath in paths {
            if let cell = collectionView.cellForItem(at: indexPath) as? TrimetDestinationCell {
                updateLabelsForCell(cell, indexPath: indexPath)
            }
        }
    }
    
    func updateLabelsForCell(_ cell: TrimetDestinationCell, indexPath: IndexPath) {
        let destination = dataSource[reverseTransformIndexPath(indexPath)]
        cell.routeLabel.text = destination.route.name
        cell.stopLabel.text = destination.stop.name
        if let arrival = destination.nextArrival?.timeIntervalSince1970 {
            let now = Date().timeIntervalSince1970
            let difference = arrival - now
            if difference > 0 {
                cell.timeLabel.text = "\(Int(difference / 60))m"
            }
            else {
                cell.timeLabel.text = "Unknown"
            }
            cell.directionLabel.text = destination.stop.directionality
            cell.vehicleImageView.image = destination.route.routeType == .bus ? UIImage(named: "bus") : UIImage(named: "rail")
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
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TrimetDestinationCell
        updateLabelsForCell(cell, indexPath: indexPath)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _ = maxItemsPerSection()
        let sections = numberOfSections(in: collectionView)
        if section != sections - 1 {
            return maxItemsPerSection()
        }
        let fullSections = dataSource.count / maxItemsPerSection()
        return dataSource.count - fullSections * maxItemsPerSection()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int(ceil(CGFloat(dataSource.count) / CGFloat(maxItemsPerSection())))
    }
}
