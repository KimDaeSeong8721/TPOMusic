//
//  SearchViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/10.
//

import UIKit
import MusicKit

private enum Size {
    static let textFieldWidth = UIScreen.main.bounds.size.width - 64
    static let textFieldHeight = 44.0
    static let tableViewRowHeight = 80.0
}

private enum SearchResultSection {
    case resultList
}

class SearchViewController: BaseViewController, ViewModelBindableType {

    // MARK: - Properties
    private lazy var searchTextField: UITextField = {
        let textfield = UITextField(frame: CGRect(origin: .zero,
                                                  size: CGSize(width: Size.textFieldWidth, height: Size.textFieldHeight)))
        textfield.placeholder = "검색어를 입력해주세요"
        textfield.font = .systemFont(ofSize: 18, weight: .medium)
        textfield.borderStyle = .none
        textfield.clearButtonMode = .whileEditing
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType = .none
        textfield.returnKeyType = .done
        textfield.delegate = self
        return textfield
    }()

    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 15
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "GUIDE💡 이렇게 검색해주세요!"
        label.font = UIFont.boldCallout
        label.textColor = .black
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = """
                    TPO에 맞는 노래를 찾는다면? \n
                    → “노을 질 때 한강에서 듣기 좋은 노래" \n
                    내가 좋아하는 노래와 비슷한 노래를 찾는다면? \n
                    → “뉴진스 Ditto랑 비슷한 노래" \n
                    """
        label.font = UIFont.regularCallout
        label.textColor = .black
        label.numberOfLines = .zero
        return label
    }()

    private let musicTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(cell: MusicTableViewCell.self)
        tableView.rowHeight = Size.tableViewRowHeight
        tableView.separatorStyle = .singleLine
        tableView.isHidden = true
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

    var viewModel: SearchViewModel!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegation()
        setDataSource()
        Task {
            await viewModel.requestMusicAuth()
        }
    }

    override func render() {
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        view.addSubview(musicTableView)
        musicTableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalToSuperview()
        }

        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(subTitleLabel)

        verticalStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(35)
            make.leading.trailing.equalToSuperview().inset(25)
        }
    }

    override func configUI() {
        view.backgroundColor = .systemBackground

        let searchController = UISearchController()
        searchController.searchBar.placeholder = "검색어를 입력하세요"
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.delegate = self

        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false

        let header = UIView()
        header.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(23)
        }
        let headerLabel = UILabel()
        headerLabel.text = "플레이리스트 추천"
        headerLabel.font = UIFont.boldTitle3
        header.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
        }
        musicTableView.tableHeaderView = header

    }

    // MARK: - Bind
    func bind() {

        viewModel.$musics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] musics in
                self?.updateDataSource(items: musics)
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
            }
            .store(in: &viewModel.subscription)

        NotificationCenter.default.publisher(for: Notification.Name("bookMarkClicked"))
            .sink { [weak self] notification in
                let tuple = notification.object as! (isSelected: Bool, music: Music)
                let isSelected = tuple.isSelected
                let music = tuple.music

                if !isSelected {
                    if let playList = self?.viewModel.isExistedPlayList() {
                        self?.viewModel.saveMusicToPlayList(listId: playList.listId, musics: [music])
                    } else {
                        guard let listId = self?.viewModel.createPlayList() else { return }
                        self?.viewModel.saveMusicToPlayList(listId: listId, musics: [music])
                    }
                } else {
                    guard let playList = self?.viewModel.isExistedPlayList() else { return }
                    self?.viewModel.deleteMusicFromPlayList(listId: playList.listId, musicIds: [music.id])

                    // 플레이 리스트에 음악이 1개 있고 이제 이 음악을 삭제할 때 플레이리스토 함께 삭제구현
                }

            }
            .store(in: &viewModel.subscription)
    }

    // MARK: - Func
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

    private func reloadDatSourceItems() {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.resultList])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    @objc func backTapped() {
        dismiss(animated: true)
    }
}

extension SearchViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        musicTableView.isHidden = false
        verticalStackView.isHidden = true
        activityIndicator.isHidden = false
        guard let searchText = searchBar.text else { return }
        activityIndicator.startAnimating()
        viewModel.searchChatGPT(searchText: searchText)

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        musicTableView.isHidden = true
        verticalStackView.isHidden = false
    }

}

extension SearchViewController: UITableViewDelegate {
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
