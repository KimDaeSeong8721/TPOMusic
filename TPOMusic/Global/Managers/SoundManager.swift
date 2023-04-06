//
//  SoundManager.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/04/06.
//


import Foundation
import AVFoundation

class SoundManager {
    // MARK: - Properties

    static let shared = SoundManager()
    private var player: AVPlayer?

    // MARK: - Init

    private init() {}

    // MARK: - Func

    func setupSound(url: URL) {
        player = AVPlayer(url: url)
    }

    func playSound() {
        if let player {
            player.play()
        }
    }

    func pauseSound() {
        if let player {
            player.pause()
        }
    }
}
