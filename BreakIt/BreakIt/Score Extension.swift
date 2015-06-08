//
//  Score Extension.swift
//  BreakIt
//
//  Created by yangyang on 6/8/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import Foundation
import CoreData

extension Score {
    class func createInManagedObjectContext(moc: NSManagedObjectContext, id: NSDate, value: Int) -> Score {
        let newScore = NSEntityDescription.insertNewObjectForEntityForName("Score", inManagedObjectContext: moc) as! Score
        newScore.id = id
        newScore.value = NSNumber(integer: value)
        return newScore
    }
    
    class func fetchScore(moc: NSManagedObjectContext) -> [Score] {
        
        let fetchRequest = NSFetchRequest(entityName: "Score")
        fetchRequest.fetchBatchSize = 10
        fetchRequest.fetchLimit = 10
        
        let sortDescriptor = NSSortDescriptor(key: "value", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Score] {
            return fetchResults
        } else {
            return []
        }
    }
    
    class func saveContext(moc: NSManagedObjectContext) {
        var error: NSError?;
        if !moc.save(&error) {
            println("save error \(error?.localizedDescription))")
        }
    }
}