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

    var name: String? {
        didSet {
            if name != nil && nameLabel != nil {
                nameLabel.text = name
            }
        }
    }
    
    var image: UIImage? {
        didSet {
            if image != nil && imageView != nil{
                imageView.image = image
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = name
        imageView.image = image
    }
    
}
