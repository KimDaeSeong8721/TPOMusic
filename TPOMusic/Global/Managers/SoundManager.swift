//
//  SoundManager.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/04/06.
//

import AVFoundation
import Foundation
import MusicKit
import MediaPlayer

class SoundManager {
    // MARK: - Properties

    static let shared = SoundManager()
    //    var avPlayer: AVPlayer?

    var avQueuePlayer: AVPlayer?

    var playerItems = [AVPlayerItem]()
    var currentTrack = 0

    let applicationPlayer =  MPMusicPlayerController.applicationQueuePlayer


    var playerIndex: Int = 0

    public var totalDuration: TimeInterval? {
        if avQueuePlayer == nil {
            return applicationPlayer.nowPlayingItem?.playbackDuration
        } else {
            return 30.0
        }
    }

    public var currentTime: TimeInterval? {
        if avQueuePlayer == nil {
            return applicationPlayer.currentPlaybackTime
        } else {
            return avQueuePlayer?.currentTime().seconds
        }
    }
    // MARK: - Init

    private init() {}

    // MARK: - Func
    // MARK: - AVPlayer
    func setupAVPlayer() {
        if avQueuePlayer == nil {
            avQueuePlayer = AVPlayer()
        }
    }

    func playPlayer() {
        if avQueuePlayer != nil {
            playTrack()
        } else {
            applicationPlayer.play()
        }
    }

    func pausePlayer() {
        if let avQueuePlayer {
            avQueuePlayer.pause()
        } else {
            applicationPlayer.pause()
        }
    }
    // MARK: - ApplicationPlayer

    func backwardPlayer() {
        if avQueuePlayer != nil {
            NotificationCenter.default.post(name: NSNotification.Name("backwardButtonTapped"), object: nil)
        } else {
            applicationPlayer.skipToPreviousItem()
        }
    }

    func forwardPlayer() {
        if avQueuePlayer != nil {
            NotificationCenter.default.post(name: NSNotification.Name("forwardButtonTapped"), object: nil)
        } else {
            applicationPlayer.skipToNextItem()
        }
    }
}

extension SoundManager {
    func playTrack() {
        if playerItems.count > 0 {
            avQueuePlayer?.replaceCurrentItem(with: playerItems[playerIndex])
            avQueuePlayer?.play()
        }
    }
}
