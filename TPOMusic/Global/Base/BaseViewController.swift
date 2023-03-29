//
//  BaseViewController.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/09.
//

import UIKit
import MusicKit
import Lottie

class BaseViewController: UIViewController {
    // MARK: - Properties
    let player =  ApplicationMusicPlayer.shared

    private lazy var backgroundView = BackgroundView()
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

    func setupLottieView(with title: String = "") {
        if let superview = view.superview {
            superview.addSubview(backgroundView)
            backgroundView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {

            view.addSubview(backgroundView)
            backgroundView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        backgroundView.setupLottieView(with: title)
    }

    func stopLottieAnimation() {
        backgroundView.stopLottieAnimation()
        backgroundView.removeFromSuperview()

    }

    func showMoreWaitLabel() {
        backgroundView.moreWaitLabel.isHidden = false
    }

}
