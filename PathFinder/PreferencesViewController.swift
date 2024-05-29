//
//  PreferencesViewController.swift
//  PathFinder
//
//  Created by Umran Jameel on 12/6/22.
//

import UIKit
import Parse
import AlamofireImage

class PreferencesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let user = PFUser.current()!
        if user["profile_pic"] != nil {
            let imageFile = user["profile_pic"] as! PFFileObject
            let urlString = imageFile.url!
            let urlImage = URL(string: urlString)
            
            profilePic.af.setImage(withURL: urlImage!)
        }
        
        if user["bio"] != nil {
            bioTextField.text = user["bio"] as? String
        } else {
            bioTextField.placeholder = "Add a bio..."
        }
    }
    
    @IBAction func onUpdateBio(_ sender: Any) {
        let user = PFUser.current()!
        user["bio"] = bioTextField.text
        
        user.saveInBackground{ (success, error) in
            if success {
                self.dismiss(animated: true)
                print("saved!")
            }else{
                print("Error")
            }
        }
    }
    
    @IBAction func onChangePic2(_ sender: Any) {
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
    
    @IBAction func onChangePic(_ sender: Any) {
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
        
        let size = CGSize(width: 100, height: 100)
        var scaledImage = image.af.imageScaled(to: size)
        scaledImage = image.af.imageRoundedIntoCircle()
        
        profilePic.image = scaledImage
        
        let user = PFUser.current()!
        user["profile_pic"] = PFFileObject(data: (profilePic.image!.pngData())!)
        
        user.saveInBackground{ (success, error) in
            if success {
                self.dismiss(animated: true)
                print("saved!")
            }else{
                print("Error")
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
