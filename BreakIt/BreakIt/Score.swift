//
//  Score.swift
//  BreakIt
//
//  Created by yangyang on 6/7/15.
//  Copyright (c) 2015 yangyang. All rights reserved.
//

import Foundation
import CoreData

class Score: NSManagedObject {

    @NSManaged var id: NSDate
    @NSManaged var value: NSNumber

}
