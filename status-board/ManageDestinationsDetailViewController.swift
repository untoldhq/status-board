//
//  ManageDestinationsDetailViewController.swift
//  status-board
//
//  Created by Sam Ingle on 9/16/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import UIKit

class ManageDestinationsDetailViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var route: Route! {
        didSet {
            title = route.name
        }
    }
    
}

extension ManageDestinationsDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let stop = route.stops[indexPath.row]
        cell.textLabel?.text = stop.name
        cell.detailTextLabel?.text = stop.directionality
        let watchedLabel = UILabel()
        if WatchedDestination.isWatched(route, stop: stop) {
            watchedLabel.text = "Watched"
        }
        else {
            watchedLabel.text = "Not watched"
        }
        cell.accessoryView = watchedLabel
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return route.stops.count
    }
}

extension ManageDestinationsDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stop = route.stops[indexPath.row]
        if WatchedDestination.isWatched(route, stop: stop) {
            WatchedDestination.unWatch(route, stop: stop)
        }
        else {
            WatchedDestination.watch(route, stop: stop)
        }
    }
}
