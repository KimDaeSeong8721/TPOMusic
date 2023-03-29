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

    @Published var musics = [Music]()

    private let searchService: SearchServiceProtocol

    var status: MusicAuthorization.Status!

    private var searchText: String = ""

    @Published var searchState: Bool = false
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

    func deleteMusicFromPlayList(listId: UUID, musicIds: [MusicItemID]) {
        searchService.deleteMusics(listId: listId, musicIds: musicIds)
    }
    
    func setRequest(title: String) {
        request = MusicCatalogSearchRequest(term: title, types: [Song.self, Album.self])
        request.limit = 1
    }

    func requestMusicAuth() async {
        status = await MusicAuthorization.request()
    }

    func searchChatGPT(searchText: String) {
        self.searchText = searchText + " 노래"
        Task {
            let chatGPT = try await searchService.fetchChatGPT(messages: [ChatMessage(role: .user, content: searchText  + "노래 알려줘")], maxTokens: 300)
            let titles = chatGPT?.choices.first?.message.content.musicTitles
            print(titles)
            searchState.toggle()
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
                        result.songs.compactMap { song in
                            if let playParameters = song.playParameters {
                                let tempMusic = Music(id: song.id,
                                                      title: song.title,
                                                      artist: song.artistName,
                                                      imageURL: song.artwork?.url(width: 340, height: 340)?.absoluteString ?? "",
                                                      url: song.url,
                                                      playParameters: playParameters)
                                tempMusics.append(tempMusic)
                            }

                        }
                    }
                    self.musics = tempMusics
                } catch {
                    print(error.localizedDescription)
                }
            default:
                break
            }
        }

    }

}
