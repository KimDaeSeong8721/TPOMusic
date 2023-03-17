//
//  Music.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/10.
//

import Foundation

struct Music: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let artist: String
    let imageURL: String

    static let sampleData: [Music] = [
        Music(name: "너랑나", artist: "아이유", imageURL: "https://wimg.mk.co.kr/meet/neds/2021/04/image_readtop_2021_330747_16177500644599916.jpg")
    ]
}

