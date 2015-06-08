//
//  MoreViewController.swift
//  BreakIt
//  View controller for future setting
//  Created by yangyang on 5/13/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import UIKit
import CoreData

class ScoreTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let fetchRequest = NSFetchRequest(entityName: "Score")
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Score] {
            println( fetchResults.count )
        }
    }
}
