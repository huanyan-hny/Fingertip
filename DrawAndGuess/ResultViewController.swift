//
//  ResultViewController.swift
//  DrawAndGuess
//
//  Created by Troy on 2017/2/4.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet var avatars: [UIImageView]!
    @IBOutlet var names: [UILabel]!
    @IBOutlet var scores: [UILabel]!

    var avatarImages:[Int:UIImage] = [:]
    var nameStrings:[Int:String] = [:]
    var scoreStrings:[Int:String] = [:]
    
    
    
    @IBAction func returnToLogin(_ sender: UIButton) {
        SocketIOManager.sharedInstance.disConnectUser(userID: UserDefaults.standard.string(forKey: "userID")!)
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        for i in 0...3 {
            names[i].frame.origin.y = avatars[i].frame.origin.y
            scores[i].frame.origin.y = avatars[i].frame.origin.y + avatars[i].frame.height - scores[i].frame.height
            names[i].center.x = avatars[i].center.x + view.frame.width/3
            scores[i].center.x = names[i].center.x
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for i in 0...3 {
            avatars[i].image = avatarImages[i]
            names[i].text = nameStrings[i]
            scores[i].text = scoreStrings[i]
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
