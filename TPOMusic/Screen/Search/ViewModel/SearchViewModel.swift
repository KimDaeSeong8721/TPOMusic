//
//  SearchViewModel.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import UIKit
import Combine
import MusicKit

class SearchViewModel {

    // MARK: - Properties
    var subscription = Set<AnyCancellable>()

    private var request: MusicCatalogSearchRequest!

    @Published var songs = [Music]()

    private let searchService: SearchServiceProtocol

    var status: MusicAuthorization.Status!

    private var searchText: String = ""

    // MARK: - Init
    init(_ searchService: SearchServiceProtocol) {
        self.searchService = searchService
    }
    // MARK: - Func

    @discardableResult
    func createPlayList() -> UUID {
        let listId = UUID()
        searchService.createPlayList(listId: listId, creationDate: Date(), name: searchText)
        return listId
    }

    func isExistedPlayList() -> PlayList? {
        let playLists = searchService.fetchPlayLists()
        let existedPlayList = playLists.filter { $0.name == searchText }
        return existedPlayList.first
    }

    func saveMusicToPlayList(listId: UUID, musics: [Music]) {
        searchService.createMusics(listId: listId, musics: musics)
    }

    func deleteMusicFromPlayList(listId: UUID, musicIds: [UUID]) {
        searchService.deleteMusics(listId: listId, musicIds: musicIds)
    }
    
    func setRequest(title: String) {
        request = MusicCatalogSearchRequest(term: title, types: [Song.self])
        request.limit = 1
    }

    func requestMusicAuth() async {
        status = await MusicAuthorization.request()
    }

    func searchChatGPT(searchText: String) {
        self.searchText = searchText
        Task {
            let chatGPT = try await searchService.fetchChatGPT(messages: [ChatMessage(role: .user, content: searchText+"제목-아티스트 형식")], maxTokens: 300)
            let titles = chatGPT?.choices.first?.message.content.musicTitles
            print(titles)
            await fetchMusics(titles: titles ?? [])
        }
    }
    func fetchMusics(titles: [String]) async {
        Task {
            var tempMusics: [Music] = []
            // Request Permission
            switch status {
            case .authorized:
                do {
                    for title in titles {
                        setRequest(title: title)
                        let result = try await request.response()

                        _ = result.songs.compactMap({ song in
                            tempMusics.append( Music(id: UUID(),
                                                     title: song.title,
                                                     artist: song.artistName,
                                                     imageURL: song.artwork?.url(width: 340, height: 340)?.absoluteString ?? "" )
                            )
                        })
                    }
                    self.songs = tempMusics
//                    let result = try await request.response()
//                    self.songs = result.songs.compactMap({ song in
//                        print(song.title)
//                        return .init(name: song.title,
//                                     artist: song.artistName,
//                                     imageURL: song.artwork?.url(width: 75, height: 75)?.absoluteString ?? "" )
//                    })
                } catch {
                    print(error.localizedDescription)
                }
            default:
                break
            }
        }

    }

}
