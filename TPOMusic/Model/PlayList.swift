//
//  PlayList.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import Foundation

struct PlayList: Hashable {
    let id: UUID = UUID()
    let title: String
    let imageURL: String
    var musicList: [Music]
}
