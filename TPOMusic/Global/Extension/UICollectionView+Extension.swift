//
//  UICollectionView+Extension.swift
//  WithBot
//
//  Created by DaeSeong on 2023/01/10.
//

import Foundation

import UIKit

extension UICollectionView {
    private var indexPathForLastItem: IndexPath? {
      guard numberOfSections > 0 else { return nil }

      for offset in 1 ... numberOfSections {
        let section = numberOfSections - offset
        let lastItem = numberOfItems(inSection: section) - 1
        if lastItem >= 0 {
          return IndexPath(item: lastItem, section: section)
        }
      }
      return nil
    }
    func scrollToBottom(animated: Bool = true) {
        guard let indexPath = indexPathForLastItem else { return }
        scrollToItem(at: indexPath, at: .bottom, animated: animated)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(withType cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.className, for: indexPath) as? T else {
            fatalError("Could not find cell with reuseID \(T.className)")
        }
        return cell
    }

    func register<T>(cell: T.Type, forCellReuseIdentifier reuseIdentifier: String = T.className) where T: UICollectionViewCell {
        register(cell, forCellWithReuseIdentifier: reuseIdentifier)
    }
}
