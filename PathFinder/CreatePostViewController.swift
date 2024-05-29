//
//  CreatePostViewController.swift
//  PathFinder
//
//  Created by Chari Altagracia on 11/15/22.
//

import UIKit
import Parse
import AlamofireImage

class CreatePostViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var postDescription: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onSubmitButton(_ sender: Any) {
        
        let post = PFObject(className: "Posts")
        
       
        post["location"] = location.text
        post["caption"] = postDescription.text
        post["author"] = PFUser.current()!
        
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(data: imageData!)
        
        post["image"] = file
    
        post.saveInBackground{ (success, error) in
            if success {
                self.dismiss(animated: true)
                print("saved!")
            }else{
                print("Error:")
            }
        }
    }
    
    @IBAction func onCamaraButton(_ sender: Any) {
//    getting the image to post
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            picker.sourceType = .photoLibrary
        }else {
            picker.sourceType = .camera
          
        }
        
        present(picker, animated:true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageScaled(to: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
}
