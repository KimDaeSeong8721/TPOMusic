//
//  PlayList.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import Foundation

struct PlayList: Hashable {
    let listId: UUID
    let name: String
    let date: Date
    let imageURL: String
    var musicList: [Music]
}
