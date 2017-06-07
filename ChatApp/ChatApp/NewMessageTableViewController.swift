//
//  NewMessageViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 5/30/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableViewController: BaseTableViewController {

    var users = [LocalUser]()
    var refreshControlView: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNavBarTitle()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(doCancel))
        cancelButton.setStyle()
        navigationItem.leftBarButtonItem = cancelButton
        fetchAllUsers()
        
        addRefreshControl()
        
        self.setNavigationBarStyle()
    }

    func doCancel() {
        self.dismiss(animated: true, completion: nil)
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
        fetchAllUsers()
    }
    
    
    func loadNavBarTitle(){
        
        let navBarTitleView = UIView()
        navBarTitleView.frame = CGRect(x: 0, y: 0, width: 130, height: 40)
        
        
        let navBarLabel = UILabel()
        navBarTitleView.addSubview(navBarLabel)
        navBarLabel.translatesAutoresizingMaskIntoConstraints = false
        navBarLabel.text = "New Message"
        navBarLabel.setMediumBoldLagashFont()
        navBarLabel.textColor = UIColor.white
        
        navBarLabel.leftAnchor.constraint(equalTo: navBarTitleView.rightAnchor, constant: 8).isActive = true
        navBarLabel.centerYAnchor.constraint(equalTo: navBarTitleView.centerYAnchor).isActive = true
        navBarLabel.rightAnchor.constraint(equalTo: navBarTitleView.rightAnchor).isActive = true
        navBarLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        navBarLabel.centerXAnchor.constraint(equalTo: navBarTitleView.centerXAnchor).isActive = true
        navBarLabel.centerYAnchor.constraint(equalTo: navBarTitleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = navBarTitleView

    }
    
    func fetchAllUsers(){
        
        self.users.removeAll()
        
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user =  LocalUser()
                user.setValuesForKeys(dictionary)
                user.id = snapshot.key
                
                if Auth.auth().currentUser?.email != user.email?.lowercased() {
                    self.users.append(user)
                    self.users.sort(by: { (user1, user2) -> Bool in
                        return user1.name! < user2.name!
                    })
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.refreshControlView?.endRefreshing()
                    }
                }
            }
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! ChatReceptorsTableViewCell
        let user = users[indexPath.row]
        cell.user = user
        
        return cell
    }

    var chatsTableViewController: ChatsTableViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        dismiss(animated: true)
            
        self.chatsTableViewController?.showChatLogControllerForUser(user: user)
    }
    
}
