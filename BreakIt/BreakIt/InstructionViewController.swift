//
//  InstructionViewController.swift
//  BreakIt
//
//  Created by yangyang on 6/3/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import UIKit

class InstructionViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    let imageNames = ["instruction1.png","instruction2.png","instruction3.png"]
    let names = ["game view", "pause", "fail"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        let startingViewController = viewControllerAtIndex(0)
        let controllers = [startingViewController!]
        
        setViewControllers(controllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let contentVC = viewController as? InstructionContentViewController {
            var index = contentVC.index
            
            if index == 0 {
                return nil
            }
            return viewControllerAtIndex(--index)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if let contentVC = viewController as? InstructionContentViewController {
            var index = contentVC.index
            
            if ++index == imageNames.count {
                return nil
            }
            return viewControllerAtIndex(index)
        }
        
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return imageNames.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        
        return 0
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        if index < imageNames.count {
            let contentVC = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController") as! InstructionContentViewController
            contentVC.image = UIImage(named: imageNames[index])
            contentVC.name = names[index]
            contentVC.index = index
            
            return contentVC
        } else {
            return nil
        }
    }
}
