//
//  Book+CoreDataProperties.swift
//  ReadMe
//
//  Created by  Максим Мартынов on 30.04.2022.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }
    
    @NSManaged public var title: String
    @NSManaged public var author: String
    @NSManaged public var imageData: Data?
    @NSManaged public var readMe: Bool
    @NSManaged public var review: String?

}

