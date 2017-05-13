//
//  ViewController.swift
//  RxStarscreamExample
//
//  Created by Bogdan Vlad on 5/13/17.
//  Copyright © 2017 Bogdan Vlad. All rights reserved.
//

import UIKit
import Starscream
import RxSwift

class ViewController: UIViewController {
    @IBOutlet var connectionStatusLabel: UILabel!
    @IBOutlet var connectionButton: UIButton!
    
    let connection : WebSocket = WebSocket(url: URL(string: "ws://localhost:1337/")!)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connection.rx.events.subscribe(onNext: { event in
            
        }).addDisposableTo(disposeBag)
        
        connection.rx.connected.subscribe(onNext: { isConnected in
            if isConnected {
                self.connectionStatusLabel.text = "Connected!"
                self.connectionButton.setTitle("Disconnect", for: .normal)
            } else {
                self.connectionStatusLabel.text = "Disconnected!"
                self.connectionButton.setTitle("Connect", for: .normal)
            }
        }).addDisposableTo(disposeBag)
        
        connection.rx.text.subscribe(onNext: { text in
            print("Received: \(text)")
            
        }).addDisposableTo(disposeBag)
    }
    
    @IBAction func sendButtonPressed() {
        self.connection.rx.send(text: "Hello world!").subscribe(onNext: {
            print("Sent!")
        }).addDisposableTo(self.disposeBag)
    }

    @IBAction func connectButtonpressed() {
        if !connection.isConnected {
            connection.connect()
        } else {
            connection.disconnect()
        }
    }
}

