//
//  Model.swift
//  Elephant-V1
//
//  Created by Lionel Yu on 11/17/22.
//

import Foundation

class Model: NSObject {
    static let shared: Model = Model()
    var stringArray: [String] = []
    var itemArray: [Item] = []
    var inactiveArray: [Item] = []
    var savedItems: [Item] = []
    var projectArray: [Project] = []
    var uniqueNumCounter: Int = 0
    
    
    func backupItems () {
        
    }
}
