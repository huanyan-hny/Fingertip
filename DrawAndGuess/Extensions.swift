//
//  Extensions.swift
//  DrawAndGuess
//
//  Created by Troy on 2017/2/3.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import Foundation
import UIKit

extension GameViewController:UITextFieldDelegate{
    
    func changeFirstResponder() {
        textField?.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guessField.text = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guessEdited = true
        guessField.text = textField.text
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == guessField) {
            if (guessEdited) {
                guessField.resignFirstResponder()
                guessEdited = false
                return false
            }
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        inDrawing = true
        swiped = false
        let touch = touches.first!
        lastPoint = touch.location(in: self.canvas)
    }
    
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(self.canvas.frame.size)
        let context = UIGraphicsGetCurrentContext()
        canvas.image?.draw(in: CGRect(x:0,y:0, width: canvas.frame.size.width, height:canvas.frame.size.height))
        
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x:toPoint.x, y: toPoint.y))
        
        context?.setLineCap(.round)
        context?.setLineWidth(2)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1)
        context?.setBlendMode(.normal)
        
        context?.strokePath()
        
        canvas.image = UIGraphicsGetImageFromCurrentImageContext()
        canvas.alpha = 1
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        let touch = touches.first!
        let currentPoint = touch.location(in: self.canvas)
        if (UserDefaults.standard.string(forKey: "userID") == self.drawingUser) {
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            SocketIOManager.sharedInstance.drawLine(fromX: Double(lastPoint.x), fromY: Double(lastPoint.y), toX: Double(currentPoint.x), toY: Double(currentPoint.y))
            lastPoint = currentPoint
        }
    }

}

extension LoginViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
