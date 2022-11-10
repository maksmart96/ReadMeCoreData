//
//  NewBookViewController.swift
//  ReadMe
//
//  Created by  Максим Мартынов on 13.04.2022.
//

import UIKit
import CoreData

class NewBookViewController: UITableViewController {
   // var book: Book
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var authorTextField: UITextField!
    @IBOutlet var addImageButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    
    var newBookImage: UIImage?
    var coreDataStack: CoreDataStack!
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBook() {
        guard let title = titleTextField.text,
              let author = authorTextField.text,
              !title.isEmpty,
              !author.isEmpty else { return }
        
        let newBook = Book(context: coreDataStack.managedContext)
//        let entityDesc = NSEntityDescription.entity(forEntityName: "Book", in: coreDataStack.managedContext)!
//        let newBook = Book(entity: entityDesc, insertInto: coreDataStack.managedContext)
//        newBook.setValue(title, forKeyPath: "title")
//        newBook.setValue(author, forKeyPath: "author")
//        newBook.setValue(true, forKeyPath: "readMe")
//        newBook.setValue(newBookImage?.pngData(), forKeyPath: "imageData")
        newBook.title = title
        newBook.author = author
        newBook.readMe = true
        newBook.imageData = newBookImage?.pngData()
        coreDataStack.saveContext()
        Library.addNew(book: newBook)
            navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNewImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera)
            ? .camera
            : .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    override func viewDidLoad() {
        imageView.layer.cornerRadius = 16
    }
}

extension NewBookViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        imageView.image = selectedImage
        newBookImage = selectedImage
        dismiss(animated: true)
    }
}

extension NewBookViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            return authorTextField.becomeFirstResponder()
        } else {
            return textField.resignFirstResponder()
        }
    }
}


