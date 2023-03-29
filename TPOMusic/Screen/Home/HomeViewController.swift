//
//  HomeViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/09.
//

import UIKit

class HomeViewController: BaseViewController, ViewModelBindableType {

    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "어떤 상황에 어울리는 플레이리스트를 알려드릴까요?"
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.regularSubheadline
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = ImageLiteral.character
        return imageView
    }()

    private lazy var searchBarView =  SearchBarView()

    private let shortcutButton1: UIButton = {
       let button = UIButton()
        button.backgroundColor = .shortcutBackground
        button.setTitle("“노을 질 때 한강에서 듣기 좋은 노래”", for: .normal)
        button.setTitleColor(.shortcutText, for: .normal)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = .regularSubheadline
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets.leading = 10
        configuration.contentInsets.trailing = 10
        button.configuration = configuration
        return button
    }()

    private let shortcutButton2: UIButton = {
       let button = UIButton()
        button.backgroundColor = .shortcutBackground
        button.setTitle("“따뜻한 주말 카페에서 공부할 때 듣기 좋은 노래”", for: .normal)
        button.layer.cornerRadius = 15
        button.setTitleColor(.shortcutText, for: .normal)
        button.titleLabel?.font = .regularSubheadline
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets.leading = 10
        configuration.contentInsets.trailing = 10
        button.configuration = configuration
        return button
    }()

    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 14
        return stackView
    }()

    var viewModel: SearchViewModel!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
        setDelegation()
        Task {
            await viewModel.requestMusicAuth()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func render() {

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.top.equalToSuperview().offset(77)
        }

        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }

        view.addSubview(searchBarView)
        searchBarView.snp.makeConstraints { make in
            make.height.equalTo(65)
            make.top.equalTo(imageView.snp.bottom).offset(37)
            make.leading.trailing.equalToSuperview().inset(23)
        }

        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(shortcutButton1)
        shortcutButton1.snp.makeConstraints { make in
            make.height.equalTo(42)
        }
        verticalStackView.addArrangedSubview(shortcutButton2)
        shortcutButton2.snp.makeConstraints { make in
            make.height.equalTo(42)
        }
        verticalStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(searchBarView.snp.bottom).offset(20)
        }
    }

    override func configUI() {
        view.backgroundColor = .systemBackground
    }

    // MARK: - Bind
    func bind() {
        viewModel.$musics
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] musics in
                self?.stopLottieAnimation()
                let searchResultViewController = SearchResultViewController(with: musics, searchText: (self?.searchBarView.searchField.text ?? "")+" 노래")
                searchResultViewController.modalPresentationStyle = .fullScreen
            self?.present(searchResultViewController, animated: true)

            guard let listId = self?.viewModel.createPlayList() else { return }
            self?.viewModel.saveMusicToPlayList(listId: listId, musics: musics)
        }
        .store(in: &viewModel.subscription)

        NotificationCenter.default.publisher(for: Notification.Name("cancelButtonTapped"))
            .sink { [weak self] _ in
                URLSession.shared.invalidateAndCancel() // 이코드 여기 있는거 좀 어색
                self?.stopLottieAnimation()
            }
            .store(in: &viewModel.subscription)

        viewModel.$searchState
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.showMoreWaitLabel()
            }
            .store(in: &viewModel.subscription)
    }

    // MARK: - Func

    private func addTargets() {
        searchBarView.searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    private func setDelegation() {
        searchBarView.searchField.delegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @objc func searchButtonTapped() {
        searchBarView.searchField.resignFirstResponder()
        guard let searchText = searchBarView.searchField.text else { return }
        setupLottieView(with: searchText)
        viewModel.searchChatGPT(searchText: searchText)
    }



    
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let searchText = textField.text else { return true }
        setupLottieView(with: searchText)
        viewModel.searchChatGPT(searchText: searchText)
        return true
    }
}
