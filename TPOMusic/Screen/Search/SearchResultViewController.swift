//
//  SearchResultViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/28.
//

import MediaPlayer
import UIKit
import Photos

import Lottie
import MusicKit
import Screenshots

private enum Size {
    static let tableViewRowHeight = 80.0
    static let defaultOffset = 23.0
}

private enum SearchResultSection {
    case resultList
}

final class SearchResultViewController: BaseViewController, ViewModelBindableType {

    // MARK: - Properties
    private let xMarkButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiteral.xMarkButton, for: .normal)
        button.tintColor = .label
        return button
    }()

    private let screenshotButton: UIButton = {
        let button = UIButton()
        button.setTitle("스크린샷 내보내기".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .semiBoldSubheadline
        return button
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.regularSubheadline
        label.textColor = .black
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyMMdd ahh시".localized()
        myDateFormatter.locale = .autoupdatingCurrent
        label.text = myDateFormatter.string(from: Date())
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()

    private lazy var createPlaylistButton: UIButton = {
        let button = UIButton()
        button.setTitle("플레이리스트 추가 〉".localized(), for: .normal)
        button.tintColor = .white
        button.setTitleColor(.appleMusicOrange, for: .normal)
        button.titleLabel?.font = .boldSubheadline
        button.layer.cornerRadius = 22.5
        return button
    }()

    private let musicTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(cell: MusicTableViewCell.self)
        tableView.rowHeight = Size.tableViewRowHeight
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: .zero,
                                                left: Size.defaultOffset,
                                                bottom: .zero,
                                                right: Size.defaultOffset)
        tableView.separatorStyle = .singleLine
        return tableView
    }()

    private let firstLabel: UILabel = {
        let label = UILabel()
        label.text = "애플 뮤직 구독중이라면?".localized()
        label.textColor = .subGray
        label.font = .semiBoldSubheadline
        return label
    }()

    private let appleMusicHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 3
        stackView.alignment = .center
        return stackView
    }()

    private let secondLabel: UIButton = {
        let button = UIButton()
        button.setTitle(" Music", for: .normal)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .light)
        button.setImage(ImageLiteral.apple
            .withRenderingMode(.alwaysTemplate)
            .withConfiguration(imageConfig),
                        for: .normal)
        button.imageView?.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSubheadline
        button.isUserInteractionEnabled = false
        return button
    }()

    private let playingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black.withAlphaComponent(0.9)
        button.layer.cornerRadius = 25
        button.isHidden = true
        return button
    }()

    private var playingLottieView: LottieAnimationView = {
        let view = LottieAnimationView(name: "playing")
        view.isUserInteractionEnabled = false
        return view
    }()

    private var dataSource: UITableViewDiffableDataSource<SearchResultSection, Music>!

    private var playingViewController: PlayerViewController?

    var viewModel: SearchResultViewModel!

    // MARK: - Init
    init(searchText: String) {
        titleLabel.text = searchText
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("소멸자")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
        setDelegation()
        setDataSource()
        updateDataSource(items: viewModel.musics)
        viewModel.checkMusicSubscription()
    }

    override func render() {
        view.addSubview(xMarkButton)
        xMarkButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(Size.defaultOffset)
        }

        view.addSubview(screenshotButton)
        screenshotButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().inset(26)
        }

        view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(xMarkButton.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(Size.defaultOffset)
        }

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(Size.defaultOffset)
        }

        view.addSubview(firstLabel)
        firstLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(Size.defaultOffset)
        }

        view.addSubview(appleMusicHStackView)
        appleMusicHStackView.addArrangedSubview(secondLabel)
        appleMusicHStackView.addArrangedSubview(createPlaylistButton)
        appleMusicHStackView.snp.makeConstraints { make in
            make.top.equalTo(firstLabel.snp.bottom)
            make.leading.equalToSuperview().offset(Size.defaultOffset)
        }

        view.addSubview(musicTableView)
        musicTableView.snp.makeConstraints { make in
            make.top.equalTo(createPlaylistButton.snp.bottom).offset(24)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        view.addSubview(playingButton)
        playingButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(40)
            make.trailing.equalToSuperview().inset(25)
            make.size.equalTo(50)
        }

        playingButton.addSubview(playingLottieView)
        playingLottieView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func configUI() {
        view.backgroundColor = .shortcutBackground
    }

    // MARK: - Bind
    func bind() {
        NotificationCenter.default
            .publisher(for: Notification.Name("backwardButtonTapped"))
            .sink { [weak self]  _ in
            if let index = self?.viewModel.getPlayerIndex(), index > .zero {
                let previousIndex = index - 1
                guard let previousMusic = self?.dataSource.itemIdentifier(for: IndexPath(row: previousIndex, section: .zero)) else { return }
                self?.viewModel.setPlayerIndex(index: previousIndex)
                self?.viewModel.setPlayerQueue(with: previousMusic)
                self?.playingViewController?.configure(with: previousMusic)
                if SoundManager.shared.avQueuePlayer == nil {
                    Task {
                        do {
                            try await self?.viewModel.playApplicationPlayer()
                        } catch {
                            self?.playingViewController?.dismiss(animated: true)
                            self?.makeAlert(title: "실패".localized(), message: "재생할 수 없는 음악입니다.".localized())
                        }
                    }
                } else {
                    SoundManager.shared.avQueuePlayer?.currentItem?.seek(to: CMTime(value: .zero, timescale: 1))
                    self?.viewModel.playAVPlayer()
                }
            } else {
                self?.viewModel.restartApplicationPlayer()
            }
        }
        .store(in: &viewModel.subscription)

        NotificationCenter.default
            .publisher(for: Notification.Name("forwardButtonTapped"))
            .sink { [weak self]  _ in
            if let index = self?.viewModel.getPlayerIndex(),
               let count = self?.dataSource.tableView(self?.musicTableView ?? UITableView(), numberOfRowsInSection: .zero),
               index < count - 1 {
                let nextIndex = index + 1
                guard let nextMusic = self?.dataSource.itemIdentifier(for: IndexPath(row: nextIndex, section: .zero)) else { return }
                self?.viewModel.setPlayerQueue(with: nextMusic)
                self?.viewModel.setPlayerIndex(index: nextIndex)
                self?.playingViewController?.configure(with: nextMusic)
                if SoundManager.shared.avQueuePlayer == nil {
                    Task {
                        do {
                            try await self?.viewModel.playApplicationPlayer()
                        } catch {
                            self?.playingViewController?.dismiss(animated: true)
                            self?.makeAlert(title: "실패".localized(), message: "재생할 수 없는 음악입니다.".localized())
                        }
                    }
                } else {
                    SoundManager.shared.avQueuePlayer?.currentItem?.seek(to: CMTime(value: .zero, timescale: 1))
                    self?.viewModel.playAVPlayer()
                }

            } else {
                self?.playingViewController?.playingState = .pause
                SoundManager.shared.pausePlayer()
                self?.playingViewController?.dismiss(animated: true)
            }
        }
        .store(in: &viewModel.subscription)

        
        NotificationCenter.default
            .publisher(for: Notification.Name.MPMusicPlayerControllerNowPlayingItemDidChange)
            .throttle(for: 3, scheduler: RunLoop.main, latest: false) // 여러 번호출 방지
            .sink { [weak self] notification in
                guard let playerController = notification.object as? MPMusicPlayerController else {
                    return
                }
                let item = playerController.nowPlayingItem
                guard let nextMusic =  self?.viewModel.musics.filter({ $0.id.rawValue == item?.playbackStoreID}).first else { return }
                self?.playingViewController?.configure(with: nextMusic) // 수정
            }
            .store(in: &viewModel.subscription)
    }

    // MARK: - Func
    private func addTargets() {
        xMarkButton.addTarget(self, action: #selector(xMarkButtonTapped), for: .touchUpInside)
        screenshotButton.addTarget(self, action: #selector(screenshotButtonTapped), for: .touchUpInside)
        createPlaylistButton.addTarget(self, action: #selector(createPlayListButtonTapped), for: .touchUpInside)
        playingButton.addTarget(self, action: #selector(playingButtonTapped), for: .touchUpInside)
    }

    private func setDelegation() {
        musicTableView.delegate = self
    }

    private func setDataSource() {
        dataSource = UITableViewDiffableDataSource<SearchResultSection, Music>(
            tableView: musicTableView,
            cellProvider: { tableView, indexPath, music -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withType: MusicTableViewCell.self, for: indexPath)
            cell.configure(with: music)
            return cell
        })
    }

    private func updateDataSource(items: [Music], animated: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<SearchResultSection, Music>()
        snapshot.appendSections([.resultList])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated, completion: nil)
    }

    private func showPermissionAlert() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: nil,
                                          message: "사진 접근 권한이 없습니다. 설정으로 이동하여 권한 설정을 해주세요.".localized(),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인".localized(),
                                          style: .default,
                                          handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            alert.addAction(UIAlertAction(title: "취소".localized(),
                                          style: .cancel,
                                          handler: nil))
            self?.present(alert, animated: true)
        }
    }

    func configure(creationDate: Date) {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyMMdd ahh시".localized()
        myDateFormatter.locale = .autoupdatingCurrent
        dateLabel.text = myDateFormatter.string(from: creationDate)
    }

    @objc func xMarkButtonTapped() {
        dismiss(animated: true)
    }

    @objc func createPlayListButtonTapped() {
        setupLottieView(with: "플레이리스트 생성 중")
        Task {
            await viewModel.createPlaylist(title: titleLabel.text)

            guard let musicURL = URL(string: "music://music.apple.com/library") else { return }
            if UIApplication.shared.canOpenURL(musicURL) {
                await UIApplication.shared.open(musicURL)
            } else {
                await UIApplication.shared.open(URL(string: "music://music.apple.com")!)
            }
            stopLottieAnimation()
        }
    }

    @objc func screenshotButtonTapped() {
        let image =  musicTableView.screenshot
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .limited, .authorized:
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
            makeAlert(title: "저장".localized(),
                      message: "스크린샷 내보내기를 했습니다.".localized())
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                if status == .limited || status == .authorized {
                    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                    DispatchQueue.main.async {
                        self?.makeAlert(title: "저장".localized(),
                                        message: "스크린샷 내보내기를 했습니다.".localized())
                    }
                } else { self?.showPermissionAlert() }
            }
        case .restricted, .denied:
            showPermissionAlert()
        default:
            break
        }
    }

    @objc func playingButtonTapped() {
        present(playingViewController ?? UIViewController(), animated: true)
    }
}

