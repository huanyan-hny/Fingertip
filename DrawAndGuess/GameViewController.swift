//
//  ViewController.swift
//  DrawAndGuess
//
//  Created by Troy on 2017/2/3.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit
import SocketIO

class GameViewController: UIViewController{
    
    lazy var timer = Timer()
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var swiped = false
    var inDrawing = false
    var inDisplaying = false
    var textField:UITextField?
    var receivedGuesses:[(String,String)] = []
    var seconds = 60
    var drawingUser:String?
    var keyword:String?
    var guessEdited = false
    var delivered:[Int:Bool] = [:]
    
    @IBOutlet var nameLabels: [UILabel]!
    @IBOutlet var avatars: [UIImageView]!
    @IBOutlet var scores: [UILabel]!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var guessLabel: UILabel!
    @IBOutlet weak var canvas: UIImageView!
    @IBOutlet weak var guessField: UITextField!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var displayWindow: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    
    
    @IBAction func resetCanvas(_ sender: UIButton) {
        if (UserDefaults.standard.string(forKey: "userID") == self.drawingUser) {
            canvas.image = nil
            SocketIOManager.sharedInstance.resetCanvas()
        }
    }
    
    @IBAction func sendGuess(_ sender: UIButton) {
        if (guessField.text! == self.keyword) {
            self.sendButton.isEnabled = false
        }
        SocketIOManager.sharedInstance.sendGuess(guess: guessField.text!)
        guessField.text = ""
        textField?.text = ""
        print("Sending Guess " + guessField.text!)
    }
    
    func receiveDrawLine(fromPoint:CGPoint,toPoint:CGPoint) {
        drawLineFrom(fromPoint: fromPoint, toPoint: toPoint)
    }
    
    func receiveSendGuess(guess:String, userID:String) {
        print("Received guess " + guess)
        if (!inDisplaying) {
            receivedGuesses.append((guess,userID))
            inDisplaying = true
            displayGuess()
        }
    }
    
    func gameover() {
        let alertController = UIAlertController(title: NSLocalizedString("Game over!", comment: ""), message: NSLocalizedString("Check results", comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toResult", sender: self)
            }
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayGuess() {
        if let guess = receivedGuesses.first {
            guessLabel.frame.origin.x = view.frame.width
            guessLabel.center.y = displayWindow.center.y
            if (guess.0 == "Round over, prepare for next round") {
                guessLabel.text =  guess.0
                guessLabel.textColor = UIColor.orange
            } else if (guess.0 == "--Right--") {
                guessLabel.text = guess.1 + " just guessed correctly!"
                guessLabel.textColor = UIColor.orange
            } else {
                guessLabel.text = guess.1 + ": " + guess.0
                guessLabel.textColor = UIColor.black
            }
            guessLabel.sizeToFit()
            UIView.animate(withDuration: 3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.guessLabel.frame.origin.x -= self.view.frame.width + self.guessLabel.frame.width
            }, completion: {(finished) in
                self.receivedGuesses.remove(at: 0)
                if (self.receivedGuesses.isEmpty) {
                    self.inDisplaying = false
                } else {
                    self.displayGuess()
                }
            })
        }
    }
    
    func startNewRound(roundCount:Int, keyword:String, hint:String, drawingUser:String) {
        seconds = 60
        timeLabel.text = "\(seconds)"
        answerLabel.text = " "
        self.canvas.image = nil
        self.drawingUser = drawingUser
        self.keyword = keyword
        self.hintLabel.text = hint
        
        if (UserDefaults.standard.string(forKey: "userID")! == drawingUser) {
            self.sendButton.isEnabled = false
            self.guessField.isEnabled = false
            self.answerLabel.text = self.keyword
        } else {
            self.sendButton.isEnabled = true
            self.guessField.isEnabled = true
        }
        
        
        for i in 0...3 {
            if (nameLabels[i].text == drawingUser) {
                avatars[i].layer.borderWidth = 1
                avatars[i].layer.borderColor = UIColor.red.cgColor
            } else {
                avatars[i].layer.borderWidth = 0
            }
        }
    }
    
    func updateUsers(users:[[String:Any]]) {
        print("Updating users")
        for i in 0...3 {
            nameLabels[i].text = users[i]["nickname"] as! String?
            let avatar = UIImage(data: users[i]["avatar"] as! Data)
            avatars[i].image = avatar
            scores[i].text = "\(users[i]["score"] as! Int)"
        }
    }
    
    func eachSecond(_ timer:Timer) {
        seconds -= 1
        if (seconds>=0) {
            timeLabel.text = "\(seconds)"
        } else {
            timeLabel.text = "0"
        }
        if (seconds < -5 ) {
            revealAnswer()
        }
    }
    
    func revealAnswer() {
        self.answerLabel.text = keyword
        receivedGuesses.append(("Round over, prepare for next round", " "))
        if (!inDisplaying) {
            inDisplaying = true
            displayGuess()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            if (UserDefaults.standard.string(forKey: "userID")! == self.drawingUser){
                SocketIOManager.sharedInstance.nextRound()
            }
        })
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(eachSecond(_:)), userInfo: nil, repeats: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
        
        self.guessLabel.center.x = 1000
        self.guessLabel.center.y = 1000
        
        let keyboardToolBar = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        keyboardToolBar.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        guessField.delegate = self
        textField = UITextField.init(frame: CGRect(x: 5, y: 0, width: self.view.frame.width-5, height: 40))
        textField!.borderStyle = .roundedRect
        textField!.text = guessField.text
        textField?.returnKeyType = .done
        textField?.delegate = self
        keyboardToolBar.addSubview(textField!)
        guessField.inputAccessoryView = keyboardToolBar
        NotificationCenter.default.addObserver(self, selector: #selector(changeFirstResponder), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        SocketIOManager.sharedInstance.receiveDrawLine(completionHandler: {(points) in
            DispatchQueue.main.async {
                self.receiveDrawLine(fromPoint: CGPoint(x: points[0], y: points[1]), toPoint: CGPoint(x:points[2],y:points[3]))
            }
        })
        
