//
//  ViewController.swift
//  ReadMe
//
//  Created by  Максим Мартынов on 19.03.2022.

import UIKit
import CoreData
import Foundation

class LibraryHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "\(LibraryHeaderView.self)"
}

enum SortStyle {
    case title
    case author
    case readMe
}

enum Section: String, CaseIterable {
    case addNew
    case readMe = "Read Me!"
    case finished = "Finished"
}


class LibraryViewController: UITableViewController {
    //MARK: - Properties
    lazy var coreDataStack = CoreDataStack(modelName: "LibraryModel")
    private let bookCellIdentifier = "BookCell"
    private let newBookCellIdentifier = "NewBookCell"
    var fetchRequest: NSFetchRequest<Book>?
    var asyncFetchRequest: NSAsynchronousFetchRequest<Book>?
    var dataSource: LibraryDS!
    
    
    //MARK: - IBOUTLETS -
    @IBOutlet var sortButtons: [UIBarButtonItem]!
    
    //MARK: - IBActions -
    @IBAction func sortByTitle(_ sender: UIBarButtonItem) {
        dataSource.updateDataSource(sortStyle: .title)
        updateTintColor(tappedButton: sender)
    }
    
    @IBAction func sortByAuthor(_ sender: UIBarButtonItem) {
        dataSource.updateDataSource(sortStyle: .author)
        updateTintColor(tappedButton: sender)
    }
    
    @IBAction func sortByReadMe(_ sender: UIBarButtonItem) {
        dataSource.updateDataSource(sortStyle: .readMe)
        updateTintColor(tappedButton: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        tableView.register(UINib(nibName: "\(LibraryHeaderView.self)", bundle: nil), forHeaderFooterViewReuseIdentifier: LibraryHeaderView.reuseIdentifier)
        fetchRequest = Book.fetchRequest()
        asyncFetchBooks()
        configureDatasource()
    }
    
    func updateTintColor(tappedButton: UIBarButtonItem) {
        sortButtons.forEach { button in
//            if button == tappedButton {
//                button.tintColor = .systemBlue
//            } else {
//                button.tintColor = .secondaryLabel
//            }
            //тоже самое только кратко
            button.tintColor = button == tappedButton
            ? .systemBlue
            : .secondaryLabel
        }
    }
    
   
    
    func asyncFetchBooks() {
        guard let fetchRequest = fetchRequest else {
            fatalError("cannot fetch the request")
        }
        
        asyncFetchRequest = NSAsynchronousFetchRequest<Book>(fetchRequest: fetchRequest) { [unowned self] result in
            guard let books = result.finalResult else {
                print("no books in final result of asyncFetchRequest")
                return
            }
            Library.books = books
            self.dataSource.updateDataSource(sortStyle: .readMe)
        }
        
        do {
            guard let asyncFetchRequest = asyncFetchRequest else { return }
            try coreDataStack.managedContext.execute(asyncFetchRequest)
        } catch let error as NSError {
            print("Fetch error: \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.updateDataSource(sortStyle: dataSource.currentSortStyle, animatingDifferences: false)
        
    }
    
    
    
    //MARK: - Handle Segues -
    @IBSegueAction func showDetailView(_ coder: NSCoder) -> DetailViewController? {
        guard let indexPath = tableView.indexPathForSelectedRow,
              let book = dataSource.itemIdentifier(for: indexPath)
        else {
            fatalError("nothing is selected!!")
            }
       
        return DetailViewController(book: book, coder: coder, coreDataStack: self.coreDataStack)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewBook" {
            guard let newBookVC = segue.destination as? NewBookViewController else { fatalError("no newBookVC")}
            newBookVC.coreDataStack = self.coreDataStack
        }
    }
    
    //MARK: - tableViewDelegate
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LibraryHeaderView.reuseIdentifier) as? LibraryHeaderView
            else { return nil }
//        headerView.textLabel?.text = Section.allCases[section].rawValue
            return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section != 0 ? 60 : 0
    }
    
