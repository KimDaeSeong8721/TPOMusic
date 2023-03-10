//
//  NSObject+Extension.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/09.
//

import Foundation

extension NSObject {
    static var className: String { 
        return String(describing: self)
    }
}
