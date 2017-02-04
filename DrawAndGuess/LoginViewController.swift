//
//  LoginViewController.swift
//  DrawAndGuess
//
//  Created by Troy on 2017/2/4.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var avatar: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var message: UILabel!
    var avatarIndex = 1
    
    @IBAction func changeAvatar(_ sender: UIButton) {
        avatarIndex += 1
        if (avatarIndex == 10) {
            avatarIndex = 1
        }
        sender.setImage(UIImage.init(named: "avatar\(avatarIndex)") , for: .normal)
    }

    @IBAction func changeStatus(_ sender: UIButton) {
        let status = message.text
        if (status == "Tap to start") {
            message.text = "Waiting for other users"
            let avatarData = UIImageJPEGRepresentation((avatar.imageView?.image)!, 1.0)
            let userID = nameField.text!
            UserDefaults.standard.set(userID, forKey:"userID")
            SocketIOManager.sharedInstance.connectUser(userID: userID,avatar:NSData(data: avatarData!))
        } else {
            message.text = "Tap to start"
            SocketIOManager.sharedInstance.disConnectUser(userID: nameField.text!)
        }
        sender.sizeToFit()
    }
    
    
    func startNewGame() {
        message.text = "Tap to start"
        self.performSegue(withIdentifier: "toGame", sender: self)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
        SocketIOManager.sharedInstance.receiveStartNewGame {
            DispatchQueue.main.async {
                self.startNewGame()
            }
        }
    }
    
    @IBAction func unwindToBegin(_ segue:UIStoryboardSegue) {
        
    }
}
