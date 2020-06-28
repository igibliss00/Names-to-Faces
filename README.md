# Names to Faces

An app that demonstrates the use of the collection view, the adding, editing, and removing each cell with the usage of UIAlertController, as well as selecting an image and writing to disk using UIImagePicker.

<img src="https://github.com/igibliss00/Names-to-Faces/blob/master/README_assets/3.png" width="400">

## Installing

```
git clone https://www.github.com/igibliss00/Names-to-Faces.git
```

## Features

### Layout

The collection view cell layout's estimated size has three different modes: none, automatic, and custom. By default, the mode is set at automatic as of Xcode 11, which looks as follows:

<img src="https://github.com/igibliss00/Names-to-Faces/blob/master/README_assets/1.png" width="400">

What we want is to fill the entire screen out, which should be done with the no estimated sizing:

<img src="https://github.com/igibliss00/Names-to-Faces/blob/master/README_assets/2.png" width="400">

### UIAlertAction with UIImage Picker

Prompted the user with the UIAlertController to either rename or delete each cell.

<img src="https://github.com/igibliss00/Names-to-Faces/blob/master/README_assets/4.png" width="400">

When the camera option is not available as the source type:

<img src="https://github.com/igibliss00/Names-to-Faces/blob/master/README_assets/5.png" width="400">

### Image Picker

This project uses "imagePickerController(_, didFinishPickingMediaWithInfo: )" from "UIImagePickerControllerDelegate".  This method is used to achieve following goals:
- Extract the image from the dictionary-form parameter
- Generate a unique filename for the image
    - UUID
- Convert the image to a JPEG, then write it to disk
    - Use jpegData() from UIImage to convert the image to a Data object in a JPEG image format
    - Use the write(to: ) method from the Data object to write to disk
- Dismiss the view controller


### NSObject

The Apple’s documentation defines NSObject as:

> The root class of most Objective-C class hierarchies, from which subclasses inherit a basic interface to the runtime system and the ability to behave as Objective-C objects.

It’s the universal base class for all Cocoa Touch classes and where all UIKit classes come from.  

```
import UIKit

class Person: NSObject {
    var name: String
    var image: String
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
```

### From Image Picker to Writing to Disk

Used the image picker controller to select an image from the photo gallery or the camera, assigned a name and the image path, then wrote to disk using “jpegData” from the Data object. “jpegData” converts a UIImage into a format that could be used with “write(to: )”:

```

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
    
    dismiss(animated: true)
}
```

### Image View Layer

Learned to programmatically add image, border colours, width, and the corner radius to the image view as well as the cell layer. 

```
cell.imageView.image = UIImage(contentsOfFile: path.path)
cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
cell.imageView.layer.borderWidth = 2
cell.imageView.layer.cornerRadius = 3
cell.layer.cornerRadius = 7
```

### NSCoding

NSCoding is a protocol that enables an object to be encoded and decoded for archiving and distribution.  Encoding means to serialize the data on your app into an architecture-independent suitable for storage in a file or sending it over the network.  Inversely, decoding means deserializing the data received from the disk or the network into a format that you can use within your app.  Once an object is encoded, it’s able to be archived, which means for the object or other structures to be stored on disk.  It could also be distributed, which means the object is copied to different address spaces.  

In order for a class to conform to NSCoding, the class has to conform to NSObject first.  This is because NSCoding requires you to use objects or structs that are interchangeable with objects.  This means any class always has to conform to both NSObject and NSCoding in order to encode or decode a class using NSCoding.

Once you’ve got both NSObject as well as NSCoding, you now have to have some methods to fully conform to NSCoding. 

```
required init(coder aDecoder: NSCoder) {
    name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
    image = aDecoder.decodeObject(forKey: "image") as? String ?? ""
}

func encode(with aCoder: NSCoder) {
    aCoder.encode(name, forKey: "name")
    aCoder.encode(image, forKey: "image")
}
```

When encoding the “NSKeyedArchiver”, which is a subclass of NSCoder, calls the encode function of of the class you want to encode and  converts whatever the current form is into the Data object. This is, then, given to UserDefaults to be written to disk:

```
if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
    let defaults = UserDefaults.standard
    defaults.set(savedData, forKey: "people")
}
```

In a similar manner, but in a reverse order, the NSKeyedUnarchiver, which is also a subclass of NSCoder, invokes the “required init(coder aDecoder: NSCoder)” method in the class you want to decode.  We are downcasting String in the “required init(coder aDecoder: NSCoder)” method shown above because “decodeObject()” returns the Any type, but the “name” and “image” variables are of the String type.  We’re also using nil coalescing because the same method returns an optional.  Nil coalescing unwraps the optional for us to use. 

```
let defaults = UserDefaults.standard

if let savedPeople = defaults.object(forKey: "people") as? Data {
    if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
        people = decodedPeople
    }
}
```
To sum up:

- For encoding:

NSKeyedArchiver.archivedData -> encode(with aCoder: NSCoder) -> UserDefaults

- For decoding:

 UserDefaults -> NSKeyedUnarchiver.unarchiveTopLevelObjectWithData -> required init(coder aDecoder: NSCoder)
