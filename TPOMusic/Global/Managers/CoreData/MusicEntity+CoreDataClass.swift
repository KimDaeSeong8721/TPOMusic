//
//  MusicEntity+CoreDataClass.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/17.
//
//

import CoreData
import MusicKit
import UIKit

@objc(MusicEntity)
public class MusicEntity: PlayListEntity {

    func toMusic() -> Music {
        do {
        let playParameters = try PropertyListDecoder().decode(PlayParameters.self, from: self.playParameters!)
            return Music(id: MusicItemID(self.id),
                         title: self.title,
                         artist: self.artist,
                         imageURL: self.imageURL,
                         url: self.url,
                         playParameters: playParameters,
                         previewURL: self.previewURL,
                         backgroundColor: UIColor.color(data: self.backgroundColor ?? Data()) ?? .systemGray5)
        } catch {
            return Music(id: MusicItemID(self.id),
                         title: self.title,
                         artist: self.artist,
                         imageURL: self.imageURL,
                         url: self.url,
                         previewURL: self.previewURL,
                         backgroundColor: UIColor.color(data: self.backgroundColor ?? Data()) ?? .systemGray5)
        }


    }
}
