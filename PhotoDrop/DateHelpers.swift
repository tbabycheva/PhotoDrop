//
//  DateHelpers.swift
//  PhotoDrop
//
//  Created by Tetiana Babycheva on 7/28/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import Foundation

extension Date {
    
    func stringValue() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
    
        return formatter.string(from: self)
    }
    
    func stringValueSpelled() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return formatter.string(from: self)
    }
}
