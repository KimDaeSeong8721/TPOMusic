//
//  MusicDataManager.swift
//  WithBot
//
//  Created by DaeSeong on 2023/03/17.
//

import CoreData
import Foundation


protocol MusicDataManagerProtocol {
    func fetchMainContext() -> NSManagedObjectContext 
    func createPlayListEntity(listId: UUID, creationDate: Date, name: String)
    func fetchPlayListEntities() -> [PlayListEntity]
    func deletePlayListEntity(entity: PlayListEntity)
    func createMusicEntities(playListEntity: PlayListEntity, musicEntities: [MusicEntity])
    func fetchMusicEntities(playListEntity: PlayListEntity) -> [MusicEntity]
    func deleteMusicEntities(playListEntity: PlayListEntity, musicEntities: [MusicEntity])
}

final class MusicDataManager: CoreDataManager, MusicDataManagerProtocol {

    // MARK: - Properties
    static let shared = MusicDataManager()


    // MARK: - Init
    private override init() { }

    // MARK: - Func
    func fetchMainContext() -> NSManagedObjectContext {
        return self.mainContext
    }

    // CREATE
    func createPlayListEntity(listId: UUID, creationDate: Date, name: String) {
        mainContext.performAndWait {
            let newPlayList = PlayListEntity(context: self.mainContext)
            newPlayList.listId = listId
            newPlayList.creationDate = creationDate
            newPlayList.name = name
            self.saveMainContext()
        }
    }

    // READ
    func fetchPlayListEntities() -> [PlayListEntity] {
        var playListEntities = [PlayListEntity]()

        mainContext.performAndWait {
            let request: NSFetchRequest<PlayListEntity> = PlayListEntity.fetchRequest()

            let sortByDate = NSSortDescriptor(key: #keyPath(PlayListEntity.creationDate), ascending: true)
            request.sortDescriptors = [sortByDate]
            do {
                playListEntities = try mainContext.fetch(request)
            } catch {
                print(error)
            }
        }
        return playListEntities
    }

    // UPDATE

    // DELETE
    func deletePlayListEntity(entity: PlayListEntity) {
        mainContext.performAndWait {
            self.mainContext.delete(entity)
            self.saveMainContext()
        }
    }

}

extension MusicDataManager {
    // CREATE
    func createMusicEntities(playListEntity: PlayListEntity, musicEntities: [MusicEntity]) {
        mainContext.performAndWait {
            playListEntity.addToMusicEntities(NSSet(array: musicEntities))
            self.saveMainContext()
        }
    }
    // READ
    func fetchMusicEntities(playListEntity: PlayListEntity) -> [MusicEntity] {
        var musicEntities = [MusicEntity]()
        mainContext.performAndWait {
            let request: NSFetchRequest<PlayListEntity> = PlayListEntity.fetchRequest()
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(PlayListEntity.listId), playListEntity.listId as CVarArg)
            do {
                let playLists = try mainContext.fetch(request)
                musicEntities = playLists.first?.musicEntities?.allObjects as! [MusicEntity]
            } catch {
                print(error)
            }
        }
        musicEntities.sort { $0.addedDate < $1.addedDate }
        return musicEntities
    }
    // UPDATE
    // DELETE
    func deleteMusicEntities(playListEntity: PlayListEntity, musicEntities: [MusicEntity]) {
        mainContext.performAndWait {
            playListEntity.removeFromMusicEntities(NSSet(array: musicEntities))
//            musicEntities.forEach {
//                playListEntity.removeFromMusicEntities($0)
//            }
            self.saveMainContext()
        }
    }
}
