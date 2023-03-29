//
//  SearchResultViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/28.
//

import MediaPlayer
import UIKit

private enum Size {
    static let tableViewRowHeight = 80.0
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

    private let screenshotButton: UIButton = {
        let button = UIButton()
        button.setTitle("스크린샷 내보내기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .semiBoldSubheadline
        return button
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.semiBoldSubheadline
        label.textColor = .black
        label.text = "2030304 오후 2시"
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        return label
    }()

    private lazy var createPlaylistButton: UIButton = {
        let button = UIButton()
        button.setTitle("Music에서 열기", for: .normal)
        button.setImage(ImageLiteral.apple.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .appleMusicOrange
        button.titleLabel?.font = .semiBoldSubheadline
        button.layer.cornerRadius = 22.5
        button.addTarget(self, action: #selector(createPlayListButtonTapped), for: .touchUpInside)
        return button
    }()

    private let musicTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(cell: MusicTableViewCell.self)
        tableView.rowHeight = Size.tableViewRowHeight
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        return tableView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.isHidden = true
        activityIndicator.layer.zPosition = 1
        return activityIndicator
    }()

    private var dataSource: UITableViewDiffableDataSource<SearchResultSection, Music>!

    let musics: [Music]

    // MARK: - Init
    init(with musics: [Music], searchText: String) {
        self.musics = musics
        titleLabel.text = searchText
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
        setDelegation()
        setDataSource()
        updateDataSource(items: musics)
    }

    override func render() {
        view.addSubview(xMarkButton)
        xMarkButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(23)
        }

        view.addSubview(screenshotButton)
        screenshotButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.trailing.equalToSuperview().inset(26)
        }

        view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(xMarkButton.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(23)
        }

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(23)
        }

        view.addSubview(createPlaylistButton)
        createPlaylistButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(23)
            make.width.equalTo(165)
            make.height.equalTo(45)
        }

        view.addSubview(musicTableView)
        musicTableView.snp.makeConstraints { make in
            make.top.equalTo(createPlaylistButton.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(23)
            make.trailing.equalToSuperview().offset(-26)
            make.bottom.equalToSuperview()
        }
    }

    override func configUI() {
        view.backgroundColor = .white
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
        let creationMetadata = MPMediaPlaylistCreationMetadata(name: titleLabel.text ?? "My Playlist")
        creationMetadata.authorDisplayName = "DaeSeong Kim"
        creationMetadata.descriptionText = "This playlist contains awesome songs!"

        Task {
            let playListId = UUID()
            let playList = try await MPMediaLibrary.default().getPlaylist(with: playListId, creationMetadata: creationMetadata)

            for music in musics {
                try await playList.addItem(withProductID: music.id.rawValue)
            }

            guard let musicURL = URL(string: "music://music.apple.com/library") else { return }
            if UIApplication.shared.canOpenURL(musicURL) {
                await UIApplication.shared.open(musicURL)
            } else {
                await UIApplication.shared.open(URL(string: "music://music.apple.com")!)
            }

            stopLottieAnimation()
        }
    }

}

extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let music = dataSource.itemIdentifier(for: indexPath) else { return }

        player.queue = [music]
        Task {
            do {
                try await player.prepareToPlay()
                beginPlaying()
            } catch {
                self.makeAlert(title: "실패", message: "재생할 수 없는 음악입니다.")
            }
        }
    }
}
