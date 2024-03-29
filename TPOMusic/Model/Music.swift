//
//  Music.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/10.
//

import UIKit
import MusicKit

struct Music: Identifiable, Hashable, PlayableMusicItem {
    let id: MusicItemID
    let title: String
    let artist: String
    let imageURL: String
    let url: URL?
    var playParameters: PlayParameters?
    var previewURL: URL?
    var backgroundColor: UIColor
}

extension Music {
    static func == (lhs: Music, rhs: Music) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
