//
//  ChatAppTests.swift
//  ChatAppTests
//
//  Created by Sergio Raul Carreño Aranguiz on 5/29/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import XCTest
@testable import ChatApp

class ChatAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
 
    
    func testAddUser(){
        let manager = ApiRestManager()
        
        manager.addUser(name: "Test10", email: "Test10@gmail.com") { (userId, error) in
            if error != nil{
                XCTFail("Error adding new user")
                return
            }
            
            XCTAssert((userId?.lengthOfBytes(using: String.Encoding.utf8))!>0)
        }
    }
    
    func testGetUsers(){
        let manager = ApiRestManager()
        
        manager.getUsers { (users, error) in
            
            if error != nil{
                XCTFail("Error fetching new user")
                return
            }
            
            if let usersArr = users {
                XCTAssert(usersArr.count > 0, "Users ok!")
            }else {
                XCTFail("Users array empty")
            }
        }
    }
    
}
