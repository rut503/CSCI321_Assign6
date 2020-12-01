//
//  Book+CoreDataProperties.swift
//  CSCI321_Assign6
//
//  Created by Rutvik Patel  (Z1865128).
//  Created by Aviraj Parmar (Z1861160).
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var author: String?
    @NSManaged public var coverImage: Data?
    @NSManaged public var isbn: Int64
    @NSManaged public var rating: Double
    @NSManaged public var releaseYear: Int16
    @NSManaged public var title: String?

}
