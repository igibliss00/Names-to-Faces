//
//  Person.swift
//  Project10
//
//  Created by jc on 2020-06-26.
//  Copyright © 2020 J. All rights reserved.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
