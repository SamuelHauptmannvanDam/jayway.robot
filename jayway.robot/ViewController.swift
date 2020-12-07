//
//  ViewController.swift
//  jayway.robot
//
//  Created by Samuel Hauptmann van Dam on 18/11/2020.
//


// GOAL:
// I want the user, to be able to use it no matter what they input, but guide them to a more useful input if there is an issue with their input. I believe it gives the user the best experience possible. Not being stopped in their tracks by an error message, but instead guided towards more useful actions.


import UIKit

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}



class Robot{
    
    var newFaceDirection : String
    var newXCoordinate : Int
    var newYCoordinate : Int
    var newRoomSize: Int
    
    init(newFaceDirection: String, newXCoordinate: Int, newYCoordinate: Int, newRoomSize: Int){
        self.newFaceDirection = newFaceDirection
        self.newXCoordinate = newXCoordinate
        self.newYCoordinate = newYCoordinate
        self.newRoomSize = newRoomSize
    }
    
    
    //        The Premise:
    //        It's super basic. Instead of building a matrix, it relies on facingDirection, xCoordinate, yCoordinate
    //        If you turn, we just change the facingDirection
    //        If you face north or south and take a step forward, we update yCoordinate by +-1
    //        If you face east or west and take a step forward, we update xCoordinate by +-1
    
    
    func turnLeft() -> String{
    
        switch "\(newFaceDirection)" {
        case "N":
            self.newFaceDirection = "W"
        case "W":
            self.newFaceDirection = "S"
        case "S":
            self.newFaceDirection = "E"
        case "E":
            self.newFaceDirection = "N"
        default:
            self.newFaceDirection = "E"
        }
        
        return newFaceDirection
        
    }
    
    
    func turnRight() -> String{
        
        switch "\(newFaceDirection)" {
        case "N":
            newFaceDirection = "E"
        case "E":
            newFaceDirection = "S"
        case "S":
            newFaceDirection = "W"
        case "W":
            newFaceDirection = "N"
        default:
            newFaceDirection = "E"
        }
        
        return newFaceDirection
        
    }
    
}




class ViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var endLocationText: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var roomSizeTextField: UITextField!
    
    @IBOutlet weak var xCoordinateTextField: UITextField!
    @IBOutlet weak var yCoordinateTextField: UITextField!
    
    @IBOutlet weak var facingDirectionTextField: UITextField!
    @IBOutlet weak var pathTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        test()

        // Textfields are delegated to themselves.
        self.roomSizeTextField.delegate = self
        self.xCoordinateTextField.delegate = self
        self.yCoordinateTextField.delegate = self
        self.facingDirectionTextField.delegate = self
        self.pathTextField.delegate = self
        
        
