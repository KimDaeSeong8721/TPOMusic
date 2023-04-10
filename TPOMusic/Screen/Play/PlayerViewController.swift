//
//  PlayerViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/04/08.
//

import UIKit

import Kingfisher
import SnapKit

protocol PlayerViewControllerDelegate {
    func PlayerViewControllerWillDisAppear()
}

private enum Size {
    static let defaultOffset = 25
}
class PlayerViewController: BaseViewController {

    // MARK: - Properties
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    // 이미지
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    // 메인타이틀
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldTitle3
        label.textColor = .white
        label.numberOfLines = 2
        label.text = "양화대교"

        return label
    }()
    // 서브타이틀
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBoldCallout
        label.textColor = .white.withAlphaComponent(0.5)
        label.text = "자이언티"
        label.numberOfLines = 2
        return label
    }()

    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = .zero
        stackView.distribution = .fillEqually
        return stackView
    }()

    // 프로그래스바
    private lazy var sliderBar: UISlider = {
        let slider = UISlider()
        slider.setThumbImage(UIImage(), for: .normal)
//        slider.addTarget(self, action: #selector(changeSeekSlider(_:)), for: .valueChanged)
        return slider
    }()

    // 이전 곡으로
    private let backwardButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiteral.backward, for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    // 재생 정지
     let playButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiteral.pause, for: .normal)
        button.setImage(ImageLiteral.play, for: .selected)
        button.tintColor = .white
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    // 다음 곡으로
    private let forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiteral.forward, for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()

    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 50
        stackView.distribution = .fillEqually
        return stackView
    }()

    let soundManager = SoundManager.shared

    var isPlaying = true

    var delegate: PlayerViewControllerDelegate?

    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
        setNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.PlayerViewControllerWillDisAppear()

    }

    override func render() {
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.width.height.equalTo(250)
            make.centerX.equalToSuperview()
        }

        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(subTitleLabel)
        verticalStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(100)
            make.horizontalEdges.equalToSuperview().inset(Size.defaultOffset)
        }

        view.addSubview(sliderBar)
        sliderBar.snp.makeConstraints { make in
            make.top.equalTo(verticalStackView.snp.bottom).offset(30)
            make.horizontalEdges.equalToSuperview().inset(Size.defaultOffset)
            make.height.equalTo(10)
        }

        view.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(backwardButton)
        backwardButton.snp.makeConstraints { make in
            make.width.equalTo(51)
            make.height.equalTo(39)
        }
        horizontalStackView.addArrangedSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(50)
        }
        horizontalStackView.addArrangedSubview(forwardButton)

        forwardButton.snp.makeConstraints { make in
            make.width.equalTo(51)
            make.height.equalTo(39)
        }
        horizontalStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(60)
            make.top.equalTo(sliderBar.snp.bottom).offset(60)
        }
    }

    override func configUI() {
         view.backgroundColor = .black
    }

    func configure(with music: Music) {
        titleLabel.text = music.title
        subTitleLabel.text = music.artist
        let url = URL(string: music.imageURL)
        imageView.kf.setImage(with: url)
        backgroundView.backgroundColor = music.backgroundColor.withAlphaComponent(0.8)
    }

    // MARK: - Func
    private func addTargets() {
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(backwardButtonTapped), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
    }

    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }

    @objc func playButtonTapped() {
        if !playButton.isSelected {
            isPlaying = false
            if soundManager.avPlayer == nil {
                soundManager.pauseApplicationPlayer()
            } else {
                soundManager.pauseAVPlayer()
            }
        } else {
            isPlaying = true
            if soundManager.avPlayer == nil {
                do {
                    try soundManager.playApplicationPlayer()
                } catch {
                    makeAlert(title: "실패".localized(), message: "재생할 수 없는 음악입니다.".localized())
                    isPlaying = false
                }
            } else {
                soundManager.playAVPlayer()
            }
        }
        playButton.isSelected.toggle()
    }

    @objc func backwardButtonTapped() {
        // 이전 플레이가 없다면 playButton pause로
        NotificationCenter.default.post(name: NSNotification.Name("backwardButtonTapped"), object: nil)
//        soundManager.backwardApplicationPlayer()
    }
    @objc func forwardButtonTapped() {
        // 다음 플레이가 없다면 playButton pause로
        NotificationCenter.default.post(name: NSNotification.Name("forwardButtonTapped"), object: nil)
//        soundManager.forwardApplicationPlayer()

    }
    @objc func playerItemDidPlayToEndTime() {
        playButton.isSelected.toggle()
        dismiss(animated: true)
    }

}
