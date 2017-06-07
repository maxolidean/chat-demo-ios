//
//  Extensions.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 5/30/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import Foundation
import UIKit


let imageCache = NSCache<NSString, UIImage>()
extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage{
            self.image = cachedImage
            return
        }
 
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil{
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!){
                    self.image = downloadedImage
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                }
            }
        }).resume()

    }
    
    func makeCircular(){
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
    }
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}

extension UITextView {
    
    func setRegularLagashFont() {
        self.font = UIFont(name: "Poppins-Light", size: 15)
    }
    
    func setInputLagashFont() {
        self.font = UIFont(name: "Poppins-Light", size: 15)
    }
}


extension UITextField {
    func setBottomBorder() {
        
        let width = CGFloat(0.5)
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        bottomBorder.borderWidth = width
        bottomBorder.borderColor = UIColor.lightGray.cgColor
        self.layer.addSublayer(bottomBorder)
        self.layer.masksToBounds = true
    }
    
    func setCornerRadius() {
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    
    func setRegularLagashFont() {
        
        self.font = UIFont(name: "Poppins-Light", size: 17)
    }
    
   
    
}

extension UILabel {
    func setRegularLagashFont() {
        self.font = UIFont(name: "Poppins-Light", size: 17)
    }
    
    func setTitleLagashFont() {
        self.font = UIFont(name: "Poppins-Medium", size: 17)
    }
    
    func setMediumLagashFont() {
        self.font = UIFont(name: "Poppins-Light", size: 14)
    }
    
    func setSmallLagashFont() {
        self.font = UIFont(name: "Poppins-Light", size: 12)
    }
    
    func setTimeStyleLagashFont() {
        self.font = UIFont(name: "Poppins-Light", size: 10)
    }
    
    func setMediumBoldLagashFont() {
        self.font = UIFont(name: "Poppins-Medium", size: 16)
    }
    
    func setSuccessStyle() {
        self.font = UIFont(name: "Poppins-Medium", size: 15)
    }
    func setErrorStyle() {
        self.font = UIFont(name: "Poppins-Medium", size: 15)
        self.textColor = UIColor.red
    }
    
}

extension UIButton{
    func setFontPrimaryButton(){
        self.titleLabel?.font = UIFont(name: "Poppins-Light", size: 17)
    }
    func setFontSecondaryButton(){
        self.titleLabel?.font = UIFont(name: "Poppins-Light", size: 15)
    }
    
    func setFontButton(){
        self.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
    }
    
    func roundCorners(){
        self.layer.cornerRadius = 5
        self.layer.masksToBounds  = true
    }
}

extension UIBarButtonItem {
    
    func setStyle(){
           
        self.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: "Poppins-Medium", size: 17)!,
            NSForegroundColorAttributeName : UIColor.white],
                                    for: UIControlState.normal)
    }
    
}

extension NSDate {
    
    func days() -> Int {
        return Calendar.current.dateComponents([.day], from: self as Date, to: Date()).day ?? 0
    }
    func hours() -> Int {
        return Calendar.current.dateComponents([.hour], from: self as Date, to: Date()).hour ?? 0
    }
    func minutes() -> Int {
        return Calendar.current.dateComponents([.minute], from: self as Date, to: Date()).minute ?? 0
    }
    func seconds() -> Int {
        return Calendar.current.dateComponents([.second], from: self as Date, to: Date()).second ?? 0
    }
    
    
    func getPrettyString() -> String {
        let secondsBetween = self.seconds()
        if (secondsBetween < 45)
        {
            return "just now"
        }
        
        let hoursBetween = self.hours()
        if (hoursBetween < 1)
        {
            let minutesBetween = self.minutes()
            return (minutesBetween <= 1 ? "a minute ago" : "\(minutesBetween) minutes ago")
        }
        
        let differenceInDays = self.days()
        if (differenceInDays < 1)
        {
            let hours = self.hours()
            return (hours <= 1) ? "an hour ago" : "\(hours) hours ago"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        
        return dateFormatter.string(from: self as Date)
    }
    
    func fullFormat()-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        
        return dateFormatter.string(from: self as Date)

    }
 
}

extension String
{
    func trimText() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
}


extension UITableViewCell{
    
    func setBottomBorder(){
        
        let width = CGFloat(0.5)
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        bottomBorder.borderWidth = width
        bottomBorder.borderColor = UIColor.lightGray.cgColor
        self.layer.addSublayer(bottomBorder)
        self.layer.masksToBounds = true

    }
}
