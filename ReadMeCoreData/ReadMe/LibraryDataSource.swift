//
//  LibraryDataSource.swift
//  ReadMe
//
//  Created by  Максим Мартынов on 04.07.2022.
//

import Foundation
import CoreData
import UIKit

class LibraryDS: UITableViewDiffableDataSource<Section, Book> {
    var currentSortStyle: SortStyle = .title
    var coreDataStack: CoreDataStack
    private let mockBook: Book
    
     init(coreDataStack: CoreDataStack, tableView: UITableView, cellProvider: @escaping CellProvider) {
         self.coreDataStack = coreDataStack
         self.mockBook = Book(context: coreDataStack.managedContext)
         super.init(tableView: tableView, cellProvider: cellProvider)
    }
    
        func updateDataSource(sortStyle: SortStyle, animatingDifferences: Bool = true) {
            currentSortStyle = sortStyle
            
            var newSnapshot = NSDiffableDataSourceSnapshot<Section, Book>()
            newSnapshot.appendSections(Section.allCases)
            
            let booksByReadMe: [Bool : [Book]] = Dictionary(grouping: Library.books, by: \.readMe)
            for (readMe, books) in booksByReadMe {
                var sortedBooks: [Book]
                switch sortStyle {
                case .title:
                    sortedBooks = books.sorted {
                        $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                    }
                case .author:
                    sortedBooks = books.sorted {
                        $0.author.localizedCaseInsensitiveCompare($1.author) == .orderedAscending
                    }
                case .readMe:
                    sortedBooks = books
                }
                newSnapshot.appendItems(sortedBooks, toSection: readMe ? .readMe : .finished)
            }
//            apply(newSnapshot,animatingDifferences: animatingDifferences)
            newSnapshot.appendItems([mockBook], toSection: .addNew)
            coreDataStack.managedContext.delete(mockBook)
            
            coreDataStack.saveContext()
            apply(newSnapshot, animatingDifferences: animatingDifferences)
        }
    
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            indexPath.section == snapshot().indexOfSection(.addNew) ? false : true
        }
    
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                guard let book = itemIdentifier(for: indexPath) else { return }
                coreDataStack.managedContext.delete(book)
                coreDataStack.saveContext()
                Library.delete(book: book)
                updateDataSource(sortStyle: currentSortStyle)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section != snapshot().indexOfSection(.readMe) || currentSortStyle != .readMe {
          return false
        } else {
          return true
        }    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard
            sourceIndexPath != destinationIndexPath,
            sourceIndexPath.section == destinationIndexPath.section,
            let bookToMove = itemIdentifier(for: sourceIndexPath),
            let bookAtDestination = itemIdentifier(for: destinationIndexPath)
            else {
                apply(snapshot(), animatingDifferences: false)
                return
            }
        Library.reorderBooks(bookToMove: bookToMove, bookAtDestination: bookAtDestination)
        coreDataStack.saveContext()
        updateDataSource(sortStyle: currentSortStyle, animatingDifferences: false)
    }
}
