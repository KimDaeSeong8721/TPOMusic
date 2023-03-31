//
//  SearchBarView.swift
//  Quiet
//
//  Created by DaeSeong on 2022/08/25.
//

import UIKit


class SearchBarView: UIView {

    // MARK: - Properties
    let searchButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.setTitle("노래 알려줘", for: .normal)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = .regularCallout
        return button
    }()
    
    let searchField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "공부하면서 잠올 때 듣기 좋은"
        return textField
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        render()
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Func
    private func render() {
        self.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(36)
            make.trailing.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }

        self.addSubview(searchField)
        searchField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(23)
            make.trailing.equalTo(searchButton.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    private func configUI() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.backgroundColor = .white
    }

}


