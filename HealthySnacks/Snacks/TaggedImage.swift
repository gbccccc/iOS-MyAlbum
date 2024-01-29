//
//  TaggedImage.swift
//  HealthySnacks
//
//  Created by cofincup on 2024/1/29.
//  Copyright © 2024 Razeware. All rights reserved.
//

import UIKit

class TaggedImage {
    init(image: UIImage) {
        self.image = image
    }
    
    var image: UIImage
    var tag: String = ""
    var confidence: Float = 0.0
}
