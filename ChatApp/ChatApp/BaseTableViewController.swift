//
//  BaseViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/5/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import Foundation
import UIKit

public class BaseTableViewController: UITableViewController {
    
    let spinner = Spinner(frame: UIScreen.main.bounds)
    let lagashBackgroundColor = UIColor(r: 30, g: 75, b: 240)
    
    func showSpinner(){
        UIApplication.shared.keyWindow?.addSubview(spinner)
    }
    
    func setNavigationBarStyle(){
        self.navigationController?.navigationBar.barTintColor = self.lagashBackgroundColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName : UIFont(name: "Poppins-Medium", size: 17)!]
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = UIColor.white

    }
    
    
    func hideSpinner(){
        if spinner != nil {
            spinner.hide()
        }
    }
    
   
}
