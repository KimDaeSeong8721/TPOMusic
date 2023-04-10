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
    var avPlayer: AVPlayer?

    var avQueuePlayer: AVQueuePlayer?

    let applicationPlayer =  ApplicationMusicPlayer.shared

    var playerIndexPath: IndexPath?

    public var totalDuration: CMTime? {
        return avQueuePlayer?.currentItem?.asset.duration
    }

    public var currentTime: CMTime? {
        return avQueuePlayer?.currentTime()
    }
    // MARK: - Init

    private init() {}

    // MARK: - Func
    // MARK: - AVPlayer
    func setupAVPlayer(url: URL) {
        avPlayer = nil
        avPlayer = AVPlayer(url: url)

    }

    func playAVPlayer() {
        if let avPlayer {
            avPlayer.play()
        }
    }

    func pauseAVPlayer() {
        if let avPlayer {
            avPlayer.pause()
        }
    }
    // MARK: - ApplicationPlayer
    func playApplicationPlayer() throws {
        Task {
                try await applicationPlayer.play()
        }
    }

    func pauseApplicationPlayer() {
            applicationPlayer.pause()
    }

    func backwardApplicationPlayer() {
        Task {
            do {
                try await applicationPlayer.skipToPreviousEntry()
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
        }
    }

    func forwardApplicationPlayer() {
        Task {
            do {
                try await applicationPlayer.skipToNextEntry()
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
        }
    }
}
