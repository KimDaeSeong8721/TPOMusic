//
//  SearchService.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import CoreData
import Foundation
import MusicKit

protocol SearchServiceProtocol {
    func fetchChatGPT(messages: [ChatMessage], maxTokens: Int) async throws -> ChatGPTResult?
    func createPlayList(listId: UUID, creationDate: Date, name: String)
    func fetchPlayLists() -> [PlayList]
    func deletePlayList(with listId: UUID)
    func createMusics(listId: UUID, musics: [Music])
    func fetchMusics(listId: UUID) -> [Music]
    func deleteMusics(listId: UUID, musicIds: [MusicItemID])
}

final class SearchService: SearchServiceProtocol {

    // MARK: - Properties
    private let searchRepository: SearchRepositoryProtocol

    private var playListEntities: [PlayListEntity] = []

    private var playListEntity: PlayListEntity?

    // MARK: - Init
    init(_ searchRepository: SearchRepositoryProtocol) {
        self.searchRepository = searchRepository
        playListEntities = searchRepository.fetchPlayListEntities() // 수정필요
    }

    // MARK: - Func
    func fetchChatGPT(messages: [ChatMessage], maxTokens: Int) async throws -> ChatGPTResult? {
        let networkRequest = SearchEndPoint.chatGPT.createChatGPTRequest(messages: messages, maxTokens: maxTokens)
        return try await searchRepository.request(type: ChatGPTResult.self, request: networkRequest)
    }
}

extension SearchService {
    func createPlayList(listId: UUID, creationDate: Date, name: String) {
        searchRepository.createPlayListEntity(listId: listId, creationDate: creationDate, name: name)
        playListEntities = searchRepository.fetchPlayListEntities() // 수정 필요
    }

    func fetchPlayLists() -> [PlayList] {
        playListEntities = searchRepository.fetchPlayListEntities()
        return playListEntities.map { $0.toPlayList()}
    }

    func deletePlayList(with listId: UUID) {
        guard let playListEntity = playListEntities.filter({ listId == $0.listId }).first else { return}
        searchRepository.deletePlayListEntity(playListEntity: playListEntity)
    }
}

extension SearchService {
    func createMusics(listId: UUID, musics: [Music]) {
        guard let playListEntity = playListEntities.filter({ listId == $0.listId }).first else { return}
        let mainContext = searchRepository.fetchContext()

        mainContext.performAndWait {
            var newMusicEntities: [MusicEntity] = []

            musics.forEach { music in
                let newMusicEntity = makeMusicEntity(context: mainContext, music: music)
                newMusicEntities.append(newMusicEntity)
            }
            searchRepository.createMusicEntities(playListEntity: playListEntity, musicEntities: newMusicEntities)
        }
    }

    func fetchMusics(listId: UUID) -> [Music] {
        guard let playListEntity = playListEntities.filter({ listId == $0.listId }).first else { return [] }
        let musicEntities = searchRepository.fetchMusicEntities(playListEntity: playListEntity)
        return musicEntities.map { $0.toMusic() }
    }

    func deleteMusics(listId: UUID, musicIds: [MusicItemID]) {
        guard let playListEntity = playListEntities.filter({ listId == $0.listId }).first else { return }
        let currentMusicEntities =  searchRepository.fetchMusicEntities(playListEntity: playListEntity)
        let checkedMusicEntities = currentMusicEntities.filter({  musicIds.contains(MusicItemID($0.id)) })
        searchRepository.deleteMusicEntities(playListEntity: playListEntity, musicEntities: checkedMusicEntities)
    }

    
}

extension SearchService {
    func makeMusicEntity(context: NSManagedObjectContext,
                         music: Music) -> MusicEntity {
        let newMusicEntity = MusicEntity(context: context)
        newMusicEntity.id = music.id.rawValue
        newMusicEntity.title = music.title
        newMusicEntity.addedDate = Date()
        newMusicEntity.imageURL = music.imageURL
        newMusicEntity.artist = music.artist
        do {
            let data = try PropertyListEncoder().encode(music.playParameters)
            newMusicEntity.playParameters = data
        } catch {

        }
        return newMusicEntity

    }
}
