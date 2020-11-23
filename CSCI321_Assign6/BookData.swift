//
//  BookData.swift
//  CSCI321_Assign6
//
//  Created by Rutvik Patel on 11/22/20.
//  Copyright © 2020 Rut Codes. All rights reserved.
//

import Foundation

struct BookData: Decodable {
    let title: String
    let author: String
    let rating: Double
    let isbn: Int64
    let releaseYear: Int16
    let coverImageName: String
    
    /*
     This enum is used to map out keys in the plist file to the property variables in this BookData class.
     */
    private enum CodingKeys: String, CodingKey {
        case title = "Book Title"
        case author = "Author Name"
        case rating = "Rating"
        case isbn = "ISBN"
        case releaseYear = "Release Year"
        case coverImageName = "Cover Image Name"
    }
    
    /*
     This is the initializer method that initializes all the BookData properties to passed in values.
     */
    init(title: String, author: String, rating: Double, isbn: Int64, releaseYear: Int16, coverImageName: String) {
        self.title = title
        self.author = author
        self.rating = rating
        self.isbn = isbn
        self.releaseYear = releaseYear
        self.coverImageName = coverImageName
    }
}
