//
//  SearchResultViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/28.
//

import MediaPlayer
import UIKit
import Photos

import Screenshots
import MusicKit

private enum Size {
    static let tableViewRowHeight = 80.0
    static let defaultOffset = 23.0
}

private enum SearchResultSection {
    case resultList
}

class SearchResultViewController: BaseViewController {

    // MARK: - Properties
    private let xMarkButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiteral.xMarkButton, for: .normal)
        button.tintColor = .label
        return button
    }()

    private lazy var screenshotButton: UIButton = {
        let button = UIButton()
        button.setTitle("스크린샷 내보내기".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .semiBoldSubheadline
        button.addTarget(self, action: #selector(screenshotButtonTapped), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(createPlayListButtonTapped), for: .touchUpInside)
        return button
    }()

    private let musicTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(cell: MusicTableViewCell.self)
        tableView.rowHeight = Size.tableViewRowHeight
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: .zero, left: Size.defaultOffset, bottom: .zero, right: Size.defaultOffset)
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
        button.setImage(ImageLiteral.apple.withRenderingMode(.alwaysTemplate).withConfiguration(imageConfig),
                        for: .normal)
        button.imageView?.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSubheadline
        button.isUserInteractionEnabled = false
        return button
    }()

    private var dataSource: UITableViewDiffableDataSource<SearchResultSection, Music>!

    let musics: [Music]

    var audioPlayer: AVPlayer?

    @Published var musicSubscription: MusicSubscription?

    // MARK: - Init
    init(with musics: [Music], searchText: String) {
        self.musics = musics
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
        updateDataSource(items: musics)
        checkMusicSubscription()
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
    }

    override func configUI() {
        view.backgroundColor = .shortcutBackground
    }

    // MARK: - Func
    private func addTargets() {
        xMarkButton.addTarget(self, action: #selector(xMarkButtonTapped), for: .touchUpInside)
    }

    private func setDelegation() {
        musicTableView.delegate = self
    }

    private func setDataSource() {
        dataSource = UITableViewDiffableDataSource<SearchResultSection, Music>(tableView: musicTableView, cellProvider: { tableView, indexPath, music -> UITableViewCell? in
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

    @objc func xMarkButtonTapped() {
        dismiss(animated: true)
    }

    @objc func createPlayListButtonTapped() {
        setupLottieView(with: "플레이리스트 생성 중")

        // TODO: - 추후 ViewModel로 코드 이동 예정
        let creationMetadata = MPMediaPlaylistCreationMetadata(name: titleLabel.text ?? "My Playlist")
        creationMetadata.authorDisplayName = "NowMusic"
        creationMetadata.descriptionText = "This playlist contains awesome songs!"

        // FIXME: - 수정필요
        Task {
            let playListId = UUID()
            let playList = try await MPMediaLibrary.default().getPlaylist(with: playListId, creationMetadata: creationMetadata)

            let dispatchGroup = DispatchGroup()
            for music in musics {
                dispatchGroup.enter()
                playList.addItem(withProductID: music.id.rawValue) { _ in
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.wait()

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

        // TODO: - 추후 ViewModel로 코드 이동 예정
        if #available(iOS 14, *) {
            switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            case .limited, .authorized:
                    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                makeAlert(title: "저장".localized().localized(), message: "스크린샷 내보내기를 했습니다.".localized())
            case .notDetermined:
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                        if status == .limited || status == .authorized {
                            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                            DispatchQueue.main.async {
                                self?.makeAlert(title: "저장".localized(), message: "스크린샷 내보내기를 했습니다.".localized())
                            }
                        } else {
                                self?.showPermissionAlert()
                        }
                    }
            case .restricted, .denied:
                    showPermissionAlert()
            default:
                break
            }
        } else {
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
            case .notDetermined:
                    PHPhotoLibrary.requestAuthorization({ [weak self] status in
                        if status == .authorized {
                            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                            DispatchQueue.main.async {
                                self?.makeAlert(title: "저장".localized(), message: "스크린샷 내보내기를 했습니다.".localized())
                            }
                        } else {
                            self?.showPermissionAlert()
                        }
                    })
            case .restricted, .denied:
                showPermissionAlert()
            default:
                break
            }
        }
    }

    private func showPermissionAlert() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: nil, message: "사진 접근 권한이 없습니다. 설정으로 이동하여 권한 설정을 해주세요.".localized(), preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "확인".localized(), style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            alert.addAction(UIAlertAction(title: "취소".localized(), style: .cancel, handler: nil))

            self?.present(alert, animated: true)
        }
    }

    func configure(creationDate: Date) {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyMMdd ahh시".localized()
        myDateFormatter.locale = .autoupdatingCurrent
        dateLabel.text = myDateFormatter.string(from: creationDate)
    }

    // TODO: - 추후 ViewModel로 코드 이동 예정
    func checkMusicSubscription() {
        Task {
            for await subscription in MusicSubscription.subscriptionUpdates {
                musicSubscription = subscription
            }
        }
    }
    // TODO: - 추후 ViewModel로 코드 이동 예정
    func remoteCommandCenterSetting() {
            UIApplication.shared.beginReceivingRemoteControlEvents()
            let center = MPRemoteCommandCenter.shared()

            // 제어 센터 재생버튼 누르면 발생할 이벤트를 정의합니다.
            center.playCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
                self?.audioPlayer?.play()
                return MPRemoteCommandHandlerStatus.success
            }

            // 제어 센터 pause 버튼 누르면 발생할 이벤트를 정의합니다.
            center.pauseCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
                self?.audioPlayer?.pause()
                return MPRemoteCommandHandlerStatus.success
            }

        }
}

// MARK: - UITableViewDelegate
extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let music = dataSource.itemIdentifier(for: indexPath) else { return }

        if let musicIsSubscribed = musicSubscription?.canPlayCatalogContent, musicIsSubscribed {
            player.queue = [music]
            Task {
                do {
                    try await player.prepareToPlay()
                    beginPlaying()
                } catch {
                    makeAlert(title: "실패".localized(), message: "재생할 수 없는 음악입니다.".localized())
                }
            }

        } else {
            if let url = music.previewURL {
                // TODO: - 추후 ViewModel로 코드 이동 예정
                
 //             FIXME: - AVPlayer 구조적 변화 필요
                let player = SoundManager.shared
                player.setupSound(url: url)
                player.playSound()
                let center = MPNowPlayingInfoCenter.default()
                var nowPlayingInfo = center.nowPlayingInfo ?? [String: Any]()

                // FIXME: - 수정 필요
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: URL(string: music.imageURL)!)
                    DispatchQueue.main.async { [weak self] in
                        nowPlayingInfo[MPMediaItemPropertyTitle] = music.title
                        nowPlayingInfo[MPMediaItemPropertyArtist] = music.artist
                        let image = UIImage(data: data ?? Data())

                        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image?.size ?? .zero, requestHandler: { _ in
                            return image ?? UIImage()
                               })
                        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self?.audioPlayer?.currentItem?.duration // FIXME: - 음악시간이 0으로 나오는 문제
                        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self?.audioPlayer?.rate
                        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self?.audioPlayer?.currentTime()

                        center.nowPlayingInfo = nowPlayingInfo
                        self?.remoteCommandCenterSetting()
                    }
                }




            }
        }
    }
}
