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
//            var tempMusics: [Music] = []
            let tempMusics = TempMusics()
            // Request Permission
            switch status {
            case .authorized:
                do {
                    let dispatchGroup = DispatchGroup()
                    for title in titles {
                        dispatchGroup.enter()
                        Task {
                            setRequest(title: title)
                            let result = try? await request.response() // FIXME: - 여기서 에러가 발생함
                            _ = result?.songs.compactMap { song in
                                if let playParameters = song.playParameters {
                                    let tempMusic = Music(id: song.id,
                                                          title: song.title,
                                                          artist: song.artistName,
                                                          imageURL: song.artwork?.url(width: 340, height: 340)?.absoluteString ?? "",
                                                          url: song.url,
                                                          playParameters: playParameters)
                                    Task {
                                        await tempMusics.append(with: tempMusic)
                                    }
                                }
                            }
                            dispatchGroup.leave()
                    }
                    }
                    dispatchGroup.wait()
                    self.musics = await Array(tempMusics.list)
                    print("음악들 \(self.musics)")
                } catch {
                    print(error.localizedDescription)
                }
            default:
                break
            }
        }

    }

}


actor TempMusics {
    var list = Set<Music>()

    func append(with music: Music) {
        list.insert(music)
    }
}
