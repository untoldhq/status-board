//
//  ManageDestinationsViewController.swift
//  status-board
//
//  Created by Sam Ingle on 9/16/16.
//  Copyright © 2016 Untold. All rights reserved.
//

import Foundation
import UIKit

class ManageDestinationsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    let dataSource = Data.objects(Route.self).sorted("id")
   
    override func viewDidLoad() {
        title = "Nearby Routes"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? ManageDestinationsDetailViewController, route = sender as? Route {
            controller.route = route
        }
    }
}

extension ManageDestinationsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let route = dataSource[indexPath.row]
        let watched = WatchedDestination.destinationsForRoute(route)
        cell.textLabel?.text = route.name
        let plural = watched.count == 1 ? "stop" : "stops"
        cell.detailTextLabel?.text = "Watching \(watched.count) \(plural) for this route."
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}

extension ManageDestinationsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDetail", sender: dataSource[indexPath.row])
    }
}
