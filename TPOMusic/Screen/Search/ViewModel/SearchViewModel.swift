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

    @Published var musics = [Music]()

    private let searchService: SearchServiceProtocol

    private var status: MusicAuthorization.Status!

    private var searchText: String = ""

    @Published var searchState: Bool = false

    @Published var musicSubscription: MusicSubscription?

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

    func requestMusicAuth() async {
        status = await MusicAuthorization.request()
    }

    func searchChatGPT(searchText: String) {
        self.searchText = String(format: "%@ 노래".localized(), searchText)
        Task {
            print(String(format: "%@ 노래 알려줘. 노래제목 - 아티스트 형식으로".localized(), searchText))
            let chatGPT = try await searchService.fetchChatGPT(messages: [ChatMessage(role: .user, content:
                                                                                        String(format: "%@ 노래 알려줘. 노래제목 - 아티스트 형식으로".localized(), searchText)
                                                                                        )], maxTokens: 300)
            let titles = chatGPT?.choices.first?.message.content.musicTitles
            print(titles)
            if let titles, !titles.isEmpty {
                searchState = true
                await fetchMusics(titles: titles)
            } else {
                searchState = false
            }
        }
    }

    func fetchMusics(titles: [String]) async {
        Task {
            switch status {
            case .authorized:
                await withTaskGroup(of: [Music].self, body: { group in
                    var tempMusics2 = Set<Music>()
                    for title in titles {
                        group.addTask {
                            var request = MusicCatalogSearchRequest(term: title, types: [Song.self, Album.self])
                            request.limit = 1
                            var tempList: [Music] = []
                            if let result = try? await request.response() {
                                _ = result.songs.compactMap { song in
                                    if let playParameters = song.playParameters {
                                        let tempMusic = Music(id: song.id,
                                                              title: song.title,
                                                              artist: song.artistName,
                                                              imageURL: song.artwork?.url(width: 340, height: 340)?.absoluteString ?? "",
                                                              url: song.url,
                                                              playParameters: playParameters,
                                                              previewURL: song.previewAssets?.first?.url)
                                        tempList.append(tempMusic)
                                    }
                                }
                            }
                            return tempList
                        }
                    }

                    for await musicList in group {
                        musicList.forEach {
                            tempMusics2.insert($0)
                        }
                    }
                    self.musics = Array(tempMusics2)
                })

            default:
                break
            }
        }

    }

    func checkMusicSubscription() {
        Task {
            for await subscription in MusicSubscription.subscriptionUpdates {
                musicSubscription = subscription
            }
        }
    }

}

