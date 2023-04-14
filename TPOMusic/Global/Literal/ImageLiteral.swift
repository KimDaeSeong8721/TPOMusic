//
//  ImageLiteral.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/09.
//

import UIKit


enum ImageLiteral {
    static var signIn: UIImage { .load(named: "SignIn") }
    static var character: UIImage { .load(named: "Character") }
    static var lp: UIImage { .load(named: "AlbumLP") }
    static var apple: UIImage { .load(systemName: "applelogo") }
    static var xMarkButton: UIImage { .load(systemName: "xmark") }
    static var icMagnifyingglass: UIImage { .load(systemName: "magnifyingglass") }
    static var backButton: UIImage { .load(systemName: "chevron.backward") }
    static var bookMark: UIImage { .load(systemName: "bookmark") }
    static var bookMarkFill: UIImage { .load(systemName: "bookmark.fill") }
    static var profileButton: UIImage { .load(systemName: "person.crop.circle.fill")}
    static var editButton: UIImage { .load(systemName: "ellipsis.circle")}
    static var trash: UIImage { .load(systemName: "trash")}

    static var backward: UIImage { .load(systemName: "backward.fill")}
    static var forward: UIImage { .load(systemName: "forward.fill")}
    static var play: UIImage { .load(systemName: "play.fill")}
    static var pause: UIImage { .load(systemName: "pause.fill")}



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
