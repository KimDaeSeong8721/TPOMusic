//
//  SearchResultViewModel.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/04/08.
//

import Combine
import Foundation
import MediaPlayer
import MusicKit

final class SearchResultViewModel {

    // MARK: - Properties
    var subscription = Set<AnyCancellable>()
    
    @Published private(set) var musicSubscription: MusicSubscription?

    let musics: [Music]

    private let soundManager: SoundManager

    // MARK: - Init
    init(with musics: [Music], soundManager: SoundManager = SoundManager.shared) {
        self.musics = musics
        self.soundManager = soundManager
        soundManager.applicationPlayer.beginGeneratingPlaybackNotifications()
    }

    // MARK: - Func
    func setPlayerIndex(index: Int) {
        soundManager.playerIndex = index
    }

    func setPlayerQueue(with music: Music) {
        let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: musics.map { $0.id.rawValue})
        descriptor.startItemID = music.id.rawValue
        soundManager.applicationPlayer.setQueue(with: descriptor)

        guard let avQueuePlayer = soundManager.avQueuePlayer else { return }

        musics.forEach({
            if let url = $0.previewURL {
                soundManager.playerItems.append(AVPlayerItem(url: url))
            }
        })

    }

    func createPlaylist(title: String?) async {
        let creationMetadata = MPMediaPlaylistCreationMetadata(name: title ?? "My Playlist")
        creationMetadata.authorDisplayName = "NowMusic"
        creationMetadata.descriptionText = "This playlist contains awesome songs!"

        let playListId = UUID()
        let playList = try? await MPMediaLibrary.default().getPlaylist(with: playListId, creationMetadata: creationMetadata)

        let dispatchGroup = DispatchGroup()
        if let playList = playList {
            for music in musics {
                dispatchGroup.enter()
                playList.addItem(withProductID: music.id.rawValue) { _ in
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.wait()
    }
    func checkMusicSubscription() {
        Task {
            for await subscription in MusicSubscription.subscriptionUpdates {
                musicSubscription = subscription
            }
        }
    }
    func remoteCommandCenterSetting() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let center = MPRemoteCommandCenter.shared()

        // 제어 센터 재생버튼 누르면 발생할 이벤트를 정의합니다.
        center.playCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            self?.soundManager.playPlayer()
            return MPRemoteCommandHandlerStatus.success
        }

        // 제어 센터 pause 버튼 누르면 발생할 이벤트를 정의합니다.
        center.pauseCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            self?.soundManager.pausePlayer()
            return MPRemoteCommandHandlerStatus.success
        }

        center.previousTrackCommand.addTarget { _ in
            return MPRemoteCommandHandlerStatus.success
        }

        center.nextTrackCommand.addTarget { _ in
            return MPRemoteCommandHandlerStatus.success
        }
    }

    func playApplicationPlayer() async throws {
        try await soundManager.applicationPlayer.prepareToPlay()
        soundManager.playPlayer()
    }

    func playAVPlayer() {
        soundManager.setupAVPlayer()
        soundManager.playPlayer()
    }

    func getPlayerIndex() -> Int? {
        return soundManager.playerIndex
    }

    func restartApplicationPlayer() {
        soundManager.applicationPlayer.skipToBeginning()
    }
}
