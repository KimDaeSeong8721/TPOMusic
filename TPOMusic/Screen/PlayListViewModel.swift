//
//  PlayListViewModel.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/18.
//

import Combine
import Foundation
import MusicKit

class PlayListViewModel {

    var subscription = Set<AnyCancellable>()

    private let searchService: SearchServiceProtocol

    @Published private(set) var musicList: [Music]

    private let playList: PlayList
    // MARK: - Init
    init(with playList: PlayList, _ searchService: SearchServiceProtocol) {
        self.playList = playList
        self.musicList = playList.musicList
        self.searchService = searchService
    }

    func updateMusicList() {
        self.musicList = searchService.fetchMusics(listId: playList.listId)
    }
    
    func deleteMusicFromPlayList(musicIds: [MusicItemID]) {
        searchService.deleteMusics(listId: playList.listId, musicIds: musicIds)
    }
    func deletePlayList() {
        searchService.deletePlayList(with: playList.listId)
    }
}
