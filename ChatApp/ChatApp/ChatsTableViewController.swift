//
//  ChatsTableViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 5/29/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit
import Firebase

class ChatsTableViewController: BaseTableViewController {

    
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    var refreshControlView: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = ""
        self.setNavigationBarStyle()
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(verifyLogout))
        logoutButton.setStyle()
        navigationItem.leftBarButtonItem = logoutButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        observeUserMessages()
        addRefreshControl()
        self.refreshControlView?.beginRefreshing()
    }
    
    func addRefreshControl(){
        
        refreshControlView = UIRefreshControl()
        refreshControlView?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControlView?.tintColor = UIColor(r: 30, g: 75, b: 240)
        refreshControlView?.attributedTitle = NSAttributedString(string: "Fetching Users...")
        // Add to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControlView
        } else {
            tableView.addSubview(refreshControlView!)
        }
    }

    func handleRefresh(){
        observeUserMessages()
    }
    
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            print("llegaaaa")
            let userId  = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(DataEventType.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessagesWithMessageId(messageId: messageId)
                
                            }, withCancel: nil)
        },withCancel: nil)
        
        refreshControlView?.endRefreshing()
    }
    
    private func fetchMessagesWithMessageId(messageId: String){
        let messageReference = Database.database().reference().child("messages").child(messageId)
        
        messageReference.observe(DataEventType.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message(dictionary: dictionary)                
                if let chatPartnerId = message.chatPartnerId() as? String {
                    
                    self.messageDictionary[chatPartnerId] = message
                    
                }
                
                self.attempReloadTable()
            }
            
        }, withCancel: nil)
    }
    var timer: Timer?
    
    func attempReloadTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable(){
        
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })

        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControlView?.endRefreshing()
        }
    
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.handleLogout()
            }
        }else {
           fetchCurrentUser()
        }

    }
    
    func fetchCurrentUser(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("users").child(uid)
            .observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let user = LocalUser()
                    user.setValuesForKeys(dictionary)
                    self.loadUserInNavBar(user: user)
                }
            })
    }
    
    func loadUserInNavBar(user :LocalUser){
        
        //clean arrays, because of the new user
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let userNameLabel = UILabel()
        containerView.addSubview(userNameLabel)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.text = user.name
        userNameLabel.setMediumBoldLagashFont()
        userNameLabel.textColor = UIColor.white
        
        userNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        userNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        userNameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        userNameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        self.navigationItem.titleView = titleView
        
    }
       func showChatLogControllerForUser(user: LocalUser){
               let chatLogController = ChatScreenViewController(collectionViewLayout: UICollectionViewFlowLayout())
       
        chatLogController.receptorUser = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }

    
    
    func handleNewMessage() {
        if let newMessageView = storyboard?.instantiateViewController(withIdentifier: "NewMessageTableViewController") as? NewMessageTableViewController {
            newMessageView.chatsTableViewController = self
            let navController = UINavigationController(rootViewController: newMessageView)
            present(navController, animated: true, completion: nil)
        }
    }
    
    func verifyLogout(){
        
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) in
            self.handleLogout()
        })
        )
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func handleLogout(){
        do{
            try Auth.auth().signOut()
            
            messages.removeAll()
            messageDictionary.removeAll()
            tableView.reloadData()
            
        }catch let logoutError {
            print(logoutError)
        }
        if let signUpView = storyboard?.instantiateViewController(withIdentifier: "SignupTableViewController") as? SignupTableViewController {
            signUpView.chatController = self
            var navSignUpView = UINavigationController(rootViewController: signUpView)
            present(navSignUpView, animated: true, completion: nil)
        }
        
    }
    
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatsCell", for: indexPath) as! ChatReceptorsTableViewCell
        let message = messages[indexPath.row]
        
        cell.message = message
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() as? String else {
            return
        }
        
       let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = LocalUser()
                user.setValuesForKeys(dictionary)
                user.id = snapshot.key
                self.showChatLogControllerForUser(user: user)
            }
            
        }, withCancel: nil)
    }

}
