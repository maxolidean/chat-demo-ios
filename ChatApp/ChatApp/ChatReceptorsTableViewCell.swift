//
//  ChatReceptorsTableViewCell.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/1/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit
import Firebase

class ChatReceptorsTableViewCell: UITableViewCell {

    
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var timeLabel: UILabel!
    
    var message: Message? {
        didSet{
            
            loadPartnerInfoOnNavBar()
            
            if let seconds = self.message?.timestamp?.doubleValue{
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"
                
                let days = timestampDate.days()
                let minutes = timestampDate.minutes()
                let hours = timestampDate.hours()
                let seconds = timestampDate.seconds()
                let current = dateFormatter.string(from: Date())
                print("current date: \(current)   formato normal \(dateFormatter.string(from: timestampDate as Date)), days: \(days) , hours: \(hours), minutes: \(minutes), seconds: \(seconds)")
                
                
                self.timeLabel.text = timestampDate.getPrettyString()
                self.timeLabel.setSmallLagashFont()
            }

        }
    }
    
    var user: LocalUser?{
        didSet{
            self.titleLabel.text = user?.name
            self.subTitleLabel.text = user?.email
            
            self.titleLabel.setTitleLagashFont()
            self.subTitleLabel.setMediumLagashFont()
            
            if let profileImageUrl = user?.profileImageUrl {
                
                if profileImageUrl != nil {
                    self.userImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    self.userImageView.layer.borderWidth = 0.5
                    self.userImageView.layer.borderColor = UIColor.black.cgColor
                }
            }

        }
    }
    
    private func loadPartnerInfoOnNavBar(){
               
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = LocalUser()
                    user.setValuesForKeys(dictionary)
                    
                    self.titleLabel.text = user.name
                    
                    if let text = self.message?.text {
                        if self.message?.fromId == Auth.auth().currentUser?.uid {
                            self.subTitleLabel.text = "You: \(text)"
                        }else{
                            self.subTitleLabel.text = text
                        }
                        
                    }else{
                        if self.message?.fromId == Auth.auth().currentUser?.uid {
                            self.subTitleLabel.text = "You: Sent an Image..."
                        }else{
                            self.subTitleLabel.text = "Sent an image..."
                        }
                    }
                    
                    self.titleLabel.setTitleLagashFont()
                    self.subTitleLabel.setMediumLagashFont()
                    
                    if let profileImageUrl = user.profileImageUrl {
                        self.userImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                        self.userImageView.layer.borderWidth = 0.5
                        self.userImageView.layer.borderColor = UIColor.black.cgColor

                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImageView.makeCircular()
    }
}
