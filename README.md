Unit 8: Group Milestone - README
===

# PathFinder

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
An application that allows users to share their travels and experiences. The primary purpose is to share interesting attractions and make discovering spots while traveling easier.

### App Evaluation
- **Category:** Social Media / Travel
- **Mobile:** This app will be primarily mobile, but could possibly be expanded to a web component in the future
- **Story:** User can view other users posts of travel spots. They can like and comment these posts, or make their own post.
- **Market:** Any individuals who enjoy traveling and want to find new things, or for people to share their findings and experiences. 
- **Habit:** This app would most likely not be used on a daily basis, but rather whenever someone has traveled or is planning on traveling
- **Scope:** This App would start with simply information being shared from user to user, but could possibly be expanded to companies advertising their own travel locations or products.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* [x] If a user does not have an account, they can register
* [x] If a user does have an account, they can log in
* [x] Once logged in, they are brought to a feed where the user can view posts, 
* [x] User can comment and like posts
* [x] User can Refresh Feed
* [x] The user can search for posts based on location or User
* [x] The user can create a post, giving the location, a picture, and a description
* [x] The user has a profile page with their profile picture and a bio
* [x] A preference page where the user can change their profile picture and bio

**Optional Nice-to-have Stories**
* User can change theme in preference page
* A user can have friends
    * A seperate friends feed that shows posts of friends

### 2. Screen Archetypes

* Login
* Register
   * Once this is done, the user will be brought to the login or homepage upon opening the app
* Home Screen - Feed
   * The user can view posts, starting with the most recent
* Search Screen
   * The user can search by location or keyword for posts 
* Post Screen
   * User can create a post, tagging a location, adding a picture, and creating a description
* Profile Screen
   * User can view their profile, including their own posts, profile picture, and bio
* Preferences Screen 
   * User can change their bio and profile picture and (optional) theme
   
Optional:
* Friends Screen
   * User can see a feed of their friends posts 

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home Feed
* Profile
* Preferences / Settings

Optional:

* Friends

**Flow Navigation** (Screen to Screen)

* Login
   * User Registers if they do not have an account
   * After logging in or registering, they are brought to the homepage
* Homepage
   * User can scroll through a feed of posts from any user
* Profile
    * User can scroll through their own posts or click on preferences and change their bio, profile picture, etc.

## Wireframes
[Add picture of your hand sketched wireframes in this section]

<img src="https://i.imgur.com/u1L0PDJ.png" width=600>
<img src="https://i.imgur.com/9LE7TA1.png" width=600>

## Schema 
[This section will be completed in Unit 9]
### Models

Users

| Property | Type     | Description |
| -------- | -------- | --------    |
|ObjectID  |Number    | Unique id for the user |
|UserName  |String    | The name of the user in the app  |
|Password  |String    | a unique string that logins the user to their account 
|Email     |String    | email connected the account  |
|CreatedAt |String    |Date user account craeted|


Posts
| Property | Type     | Description |
|----------|----------|-------------|
|ObjectID  |String    |A Unique string to represent each post|
|Author    |String    |Points to the user who created the post|
|Image     |File      |Image that the user posts|
|Caption|String|Caption that the user writes|
|Likes|Int|Number of likes for post|
|CreatedAt|String|Date post was craeted|

Comments
| Property | Type     | Description |
|----------|----------|-------------|
| ObjectID | String   | Unique String to represent the comment|
| PostID   | String   | Unique string representing the post which the comment is under|
| createdAt| Date     | Date that the comment was made|
| Author   | String   | Name of user who wrote the comment|
| Text     | String   | Text of the comment string|

### Networking
#### List of Network Requests by screen
* Login
    * (Read/Get) User logs in given valid username and password
    ```
    PFUser.logInWithUsername(inBackground: username, password: password){(user, error) in 
        if user != nil {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        } else{
            print("Error:\(error?.localizedDescription)")
        }
    }
    ```
    
* Register
    * (Create/Post) Create a new user
    ```
    var user = PFUser()
    user.username = usernameField.text
    user.password = passwordField.text
        
    user.signUpInBackground { (success, error) in
        if success {     
            // success
        } else {
            // error, could not sign up
        }
    }
    ```
