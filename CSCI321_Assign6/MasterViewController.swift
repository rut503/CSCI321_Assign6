//
//  MasterViewController.swift
//  CSCI321_Assign6
//
//  Created by Rutvik Patel (Z1865128).
//  Created by Aviraj Parmar (Z1861160).
//

// For EC:
//     Display books written by a specific author
//     Allow user to modify the book info

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // referance to the detail view controller
    var detailViewController: DetailViewController? = nil
    // referance to the core data database
    var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adding edit button on the left side of the navbar
        navigationItem.leftBarButtonItem = editButtonItem
        // split view boiler plate code
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // Inserting data into the database from the plist file and load into table view
        insertDataIntoDatabaseFromFile()
    }
    
    /*
     This function will first check if the data from plist file needs to be added into
     the database for initial run of the app. Then it will add the data from the plist
     file into the database.
     */
    func insertDataIntoDatabaseFromFile() {
        // checking if books.plist data is already in Core Data
        let fetch = NSFetchRequest<Book>(entityName: "Book")
        let count = try! managedObjectContext!.count(for: fetch)
        if count > 0 {
            return // books.plist data is already in the Core Data
        }
        
        // if data needs to be loaded into the database then get the url to the plist file
        //  and data from that url
        guard let url = Bundle.main.url(forResource: "books", withExtension: ".plist"), let data: Data = try? Data(contentsOf: url) else {
            print("Unable to read property list")
            return
        }
        
        // if we have data from the plist file, add all that data to the database
        do {
            let decoder = PropertyListDecoder()  // decoding plist file
            // tranfering data into an array
            let array = try decoder.decode([BookData].self, from: data)
            
            // for each item in the array full of book data add it to the core data database
            for b in array {
                let entity = NSEntityDescription.entity(forEntityName: "Book", in: managedObjectContext!)!
                let newBook = Book(entity: entity, insertInto: managedObjectContext)
                
                newBook.title = b.title
                newBook.author = b.author
                newBook.releaseYear = b.releaseYear
                newBook.rating = b.rating
                newBook.isbn = b.isbn
                
                let image = UIImage(named: b.coverImageName)
                let coverImageData = image!.jpegData(compressionQuality: 1.0)!
                newBook.coverImage = NSData(data: coverImageData) as Data
                
                // Save the context.
                try managedObjectContext!.save()
            }
        } catch {
            print("Unable to save book data to database: \(error.localizedDescription)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }
    
    /*
     This funtion handles the situation where user cancels the action of adding a new
     book to the database.
     */
    @IBAction func unwindToCancel(_ segue: UIStoryboardSegue){
        
    }
    
    /*
     This function handles the situation where user saves the new book to the database.
     It will get the book data from the AddABookViewController and then add that data
     into the database including binary data of a book cover image.
     */
    @IBAction func unwindToSave(_ segue: UIStoryboardSegue){
        if let addABookViewController = segue.source as? AddABookViewController {
            if let addBook = addABookViewController.bookData {
                // creating book context pointer
                let context = self.fetchedResultsController.managedObjectContext
                let newBook = Book(context: context)
                
                // adding basic book info from AddABookViewController to the newBook
                newBook.title = addBook.title
                newBook.author = addBook.author
                newBook.releaseYear = addBook.releaseYear
                newBook.rating = addBook.rating
                newBook.isbn = addBook.isbn
                
                // if an image data was passed to the AddABookViewController then add that
                //  data to the coverImage attribute in the Book entity database.
                if let coverImageData = addABookViewController.coverImageData {
                    newBook.coverImage = NSData(data: coverImageData) as Data
                }
                // if image data was NOT passed to the AddABookViewController then add a
                //  default book cover image which is the logo of the app to the coverImage
                //  attribute in the Book entity database.
                else {
                    let image = UIImage(named: "DefaultBookCover")
                    let coverImageData = image!.jpegData(compressionQuality: 1.0)!
                    newBook.coverImage = NSData(data: coverImageData) as Data
                }
                
                // Save the context.
                do {
                    try context.save()
                } catch let error as NSError {
                    print("Unable to save new book: \(error), \(error.userInfo)")
                }
                
                self.tableView.reloadData() // reload table view (displayed book list)
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // referance to a cutome made cell BookCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BookCell
        
        // get book data from database at given index
        let book = fetchedResultsController.object(at: indexPath)
        
        // setting background color of each cell to dark purple color for dark mode theme
        let colorView = UIView()
        colorView.backgroundColor = UIColor(red: CGFloat(25.0/255.0), green: CGFloat(25.0/255.0), blue: CGFloat(39.0/255.0), alpha: CGFloat(1.0))
        cell.backgroundView = colorView

        // setting cell fields to book data from database for each cell
        cell.coverImageView.image = UIImage(data: book.coverImage!) // book cover image
        cell.titleLabel!.text = book.title                          // title of the book
        cell.authorLabel!.text = "- " + book.author!                // author of the book

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true   // allow user to delete a book from the database
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch let error as NSError{
                print("Unable to delete a row from a table: \(error), \(error.userInfo)")
            }
        }
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Book> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error as NSError {
             print("Unresolved error \(error), \(error.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Book>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            default:
                return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