        SocketIOManager.sharedInstance.receiveResetCanvas {
            DispatchQueue.main.async {
                self.canvas.image = nil
            }
        }
        
        SocketIOManager.sharedInstance.receiveSendGuess(completionHandler: {(guess, userID, verdict) in
            if (verdict == "right") {
                DispatchQueue.main.async {
                    self.receiveSendGuess(guess: "--Right--", userID: userID)
                }
            } else if (verdict == "wrong") {
                DispatchQueue.main.async {
                    self.receiveSendGuess(guess: guess, userID: userID)
                }
            } else if (verdict == "over") {
                DispatchQueue.main.async {
                    self.gameover()
                }
            }
        })
        
        SocketIOManager.sharedInstance.receiveStartNewRound(completionHandler: {(roundCount, keyword, hint, drawingUser) in
            DispatchQueue.main.async {
                self.startNewRound(roundCount: roundCount, keyword: keyword, hint: hint, drawingUser:drawingUser)
            }
        })
        
        SocketIOManager.sharedInstance.receiveUsers(completionHandler: {(users) in
            DispatchQueue.main.async {
                self.updateUsers(users:users)
            }
        })
        
        SocketIOManager.sharedInstance.receiveRevealAnswer {
            DispatchQueue.main.async {
                self.revealAnswer()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ResultViewController {
            var rankedScores:[Int] = []
            for i in 0...3 {
                let score = Int(scores[i].text!)
                rankedScores.append(score!)
            }
            rankedScores.sort{$0>$1}
            
            for i in 0...3 {
                delivered[i] = false
            }
            
            for i in 0...3 {
                let scoreRanked = rankedScores[i]
                for j in 0...3 {
                    let score = Int(scores[j].text!)
                    if (score == scoreRanked && delivered[j] == false) {
                        delivered[j] = true
                        destination.avatarImages[i] = self.avatars[j].image
                        destination.nameStrings[i] = self.nameLabels[j].text
                        destination.scoreStrings[i] = self.scores[j].text
                        break
                    }
                }
            }
            
        }
    }
    
}
