//
//  PlayerViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/04/08.
//

import Combine
import UIKit

import Kingfisher
import SnapKit
import CoreMedia

protocol PlayerViewControllerDelegate {
    func PlayerViewControllerWillDisAppear()
}

private enum Size {
    static let defaultOffset = 25
    static let topOffset = UIScreen.main.bounds.height / 8.44
}

enum PlayingState {
    case playing
    case pause
    case previous
    case next
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
    private lazy var sliderBar: CustomSlider = {
        let slider = CustomSlider()
        slider.setThumbImage(UIImage(), for: .normal)
        slider.minimumValue = 0.0
        slider.addTarget(self, action: #selector(changeSeekSlider(_:)), for: .valueChanged)
        slider.tintColor = .white
        return slider
    }()

    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .regularCaption1
        label.text = "00:00"
        return label
    }()

    private lazy var finishTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .regularCaption1
        let duration = soundManager.totalDuration ?? 30.0
        let leftMinute = Int(duration / 60.0)
        let leftSecond = Int(duration.truncatingRemainder(dividingBy: 60))
        let leftTimeText: String = String(format: "%02ld:%02ld", leftMinute, leftSecond)
        label.text = leftTimeText
        return label
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

    var playingState: PlayingState = .playing

    var delegate: PlayerViewControllerDelegate?

    private var timer: Timer?

    var subscription = Set<AnyCancellable>()

    // MARK: - Deinit
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        makeAndFireTimer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            make.top.equalToSuperview().offset(Size.topOffset)
            make.width.height.equalTo(250)
            make.centerX.equalToSuperview()
        }

        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(subTitleLabel)
        verticalStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(Size.topOffset)
            make.horizontalEdges.equalToSuperview().inset(Size.defaultOffset)
        }

        view.addSubview(sliderBar)
        sliderBar.snp.makeConstraints { make in
            make.top.equalTo(verticalStackView.snp.bottom).offset(30)
            make.horizontalEdges.equalToSuperview().inset(Size.defaultOffset)
        }

        view.addSubview(currentTimeLabel)
        currentTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(sliderBar.snp.bottom)
            make.leading.equalTo(sliderBar)
        }

        view.addSubview(finishTimeLabel)
        finishTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(sliderBar.snp.bottom)
            make.trailing.equalTo(sliderBar)
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
        sliderBar.maximumValue = Float(soundManager.totalDuration ?? 30.0)


    }

    // MARK: - Func
    private func addTargets() {
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(backwardButtonTapped), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
    }

    private func setNotification() {

        NotificationCenter.default.publisher(for: Notification.Name.AVPlayerItemDidPlayToEndTime)
            .sink { [weak self] _ in
                NotificationCenter.default.post(name: NSNotification.Name("forwardButtonTapped"), object: nil)
            }
            .store(in: &subscription)

        NotificationCenter.default.publisher(for: Notification.Name.MPMusicPlayerControllerPlaybackStateDidChange)
            .throttle(for: 1, scheduler: RunLoop.main, latest: false) // 여러 번호출 방지 이유 찾기
            .sink { [weak self] _ in

                if self?.soundManager.applicationPlayer.nowPlayingItem == nil && self?.soundManager.avQueuePlayer?.currentItem == nil { return }

                switch self?.playingState {
                case .playing:
                    if self?.soundManager.applicationPlayer.playbackState == .paused {
                        self?.playButton.isSelected = true
                        self?.playingState = .pause
                    }
                case .pause:
                    if self?.soundManager.applicationPlayer.playbackState == .playing {
                        self?.playButton.isSelected = false
                        self?.playingState = .playing
                    }
                case .previous:
                    self?.playingState = .playing
                    NotificationCenter.default.post(name: NSNotification.Name("backwardButtonTapped"), object: nil)
                case .next:
                    self?.playingState = .playing
                    NotificationCenter.default.post(name: NSNotification.Name("forwardButtonTapped"), object: nil)
                default: break
                }
            }
            .store(in: &subscription)
    }

    private func updateTimeLabelText(time: TimeInterval) {
        if time.isNaN { return }
        let minute = Int(time / 60)
        let second = Int(time.truncatingRemainder(dividingBy: 60))

        let leftTime = (soundManager.totalDuration ?? .zero) - time
        let leftMinute = Int(leftTime / 60)
        let leftSecond = Int(leftTime.truncatingRemainder(dividingBy: 60))
        let currentTimeText: String = String(format: "%02ld:%02ld", minute, second)
        let leftTimeText: String = String(format: "%02ld:%02ld", leftMinute, leftSecond)

        self.currentTimeLabel.text = currentTimeText
        self.finishTimeLabel.text = leftTimeText
    }

    private func makeAndFireTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01,
                                          repeats: true,
                                          block: { [weak self] _ in
            UIView.animate(withDuration: 3.0) {
                self?.sliderBar.trackHeight = 10
            }
            if let isTracking = self?.sliderBar.isTracking, isTracking { return }
            UIView.animate(withDuration: 3.0) {
                self?.sliderBar.trackHeight = 6
            }

            let time = self?.soundManager.currentTime ?? .zero
            guard let slider = self?.sliderBar else { return }
            self?.updateTimeLabelText(time: time)
            self?.sliderBar.value = Float(time)
        })
    }

    private func invalidateTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

    @objc func playButtonTapped() {
        if playingState == .playing {
            invalidateTimer()
            soundManager.pausePlayer()
            if soundManager.avQueuePlayer != nil {
                playingState = .pause
            }
        } else {
            makeAndFireTimer()
            soundManager.playPlayer()
            if soundManager.avQueuePlayer != nil {
                playingState = .playing
            }
        }
        playButton.isSelected.toggle()
    }

    @objc func backwardButtonTapped() {
        playingState = .previous
        soundManager.backwardPlayer()
    }

    @objc func forwardButtonTapped() {
        playingState = .next
        soundManager.forwardPlayer()

    }

    @objc func changeSeekSlider(_ sender: UISlider) {
        let currentTime = TimeInterval(sender.value)
        updateTimeLabelText(time: currentTime)
        if sender.isTracking { return }
        if soundManager.avQueuePlayer == nil {
            soundManager.applicationPlayer.currentPlaybackTime = currentTime
        } else {
            let cmTime = CMTime(value: CMTimeValue(currentTime), timescale: 1)
            soundManager.avQueuePlayer?.currentItem?.seek(to: cmTime)
        }
    }
}
