//
//  ViewController.swift
//  Calculator
//
//  Created by Андрей Рыжов on 17.05.15.
//  Copyright (c) 2015 Lazy Team. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var historyDisplay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //brain.evaluate()
 
        if brain.description == " " && brain.evaluate() == nil  {
        display.text = "0"
        } else {
            print("description [\(brain.description)]")
            displayValue = brain.evaluate()
            historyDisplay.text = brain.description
        }
    }
    
    var userIsInTheMiddleOfTypingANumber: Bool = false
    
    var brain = CalculatorBrain() // стрелка от контроллера к модели

    @IBAction func clean() {
        userIsInTheMiddleOfTypingANumber = false
        brain.cleanArray()
        display.text = "0"
        historyDisplay.text = " "
        brain.descriptionForM = false
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber == true && (display.text!).characters.count > 1 {
            display.text = String((display.text!).characters.dropLast())
        }
    }
    
    @IBAction func plusAndMinus() {
        if userIsInTheMiddleOfTypingANumber {
            let myStartIndex = display.text!.characters.index(display.text!.startIndex, offsetBy: 1)
           // if display.text!.removeAtIndex(display.text!.startIndex) == "-" { удаляет первый индекс, поэтому не очень хочется использовать
            if display.text![display.text!.startIndex ..< myStartIndex] == "-" {
                display.text = String((display.text!).characters.dropFirst())
            } else {
                display.text!.insert("-", at: display.text!.startIndex)
            }
        }
    }
    
    
    @IBAction func appendDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        //historyDisplay.text = historyDisplay.text! + digit
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        historyDisplay.text = brain.description
    }
 
    @IBAction func operate(_ sender: UIButton) {
        //historyDisplay.text = historyDisplay.text! + sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber { //чтобы не нажимать энтер после ввода второго числа
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        historyDisplay.text = brain.description
    }
    
    @IBAction func enter() {
        //historyDisplay.text = historyDisplay.text! + "⏎"
        userIsInTheMiddleOfTypingANumber = false
        print("\(String(describing: displayValue))")
        if let checkDisplayValue = displayValue {
//        if let _ = displayValue {
//            if let result = brain.pushOperand(displayValue!) { //- положим значение в стек
            if let result = brain.pushOperand(checkDisplayValue) {
                displayValue = result
                //display.text = "\(result)"
            } else {
                displayValue = nil
            }
        } else {
            displayValue = nil
        }
        historyDisplay.text = brain.description
    }
    
    @IBAction func setM() { // ->M
        userIsInTheMiddleOfTypingANumber = false
        if let checkDisplayValue = displayValue {
            brain.variableValues["M"] = checkDisplayValue
            //brain.descriptionForM = false //выключаем распознование М
        }
       // if brain.descriptionForM == true { //заносим в пустые M
            displayValue = brain.evaluate()
            historyDisplay.text = brain.description
        //}
    }
    
    @IBAction func getM() { // M
        if userIsInTheMiddleOfTypingANumber {
        enter()
        }
        let result = brain.pushOperand("M")
        displayValue = result
        historyDisplay.text = brain.description
        //brain.descriptionForM = true  // выключаем распознование М
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination as? UIViewController
        //var destination = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let gvc = destination as? GraphViewController {
            if let identifier = segue.identifier { // из оставшихся сиг выбираем только те, в которых мы прописали идентифаер в стори борде
                switch identifier {
                case "showGraph": //break
                    gvc.storedValue = [0,0,0]
                    //gvc.myTitle = brain.getResultString()
                    //можно не передавать, потому что я сделал модель в проперте листе
                   // gvc.brain = brain
                   // gvc.fillPhysPoints(50)
                  //  println(gvc.myTitle)
                default: break//gvc.myTitle = "50"
                }
            }
        }
    }
    
    var displayValue: Double? {
        get {
            //делаем проверку, чтобы небыло чисел типа 0.5.5.5
   //         if display.text!.rangeOfString(".") == display.text!.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch){
                //return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
            return Double(display.text!)
      //      }
            // нан - это хитрая штука, получается когда делят на ноль или корень из отрицательного числа
            //return Double.NaN
            
        }
        set {
            if let checkNewValue = newValue {
            display.text = "\(checkNewValue)"
            } else {
                display.text = " "
            }
 //            userIsInTheMiddleOfTypingANumber = false
        }
    }
}
