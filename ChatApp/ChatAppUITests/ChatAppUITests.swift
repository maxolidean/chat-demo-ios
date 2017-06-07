//
//  ChatAppUITests.swift
//  ChatAppUITests
//
//  Created by Sergio Raul Carreño Aranguiz on 5/29/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import XCTest

class ChatAppUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testLogin(){
        XCUIDevice.shared().orientation = .faceUp
        XCUIDevice.shared().orientation = .faceUp
        
        let tablesQuery = XCUIApplication().tables
        tablesQuery.buttons["Sign Up"].tap()
        XCUIDevice.shared().orientation = .portrait
        tablesQuery.buttons["I'm a registered user"].tap()
        tablesQuery.textFields["Email"].tap()
        
        let cellsQuery = tablesQuery.cells
        cellsQuery.children(matching: .textField).element.typeText("sergio@gmail.com")
        
        let signInButton = tablesQuery.buttons["Sign In"]
        signInButton.tap()
        tablesQuery.secureTextFields["Password"].tap()
        cellsQuery.children(matching: .secureTextField).element.typeText("qwerty")
        signInButton.tap()
        
        
    }
    
    func testLogout() {
        XCUIDevice.shared().orientation = .faceUp
        XCUIDevice.shared().orientation = .faceUp
        
        let app = XCUIApplication()
        app.navigationBars["ChatApp.ChatsTableView"].buttons["Logout"].tap()
        app.alerts["Logout"].buttons["Yes"].tap()
        
        
    }
    
}
