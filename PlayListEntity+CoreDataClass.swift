//
//  PlayListEntity+CoreDataClass.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/17.
//
//

import Foundation
import CoreData

@objc(PlayListEntity)
public class PlayListEntity: NSManagedObject {

    func getArrayOfMusicEntity() -> [MusicEntity] {
        let musicEntities = self.musicEntities?.allObjects as? [MusicEntity]
        return musicEntities ?? []
    }

    func toPlayList() -> PlayList {
        return PlayList(listId: self.listId, name: self.name,
                        imageURL: getArrayOfMusicEntity().first?.imageURL ?? "",
                        musicList: getArrayOfMusicEntity().map { $0.toMusic()})
    }
}
