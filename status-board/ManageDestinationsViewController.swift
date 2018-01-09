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
    let dataSource = Data.objects(inContext: Data.context(), ofType: Route.self).sorted(byKeyPath: "id")
   
    override func viewDidLoad() {
        title = "Nearby Routes"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ManageDestinationsDetailViewController, let route = sender as? Route {
            controller.route = route
        }
    }
}

extension ManageDestinationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let route = dataSource[indexPath.row]
        let watched = WatchedDestination.destinationsForRoute(route)
        cell.textLabel?.text = route.name
        let plural = watched.count == 1 ? "stop" : "stops"
        cell.detailTextLabel?.text = "Watching \(watched.count) \(plural) for this route."
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}

extension ManageDestinationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: dataSource[indexPath.row])
    }
}
