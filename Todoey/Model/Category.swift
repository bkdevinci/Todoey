//
//  Category.swift
//  Todoey
//
//  Created by Brian Kump on 4/29/18.
//  Copyright © 2018 Brian Kump. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
    
}
