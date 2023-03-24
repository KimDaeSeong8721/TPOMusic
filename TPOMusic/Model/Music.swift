//
//  Music.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/10.
//

import Foundation
import MusicKit

struct Music: Identifiable, Hashable, PlayableMusicItem {
    let id: MusicItemID
    let title: String
    let artist: String
    let imageURL: String
    var playParameters: PlayParameters?
}

