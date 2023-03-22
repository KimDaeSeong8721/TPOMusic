//
//  PlayListEntity+CoreDataProperties.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/17.
//
//

import Foundation
import CoreData

extension PlayListEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayListEntity> {
        return NSFetchRequest<PlayListEntity>(entityName: "PlayListEntity")
    }

    @NSManaged public var listId: UUID
    @NSManaged public var name: String
    @NSManaged public var creationDate: Date
    @NSManaged public var musicEntities: NSSet?

}

// MARK: Generated accessors for musicEntities
extension PlayListEntity {

    @objc(addMusicEntitiesObject:)
    @NSManaged public func addToMusicEntities(_ value: MusicEntity)

    @objc(removeMusicEntitiesObject:)
    @NSManaged public func removeFromMusicEntities(_ value: MusicEntity)

    @objc(addMusicEntities:)
    @NSManaged public func addToMusicEntities(_ values: NSSet)

    @objc(removeMusicEntities:)
    @NSManaged public func removeFromMusicEntities(_ values: NSSet)

}

extension PlayListEntity : Identifiable {
}
