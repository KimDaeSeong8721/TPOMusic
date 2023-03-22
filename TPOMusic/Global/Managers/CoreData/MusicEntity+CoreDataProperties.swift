//
//  MusicEntity+CoreDataProperties.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/17.
//
//

import Foundation
import CoreData

extension MusicEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MusicEntity> {
        return NSFetchRequest<MusicEntity>(entityName: "MusicEntity")
    }

    @NSManaged public var title: String
    @NSManaged public var imageURL: String
    @NSManaged public var id: UUID
    @NSManaged public var artist: String
    @NSManaged public var addedDate: Date
    @NSManaged public var playListEntity: PlayListEntity?

}

