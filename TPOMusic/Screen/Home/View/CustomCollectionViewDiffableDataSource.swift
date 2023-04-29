//
//  CustomCollectionViewDiffableDataSource.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/04/18.
//

import UIKit

class CustomCollectionViewDiffableDataSource: UICollectionViewDiffableDataSource<ContentSection, PlayList> {

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let snapshot = self.snapshot()
        let sections = snapshot.sectionIdentifiers
        let section = sections[indexPath.section]
        if kind == UICollectionView.elementKindSectionHeader {
                let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SectionHeader
            sectionHeader.label.text = section.historyDate
                return sectionHeader
           } else {
                return UICollectionReusableView()
           }

    }
}

class SectionHeader: UICollectionReusableView {
    let label: UILabel = {
         let label: UILabel = UILabel()
         label.textColor = .black
         label.font = .semiBoldSubheadline
         label.sizeToFit()
         return label
     }()

    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()


     override init(frame: CGRect) {
         super.init(frame: frame)

         addSubview(label)

         label.snp.makeConstraints { make in
             make.edges.equalToSuperview()

         }

         addSubview(bottomLine)
         bottomLine.snp.makeConstraints { make in
             make.leading.trailing.equalToSuperview()
             make.bottom.equalToSuperview().inset(3)
             make.height.equalTo(1)
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