    //MARK: - DataSource
    func configureDatasource() {
        dataSource = LibraryDS(coreDataStack: coreDataStack, tableView: tableView) { [weak self] (tableView, indexPath, book) -> UITableViewCell? in
            guard let self = self else { fatalError("cannot unwrap self") }
            if indexPath == IndexPath(row: 0, section: 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: self.newBookCellIdentifier, for: indexPath)
                return cell
            }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: self.bookCellIdentifier, for: indexPath) as? BookCell else { fatalError("cannot deque cell") }
            cell.titleLabel.text = book.title
            cell.authorLabel.text = book.author
            if let booksImageData = book.imageData {
                cell.thumbnail.image = UIImage(data: booksImageData)
            } else {
                cell.thumbnail.image = LibrarySymbol.letterSquare(letter: book.title.first).image as UIImage
            }
            cell.thumbnail.layer.cornerRadius = 12
            if let review = book.review {
                cell.reviewLabel.text = review
                cell.reviewLabel.isHidden = false
            }
            cell.bookMark.isHidden = !book.readMe
            
            return cell
            }
        self.tableView.dataSource = dataSource
       }

//    func updateDataSource(sortStyle: SortStyle, animatingDifferences: Bool = true) {
//        currentSortStyle = sortStyle
//        var newSnapshot = NSDiffableDataSourceSnapshot<Section, Book>()
//        newSnapshot.appendSections(Section.allCases)
//
//        let booksByReadMe: [Bool : [Book]] = Dictionary(grouping: Library.books, by: \.readMe)
//        for (readMe, books) in booksByReadMe {
//            var sortedBooks: [Book]
//            switch sortStyle {
//            case .title:
//                sortedBooks = books.sorted { $0.title!.caseInsensitiveCompare($1.title!) == .orderedAscending
//                }
//            case .author:
//                sortedBooks = books.sorted(by: { $0.author!.caseInsensitiveCompare($1.author!) == .orderedAscending })
//            case .readMe:
//                sortedBooks = books
//            }
//            newSnapshot.appendItems(sortedBooks, toSection: readMe ? .readMe : .finished)
//        }
//        
//        if newSnapshot.itemIdentifiers(inSection: .addNew).isEmpty {
//            let mockBook = Book(context: coreDataStack.managedContext)
//            mockBook.title = nil
//            mockBook.author = nil
//            mockBook.imageData = nil
//            mockBook.readMe = true
//            mockBook.review = nil
//            coreDataStack.managedContext.delete(mockBook)
////          coreDataStack.saveContext()
//            newSnapshot.appendItems([mockBook], toSection: .addNew)
//        }
//        dataSource.apply(newSnapshot, animatingDifferences: animatingDifferences)
//    }
//    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        indexPath.section == dataSource.snapshot().indexOfSection(.addNew) ? false : true
//    }
//
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            guard let book = dataSource.itemIdentifier(for: indexPath) else { return }
//            coreDataStack.managedContext.delete(book)
//            coreDataStack.saveContext()
//            updateDataSource(sortStyle: currentSortStyle,animatingDifferences: false)
//            
//    }
//}
//
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.section != dataSource.snapshot().indexOfSection(.readMe)
//            || currentSortStyle == .readMe {
//            return false
//        } else {
//            return true
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//    guard
//        sourceIndexPath != destinationIndexPath,
//        sourceIndexPath.section == destinationIndexPath.section,
//        let bookToMove = dataSource.itemIdentifier(for: sourceIndexPath),
//        let bookAtDestination = dataSource.itemIdentifier(for: destinationIndexPath)
//        else {
//            dataSource.apply(dataSource.snapshot(), animatingDifferences: false)
//            return
//        }
//        Library.reorderBooks(bookToMove: bookToMove, bookAtDestination: bookAtDestination)
//        updateDataSource(sortStyle: currentSortStyle, animatingDifferences: false)
//    }
}


