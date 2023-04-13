//
//  UIColor+Extension.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/09.
//

import UIKit

extension UIColor {
   static let accentColor = UIColor(named: "AccentColor")
    static let shortcutText: UIColor = UIColor(hex: "494949")
    static let subGray: UIColor = UIColor(hex: "949494")

    static let shortcutBackground: UIColor = UIColor(hex: "EFEFEF")
    static let appleMusicOrange: UIColor = UIColor(hex: "EB5936")


}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)
    }
}

extension UIColor {
     class func color(data:Data) -> UIColor? {
          return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
     }

     func encode() -> Data? {
          return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
     }
}
