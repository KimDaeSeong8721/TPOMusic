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

    private let profileButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiteral.profileButton, for: .normal)
        button.tintColor = .black
        button.frame = .init(x: .zero, y: .zero, width: 30, height: 30)
        return button
    }()

    private let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        view.isUserInteractionEnabled = false
        return view
    }()
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.itemSize = .init(width: 340, height: 340)
        return layout
    }()

    private lazy var playListCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(cell: HistoryCollectionViewCell.self)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .systemGray5
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
//        updateDataSource(items: [PlayList(title: "노을 질 때 한강에서 듣기 좋은 노래", imageURL: "", musicList: [Music(title: "나다", artist: "김대성", imageURL: "안물")]),
//                                 PlayList(title: "노을 질 때 한강에서 듣기 좋은 노래", imageURL: "", musicList: [Music(title: "나다", artist: "김대성", imageURL: "안물")])])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updatePlayList() // 노티피케이션 쓰면 됨

    }

    override func render() {

        view.addSubview(barView)
        barView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(8)
        }
        barTopConstraint = barView.topAnchor.constraint(equalTo: view.topAnchor)
        barTopConstraint.constant = 20
        barTopConstraint.isActive = true

        view.addSubview(historyLabel)
        historyLabel.snp.makeConstraints { make in
            make.top.equalTo(barView.snp.bottom).offset(15)
            make.leading.equalToSuperview().inset(25)
        }

        view.addSubview(profileButton)
        profileButton.snp.makeConstraints { make in
            make.top.equalTo(barView.snp.bottom).offset(7)
            make.trailing.equalToSuperview().inset(25)
        }

        view.addSubview(playListCollectionView)
        playListCollectionView.snp.makeConstraints { make in
            make.top.equalTo(historyLabel.snp.bottom).offset(20)
            make.leading.bottom.trailing.equalToSuperview().inset(25)
        }
    }

    override func configUI() {
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 20
    }

    // MARK: - Bind
    func bind() {
        viewModel.$playLists.sink { [weak self] playLists in
            self?.updateDataSource(items: playLists)
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

extension HistoryViewController: UICollectionViewDelegate {

}
