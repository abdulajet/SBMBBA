//
//  AppDelegate.swift
//  SBMBBA (Starling Bank Menu Bar Balance App)
//
//  Created by Abdulhakim Ajetunmobi on 15/07/2017.
//  Copyright © 2017 Abdulhakim Ajetunmobi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    var strBal = "Loading"
    //replace with your personal token from developer.starlingbank.com
    let clientAuth = ""
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AppDelegate.update), userInfo: nil, repeats: true)
        
        //Show statusMenu
        statusItem.menu = statusMenu
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func update() {
        //Balance Endpoint
        let urlString = "https://api.starlingbank.com/api/v1/accounts/balance"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        
        //Auth Header
        request.setValue("Bearer \(clientAuth)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        //Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            let dict = json as? NSDictionary
            
            if let balance = dict!["effectiveBalance"] as? Double {
                self.strBal = "£" + String(balance)
            }
        }
        
        task.resume()
        
        //Update value
        statusItem.title = strBal
    }
}

