//
//  Library.swift
//  ReadMe
//
//  Created by  Максим Мартынов on 10.04.2022.
//

import UIKit

enum LibrarySymbol {
    case bookmark
    case bookmarkFill
    case book
    case letterSquare(letter: Character?)
    
    var image: UIImage {
        let imageName: String
        switch self {
        case .bookmark, .book:
            imageName = "\(self)"
        case .bookmarkFill:
            imageName = "bookmark.fill"
        case .letterSquare(letter: let letter):
            guard let letter = letter?.lowercased(),
            let image = UIImage(systemName: "\(letter).square") else {
                imageName = "square"
                break
            }
           return image
        }
        return UIImage(systemName: imageName)!
    }
}

enum Library {

    static var books: [Book] = []

//    MARK: - Методы с книгами
    static func addNew(book: Book) {
        books.insert(book, at: 0)
}
    
    static func delete(book: Book) {
        guard let bookIndex = books.firstIndex(where: { storedBook in
            book == storedBook
        }) else { return }
        books.remove(at: bookIndex)
    }

    static func update(book: Book) {
        guard let bookIndex = books.firstIndex(where: { storedBook in
            book.title == storedBook.title
        }) else {
            print("No book to update")
            return
        }
        books[bookIndex] = book
    }

    static func reorderBooks(bookToMove: Book, bookAtDestination: Book) {
        let destinationIndex = books.firstIndex(of: bookAtDestination) ?? 0
        books.removeAll(where: { $0.title == bookToMove.title })
        books.insert(bookToMove, at: destinationIndex)
    }
}
