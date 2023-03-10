//
//  UIFont+Extension.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/09.
//

import UIKit

extension UIFont {
    /// regularCaption1 - 12px
    static let regularCaption1 = UIFont.font(.caption1, weight: .regular)
    /// regularCaption2 - 11px
    static let regularCaption2 = UIFont.font(.caption2, weight: .regular)
    /// regularFootnote - 13px
    static let regularFootnote = UIFont.font(.footnote, weight: .regular)
    /// regularSubheadline - 15px
    static let regularSubheadline = UIFont.font(.subheadline, weight: .regular)
    /// regularCallout - 16px
    static let regularCallout = UIFont.font(.callout, weight: .regular)
    /// regularBody - 17px
    static let regularBody = UIFont.font(.body, weight: .regular)
    /// regularTitle1 - 28px
    static let regularTitle1 = UIFont.font(.title1, weight: .regular)
    /// regularTitle2 - 22px
    static let regularTitle2 = UIFont.font(.title2, weight: .regular)
    /// regularTitle3 - 20px
    static let regularTitle3 = UIFont.font(.title3, weight: .regular)


    /// semiBoldCallout - 16px
    static let semiBoldCallout = UIFont.font(.callout, weight: .semibold)
    /// semiBoldHeadline - 17px
    static let semiBoldHeadline = UIFont.font(.headline, weight: .semibold)
    /// semiBoldTitle3 - 20px
    static let semiBoldTitle3 = UIFont.font(.title3, weight: .semibold)

    /// boldCaption1 - 12px
    static let boldCaption1 = UIFont.font(.caption1, weight: .bold)
    /// boldFootnote - 13px
    static let boldFootnote = UIFont.font(.footnote, weight: .bold)
    /// boldSubheadline - 15px
    static let boldSubheadline = UIFont.font(.subheadline, weight: .bold)
    /// boldCallout - 16px
    static let boldCallout = UIFont.font(.callout, weight: .bold)
    /// boldBody - 17px
    static let boldBody = UIFont.font(.body, weight: .bold)
    /// boldTitle1 - 28px
    static let boldTitle1 = UIFont.font(.title1, weight: .bold)
    /// boldTitle2 - 22px
    static let boldTitle2 = UIFont.font(.title2, weight: .bold)
    /// boldTitle3 - 20px
    static let boldTitle3 = UIFont.font(.title3, weight: .bold)
    /// boldLargeTitle - 34px
    static let boldLargeTitle = UIFont.font(.largeTitle, weight: .bold)

}

extension UIFont {
    static func font(_ textStyle: TextStyle, weight: Weight) -> UIFont {
        return UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: textStyle).pointSize, weight: weight)
    }
}
