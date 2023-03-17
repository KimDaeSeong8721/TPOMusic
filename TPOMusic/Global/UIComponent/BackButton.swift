//
//  BackButton.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/10.
//

import UIKit

final class BackButton: UIButton {

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 44, height: 44)))
        configUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Func
    private func configUI() {
        self.setImage(ImageLiteral.backButton, for: .normal)
        self.tintColor = .black
        self.contentMode = .scaleToFill
    }
}
