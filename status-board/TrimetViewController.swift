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

    @IBOutlet var tableView: UITableView!

    lazy var dataSource: Results<WatchedDestination>! = {
        return Data.objects(WatchedDestination.self)
    }()
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationToken = dataSource.addNotificationBlock { [weak self] changes in
            guard let tableView = self?.tableView else {
                return
            }
            switch changes {
            case .Initial:
                tableView.reloadData()
            case .Update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
                tableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
                self?.updateRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 0) })
                tableView.endUpdates()
            case .Error(let error):
                print(error)
            }
        }
    }
    
    func updateRowsAtIndexPaths(paths: [NSIndexPath]) {
        for indexPath in paths {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TrimetDestinationCell {
                updateLabelsForCell(cell, indexPath: indexPath)
            }
        }
    }
    
    func updateLabelsForCell(cell: TrimetDestinationCell, indexPath: NSIndexPath) {
        let destination = dataSource[indexPath.row]
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

extension TrimetViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TrimetDestinationCell
        updateLabelsForCell(cell, indexPath: indexPath)
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}
