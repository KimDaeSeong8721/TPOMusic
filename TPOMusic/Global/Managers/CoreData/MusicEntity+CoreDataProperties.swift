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
    @NSManaged public var id: String
    @NSManaged public var artist: String
    @NSManaged public var addedDate: Date
    @NSManaged public var url: URL?
    @NSManaged public var playParameters: Data?
    @NSManaged public var playListEntity: PlayListEntity?
    @NSManaged public var previewURL: URL?
    @NSManaged public var backgroundColor: Data?


}

