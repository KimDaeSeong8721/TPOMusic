//
//  MusicEntity+CoreDataClass.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/17.
//
//

import Foundation
import CoreData

@objc(MusicEntity)
public class MusicEntity: PlayListEntity {

    func toMusic() -> Music {
        return Music(id: self.id, title: self.title, artist: self.artist, imageURL: self.imageURL)
    }
}
