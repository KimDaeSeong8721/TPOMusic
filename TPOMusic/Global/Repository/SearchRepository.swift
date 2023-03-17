//
//  SearchRepository.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import CoreData
import Foundation

protocol SearchRepositoryProtocol {
    func request<T: Decodable>(type: T.Type, request: NetworkRequest) async throws -> T?
    func fetchContext() -> NSManagedObjectContext
    func createPlayListEntity(listId: UUID, creationDate: Date, name: String)
    func fetchPlayListEntities() -> [PlayListEntity]
    func deletePlayListEntity(playListEntity: PlayListEntity)
    func createMusicEntities(playListEntity: PlayListEntity, musicEntities: [MusicEntity])
    func fetchMusicEntities(playListEntity: PlayListEntity) -> [MusicEntity]
    func deleteMusicEntities(playListEntity: PlayListEntity, musicEntities: [MusicEntity])
}

final class SearchRepository: SearchRepositoryProtocol {
    // MARK: - Properties
    private let apiService: APIServiceProtocol?
    private let musicDataManager: MusicDataManagerProtocol

    // MARK: - Init
    init(_ apiService: APIServiceProtocol, musicDataManager: MusicDataManagerProtocol =
         MusicDataManager.shared) {
        self.apiService = apiService
        self.musicDataManager = musicDataManager
    }

    // MARK: - Func
    func request<T: Decodable>(type: T.Type, request: NetworkRequest) async throws -> T? {
        return try await apiService?.request(type: type, request: request)
    }

    func fetchContext() -> NSManagedObjectContext {
        return musicDataManager.fetchMainContext()
    }

    func createPlayListEntity(listId: UUID, creationDate: Date, name: String) {
        musicDataManager.createPlayListEntity(listId: listId,
                                              creationDate: creationDate,
                                              name: name)
    }

    func fetchPlayListEntities() -> [PlayListEntity] {
        return musicDataManager.fetchPlayListEntities()
    }

    func deletePlayListEntity(playListEntity: PlayListEntity) {
        musicDataManager.deletePlayListEntity(entity: playListEntity)
    }
}

extension SearchRepository {
    func createMusicEntities(playListEntity: PlayListEntity, musicEntities: [MusicEntity]) {
        musicDataManager.createMusicEntities(playListEntity: playListEntity, musicEntities: musicEntities)
    }

    func fetchMusicEntities(playListEntity: PlayListEntity) -> [MusicEntity] {
        return musicDataManager.fetchMusicEntities(playListEntity: playListEntity)
    }

    func deleteMusicEntities(playListEntity: PlayListEntity, musicEntities: [MusicEntity]) {
        musicDataManager.deleteMusicEntities(playListEntity: playListEntity, musicEntities: musicEntities)
    }
}

