//
//  String+Extension.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import Foundation

extension String {
    
    // FIXME: - 수정 필요
    var musicTitles: [String] {
        let pattern = "\"([^\"]*)\"|(^[^\"]*$)"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        let matches = regex.matches(in: self, options: [], range: range)
        let matchedStrings = matches.map {
            if $0.range(at: 1).location != NSNotFound {
                return (self as NSString).substring(with: $0.range(at: 1))
            } else {
                return (self as NSString).substring(with: $0.range(at: 2))
            }
        }
        return matchedStrings
    }
}
