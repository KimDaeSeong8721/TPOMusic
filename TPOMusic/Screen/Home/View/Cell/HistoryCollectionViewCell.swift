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
        label.font = .regularTitle3
        label.numberOfLines = 2
        return label
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
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(25)
        }
    }

    func configure(listTitle: String) {
        titleLabel.text = listTitle
    }
}
