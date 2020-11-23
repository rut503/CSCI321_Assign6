//
//  Book+CoreDataProperties.swift
//  CSCI321_Assign6
//
//  Created by Rutvik Patel on 11/21/20.
//  Copyright © 2020 Rut Codes. All rights reserved.
//
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
