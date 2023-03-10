//
//  ImageLiteral.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/09.
//

import UIKit


enum ImageLiteral {
    static var signIn: UIImage { .load(named: "SignIn") }
    static var icMagnifyingglass: UIImage { .load(systemName: "magnifyingglass") }

}


extension UIImage {

    static func load(named imageName: String) -> UIImage {
        guard let image = UIImage(named: imageName) else {
            return UIImage()
        }
        image.accessibilityIdentifier = imageName
        return image
    }

    static func load(systemName: String) -> UIImage {
        guard let image = UIImage(systemName: systemName) else {
            return UIImage()
        }
        image.accessibilityIdentifier = systemName
        return image
    }
}
