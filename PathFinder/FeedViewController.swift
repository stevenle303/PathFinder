//
//  FeedViewController.swift
//  PathFinder
//
//  Created by Hensanity Le on 11/15/22.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, MessageInputBarDelegate, UISearchBarDelegate {
   
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var selectedPost: PFObject!
    
    let searchController = UISearchController(searchResultsController: nil)
    let myRefreshControl = UIRefreshControl()
    
    // Empty array
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PathFinder"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false;

        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        myRefreshControl.addTarget(self, action: #selector(viewDidAppear), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text
        else{
            return
        }
        /*
        let vc = searchController.searchResultsController as? ResultsVC
        vc?.view.backgroundColor = .white
         */
        // parse query -- get post based on searh

        let LocationQuery = PFQuery(className: "Posts")
        LocationQuery.whereKey("location", contains: text)
        LocationQuery.includeKeys(["author", "comments", "comments.author"])
        LocationQuery.order(byDescending: "createdAt")
        LocationQuery.limit = 20
        
        LocationQuery.findObjectsInBackground{ [self]
            (posts, error) in
            if posts != nil {
                // add post into the array
                self.posts = posts!
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            }
        }
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    // Logout Function
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else {return}
        
        delegate.window?.rootViewController = loginViewController
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // parse query -- get post
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.order(byDescending: "createdAt")
        query.limit = 20
        
        query.findObjectsInBackground{ [self]
            (posts, error) in
            if posts != nil {
                // add post into the array
                self.posts = posts!
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
                
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
    
    @IBAction func onComment(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        showsCommentBar = true
        becomeFirstResponder()
        commentBar.inputTextView.becomeFirstResponder()
        selectedPost = posts[indexPath.section]
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()
        
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if (success) {
                self.tableView.reloadData()
            } else {
                print("error saving coment")
            }
        }
        
        
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
}
