//
//  SheetViewController.swift
//  Quiet
//
//  Created by SHIN YOON AH on 2022/08/25.
//

import UIKit

class SheetViewController<Content: UIViewController, BottomSheet: UIViewController>: BaseViewController, UIGestureRecognizerDelegate {
    
    struct BottomSheetConfiguration {
        let height: CGFloat
        let initialOffset: CGFloat
    }

    enum BottomSheetState {
        case initial, full
    }
    
    // MARK: - Properties
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.delegate = self
        pan.addTarget(self, action: #selector(handlePan))
        return pan
    }()

    private var topConstraint = NSLayoutConstraint()
    var state: BottomSheetState = .initial
    
    private let configuration: BottomSheetConfiguration
    let contentViewController: Content
    let bottomSheetViewController: BottomSheet

    // MARK: - Init
    
    init(contentViewController: Content,
         bottomSheetViewController: BottomSheet,
         bottomSheetConfiguration: BottomSheetConfiguration) {
        self.contentViewController = contentViewController
        self.bottomSheetViewController = bottomSheetViewController
        self.configuration = bottomSheetConfiguration
        
        super.init(nibName: nil, bundle: nil)
    }



    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    override func render() {
        self.addChild(contentViewController)
        self.view.addSubview(contentViewController.view)

        contentViewController.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentViewController.didMove(toParent: self)
        
        self.addChild(bottomSheetViewController)
        self.view.addSubview(bottomSheetViewController.view)

        bottomSheetViewController.view.snp.makeConstraints { make in
            make.height.equalTo(configuration.height)
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom).offset(-configuration.initialOffset)
        }

        bottomSheetViewController.didMove(toParent: self)
    }
    
    override func configUI() {
        super.configUI()
        bottomSheetViewController.view.addGestureRecognizer(panGesture)
        configureBackButton(title: "검색")
    }
    
    // MARK: - Func
    private func showBottomSheet(animated: Bool = true) {
        changeTopConstraint(to: -configuration.height)
        let bottomSheetVC = bottomSheetViewController as? HistoryViewController
        bottomSheetVC?.barTopConstraint.constant = 60
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.state = .full
            })
        } else {
            self.view.layoutIfNeeded()
            self.state = .full
        }
    }
    
    private func hideBottomSheet(animated: Bool = true) {
        changeTopConstraint(to: -configuration.initialOffset)
        let bottomSheetVC = bottomSheetViewController as? HistoryViewController
        bottomSheetVC?.barTopConstraint.constant = 20
        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseOut],
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: { _ in
                self.state = .initial
            })
        } else {
            self.view.layoutIfNeeded()
            self.state = .initial
        }
    }
    
    private func changeTopConstraint(to constant: CGFloat) {
        self.bottomSheetViewController.view.snp.remakeConstraints { make in
            make.height.equalTo(configuration.height)
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom).offset(constant)

        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    private func configureBackButton(title: String) {
        let backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .label
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    // MARK: - Selector
    @objc
    private func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let vc = bottomSheetViewController as? HistoryViewController else { return }
        let translation = sender.translation(in: bottomSheetViewController.view)
        let velocity = sender.velocity(in: bottomSheetViewController.view)
        let yTranslationMagnitude = translation.y.magnitude
        switch ([sender.state], self.state) {
        case ([.changed], .full):
            guard translation.y > 0, vc.playListCollectionView.indexPathsForVisibleItems.contains(where: { $0.item == .zero
            }) else {
                vc.playListCollectionView.isUserInteractionEnabled = true
                return } //
            print(translation.y)
            let topConstraint = -(configuration.height - yTranslationMagnitude)
            changeTopConstraint(to: topConstraint)
            
        case ([.changed], .initial):
            let newConstant = -(configuration.initialOffset + yTranslationMagnitude)
            vc.playListCollectionView.isUserInteractionEnabled = false
            guard translation.y < 0 else { return }
            guard newConstant.magnitude < configuration.height else {
                self.showBottomSheet()
                return
            }
            changeTopConstraint(to: newConstant)
            
        case ([.ended], .full):
            let shouldHideSheet = yTranslationMagnitude >= configuration.height / 2 || (velocity.y > 1000
                                                                                        && vc.playListCollectionView.indexPathsForVisibleItems.first?.item == .zero
            )
            shouldHideSheet ? hideBottomSheet() : showBottomSheet()
            vc.playListCollectionView.isUserInteractionEnabled = true // 수정필요
        case ([.ended], .initial):
            let shouldShowSheet = yTranslationMagnitude >= configuration.height / 2 || (velocity.y < -1000
//                                                                                        && vc.playListCollectionView.indexPathsForVisibleItems.first?.item == .zero
            )
            shouldShowSheet ? showBottomSheet() : hideBottomSheet()
            vc.playListCollectionView.isUserInteractionEnabled = false
        case ([.failed], .full):
            showBottomSheet()
            
        case ([.failed], .initial):
            hideBottomSheet()
            
        default:
            break
        }
    }
}
