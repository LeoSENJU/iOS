//
//  MoreViewController.swift
//  BreakIt
//  View controller for future setting
//  Created by yangyang on 5/13/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController, UITableViewDataSource {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var scoreTableView: UITableView!
    
    var scoreList = [Score]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreTableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchScore()
    }
    
    func fetchScore() {
        scoreList = Score.fetchScore(managedObjectContext!)
        scoreTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("score cell") as! ScoreTableViewCell
        
        let score = scoreList[indexPath.row]
        let rank = NSLocalizedString("#%d    %d", comment: "rank")
        cell.rankText = String.localizedStringWithFormat(rank, indexPath.row + 1,  Int(score.value))
        
        return cell
    }
    
}
