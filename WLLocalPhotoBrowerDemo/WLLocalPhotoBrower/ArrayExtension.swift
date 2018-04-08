//
//  ArrayExtension.swift
//  LikeUber
//
//  Created by lei wang on 2018/4/2.
//  Copyright © 2018年 lei wang. All rights reserved.
//

import Foundation

    
    
extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
    
    mutating func removeFrom(array: Array<Element>) {
        for ele in array {
            remove(object: ele)
        }
    }
}