//        Keyboard modifiers.
//        Moves view up to make all textfields visible.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
//        Tapping elsewhere will close the keyboard.
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
    }

    // When clicking the button after having added all your inputs.
    @IBAction func goButton(_ sender: Any) {
       
        errorLabel.textColor = UIColor.white // resetting error message

//        I choose to go for square rooms for simplicity. Could also have done, what I did for coordinates, or added two input views. One for height and one for width, but choose square rooms for simplicity in code and in UI.
        
        var roomSize = 5
        let roomSizeCheck = roomSizeTextField.text
        if checkForIntAndCount(input: roomSizeCheck!) {
            roomSize = Int(String(roomSizeCheck!))!
            
        } else {
            errorLabel.textColor = UIColor.red
            errorLabel.text = "The room takes a single digit, from 1-9"
        }
        
        
        var xCoordinate = 0
        let xCoordinateCheck = xCoordinateTextField.text
        if checkForIntAndCount(input: xCoordinateCheck!) {
            xCoordinate = Int(String(xCoordinateCheck!))!
        } else {
            errorLabel.textColor = UIColor.red
            errorLabel.text = "The X coordinate takes a single digit, from 1-9"
        }
        
        var yCoordinate = 0
        let yCoordinateCheck = yCoordinateTextField.text
        if checkForIntAndCount(input: yCoordinateCheck!) {
            yCoordinate = Int(String(yCoordinateCheck!))!
        } else {
            errorLabel.textColor = UIColor.red
            errorLabel.text = "The Y coordinate takes a single digit, from 1-9"
        }
        
        var facingDirection = "E" // Needed for the switch
        facingDirection = facingDirectionTextField.text ?? "E" // Needed to take care of nil
        if facingDirection != "N" && facingDirection != "E" && facingDirection != "S" && facingDirection != "E" {
           
            errorLabel.textColor = UIColor.red
            errorLabel.text = "Almost there. Face direction should be N, E, S or W"
            
        }
        
//        New robot object
        let newRobot = Robot(newFaceDirection: facingDirection, newXCoordinate: xCoordinate, newYCoordinate: yCoordinate, newRoomSize: roomSize)
        
//        Takes any input, if there is anything useful, it will apply it.
        let path = Array(pathTextField.text!)
        
//        Loop through commands, if any of characters resemble F, L or R, we deal with it.
//        This means, we can take any command or input, and ignore what isn't useful.
//        I believe it to be a pro, as people might leave a space " " or other letters
//        CON: Does not take small charcters. But I've changed the keyboard to be caps on everything by default. It's not perfect, but it will work for most.

        
//        Runs newRobot through it's path
        for (_, element) in path.enumerated() {
            
            if element == "R" { // Turning right
               
                facingDirection = newRobot.turnRight()
                
            } else if element == "L" { // Turning left
                
                facingDirection = newRobot.turnLeft()
                                
            } else if element == "F" { // Move forward
                
                let errorTextPathingOutTheBox = "You left the room by choosing that path! Try increasing the size of the room or a different path"
        
                switch "\(facingDirection)" {
                case "N":
                    yCoordinate = (yCoordinate )+1
                    if yCoordinate > roomSize {
                        errorLabel.textColor = UIColor.red
                        errorLabel.text = errorTextPathingOutTheBox
                    }
                    
                case "W":
                    xCoordinate = (xCoordinate )-1
                    if xCoordinate < 0 {
                        errorLabel.textColor = UIColor.red
                        errorLabel.text = errorTextPathingOutTheBox
                    }
                    
                case "S":
                    yCoordinate = (yCoordinate )-1
                    if yCoordinate < 0 {
                        errorLabel.textColor = UIColor.red
                        errorLabel.text = errorTextPathingOutTheBox
                    }
                    
                case "E":
                    xCoordinate = (xCoordinate )+1
                    if xCoordinate > roomSize {
                        errorLabel.textColor = UIColor.red
                        errorLabel.text = errorTextPathingOutTheBox
                    }
                    
                default:
                    xCoordinate = 0
                    yCoordinate = 0
                }
                
            
                
            } else {
                errorLabel.textColor = UIColor.red
                errorLabel.text = "You're close. Only the letters F, L & R is understood, when creating a path"
            }
            
        }
        
        endLocationText.text = "End Location: \n \(xCoordinate) \(yCoordinate) \(facingDirection)"
        

        
        
        
    }
    
    
    // ------------------ This part, is about jumping to the next textfield
    
    // textFieldShouldReturn checks when someone taps return on their keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.switchBasedNextTextField(textField)
        return true
    }
    
    // Switch which takes textfield as input and then depending on the textfield, jumps to the next, unless, it's the last textfield which closes the keyboard.
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.roomSizeTextField:
            self.xCoordinateTextField.becomeFirstResponder()
        case self.xCoordinateTextField:
            self.yCoordinateTextField.becomeFirstResponder()
        case self.yCoordinateTextField:
            self.facingDirectionTextField.becomeFirstResponder()
        case self.facingDirectionTextField:
            self.pathTextField.becomeFirstResponder()
        default:
            self.pathTextField.resignFirstResponder()
        }
    }
    
    // ------------------ jumping textfield ends

//    Check if input is single int
    func checkForIntAndCount(input: String) -> Bool{
        if input.count == 1 && input.isInt {
            return true
        }
        return false
    }
    
//    Runs test checking assumption of output, meaning we aren't testing for specific implementation of method, just output.
    
    func test(){
        let testRobot = Robot(newFaceDirection: "E", newXCoordinate: 0, newYCoordinate: 0, newRoomSize: 5)
        testRobot.turnLeft()
        if testRobot.newFaceDirection == "N" {
            print("Test succesfully passed")
            
        }

    }
    
    
    
//    When the keyboard appears, the view is moved up to make all 4 textfields visible.
    
    @IBAction func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 170
            }
        }
    }

//    Sets the view back down.
    @IBAction func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}

// If I had more time, I would have improved the keyboard moving up.
// If I had more time, I would have created an introduction to the game.
// If I had more time, I would have create better error comments.


