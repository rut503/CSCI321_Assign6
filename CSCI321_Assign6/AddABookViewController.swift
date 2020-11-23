//
//  AddABookViewController.swift
//  CSCI321_Assign6
//
//  Created by Rutvik Patel on 11/22/20.
//  Copyright © 2020 Rut Codes. All rights reserved.
//

import UIKit

class AddABookViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var bookData: BookData?
    var coverImageData: Data?
    
    var imagePicker = UIImagePickerController()

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var releaseYearTextField: UITextField!
    @IBOutlet weak var ratingTextField: UITextField!
    @IBOutlet weak var isbnTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        imagePicker.delegate = self
    }
    
    @IBAction func pickBookCoverButtonClicked(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var newImage: UIImage

        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }

        // passing image data back to the master detail view
        let imageData = newImage.jpegData(compressionQuality: 1.0)!
        coverImageData = NSData(data: imageData) as Data

        dismiss(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "Save") {
            guard let title = titleTextField.text, !title.isEmpty else {
                showAlert("Please enter a book title")
                return false
            }
            
            guard let author = authorTextField.text, !author.isEmpty else {
                showAlert("Please enter name of the author")
                return false
            }
            
            guard let releaseYear = releaseYearTextField.text, !releaseYear.isEmpty else {
                showAlert("Please enter the release year of the book")
                return false
            }
            
            guard let rating = ratingTextField.text, !rating.isEmpty else {
                showAlert("Please enter book rating")
                return false
            }
            
            guard let isbn = isbnTextField.text, !isbn.isEmpty else {
                showAlert("Please enter isbn of the book")
                return false
            }
        }
        
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "Save") {
            if let title = titleTextField.text,
                let author = authorTextField.text,
                let releaseYear = Int16(releaseYearTextField.text!),
                let rating = Double(ratingTextField.text!),
                let isbn = Int64(isbnTextField.text!)
            {
                bookData = BookData(title: title, author: author, rating: rating, isbn: isbn, releaseYear: releaseYear, coverImageName: "")
            }
        }
    }

}
