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


    // MARK: - Init
    init(_ searchService: SearchServiceProtocol) {
        self.searchService = searchService
    }
    // MARK: - Func

    func saveMusicToPlaylist() {

    }
    
    func setRequest(title: String) {
        request = MusicCatalogSearchRequest(term: title, types: [Song.self])
        request.limit = 1
    }

    func requestMusicAuth() async {
        status = await MusicAuthorization.request()
    }

    func searchChatGPT(searchText: String) {
        Task {
            let chatGPT = try await searchService.fetchChatGPT(messages: [ChatMessage(role: .user, content: searchText)], maxTokens: 300)
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
                            tempMusics.append( Music(name: song.title,
                                                     artist: song.artistName,
                                                     imageURL: song.artwork?.url(width: 75, height: 75)?.absoluteString ?? "" )
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
