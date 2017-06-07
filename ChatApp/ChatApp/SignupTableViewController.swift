//
//  RegisterTableViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/5/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import UIKit
import Firebase


class SignupTableViewController: BaseTableViewController {

    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var nameTextField: UITextField!
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet var alreadyRegisteredButton: UIButton!
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        registerUser()
    }
    
    @IBAction func alreadyRegisteredButtonPressed(_ sender: Any) {
       
    }
    
    var isProfilePictureLoaded: Bool = false
    var chatController: ChatsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageSelection)))
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        StylizeForm()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func StylizeForm(){
        self.nameTextField.setBottomBorder()
        self.emailTextField.setBottomBorder()
        self.passwordTextField.setBottomBorder()
        self.profileImageView.makeCircular()
        self.registerButton.layer.cornerRadius = 10
        self.registerButton.layer.masksToBounds = true
        self.registerButton.setFontPrimaryButton()
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.borderWidth = 0.5
        profileImageView.layer.borderColor = UIColor(r: 30, g: 75, b: 240).cgColor
        profileImageView.backgroundColor = UIColor.white
        self.alreadyRegisteredButton.setFontSecondaryButton()
        
        self.nameTextField.setRegularLagashFont()
        self.emailTextField.setRegularLagashFont()
        self.passwordTextField.setRegularLagashFont()
    }
    
    
    
    func registerUser(){
        if !self.isProfilePictureLoaded {
            showMessage(text: "Select a picture!", title: "Oops!")
            return
        }
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            else {
                return
        }
        
        if email == "" || password == "" || name == "" {
            showMessage(text: "Fill the fields!", title: "Oops!")
            return
        }
        
        self.showSpinner()
        
        Auth.auth().createUser(withEmail: email.lowercased(), password: password,
                               completion: { (user: User?, error) in
                                if error != nil {
                                    print(error)
                                    self.showMessage(text: "There has been an error trying to sign up the user", title: "Error!")
                                    self.hideSpinner()
                                    return
                                }
                                
                                //get de uid from the current user.
                                guard let uid = user?.uid else {
                                    return
                                }
                                //success!
                                
                                let imageName = NSUUID().uuidString
                                let storageRef = Storage.storage().reference().child("\(imageName).jpg")
                                
                                if let profileImage = self.profileImageView.image,  let uploadData = UIImageJPEGRepresentation(profileImage, 0.2) {
                                    
                                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                        if error != nil {
                                            self.showMessage(text: "There has been an error uploading the profile picture", title: "Error!")
                                            self.hideSpinner()
                                            return
                                        }
                                        
                                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                                            let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                                            self.registerUserIntoDb(uid: uid, values: values as [String : AnyObject])
                                        }
                                    })
                                }
        })
    }
    
    func registerUserIntoDb(uid: String, values: [String: AnyObject]){
        
        let ref = Database.database().reference()
        let userReferences = ref.child("users").child(uid)
        
        userReferences.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                self.showMessage(text: "There has been an error registering the user in the BD", title: "Error!")
                return
            }
        })
        
        print("User successfully added")
        
        self.nameTextField.text = ""
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        self.profileImageView.image = nil
        
        let user = LocalUser()
        user.setValuesForKeys(values)
        self.chatController?.loadUserInNavBar(user: user)
        
        self.hideSpinner()
        self.dismiss(animated: true, completion: nil)
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLoginControllerSegue" {
            if let signInController = segue.destination as? LoginTableViewController{
                signInController.chatController = self.chatController
            }
        }
    }

}


extension SignupTableViewController : UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
            return true
        }
        else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            return true
        }
        else{
            textField.resignFirstResponder()
            registerUser()
            return true
        }
    }
    
    func handleProfileImageSelection() {
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
            profileImageView.image = selectedImage
            self.isProfilePictureLoaded = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled Picker")
        self.isProfilePictureLoaded = false
        dismiss(animated: true, completion: nil)
    }

}
