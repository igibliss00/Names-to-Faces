//
//  ViewController.swift
//  Project10
//
//  Created by jc on 2020-06-25.
//  Copyright © 2020 J. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var people = [Person]()
    var isAuthenticated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addFromCamera))
        navigationItem.leftBarButtonItems = [addButton, cameraButton]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(logout))
        
        if isAuthenticated {
            loadPeople()
        } else {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Identify yourself"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self](success, authError) in
                    DispatchQueue.main.async {
                        if success {
                            self?.isAuthenticated = true
                            self?.loadPeople()
                        } else {
                            let authFailedController = UIAlertController(title: "Authentication failed", message: nil, preferredStyle: .alert)
                            authFailedController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            self?.present(authFailedController, animated: true)
                        }
                    }
                }
            } else {
                let ac = UIAlertController(title: "No biometry available", message: nil, preferredStyle: .alert)
                ac.addAction((UIAlertAction(title: "OK", style: .cancel, handler: nil)))
                present(ac, animated: true)
            }
        }
        
        
//        if let savedPeople = defaults.object(forKey: "people") as? Data {
//            let jsonDecoder = JSONDecoder()
//
//            do {
//                people = try jsonDecoder.decode([people].self, from: savedPeople)
//            } catch {
//                print("Failed to load people")
//            }
//        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Invalid PersonCell")
        }
        
        let person = people[indexPath.item]
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        let ac = UIAlertController(title: "Edit", message: "Would you like to rename or delete the entry?", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self, weak ac](_) in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            self?.collectionView.reloadData()
            self?.save()
        }))
        
        ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self](_) in
            if let index = self?.people.firstIndex(of: person) {
                self?.people.remove(at: index)
            }
            self?.collectionView.reloadData()
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func addFromCamera() {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            present(picker, animated: true)
        } else {
            let ac = UIAlertController(title: "Camera Not Available", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: nil))
            present(ac, animated: true)
        }
    }
    
    @objc func logout() {
        isAuthenticated = false
        collectionView.reloadData()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        save()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        }
      
//        let jsonEncoder = JSONEncoder()
//        if let savedData = try? jsonEncoder.encode(people) {
//            let defaults = UserDefaults.standard
//            defaults.set(savedData, forKey: "people")
//        } else {
//            print("Failed to save people")
//        }
    }
    
    func loadPeople() {
        let defaults = UserDefaults.standard
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
                people = decodedPeople
                collectionView.reloadData()
            }
        }
    }
}
