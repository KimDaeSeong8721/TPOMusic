//
//  HistoryCollectionViewCell.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/12.
//

import UIKit

final class HistoryCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldTitle3
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private let imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
        contentView.backgroundColor = .red
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    private func render() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(25)
        }
    }

    func configure(with playList: PlayList) {
        titleLabel.text = playList.name

        print("\(playList.imageURL) 입니다")
        print("\(playList.musicList) 입니다")

        let url = URL(string: playList.imageURL)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
    }
}
