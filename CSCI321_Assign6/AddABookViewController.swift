//
//  AddABookViewController.swift
//  CSCI321_Assign6
//
//  Created by Rutvik Patel  (Z1865128).
//  Created by Aviraj Parmar (Z1861160).
//

import UIKit

class AddABookViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var bookData: BookData?    // holds info about new book that needs to be added to the DB
    var coverImageData: Data?  // holds data of an image that user picks as book cover image
    
    // diplays the book cover image that user chose
    @IBOutlet weak var pickedImageView: UIImageView!
    
    // image picker for book cover image
    var imagePicker = UIImagePickerController()

    // input fields for book data
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var releaseYearTextField: UITextField!
    @IBOutlet weak var ratingTextField: UITextField!
    @IBOutlet weak var isbnTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self

        // this code customizes the color of the table view backgroud to dark purple to give
        //  overall custome dark mode
        self.tableView.backgroundColor = UIColor(red: CGFloat(33.0/255.0), green: CGFloat(33.0/255.0), blue: CGFloat(46.0/255.0), alpha: CGFloat(1.0))
    }
    
    /*
     This function runs when user wants to pick an image. This function shows a image picker from
     user's existing pictures in thier photo library.
     */
    @IBAction func pickBookCoverButtonClicked(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    /*
     This code
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var newImage: UIImage

        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        // showing user picked image
        pickedImageView.image = newImage

        // passing image data back to the master detail view
        let imageData = newImage.jpegData(compressionQuality: 1.0)!
        coverImageData = NSData(data: imageData) as Data

        dismiss(animated: true)
    }
    
    /*
     Boiler plate code to handle closing the keyboard after user clicks return.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /*
     This function will show a cutome alert to user when a field is left empty.
     */
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Navigation
    
    /*
     This function will check all the fields when a user clicks the save button for empty
     fields. If a field is empty, an alert will be shown with a warning and the segue will be
     canceled, not allowing user to save with empty data fields.
     */
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
        // if all fields are filled, allow user to save data and go back to master detail view
        return true
    }

    /*
     This function will run when a user clicks save button to save data and return to
     master detail view. All the data about the book will be saved into this view
     controller's property called bookData which is an instance of BookData class.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "Save") {
            // check if all data is compatiable with data expected by Book entity in DB.
            if let title = titleTextField.text,
                let author = authorTextField.text,
                let releaseYear = Int16(releaseYearTextField.text!),
                let rating = Double(ratingTextField.text!),
                let isbn = Int64(isbnTextField.text!)
            {
                // add all that data into the bookData instance
                bookData = BookData(title: title, author: author, rating: rating, isbn: isbn, releaseYear: releaseYear, coverImageName: "")
            }
        }
    }
    
    // MARK: - Customizing Table View to fit Dark Mode
    
    /*
     This function is used to customize the color of the table view section headers.
     */
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        // For Header Text Color, making it Orangish Red.
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(61.0/255.0), blue: CGFloat(0), alpha: CGFloat(1.0))
    }

}
