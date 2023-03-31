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
        label.font = .semiBoldSubheadline
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()

    private let subLabel: UILabel = {
        let label = UILabel()
        label.font = .regularSubheadline
        label.textColor = .black.withAlphaComponent(0.5)
        label.text = "dsadasdsadsadsadasdasdas"
        label.numberOfLines = 2
        return label
    }()

    private let lPImageView: UIImageView = {
        let view = UIImageView()
        view.frame = .init(x: .zero,
                           y: .zero,
                           width: 80,
                           height: 80)
        view.image = ImageLiteral.lp
        view.clipsToBounds = true
        return view
    }()

    private let firstImageView: UIImageView = {
        let view = UIImageView()
        view.frame = .init(x: .zero,
                           y: .zero,
                           width: 40,
                           height: 40)
        return view
    }()

    private let secondImageView: UIImageView = {
        let view = UIImageView()
        view.frame = .init(x: .zero,
                           y: .zero,
                           width: 40,
                           height: 40)
        return view
    }()

    private let thirdImageView: UIImageView = {
        let view = UIImageView()
        view.frame = .init(x: .zero,
                           y: .zero,
                           width: 40,
                           height: 40)
        return view
    }()

    private let fourthImageView: UIImageView = {
        let view = UIImageView()
        view.frame = .init(x: .zero,
                           y: .zero,
                           width: 40,
                           height: 40)
        return view
    }()

    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = .zero
        stackView.distribution = .fillEqually
        stackView.layer.borderWidth = 1
        return stackView
    }()

    private let firstVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = .zero
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let secondVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = .zero
        stackView.distribution = .fillEqually
        return stackView
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: - Func
    private func render() {

        contentView.addSubview(lPImageView)
        lPImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().offset(40)
            make.top.bottom.equalToSuperview()
            make.size.equalTo(80)
        }

        horizontalStackView.addArrangedSubview(firstVerticalStackView)
        firstVerticalStackView.addArrangedSubview(firstImageView)
        firstVerticalStackView.addArrangedSubview(secondImageView)
        horizontalStackView.addArrangedSubview(secondVerticalStackView)
        secondVerticalStackView.addArrangedSubview(thirdImageView)
        secondVerticalStackView.addArrangedSubview(fourthImageView)

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(horizontalStackView.snp.trailing).offset(23)
            make.trailing.equalToSuperview().inset(23)
            make.top.equalToSuperview()
        }

        contentView.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.leading.equalTo(horizontalStackView.snp.trailing).offset(23)
            make.trailing.equalToSuperview().inset(23)
            make.bottom.equalToSuperview()
        }

    }

    func configure(with playList: PlayList) {
        titleLabel.text = playList.name
        var artists = ""
        playList.musicList.forEach { music in
            artists += music.artist + ", "
        }
        subLabel.text = artists
        print("\(playList.imageURL) 입니다")
        print("\(playList.musicList) 입니다")

        for (index, imageView) in [firstImageView,
                  secondImageView,
                  thirdImageView,
                  fourthImageView].enumerated() {
            if playList.musicList.count < 4,
                index == playList.musicList.count {
                break
            }
            let url = URL(string: playList.musicList[index].imageURL)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
        }

    }
}
