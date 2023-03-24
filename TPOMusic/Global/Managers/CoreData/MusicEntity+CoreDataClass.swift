//
//  MusicEntity+CoreDataClass.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/17.
//
//

import Foundation
import CoreData
import MusicKit

@objc(MusicEntity)
public class MusicEntity: PlayListEntity {

    func toMusic() -> Music {
        do {
        let playParameters = try PropertyListDecoder().decode(PlayParameters.self, from: self.playParameters!)
            return Music(id: MusicItemID(self.id),
                         title: self.title,
                         artist: self.artist,
                         imageURL: self.imageURL,
                         playParameters: playParameters)
        } catch {
            return Music(id: MusicItemID(self.id),
                         title: self.title,
                         artist: self.artist,
                         imageURL: self.imageURL)
        }


    }
}