* Home Screen - Feed
    * (Read/Get) Query all posts that don't belong to the current user
    ```
    let query = PFQuery(className:"Post")
    query.whereKey("author", notEqualTo: currentUser)
    query.order(byDescending: "createdAt")
    query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
       if let error = error { 
          print(error.localizedDescription)
       } else if let posts = posts {
          print("Successfully retrieved \(posts.count) posts.")
      // TODO: Do something with posts...
       }
    }
    ```
    * (Create/Post) Like a post
    ```
    let query = PFQuery(className:"Post")
    query.whereKey("ObjectID", equalTo: postID)
    query.findObjectsInBackground { (post: PFObject, error: Error?) in 
        if let error = error {
          print(error.localizedDescription)
       } else if let post = post {
          print("Successfully retrieved post.")
          post.Likes += 1
       }
    }
    ```
    * (Delete) Unlike a post
    ```
    let query = PFQuery(className:"Post")
    query.whereKey("ObjectID", equalTo: postID)
    query.findObjectsInBackground { (post: PFObject, error: Error?) in 
        if let error = error {
          print(error.localizedDescription)
       } else if let post = post {
          print("Successfully retrieved post.")
          post.Likes -= 1
       }
    }
    ```
    * (Create/Post) Comment on a post
    ```
    let comment = PFObject(className: "Comments")
    comment["text"] = text
    comment["post"] = selectedPost
    comment["author"] = PFUser.current()!

    selectedPost.add(comment, forKey: "comments")
    selectedPost.saveInBackground { (success, error) in
        if success {
            // success
        } else {
            // error, could not post comment
        }
    }
    ```
    * (Delete) Delete a comment
    ```
    let comment = PFObject(className: "Comments")
    comment["text"] = text
    comment["post"] = selectedPost
    comment["author"] = PFUser.current()!

    selectedPost.add(comment, forKey: "comments")
    selectedPost.saveInBackground { (success, error) in
        if success {
            // delete comment
        } else {
            // error, could not post comment
        }
    }
    ```
* Search Screen
    * (Read/Get) Get all posts who's author or location match the current search value

    ```
    let query = PFQuery(className:"Post")
    query.whereKey("ObjectID", equalTo: postID)
    query.order(byDescending: "createdAt")
    query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
       if let error = error { 
          print(error.localizedDescription)
       } else if let posts = posts {
          print("Successfully retrieved \(posts.count) posts.")
      
       }
    }
    ```
* Post Screen
    * (Create/Post) Create a new post given a picture, caption, and location
    ```
    let post = PFObject(className: "Posts")
        
        post["caption"] = commentField.text!
        post["author"] = PFUser.current()!
        
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(name: "image.png",data: imageData!)
        
        post["image"] = file
        
        post.saveInBackground { success, error in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("Saved !")
            }
            else {
                print("error!")
            }
        }
    ```
* Profile Screen
    * (Read/Get) Query all posts that belong to the current user
    ```
    let query = PFQuery(className:"Post")
    query.whereKey("author", equalTo: currentUser)
    query.order(byDescending: "createdAt")
    query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
       if let error = error {
          print(error.localizedDescription)
       } else if let posts = posts {
          print("Successfully retrieved \(posts.count) posts.")
          // TODO: Do something with posts...
       }
    }
    ```
    * (Read/Get) Query user information, such as profile picture and bio
    ```
    let query = PFQuery(className:"Users")
    query.whereKey("ObjectID", equalTo: userID)
    query.findObjectsInBackground { (user: PFObject, error: Error?) in 
        if let error = error {
          print(error.localizedDescription)
       } else if let user = User {
          // use User
       }
    }
    ```
* Preferences Screen 
    * (Update/Put) User can update their information, such as profile picture and bio
    ```
    let query = PFQuery(className:"Users")
    query.whereKey("ObjectID", equalTo: userID)
    query.findObjectsInBackground { (user: PFObject, error: Error?) in 
        if let error = error {
          print(error.localizedDescription)
       } else if let user = User {
          // edit user
       }
    }

### Checkpoint 1 GIF

<img src="https://github.com/stevenle303/PathFinder/blob/main/PathFinderGifs/Checkpoint1.gif" width=250><br>

### Checkpoint 2 GIF

<img src="https://github.com/stevenle303/PathFinder/blob/main/PathFinderGifs/CheckPoint2.gif" width=250><br>

### Checkpoint 3 GIF

<img src="https://github.com/stevenle303/PathFinder/blob/main/PathFinderGifs/Checkpoint3.gif" width=250><br>

### Final Checkpoint GIF

<img src="https://github.com/stevenle303/PathFinder/blob/main/PathFinderGifs/finalCheckpoint.gif" width=250><br>

