//
//  ScoreTableViewCell.swift
//  BreakIt
//
//  Created by yangyang on 6/8/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var rankLabel: UILabel!

    var rankText:String = "" {
        didSet {
            if rankLabel != nil {
                rankLabel.text = rankText
            }
        }
    }
    
    
}
