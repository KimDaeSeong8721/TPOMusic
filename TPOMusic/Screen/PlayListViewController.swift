//
//  PlayListViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/18.
//

import UIKit

private enum Size {
    static let tableViewRowHeight = 80.0
}

private enum PlayListSection {
    case playList
}

class PlayListViewController: BaseViewController, ViewModelBindableType {

    // MARK: - Properties
    private let musicTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(cell: MusicTableViewCell.self)
        tableView.rowHeight = Size.tableViewRowHeight
        tableView.separatorStyle = .singleLine
        return tableView
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldTitle3
        label.text = "노을 질 때 한강에서 듣기 좋은 노래"
        return label
    }()

    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiteral.editButton, for: .normal)
        button.frame = .init(x: .zero, y: .zero, width: 25, height: 25)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private lazy var backButton: BackButton = {
        let button = BackButton()
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()

    private lazy var menuItems: [UIAction] = {
                   return [
                       UIAction(title: "이름 수정", image: UIImage(systemName: "pencil"), handler: { _ in
                           print("")
                           print("===============================")
                           print("[ViewController >> testMain() :: 다운로드 버튼 이벤트 발생]")
                           print("===============================")
                           print("")
                       }),
                       UIAction(title: "플리 삭제", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                           self?.viewModel.deletePlayList()
                           self?.dismiss(animated: true)
                       })
                   ]
               }()

    private lazy var menu: UIMenu = {
        let menu = UIMenu(title: "", options: [], children: menuItems)
        return menu
    }()

    private var dataSource: UITableViewDiffableDataSource<PlayListSection, Music>!

    var viewModel: PlayListViewModel!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegation()
        setDataSource()
    }

    override func render() {

        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        view.addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        view.addSubview(musicTableView)
        musicTableView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalToSuperview()
        }
    }

    override func configUI() {

        view.backgroundColor = .systemBackground

        let header = UIView()
        header.frame = .init(x: .zero,
                             y: .zero,
                             width: UIScreen.main.bounds.width,
                             height: 23)
        header.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
        }
        musicTableView.tableHeaderView = header
    }

    func bind() {

        viewModel.$musicList
            .sink { [weak self] musics in
                self?.updateDataSource(items: musics)
            }
            .store(in: &viewModel.subscription)

        NotificationCenter.default.publisher(for: Notification.Name("bookMarkClicked"))
            .sink { [weak self] notification in
                let tuple = notification.object as! (isSelected: Bool, music: Music)
                let isSelected = tuple.isSelected
                let music = tuple.music
                if isSelected {
                    self?.viewModel.deleteMusicFromPlayList(musicIds: [music.id])
                    self?.viewModel.updateMusicList()
                }

            }
            .store(in: &viewModel.subscription)
    }

    // MARK: - Func
    private func setDelegation() {
        musicTableView.delegate = self
    }

    private func setDataSource() {
        dataSource = UITableViewDiffableDataSource<PlayListSection, Music>(tableView: musicTableView, cellProvider: { tableView, indexPath, music -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withType: MusicTableViewCell.self, for: indexPath)
            cell.configure(with: music, isSaved: true)
            return cell
        })
    }

    private func updateDataSource(items: [Music], animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<PlayListSection, Music>()
        snapshot.appendSections([.playList])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated, completion: nil)
    }

    private func reloadDatSourceItems() {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.playList])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    @objc func backTapped() {
        dismiss(animated: true)
    }

}

extension PlayListViewController: UITableViewDelegate {
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
