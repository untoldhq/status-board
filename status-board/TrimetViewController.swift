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
    let numberOfSections = 1

    lazy var dataSource: Results<WatchedDestination>! = {
        return Data.objects(inContext: Data.context(), ofType: WatchedDestination.self)
    }()
    
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInset = UIEdgeInsets(top: -60, left: 0, bottom: 0, right: 0)
        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        let layout = collectionView.collectionViewLayout as! DestinationLayout
        layout.register(DestinationDecorationView.self, forDecorationViewOfKind: "signage")
        
        notificationToken = dataSource.observe { [weak self] changes in
            guard let collectionView = self?.collectionView else {
                return
            }
            switch changes {
            case .initial:
                collectionView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                
                collectionView.performBatchUpdates({
                    collectionView.insertItems(at: insertions.map { IndexPath(item: $0, section: 0) })
                    collectionView.deleteItems(at: deletions.map { IndexPath(item: $0, section: 0) })
                    
                }, completion: nil)
                
                self?.updateRowsAtIndexPaths(modifications.map { IndexPath(item: $0, section: 0) })
            case .error(let error):
                print(error)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performSegue(withIdentifier: "showMonitor", sender: nil)
    }
    
    func updateRowsAtIndexPaths(_ paths: [IndexPath]) {
        for indexPath in paths {
            if let cell = collectionView.cellForItem(at: indexPath) as? TrimetDestinationCell {
                updateLabelsForCell(cell, indexPath: indexPath)
            }
        }
    }
    
    func updateLabelsForCell(_ cell: TrimetDestinationCell, indexPath: IndexPath) {
        let destination = dataSource[indexPath.item]
        cell.routeLabel.text = destination.route.name
        cell.stopLabel.text = destination.stop.name
        if let arrival = destination.nextArrival?.timeIntervalSince1970 {
            let now = Date().timeIntervalSince1970
            let difference = arrival - now
            if difference > 0 {
                cell.timeLabel.text = "\(Int(difference / 60))m"
            }
            else {
                cell.timeLabel.text = "Due"
            }
            cell.directionLabel.text = destination.stop.directionality
            cell.vehicleImageView.image = destination.route.routeType == .bus ? UIImage(named: "bus") : UIImage(named: "rail")
        }
        else {
            cell.timeLabel.text = "Unknown"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension TrimetViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TrimetDestinationCell
        updateLabelsForCell(cell, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
}

extension TrimetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}