// MARK: - UITableViewDelegate
extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let music = dataSource.itemIdentifier(for: indexPath) else { return }
        playingViewController = PlayerViewController()
        playingViewController?.delegate = self
        playingViewController?.configure(with: music)

        guard let sheet = playingViewController?.sheetPresentationController else { return }
        sheet.detents = [.large()]
        sheet.prefersGrabberVisible = true
        sheet.largestUndimmedDetentIdentifier = .large

        if let musicIsSubscribed = viewModel.musicSubscription?.canPlayCatalogContent, musicIsSubscribed {
            // 구독 중이면 ApplicationPlayer 사용
            viewModel.setPlayerQueue(with: music)
            viewModel.setPlayerIndex(index: indexPath.row)
            Task {
                do {
                    try await viewModel.playApplicationPlayer()
                    present(playingViewController ?? UIViewController(), animated: true)
                } catch {
                    makeAlert(title: "실패".localized(), message: "재생할 수 없는 음악입니다.".localized())
                }
            }
        } else {
            // 구독이 아니라면 AVPlayer 사용
            viewModel.setPlayerQueue(with: music) // 수정 필요?
            if let url = music.previewURL {
                viewModel.setPlayerIndex(index: indexPath.row)
                viewModel.playAVPlayer()
                present(playingViewController ?? UIViewController(), animated: true)
            } else {
                makeAlert(title: "실패".localized(), message: "재생할 수 없는 음악입니다.".localized())
            }
        }
    }
}

// MARK: - UISheetPresentationControllerDelegate
extension SearchResultViewController: PlayerViewControllerDelegate {
    func PlayerViewControllerWillDisAppear() {
        if SoundManager.shared.avQueuePlayer != nil {
            // AV 플레이어
            if let playingState = playingViewController?.playingState, playingState == .pause {
                playingButton.isHidden = true
                playingLottieView.stop()
            } else {
                playingButton.isHidden = false
                playingLottieView.loopMode = .loop
                playingLottieView.play()
            }
        } else {
            // Application 플레이어
            if SoundManager.shared.applicationPlayer.playbackState == .paused {
                playingButton.isHidden = true
                playingLottieView.stop()
            } else {
                playingButton.isHidden = false
                playingLottieView.loopMode = .loop
                playingLottieView.play()
            }
        }
    }


}
