//
//  GraphViewController.swift
//  GraphingCalculator
//
//  Created by Андрей Рыжов on 21.07.15.
//  Copyright (c) 2015 Lazy Team. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource, GraphViewStoredValue
{
    var brain = CalculatorBrain()
    var myTitle: String {
        _ = brain.evaluate()
        return brain.getResultString()
    }
    
    var ratioX: CGFloat = 1
    var ratioY: CGFloat = 1
    
    override func viewWillLayoutSubviews() {
        ratioX = graphView.originPoint.x / graphView.widthView
        ratioY = graphView.originPoint.y / graphView.heightView
    }
    
    override func viewDidLayoutSubviews() {
        graphView.originPoint.x = ratioX * graphView.widthView
        graphView.originPoint.y = ratioY * graphView.heightView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = myTitle
        let array = storedValue
        print("viewDidLoad \(array)")
        if array.isEmpty || array == [0,0,0] {
        } else {
            graphView.originPoint.x = CGFloat(array[0])
            graphView.originPoint.y = CGFloat(array[1])
            graphView.pointsPerUnit = CGFloat(array[2])
            print("DidLoad")
        }

    }
    
    fileprivate let defaults = UserDefaults.standard
    var storedValue: [Float] {
        get { return defaults.object(forKey: "origin, scale") as? [Float] ?? [] }
        set { defaults.set(newValue, forKey: "origin, scale")
            //print("set storedValue = \(storedValue)")
        }
    }
    
    func fillStoredValue(_ sender: GraphView, originPoint: CGPoint, pointPerUnit: CGFloat) {
        storedValue = [Float(originPoint.x), Float(originPoint.y), Float(pointPerUnit)]
    }
    
    func getStoredValue(_ sender: GraphView) -> [CGFloat] {
        return [CGFloat(storedValue[0]), CGFloat(storedValue[1]), CGFloat(storedValue[2])]
    }
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.dataStoredValue = self
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: Selector(("changeOrigin:"))))
//            if !storedValue.isEmpty || storedValue != [0,0,0] {
//                    graphView.pointsPerUnit = CGFloat(storedValue[2])
//                    graphView.changePoint.x = CGFloat(storedValue[0])
//                    graphView.changePoint.y = CGFloat(storedValue[1])
//            }
        }
    }
    
    //Сделал в стори борде в контент моде
//    override func viewDidLayoutSubviews() {
//        //graphView.setNeedsDisplay() //
//        //title = myTitle
//    }
    
    
    @IBAction func changeOriginByTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let location = gesture.location(in: graphView)
            print("\(location)")
//            changeX = location.x - graphView.originPoint.x
//            addPhysPoints(graphView.pointsPerUnit, changeX: changeX)
            graphView.originPoint.x = round(location.x * graphView.contentScaleFactorView) / graphView.contentScaleFactorView
            graphView.originPoint.y = round(location.y * graphView.contentScaleFactorView) / graphView.contentScaleFactorView
            print("x = \(graphView.originPoint.x); y = \(graphView.originPoint.y)")
            graphView.setNeedsDisplay()
        }
    }
    
    @IBAction func pinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            graphView.pointsPerUnit *= gesture.scale
            gesture.scale = 1
        }
    }
    
//    //my GraphModel!
//    var physPoints = [Double:Double?]() //{ didSet { graphView.setNeedsDisplay() } }
//    var changeX: CGFloat = 0
// //   var point: CGFloat { return graphView.pointsPerUnit }
//    func addPhysPoints (pointPerUnit: CGFloat, changeX: CGFloat) {
//        
//        for var x = -(100 + Double(changeX)) / Double(pointPerUnit); x <= (100 + Double(changeX)) / Double(pointPerUnit); x += 1 / Double(pointPerUnit) {
//            if physPoints[x] == nil {
//            brain.variableValues["M"] = x
//            var y = brain.evaluate()
//            physPoints[x] = y
//            }
//        }
//    }
//
//    
//    func fillPhysPoints (pointPerUnit: CGFloat) {
//        
//        for var x = -(100) / Double(pointPerUnit); x <= (100) / Double(pointPerUnit); x += 1 / Double(pointPerUnit) {
//            brain.variableValues["M"] = x
//            var y = brain.evaluate()
//            physPoints[x] = y
//        }
//    }
    
//    func comparePoints (sender: GraphView, originPoint: CGPoint, weightBounds:CGFloat, pointPerUnit: CGFloat) -> [CGPoint] {
//        var graphOnPoint = [CGPoint]()
//            for valueX in physPoints.keys {
//              var x = CGFloat(valueX) * pointPerUnit + originPoint.x
//                if let valueY = physPoints[valueX] {
//                    if let valueY2 = valueY {
//                var y: CGFloat = pointPerUnit * (-1) * CGFloat(valueY2) + originPoint.y
//                graphOnPoint.append(CGPoint(x: x, y: y))
//                    }
//                } else {
//                    break
//                }
//        }
//        return graphOnPoint
//
//    }
//    
    
    func fillStackPoints (_ sender: GraphView, originPoint: CGPoint, widthBounds:CGFloat, heightBounds:CGFloat, pointPerUnit: CGFloat) -> [CGPoint] {
       
        var graphOnPoint = [CGPoint]()
        
        //for x in 0...Int(weightBounds) {
        let oldMValue = brain.variableValues["M"]
        for x in stride(from: CGFloat(0), through: CGFloat(widthBounds), by: 1 / graphView.contentScaleFactorView) {
            let xRound = round(x * graphView.contentScaleFactorView) / graphView.contentScaleFactorView
            let valueX = (xRound - originPoint.x) / pointPerUnit
            brain.variableValues["M"] = Double(valueX)
            var y: CGFloat
            if let valueY = brain.evaluateForGraph() {
                y = round ((pointPerUnit * (-1) * CGFloat(valueY) + originPoint.y) * graphView.contentScaleFactorView) / graphView.contentScaleFactorView
                //println("x = \(xRound) and \(originPoint.x); y = \(y) and \(originPoint.y)")
                graphOnPoint.append(CGPoint(x: xRound, y: y))
                }  else {
                break
            }
        brain.variableValues["M"] = oldMValue
        _ = brain.evaluateForGraph()
            }
        return graphOnPoint
}
    
//    func fillStackPoints (sender: GraphView, originPoint: CGPoint, weightBounds:CGFloat, pointPerUnit: CGFloat) -> [CGPoint] {
//        
//        var graphOnPoint = [CGPoint]()
//        
//        for x in stride(from: 0, through: CGFloat(weightBounds), by: 1 / graphView.contentScaleFactorView) {
//            let xRound = round(x * graphView.contentScaleFactorView) / graphView.contentScaleFactorView
//            let valueX = (xRound - originPoint.x) / pointPerUnit
//            var y: CGFloat
//            let valueY = valueX
//                y = round ((pointPerUnit * (-1) * CGFloat(valueY) + originPoint.y) * graphView.contentScaleFactorView) / graphView.contentScaleFactorView
//                //println("x = \(xRound) and \(originPoint.x); y = \(y) and \(originPoint.y)")
//                graphOnPoint.append(CGPoint(x: xRound, y: y))
//
//        }
//        return graphOnPoint
//    }
}
