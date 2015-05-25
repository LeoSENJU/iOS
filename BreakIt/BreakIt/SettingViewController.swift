//
//  SettingViewController.swift
//  BreakIt
//  View controller for setting different parameter of BreakIt game
//  Created by yangyang on 5/13/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    
    // MARK: IBoutlets
    @IBOutlet weak var brickRowLabel: UILabel!
    @IBOutlet weak var grativationPullSwitch: UISwitch!
    @IBOutlet weak var rowOfBricksStepper: UIStepper!
    @IBOutlet weak var bouncingBallsSegments: UISegmentedControl!
    @IBOutlet weak var bouncinessSlider: UISlider!
    
    // MARK: Keys for the user settings
    struct BreakItGameUserDefaultsKey {
        static let PullGravitationKey = "BraekItGamePullGravitation"
        static let RowOfBricksKey = "BraekItGameRowOfBricks"
        static let NumberOfBouncingBallsKey = "BraekItGamePullNumberOfBouncingBalls"
        static let BouncinessKey = "BraekItGamePullBounciness"
        static let IsSettingEdited = "BreakItGameSettingEdited"
    }
    
    // MARK: propertes for setting parameters
    var isEdited: Bool?
    
    var isGravitationPulled: Bool? {
        didSet {
            if let isPulled = self.isGravitationPulled
            {
                grativationPullSwitch.selected = isPulled
            }
        }
    }
    
    var rowOfBricks: Int? {
        didSet {
            if let row = self.rowOfBricks
            {
                rowOfBricksStepper.value = Double(row)
                let rowOfBrickHint = NSLocalizedString("Row of Bricks: %d", comment: "row of bricks in the label")
                brickRowLabel.text = String.localizedStringWithFormat(rowOfBrickHint, row)
            }
            
        }
    }
    
    var numberOfBouncingBalls: Int? {
        didSet {
            if let num = self.numberOfBouncingBalls
            {
                bouncingBallsSegments.selectedSegmentIndex = num - 1
            }
        }
    }
    
    var bouciness: Double? {
        didSet {
            if let bouce = self.bouciness
            {
                bouncinessSlider.value = Float(bouce)
            }
        }
    }
    
    // MARK: linsteners of the UIController
    @IBAction func pullGravitation(sender: UISwitch) {
        isGravitationPulled = sender.selected
        isEdited = true
    }
    
    @IBAction func changeRowOfBricks(sender: UIStepper) {
        rowOfBricks = Int(sender.value)
        isEdited = true
    }

    @IBAction func changeNumberOfBouncingBalls(sender: UISegmentedControl) {
        numberOfBouncingBalls = sender.selectedSegmentIndex + 1
        isEdited = true
    }
    
    @IBAction func changeBouciness(sender: UISlider) {
        bouciness = Double(sender.value)
        isEdited = true
    }
    
    // MARK: Reading and saving userDrfaults
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        isGravitationPulled = defaults.boolForKey(BreakItGameUserDefaultsKey.PullGravitationKey)
        rowOfBricks = defaults.integerForKey(BreakItGameUserDefaultsKey.RowOfBricksKey)
        numberOfBouncingBalls = defaults.integerForKey(BreakItGameUserDefaultsKey.NumberOfBouncingBallsKey)
        bouciness = defaults.doubleForKey(BreakItGameUserDefaultsKey.BouncinessKey)
        
        rowOfBricksStepper.maximumValue = Double(BreakItViewController.ConstantsForBreakItGame.NumberOfMaxBricksRow)
        
        isEdited = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(isGravitationPulled!, forKey: BreakItGameUserDefaultsKey.PullGravitationKey)
        defaults.setInteger(rowOfBricks!, forKey: BreakItGameUserDefaultsKey.RowOfBricksKey)
        defaults.setInteger(numberOfBouncingBalls!, forKey: BreakItGameUserDefaultsKey.NumberOfBouncingBallsKey)
        defaults.setDouble(bouciness!, forKey: BreakItGameUserDefaultsKey.BouncinessKey)
        defaults.setBool(isEdited!, forKey: BreakItGameUserDefaultsKey.IsSettingEdited)
    }
    
}
