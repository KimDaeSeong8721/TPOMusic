//
//  BackgroundView.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/28.
//

import UIKit

import Lottie

final class BackgroundView: UIView {
    // MARK: - Properties

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = .zero
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .regularSubheadline
        label.text = "상황에 \n딱! 맞는 음악을 찾고 있어요..."
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = ImageLiteral.character
        return imageView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("멈추기", for: .normal)
        button.setTitleColor(.black.withAlphaComponent(0.6), for: .normal)
        button.titleLabel?.font = .boldSubheadline
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    let moreWaitLabel: UILabel = {
        let label = UILabel()
        label.text = "거의 다 왔어요!!"
        label.font = .boldSubheadline
        label.isHidden = true
        return label
    }()

    private var lottieView: LottieAnimationView = {
        let view = LottieAnimationView(name: "dots")
        return view
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
        configUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Func
    private func render() {
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(235)
        }
        
        self.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subTitleLabel.snp.bottom).offset(24)
        }

        self.addSubview(lottieView)
        lottieView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom)
            make.size.equalTo(150)
        }
        
        self.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(203)
        }
        
        self.addSubview(moreWaitLabel)
        moreWaitLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cancelButton.snp.bottom).offset(20)
        }
        

    }

    private func configUI() {
        self.backgroundColor = .white
    }

    func setupLottieView(with title: String = "") {
        titleLabel.text = "\"\(title)\""
        lottieView.loopMode = .loop
        lottieView.play()
    }

    func stopLottieAnimation() {
        lottieView.stop()
        moreWaitLabel.isHidden = true
    }

    @objc func cancelButtonTapped() {
        NotificationCenter.default.post(name: NSNotification.Name("cancelButtonTapped"),
                                        object: nil)
    }
}
