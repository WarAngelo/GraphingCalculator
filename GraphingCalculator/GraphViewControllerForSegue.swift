//
//  GraphViewControllerForSegue.swift
//  GraphingCalculator
//
//  Created by Андрей Рыжов on 10.08.15.
//  Copyright (c) 2015 Lazy Team. All rights reserved.
//

import UIKit

class GraphViewControllerForSegue: GraphViewController, UIPopoverPresentationControllerDelegate {
    
    var minAndMax = [Double]()
    
    override func fillStackPoints(_ sender: GraphView, originPoint: CGPoint, widthBounds: CGFloat, heightBounds:CGFloat, pointPerUnit: CGFloat) -> [CGPoint] {
        var graphOnPoint = [CGPoint]()
        
        //for x in 0...Int(weightBounds) {
        let oldMValue = brain.variableValues["M"]
        minAndMax.removeAll()
        for x in stride(from: CGFloat(0), through: CGFloat(widthBounds), by: 1 / graphView.contentScaleFactorView) {
            let xRound = round(x * graphView.contentScaleFactorView) / graphView.contentScaleFactorView
            let valueX = (xRound - originPoint.x) / pointPerUnit
            brain.variableValues["M"] = Double(valueX)
            var y: CGFloat
            if let valueY = brain.evaluateForGraph() {
                y = round ((pointPerUnit * (-1) * CGFloat(valueY) + originPoint.y) * graphView.contentScaleFactorView) / graphView.contentScaleFactorView
                  //println("x = \(xRound) and \(originPoint.x); y = \(y) and \(originPoint.y)")
                graphOnPoint.append(CGPoint(x: xRound, y: y))
                if y >= 0 && y <= heightBounds && !(y).isNaN {
                    minAndMax += [valueY]
                }
            }  else {
                break
            }
            brain.variableValues["M"] = oldMValue
            _ = brain.evaluateForGraph() //swift 3
        }
        return graphOnPoint

    }
    
    fileprivate struct MinAndMax {
        static let SegueIdentifier = "Show min and max Y"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case MinAndMax.SegueIdentifier:
                if let tvc = segue.destination as? TextViewController {
                    if let ppc = tvc.popoverPresentationController {
                        ppc.delegate = self
                    }
                    if !minAndMax.isEmpty {
                        tvc.text = "min Y = \(round(100 * minAndMax.min()!) / 100)\n" + "max Y = \(round(100 * minAndMax.max()!) / 100)"
                    } else {
                        tvc.text = "Graphing area is empty"
                    }
                }
            default: break
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
