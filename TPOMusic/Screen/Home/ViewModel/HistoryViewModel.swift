//
//  HistoryViewModel.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/17.
//

import Combine
import Foundation

class HistoryViewModel {
    var subscription = Set<AnyCancellable>()

    private let searchService: SearchServiceProtocol
    @Published private(set) var playLists: [PlayList] = []

    init(searchService: SearchServiceProtocol) {
        self.searchService = searchService
    }

    func updatePlayList() {
        playLists = searchService.fetchPlayLists()
    }
}
