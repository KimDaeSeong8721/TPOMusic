//
//  PlayListViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/04/17.
//

import UIKit
import MediaPlayer


private enum Size {
    static let tableViewRowHeight = 80.0
    static let defaultOffset = 23.0
}
class PlayListViewController: BaseViewController {

    // MARK: - Properties
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
        tableView.isUserInteractionEnabled = true
        tableView.setEditing(true, animated: false)
        return tableView
    }()

    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        return button
    }()

    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    private var dataSource: UITableViewDiffableDataSource<SearchResultSection, Music>!

    var musics: [Music] = []

    // MARK: - Init
    init(musics: [Music]) {
        self.musics = musics
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDataSource()
        updateDataSource(items: musics)
        addTargets()
    }

    override func render() {
        view.addSubview(musicTableView)
        musicTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.leading.trailing.bottom.equalToSuperview()
        }

        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(15)
        }
    }

    override func configUI() {
        view.backgroundColor = .white
    }
    // MARK: - Func
    private func addTargets() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }

    private func setDataSource() {
        dataSource = CustomTableDiffableDataSource(
            tableView: musicTableView,
            cellProvider: { tableView, indexPath, music -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withType: MusicTableViewCell.self, for: indexPath)
            cell.configure(with: music, musicButtonIsHidden: true)
            return cell
        })
    }

    private func updateDataSource(items: [Music], animated: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<SearchResultSection, Music>()
        snapshot.appendSections([.resultList])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated, completion: nil)
    }

    @objc func confirmButtonTapped() {
        setupLottieView(with: "플레이리스트 생성 중")
        let selectedMusics = dataSource.snapshot().itemIdentifiers
        Task {
            await createPlaylist(title: "지금플리", musics: selectedMusics)
            guard let musicURL = URL(string: "music://music.apple.com/library") else { return }
            if UIApplication.shared.canOpenURL(musicURL) {
                await UIApplication.shared.open(musicURL)
            } else {
                await UIApplication.shared.open(URL(string: "music://music.apple.com")!)
            }
            stopLottieAnimation()
            dismiss(animated: true)
        }
    }
    // TODO: - 추후 Viewmodel로 옮김기
    func createPlaylist(title: String?, musics: [Music]) async {
        let creationMetadata = MPMediaPlaylistCreationMetadata(name: title ?? "My Playlist")
        creationMetadata.authorDisplayName = "NowMusic"
        creationMetadata.descriptionText = "This playlist contains awesome songs!"

        let playListId = UUID()
        let playList = try? await MPMediaLibrary.default().getPlaylist(with: playListId, creationMetadata: creationMetadata)

        let dispatchGroup = DispatchGroup()
        if let playList = playList {
            for music in musics {
                dispatchGroup.enter()
                playList.addItem(withProductID: music.id.rawValue) { _ in
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.wait()
    }
}

