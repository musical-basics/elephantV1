//
//  Project.swift
//  Elephant-V1
//
//  Created by Lionel Yu on 11/17/22.
//

import Foundation

class Project: Codable {
    var name: String
    var completed: Bool
    var priority: Int
    
    init(name: String, completed: Bool, priority: Int) {
        self.name = name
        self.completed = completed
        self.priority = priority
    }
    
    
}
