//
//  ViewModelBindableType.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/12.
//

import UIKit

protocol ViewModelBindableType {
    associatedtype ViewModelType

    var viewModel: ViewModelType! { get set }
    func bind()
}

extension ViewModelBindableType where Self: UIViewController {
    // mutating을 사용 - ViewModelBindableType을 채택하는 것이 struct일 수도 있어서
     mutating func bindViewModel(_ viewModel: Self.ViewModelType) {
        self.viewModel = viewModel

        loadViewIfNeeded() // ViewController의 view가 아직 로드되지 않은 경우 로드함.
        bind()
    }
}
