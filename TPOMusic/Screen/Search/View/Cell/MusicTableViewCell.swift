//
//  MusicTableViewCell.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/10.
//

import UIKit
import Kingfisher
import MusicKit

class MusicTableViewCell: UITableViewCell {

    // MARK: - Properties
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 4
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.regularSubheadline
        label.textColor = .black
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.regularSubheadline
        label.textColor = .black.withAlphaComponent(0.5)
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

    private lazy var appleMusicButton: UIButton = {
        let button = UIButton()
        button.setTitle("Music", for: .normal)
        button.setImage(ImageLiteral.apple.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .semiBoldSubheadline
        button.layer.cornerRadius = 11.5
        button.addTarget(self, action: #selector(appleMusicButtonTapped), for: .touchUpInside)
        return button
    }()

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
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(48)
        }

        contentView.addSubview(appleMusicButton)
        appleMusicButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(66)
            make.height.equalTo(23)

        }

        contentView.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(subtitleLabel)

        verticalStackView.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.trailing.equalTo(appleMusicButton.snp.leading).offset(-5)
            make.centerY.equalToSuperview()
        }


    }

    func configure(with music: Music) {
        self.music = music
        let url = URL(string: music.imageURL)

        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)

        titleLabel.text = music.title
        subtitleLabel.text = music.artist
    }

    @objc func appleMusicButtonTapped() {

        guard let musicURL = music?.url else { return }
        if UIApplication.shared.canOpenURL(musicURL) {
            UIApplication.shared.open(musicURL)
        } else {
            UIApplication.shared.open(URL(string: "music://music.apple.com")!)
        }
    }
}
