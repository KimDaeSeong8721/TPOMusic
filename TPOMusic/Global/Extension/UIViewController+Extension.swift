//
//  UIViewController+Extension.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/10.
//

import UIKit

extension UIViewController {
    var screenWidth: Double {
        return UIScreen.main.bounds.size.width
    }

    var screenHeight: Double {
        return UIScreen.main.bounds.size.height
    }

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
