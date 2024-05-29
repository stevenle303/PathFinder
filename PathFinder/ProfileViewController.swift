//
//  ProfileViewController.swift
//  PathFinder
//
//  Created by Umran Jameel on 12/6/22.
//

import UIKit
import AlamofireImage
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = PFUser.current()!
        if user["profile_pic"] != nil {
            let imageFile = user["profile_pic"] as! PFFileObject
            let urlString = imageFile.url!
            let urlImage = URL(string: urlString)
            
            profilePic.af.setImage(withURL: urlImage!)
        }
        
        usernameLabel.text = user["username"] as? String
        if user["bio"] != nil {
            bioLabel.text = user["bio"] as? String
        }
        
        
        tableView.delegate = self
        tableView.dataSource = self
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let user = PFUser.current()!
        
        // parse query -- get post
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.order(byDescending: "createdAt")
        query.whereKey("author", equalTo: user)
        
        query.findObjectsInBackground{ [self]
            (posts, error) in
            if posts != nil {
                // add post into the array
                self.posts = posts!
                self.tableView.reloadData()
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.descriptionLabel.text = post["caption"] as? String
            cell.locationLabel.text = post["location"] as? String
            cell.post = post
            
            if (post["likes"] != nil)
            {
                if ((post["likes"] as! [PFUser]).contains(where: {$0.objectId == PFUser.current()?.objectId}))
                {
                    cell.setLike(true)
                }
            }
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let urlImage = URL(string: urlString)
            
            cell.photoview.af.setImage(withURL: urlImage!)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
    }
    
    @IBAction func onChangeProfilePic(_ sender: Any) {
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
