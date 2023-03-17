//
//  SearchBarView.swift
//  Quiet
//
//  Created by DaeSeong on 2022/08/25.
//

import UIKit


class SearchBarView: UIView {

    // MARK: - Properties
    private let searchImage: UIImageView = {
        let view = UIImageView(image: ImageLiteral.icMagnifyingglass)
        view.tintColor = .black
        return view
    }()
    
    private let searchField: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray2
        label.isUserInteractionEnabled = true
        return label
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
        self.addSubview(searchImage)
        searchImage.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    private func configUI() {
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor(red: 0,
                                         green: 0,
                                         blue: 0,
                                         alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 10
        
        self.backgroundColor = .white
    }

}


