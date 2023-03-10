//
//  BaseViewController.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/09.
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        configUI()
    }

    func render() {
        // auto layout 관련 코드
    }

    func configUI() {
        // UI 관련 코드
        view.backgroundColor = .systemBackground
    }
}
