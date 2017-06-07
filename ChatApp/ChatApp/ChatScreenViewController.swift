//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/2/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit
import Firebase


class ChatScreenViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    let cellId = "cellId"
    var attachAlert: UIAlertController?
    
    var messages = [Message]()
    var receptorUser: LocalUser? {
        didSet{
            if let user = receptorUser {
                setupNavBarWithUser(user: user)
                observeMessages()
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.register(ChatMessageCellController.self, forCellWithReuseIdentifier: cellId)
        
        self.collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 58, 0)
        self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 58, 0)
        //collectionView?.keyboardDismissMode = .interactive
        collectionView?.alwaysBounceVertical = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        configAttachAlert()
        setupInputComponents()
        resizeInputTextView()
    }
    

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCellController
        let message = messages[indexPath.row]
        
        setupCell(cell: cell, message: message)
        
        return cell
    }
    
    func setupCell(cell: ChatMessageCellController, message: Message){
        
        cell.chatScreenViewController = self
        
        if let seconds = message.timestamp?.doubleValue{
            let timestampDate = NSDate(timeIntervalSince1970: seconds)
            cell.timeLabel.text = timestampDate.fullFormat()
        }
        
        if let text = message.text {
            cell.textView.text = text
            cell.bubbleWithAnchor?.constant = estimatedFrameForText(text: text).width + 32
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
        }else if let messageImageUrl = message.imageUrl  {
            cell.textView.text = ""
            cell.bubbleWithAnchor?.constant = 200
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.white
            cell.textView.isHidden = true
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            if  message.text != nil {
                cell.bubbleView.backgroundColor = UIColor(r: 0, g: 137, b: 249)
            }
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.profileImageView.image = nil
            cell.timeLabelRightAnchor?.isActive = true
            cell.timeLabelLeftAnchor?.isActive = false
            cell.timeLabel.textAlignment = .right
        }else {
            
            if  message.text != nil {
                cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            }
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.timeLabelRightAnchor?.isActive = false
            cell.timeLabelLeftAnchor?.isActive = true
            cell.timeLabel.textAlignment = .left
            
            if let profileImageUrl = receptorUser?.profileImageUrl {
                cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
            
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = CGFloat(100)
        
        let message = messages[indexPath.row]
        
        if let text = message.text {
            height = estimatedFrameForText(text: text).height  + 50
        }else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue{
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    
    
    func estimatedFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 2000)
        let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 19)], context: nil)
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupKeyboardObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func handleKeyboardWillShow(notification: Notification){
        
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        //move the containerInput
        containerViewbottomAnchor?.constant = -keyboardFrame.height
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleKeyboardWillHide(notification: Notification){
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        //move the containerInput
        containerViewbottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }

    }
    
    func resizeInputTextView(){
        let sizeThatFitsTextView = inputTextView.sizeThatFits(CGSize(width: inputTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        containerViewHeightAnchor?.constant = sizeThatFitsTextView.height + 10;
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    var containerViewbottomAnchor: NSLayoutConstraint?
    var containerViewHeightAnchor: NSLayoutConstraint?
    let inputTextView = UITextView()
    let sendButton = UIButton(type: .system)
    
    func configAttachAlert(){
        self.attachAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        self.attachAlert?.addAction(UIAlertAction(title: "Send Image", style: .default, handler: { (alertAction) in
            self.handleImageSelection()
        }))
        self.attachAlert?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
    }
    
    
    func setupInputComponents(){
    
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(containerView)
        
        //x,y,w,h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerViewbottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewbottomAnchor?.isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerViewHeightAnchor = containerView.heightAnchor.constraint(equalToConstant: 50)
        containerViewHeightAnchor?.isActive = true
        
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "icon-Attach")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.contentMode = .scaleAspectFill
        uploadImageView.layer.masksToBounds = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        uploadImageView.isUserInteractionEnabled = true
        containerView.addSubview(uploadImageView)
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        
        
        sendButton.setTitle("Send", for: UIControlState.normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        sendButton.isEnabled = false
        sendButton.setFontButton()
        containerView.addSubview(sendButton)
        
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
       
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.layer.cornerRadius = 5
        inputTextView.delegate = self
        inputTextView.isScrollEnabled = false
        inputTextView.layer.masksToBounds = true
        inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        inputTextView.layer.borderWidth = 0.5
        inputTextView.setInputLagashFont()
        containerView.addSubview(inputTextView)
        
        //x,y,w,h
        inputTextView.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 5).isActive = true
        inputTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5).isActive = true
        inputTextView.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 5).isActive = true
        inputTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        
        
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.lightGray
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    
    func handleUploadTap(){
        self.present(attachAlert!, animated: true, completion: nil)
    }
    
    
    
    func setupNavBarWithUser(user :LocalUser){
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
        
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = user.name
        nameLabel.textColor = UIColor.white
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        self.navigationItem.titleView = titleView
    }
    
    
   
    
    
    func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid, let toId = receptorUser?.id else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid).child(toId)
        ref.observe(DataEventType.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observe(DataEventType.value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                self.messages.append(Message(dictionary: dictionary))
                DispatchQueue.main.async {
                self.collectionView?.reloadData()
                    let indexPath = IndexPath(item: self.messages.count-1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
            }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    func uploadToFireBaseStorageUsingImage(image: UIImage){
        
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message_images").child("\(imageName).jpg")
        
        if  let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    //self.showMessage(text: "There has been an error uploading the profile picture", title: "Error!")
                    print("Failed to upload image")
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                    
                }
            })
        }

        
    }
    
    func handleSendMessage(){
        guard let fromId = Auth.auth().currentUser?.uid else {
            return
        }
        if let message = inputTextView.text {
            print(message)
            let values = ["text": message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)] as [String : AnyObject]
            sendMessageWithProperties(properties: values)
        }
        
        inputTextView.text = ""
        inputTextView.resignFirstResponder()
        self.dismissKeyboard()
        resizeInputTextView()
    }
    
    func sendMessageWithImageUrl(imageUrl: String, image: UIImage){
        let values = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : AnyObject]
        sendMessageWithProperties(properties: values)
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]){
        let ref = Database.database().reference().child("messages")
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: Int = (Int(NSDate().timeIntervalSince1970) as? Int)!
        let toId = receptorUser!.id!
        var values = ["fromId": fromId, "toId": toId, "timestamp": timestamp] as [String: AnyObject]
        
        //append values
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        let childRef = ref.childByAutoId()
        childRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let userMessageRecipientRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            userMessageRecipientRef.updateChildValues([messageId: 1])
        })

    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoomInStartingImageView(startingImageView: UIImageView){
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            blackBackgroundView?.translatesAutoresizingMaskIntoConstraints = false
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
               
                self.blackBackgroundView?.alpha = 1
                self.blackBackgroundView?.topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive = true
                self.blackBackgroundView?.leftAnchor.constraint(equalTo: keyWindow.leftAnchor).isActive = true
                self.blackBackgroundView?.rightAnchor.constraint(equalTo: keyWindow.rightAnchor).isActive = true
                self.blackBackgroundView?.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive = true

                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor).isActive = true
                zoomingImageView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor).isActive = true
                zoomingImageView.centerYAnchor.constraint(equalTo: keyWindow.centerYAnchor).isActive = true
                zoomingImageView.heightAnchor.constraint(equalToConstant: height).isActive = true
                
                
            }, completion: { (completed) in
                
            })
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view{
           
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.layer.masksToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: { 
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0

            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
}



extension ChatScreenViewController: UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        self.resizeInputTextView()
        
        self.sendButton.isEnabled = textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lengthOfBytes(using: String.Encoding.utf8) > 0
    }
    
    func handleImageSelection() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImage : UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let pickedImage = selectedImage {
            uploadToFireBaseStorageUsingImage(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

