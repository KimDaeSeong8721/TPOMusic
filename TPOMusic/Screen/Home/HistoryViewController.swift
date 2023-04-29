//
//  HistoryViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import UIKit

struct ContentSection: Hashable {
    let historyDate: String
}

final class HistoryViewController: BaseViewController, ViewModelBindableType {

    // MARK: - Properties
    private let historyLabel: UILabel = {
        let label = UILabel()
        label.text = "히스토리".localized()
        label.font = UIFont.boldTitle3
        return label
    }()

    private let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.layer.cornerRadius = 3
        view.isUserInteractionEnabled = false
        return view
    }()
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = .zero
        return layout
    }()

    private(set) lazy var playListCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(cell: HistoryCollectionViewCell.self)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isUserInteractionEnabled = false
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        return collectionView
    }()

    private let noContentLabel: UILabel = {
        let label = UILabel()
        label.text = "히스토리가 존재하지 않습니다".localized()
        label.textAlignment = .center
        label.font = .regularBody
        label.textColor = .black.withAlphaComponent(0.5)
        return label
    }()
    var barTopConstraint: NSLayoutConstraint!

    private var dataSource: UICollectionViewDiffableDataSource<ContentSection, PlayList>!

    var viewModel: HistoryViewModel!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegation()
        setDataSource()
        viewModel.updatePlayList()
    }

    override func render() {
        view.addSubview(barView)
        barView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(91)
            make.height.equalTo(5)
        }
        barTopConstraint = barView.topAnchor.constraint(equalTo: view.topAnchor)
        barTopConstraint.constant = 20
        barTopConstraint.isActive = true

        view.addSubview(historyLabel)
        historyLabel.snp.makeConstraints { make in
            make.top.equalTo(barView.snp.bottom).offset(34)
            make.leading.equalToSuperview().inset(25)
        }

        view.addSubview(playListCollectionView)
        playListCollectionView.snp.makeConstraints { make in
            make.top.equalTo(historyLabel.snp.bottom).offset(23)
            make.leading.bottom.trailing.equalToSuperview().inset(25)
        }
        view.addSubview(noContentLabel)
        noContentLabel.snp.makeConstraints { make in
            make.top.equalTo(historyLabel.snp.bottom).offset(23)
            make.leading.trailing.equalToSuperview().inset(25)
        }
    }

    override func configUI() {
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.shortcutBackground.cgColor
        view.layer.cornerRadius = 20
    }

    // MARK: - Bind
    func bind() {
        viewModel.$playLists
            .sink { [weak self] playLists in
                self?.updateDataSource(items: playLists, animated: true)
                if !playLists.isEmpty {
                    self?.noContentLabel.isHidden = true
                } else {
                    self?.noContentLabel.isHidden = false
                }
        }
        .store(in: &viewModel.subscription)

        NotificationCenter.default.publisher(for: Notification.Name.NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                self?.viewModel.updatePlayList()
            }
            .store(in: &viewModel.subscription)
    }
    
    // MARK: - Func
    private func setDelegation() {
        playListCollectionView.delegate = self
    }

    private func setDataSource() {
        dataSource = CustomCollectionViewDiffableDataSource(collectionView: playListCollectionView, cellProvider: { collectionView, indexPath, playList -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withType: HistoryCollectionViewCell.self, for: indexPath)
            cell.configure(with: playList)
            return cell
        })
    }

    private func updateDataSource(items: [PlayList], animated: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<ContentSection, PlayList>()

        // TODO: - 리팩토링
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yy. MM. dd"
        myDateFormatter.locale = .autoupdatingCurrent

        var dateList = Set<String>()

        items.forEach { playlist in
            let dateString = myDateFormatter.string(from: playlist.date)
            dateList.insert(dateString)
        }

        let orderedDateList = Array(dateList).sorted { date1, date2 in
            date1 > date2
        }

        var dict: [ContentSection: [PlayList]] = [:]

        let sections = orderedDateList.map { date in
            let section = ContentSection(historyDate: date)
            dict[section] = []
            return section
        }

        items.forEach { playlist in
            let playlistDate = myDateFormatter.string(from: playlist.date)
            let section = sections.filter { playlistDate == $0.historyDate }.first!
            dict[section]?.insert(playlist, at: .zero)
        }
        snapshot.appendSections(sections)
        for (section, playlists) in dict {
            snapshot.appendItems(playlists, toSection: section)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

    // MARK: - UICollectionViewDelegate
extension HistoryViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let playList = dataSource.itemIdentifier(for: indexPath) else { return }
        var searchResultViewController = SearchResultViewController(searchText: playList.name)
        searchResultViewController.bindViewModel(SearchResultViewModel(with: playList.musicList))
        searchResultViewController.configure(creationDate: playList.date)
        searchResultViewController.modalPresentationStyle = .fullScreen
        present(searchResultViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let playList = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            let deleteAction = UIAction(title: "삭제".localized(), image: ImageLiteral.trash, identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) { [weak self] _  in
                self?.makeRequestAlert(title: "삭제".localized(), message: "정말 삭제하시겠습니까".localized(), okayAction: { _ in
                    self?.viewModel.deletePlayList(with: playList.listId)
                    self?.viewModel.updatePlayList()
                })
            }
            return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [deleteAction])
        }
        return config
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HistoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}
