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

    private lazy var searchBarView: SearchBarView = {
        let view = SearchBarView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        view.isUserInteractionEnabled = true
        return view
    }()

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
        navigationItem.title = "검색"
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
    }

    // MARK: - Func

    private func setDelegation() {
        searchBarView.searchField.delegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        var searchViewController = SearchViewController()
        searchViewController.bindViewModel(SearchViewModel(
            SearchService( SearchRepository( APIService()))))
        navigationController?.pushViewController(searchViewController, animated: true)
      }

    @objc func searchButtonClicked() {
        guard let searchText = searchBarView.searchField.text else { return }
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
        return true
    }

}
