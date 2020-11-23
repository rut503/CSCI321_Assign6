//
//  DetailViewController.swift
//  CSCI321_Assign6
//
//  Created by Rutvik Patel on 11/20/20.
//  Copyright © 2020 Rut Codes. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let title = titleLabel {
                title.text = detail.title
            }
            if let author = authorLabel {
                author.text = "- " + detail.author!
            }
            if let rating = ratingLabel {
                rating.text = "Rating: \(detail.rating)/5.0"
            }
            if let isbn = isbnLabel {
                isbn.text = "ISBN: \(detail.isbn)"
            }
            if let releaseYear = releaseYearLabel {
                releaseYear.text = "Release Year: \(detail.releaseYear)"
            }
            if let coverImage = coverImageView {
                coverImage.image = UIImage(data: detail.coverImage!)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: Book? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}
