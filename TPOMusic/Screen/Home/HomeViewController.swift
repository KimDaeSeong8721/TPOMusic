//
//  HomeViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/09.
//

import UIKit

class HomeViewController: BaseViewController {

    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "나만의 플레이리스트를 찾아보세요"
        label.textColor = .black
        label.font = UIFont.boldTitle3
        return label
    }()

    private lazy var searchBarView: SearchBarView = {
        let view = SearchBarView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        view.isUserInteractionEnabled = true
        return view
    }()

    
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
        view.addSubview(searchBarView)
        searchBarView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(45)
        }

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(searchBarView.snp.top).inset(-35)
        }
    }

    override func configUI() {
        view.backgroundColor = .systemBackground
    }
    // MARK: - Func

    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        var searchViewController = SearchViewController()
        searchViewController.bindViewModel(SearchViewModel(
            SearchService( SearchRepository( APIService()))))
        navigationController?.pushViewController(searchViewController, animated: true)
      }
}
