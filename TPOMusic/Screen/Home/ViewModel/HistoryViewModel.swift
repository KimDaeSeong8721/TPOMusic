//
//  HistoryViewModel.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/17.
//

import Combine
import Foundation

class HistoryViewModel {

    // MARK: - Properties
    var subscription = Set<AnyCancellable>()

    private let searchService: SearchServiceProtocol
    @Published private(set) var playLists: [PlayList] = []

    // MARK: - Init
    init(searchService: SearchServiceProtocol) {
        self.searchService = searchService
    }

    // MARK: - Func
    func updatePlayList() {
        let tempPlayLists = searchService.fetchPlayLists()

        playLists = tempPlayLists.filter { playList in
            if playList.musicList.isEmpty {
                searchService.deletePlayList(with: playList.listId)
                return false
            } else {
                return true
            }
        }
    }

    func deletePlayList(with listId: UUID) {
        searchService.deletePlayList(with: listId)
    }
}
