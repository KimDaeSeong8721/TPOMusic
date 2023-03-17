//
//  MusicTableViewCell.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/10.
//

import UIKit
import Kingfisher

class MusicTableViewCell: UITableViewCell {

    // MARK: - Properties
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldTitle3
        label.textColor = .label
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.regularCaption1
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5
        return stackView
    }()

    lazy var bookMarkButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiteral.bookMark, for: .normal)
        button.setImage(ImageLiteral.bookMarkFill, for: .selected)
        button.addTarget(self, action: #selector(bookMarkClicked), for: .touchUpInside)
        return button
    }()

//    private(set)var indexRow: Int?

    private var music: Music?
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        render()
        contentView.isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Func
    private func render() {

        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(60)
        }

        contentView.addSubview(bookMarkButton)
        bookMarkButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(25)
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(subtitleLabel)

        verticalStackView.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(20)
            make.trailing.equalTo(bookMarkButton.snp.leading).offset(-5)
            make.centerY.equalToSuperview()
        }


    }

    func configure(with music: Music) {
//        self.indexRow = indexRow
        self.music = music
        let url = URL(string: music.imageURL)

        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)

        titleLabel.text = music.title
        subtitleLabel.text = music.artist
    }

    @objc func bookMarkClicked() {
        bookMarkButton.isSelected.toggle()
//        guard let indexRow = indexRow else { return }
        NotificationCenter.default.post(name: NSNotification.Name("bookMarkClicked"),
                                        object: music)
    }
}
