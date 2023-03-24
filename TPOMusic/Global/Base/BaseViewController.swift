//
//  BaseViewController.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/09.
//

import UIKit
import MusicKit

class BaseViewController: UIViewController {
    // MARK: - Properties
    let player =  ApplicationMusicPlayer.shared
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        configUI()
    }

    func render() {
        // auto layout 관련 코드
    }

    func configUI() {
        // UI 관련 코드
        view.backgroundColor = .systemBackground
    }

    // MARK: - Func
    func beginPlaying() {
        Task {
            do {
                try await player.play()
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
        }
    }
}
