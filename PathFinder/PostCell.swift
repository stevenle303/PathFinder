//
//  PostCell.swift
//  PathFinder
//
//  Created by Robert Farrell on 11/22/22.
//

import UIKit
import Parse

class PostCell: UITableViewCell {

    @IBOutlet weak var photoview: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var liked:Bool = false
    var post:PFObject? = nil
    
    @IBAction func likePost(_ sender: Any) {
        let tobeLiked = !liked
        if (tobeLiked){
            post?.add(PFUser.current(), forKey: "likes")
            post?.saveInBackground { (success, error) in
                if success {
                    self.setLike(true)
                    print("Like saved")
                } else {
                    print("Error saving like")
                }
            }
        }
        else {
            post?.remove(PFUser.current(), forKey: "likes")
            post?.saveInBackground { (success, error) in
                if success {
                    self.setLike(false)
                    print("Unlike saved")
                } else {
                    print("Error saving unlike")
                }
            }
        }
    }
    
    func setLike(_ isLiked: Bool){
        liked = isLiked
        if (liked){
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: UIControl.State.normal)
        }
        else{
            likeButton.setImage(UIImage(systemName: "heart"), for: UIControl.State.normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
