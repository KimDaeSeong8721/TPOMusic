//
//  HistoryViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import UIKit

enum ContentSection {
    case historyList
}

final class HistoryViewController: BaseViewController, ViewModelBindableType {
    // MARK: - Properties

    private let historyLabel: UILabel = {
        let label = UILabel()
        label.text = "히스토리"
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
        layout.minimumLineSpacing = 20
        return layout
    }()

    private(set) lazy var playListCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(cell: HistoryCollectionViewCell.self)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isUserInteractionEnabled = false
        return collectionView
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
    }

    override func configUI() {
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.shortcutBackground.cgColor
        view.layer.cornerRadius = 20
    }

    // MARK: - Bind
    func bind() {
        viewModel.$playLists.sink { [weak self] playLists in
            self?.updateDataSource(items: playLists)
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
        dataSource = UICollectionViewDiffableDataSource<ContentSection, PlayList>(collectionView: playListCollectionView, cellProvider: { collectionView, indexPath, playList -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(withType: HistoryCollectionViewCell.self, for: indexPath)
            cell.configure(with: playList)
            
            return cell
        })

    }

    private func updateDataSource(items: [PlayList], animated: Bool = false, completion: (() -> Void)? = nil) {
        var snapshot = NSDiffableDataSourceSnapshot<ContentSection, PlayList>()
        snapshot.appendSections([.historyList])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }

    private func reloadDatSourceItems(animated: Bool = false) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.historyList])
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let playList = dataSource.itemIdentifier(for: indexPath) else { return }
        let searchResultViewController = SearchResultViewController(with: playList.musicList, searchText: playList.name)
        searchResultViewController.modalPresentationStyle = .fullScreen
        present(searchResultViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            let deleteAction = UIAction(title: "삭제", image: ImageLiteral.trash, identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) { (_) in
                    // TODO: - 삭제기능 구현
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [deleteAction])
        }
        return config
    }
}
