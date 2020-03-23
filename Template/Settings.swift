//
//  Settings.swift
//  ColorSwitch
//
//  Created by Marissa Gonzales on 3/22/20.
//  Copyright © 2020 Joe Veverka. All rights reserved.
//

import SpriteKit

enum PhysicsCategories {
    
    static let none: UInt32 = 0
    static let ballCategory: UInt32 = 0x1 // 1
    static let switchCategory: UInt32 = 0x1 << 1 // 10 
}

enum Zpositions {
    static let label: CGFloat = 0
    static let ball: CGFloat = 1
    static let colorSwitch: CGFloat = 2
}
