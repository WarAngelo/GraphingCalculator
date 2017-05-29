//
//  TextViewController.swift
//  GraphingCalculator
//
//  Created by Андрей Рыжов on 10.08.15.
//  Copyright (c) 2015 Lazy Team. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!  {
        didSet {
            textView.text = text
        }
    }
    
    var text: String = "" {
        didSet {
            textView?.text = text // если не установится аутлет, например в прерпаре фо сиге
        }
    }
    
    override var preferredContentSize: CGSize {
        get {
            if textView != nil && presentingViewController != nil { //презентинг вью контроллер - это граф вью контроллер и он не равен нилу, когда представляет
                return textView.sizeThatFits(presentingViewController!.view.bounds.size) // берет нашу вьюху и подгоняет размер под вызывающий внешний размер контроллера
            } else {
                return super.preferredContentSize
            }
        }
        set {
            super.preferredContentSize = newValue
        }
    }
}
