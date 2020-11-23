//
//  DetailViewController.swift
//  CSCI321_Assign6
//
//  Created by Rutvik Patel (Z1865128).
//  Created by Aviraj Parmar (Z1861160).
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!

    /*
     This function takes data that was passed in through the master detail view controller and
     maps all that data in a simple view board.
     */
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let title = titleLabel {
                title.text = detail.title // set book title to title label
            }
            if let author = authorLabel {
                author.text = "- " + detail.author! // set author to author label
            }
            if let rating = ratingLabel {
                rating.text = "Rating: \(detail.rating)/5.0" // set rating to rating label
            }
            if let isbn = isbnLabel {
                isbn.text = "ISBN: \(detail.isbn)" // set isbn to isbn label
            }
            if let releaseYear = releaseYearLabel {
                // set release year to release year label
                releaseYear.text = "Release Year: \(detail.releaseYear)"
            }
            if let coverImage = coverImageView {
                // set cover image to cover image view 
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
