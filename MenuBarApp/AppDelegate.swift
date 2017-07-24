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
    
    
    //replace with your personal token from developer.starlingbank.com
    let clientAuth = ""
    //0 - balance, 1 - daily transactions
    var mode = 0
    
    //switch button in reference
    @IBOutlet weak var switchBtn: NSMenuItem!
    //menu
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    //quit button action
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    //switch button action
    @IBAction func switchClicked(_ sender: NSMenuItem) {
        if (mode == 0) {
            mode = 1
            switchBtn.title = "Show Balance"
        }else {
            mode = 0
            switchBtn.title = "Show Transactions"
        }
        update()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        update()
        //time interval is in secs, adjust to your desired refersh rate.
        Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(AppDelegate.update), userInfo: nil, repeats: true)
        
        //Show statusMenu
        statusItem.menu = statusMenu
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func update() {
        if (mode == 0) {
            balance()
        }else {
            transactions()
        }
    }
    
    func balance() {
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
                DispatchQueue.main.sync(execute: {
                    //update the menu bar on the main thread
                    self.statusItem.title = "Balance: £" + String(format: "%.2f", balance)
                })
            }
        }
        task.resume()
    }
    
    func transactions() {
        //current date
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let tempDate = dateFormatter.string(from: date)

        
        //Balance Endpoint
        let urlString = "https://api.starlingbank.com/api/v1/transactions?from=\(tempDate)"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        var total = 0.0
        
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
            
            let json = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let dict = json as! NSDictionary
            
            let transactionsDict = dict["_embedded"]! as! NSDictionary
            let transactionsArr = transactionsDict["transactions"] as! [NSDictionary]
            
            //loop over transactions
            for transaction in transactionsArr {
                let amount = transaction["amount"] as! Double
                if (amount < 0) {
                    total += amount
                }
            }
            
            DispatchQueue.main.sync(execute: {
                //update the menu bar on the main thread
                if total != 0 { total = total * -1 }
                self.statusItem.title = "Spent Today: £" + String(format: "%.2f", total)
            })
        }
        task.resume()
    }
    
}

