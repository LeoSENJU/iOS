//
//  InstructionContentViewController.swift
//  BreakIt
//
//  Created by yangyang on 6/3/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import UIKit

class InstructionContentViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var index: Int = 0

    var name: String?
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = NSLocalizedString(name!, comment: "name of the label in instruction content view controller")
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
}
