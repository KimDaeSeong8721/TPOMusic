//
//  CustomDiffableDataSource.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/04/17.
//

import UIKit


final class CustomTableDiffableDataSource: UITableViewDiffableDataSource<SearchResultSection, Music> {

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let snapshot = self.snapshot()
        var musics = snapshot.itemIdentifiers
        musics.remove(at: indexPath.row)
        updateDataSource(items: musics, animated: true)


    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let snapshot = self.snapshot()
        var musics = snapshot.itemIdentifiers
        let targetItem = musics[sourceIndexPath.row]
        musics.remove(at: sourceIndexPath.row)
        musics.insert(targetItem, at: destinationIndexPath.row)
        updateDataSource(items: musics, animated: false)

    }
    

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    private func updateDataSource(items: [Music], animated: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<SearchResultSection, Music>()
        snapshot.appendSections([.resultList])
        snapshot.appendItems(items)
        self.apply(snapshot, animatingDifferences: animated, completion: nil)
    }
}
