//
//  MasterViewController.swift
//  CSCI321_Assign6
//
//  Created by Rutvik Patel on 11/20/20.
//  Copyright © 2020 Rut Codes. All rights reserved.
//

// For EC:
//     Display books written by a specific author
//     Allow user to modify the book info

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
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
        
        // Insert data into the database from the plist file and load into table view
        insertDataIntoDatabaseFromFile()
    }
    
    func insertDataIntoDatabaseFromFile() {
        // checking if books.plist data is already in Core Data
        let fetch = NSFetchRequest<Book>(entityName: "Book")
        let count = try! managedObjectContext!.count(for: fetch)
        
        if count > 0 {
            return // books.plist data is already in the Core Data
        }
        
        guard let url = Bundle.main.url(forResource: "books", withExtension: ".plist"), let data: Data = try? Data(contentsOf: url) else {
            print("Unable to read property list")
            return
        }
        
        do {
            let decoder = PropertyListDecoder()
            let array = try decoder.decode([BookData].self, from: data)
            
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
    
    @IBAction func unwindToCancel(_ segue: UIStoryboardSegue){
        
    }
    
    @IBAction func unwindToSave(_ segue: UIStoryboardSegue){
        if let addABookViewController = segue.source as? AddABookViewController {
            if let addBook = addABookViewController.bookData {
                
                let context = self.fetchedResultsController.managedObjectContext
                let newBook = Book(context: context)
                
                newBook.title = addBook.title
                newBook.author = addBook.author
                newBook.releaseYear = addBook.releaseYear
                newBook.rating = addBook.rating
                newBook.isbn = addBook.isbn
                
                if let coverImageData = addABookViewController.coverImageData {
                    newBook.coverImage = NSData(data: coverImageData) as Data
                } else {
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
                
                self.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BookCell
        
        let book = fetchedResultsController.object(at: indexPath)
        
        // setting background color of each cell
        let colorView = UIView()
        colorView.backgroundColor = UIColor(red: CGFloat(25.0/255.0), green: CGFloat(25.0/255.0), blue: CGFloat(39.0/255.0), alpha: CGFloat(1.0))
        cell.backgroundView = colorView
        // setting ___ under each cell
        

        cell.coverImageView.image = UIImage(data: book.coverImage!)
        cell.titleLabel!.text = book.title
        cell.authorLabel!.text = "- " + book.author!

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Book)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Book)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                return
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withEvent book: Book) {
//        cell.coverImageView.image = UIImage(data: book.coverImage!)
//        cell.titleLabel!.text = book.title
//        cell.authorLabel!.text = "- " + book.author!
        
//        cell.textLabel!.text = book.title
//        cell.detailTextLabel!.text = "- " + book.author!
//        cell.imageView!.image = UIImage(data: book.coverImage!)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

