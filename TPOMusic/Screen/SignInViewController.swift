//
//  SignInViewController.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/09.
//

import AuthenticationServices
import UIKit

import SnapKit

class SignInViewController: BaseViewController {

    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "나만의 플레이리스트를 찾아보세요"
        label.textColor = .white
        label.font = UIFont.boldTitle3
        return label
    }()

    private let signInButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        button.cornerRadius = 30
        return button
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
    }

    override func render() {

        view.addSubview(signInButton)
        signInButton.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(signInButton.snp.top).inset(-35)
        }
    }

    override func configUI() {
        self.view.backgroundColor = UIColor(patternImage: ImageLiteral.signIn)
    }

    // MARK: - Func
    private func addTargets() {
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
    }
    @objc func signInTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])

        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

}

extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("failed")
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            let email = credentials.email

            if let fullName = credentials.fullName {
                UserDefaults.standard.set("\(fullName.givenName ?? "") \(fullName.familyName ?? "")", forKey: "Name")
                UserDefaults.standard.set(email, forKey: "Email")
            }

            let sceneDelegate = UIApplication.shared.connectedScenes
                .first!.delegate as! SceneDelegate
            var historyViewController = HistoryViewController()
            historyViewController.bindViewModel(HistoryViewModel(searchService: SearchService(SearchRepository(APIService()))))
            sceneDelegate.window!.rootViewController = UINavigationController(rootViewController: SheetViewController(contentViewController: HomeViewController(), bottomSheetViewController: historyViewController, bottomSheetConfiguration: .init(height: UIScreen.main.bounds.height, initialOffset: 150)))
        default:
            break
        }
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }


}
