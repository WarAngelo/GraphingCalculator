//
//  GraphView.swift
//  GraphingCalculator
//
//  Created by Андрей Рыжов on 21.07.15.
//  Copyright (c) 2015 Lazy Team. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func fillStackPoints(_ sender: GraphView, originPoint: CGPoint, widthBounds:CGFloat, heightBounds:CGFloat, pointPerUnit: CGFloat) -> [CGPoint]
}

protocol GraphViewStoredValue: class {
    func fillStoredValue(_ sender: GraphView, originPoint: CGPoint, pointPerUnit:CGFloat)
    func getStoredValue(_ sender: GraphView) -> [CGFloat]
}

@IBDesignable
class GraphView: UIView {

    //var axes = AxesDrawer()
    var lineWidth: CGFloat = 2 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var pointsPerUnit: CGFloat = 50 { didSet {
       // if pointsPerUnit != 50 {
        //if let storedValue = dataStoredValue?.getStoredValue(self) {
        //if storedValue != [0,0,0] {
         //   println("storedValue = \(storedValue)")
            dataStoredValue?.fillStoredValue(self, originPoint: originPoint, pointPerUnit: pointsPerUnit)
      //  storedValue = [Double(changePoint.x), Double(changePoint.y), Double(pointsPerUnit)]
            setNeedsDisplay()
            } }// } //}
    var widthView: CGFloat { return bounds.size.width }
    var heightView: CGFloat { return bounds.size.height }
    var changePoint = CGPoint(x: 0, y: 0) {
        didSet {
            changePoint.x = round(changePoint.x * contentScaleFactorView) / contentScaleFactorView
            changePoint.y = round(changePoint.y * contentScaleFactorView) / contentScaleFactorView
        }
    }
    var contentScaleFactorView: CGFloat = 1.0
    
//    private let defaults = NSUserDefaults.standardUserDefaults()
//    var storedValue: [Double] {
//        get { return defaults.objectForKey("origin, scale") as? [Double] ?? [] }
//        set { defaults.setObject(newValue, forKey: "origin, scale")
//        println("set storedValue = \(storedValue)")
//        }
//    }
    weak var dataStoredValue: GraphViewStoredValue?
    
    var originPoint: CGPoint {
        get {
            if changePoint == CGPoint(x: 0, y: 0) {
                return convert(center, from: superview)
            } else { return changePoint }
        }
        set {
            changePoint = newValue
       //     storedValue = [Double(newValue.x), Double(newValue.y), Double(pointsPerUnit)]
            //print("changed originPoint = \(changePoint)")
           // if let storedValue = dataStoredValue?.getStoredValue(self) {
             //   println("storedValue = \(storedValue)")
               // if storedValue == [0,0,0] {
                    dataStoredValue?.fillStoredValue(self, originPoint: originPoint, pointPerUnit: pointsPerUnit)
             //   }
            //}
        }
    }
    
    func changeOrigin(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
                    case .ended: fallthrough
                    case .changed:
                        let translation = gesture.translation(in: self)
                        //println("\(translation)")
                        if translation != CGPoint (x: 0, y: 0) {
                            originPoint.x = round((originPoint.x + translation.x) * contentScaleFactorView) / contentScaleFactorView
                            originPoint.y = round((originPoint.y + translation.y) * contentScaleFactorView) / contentScaleFactorView
                           // println("x = \(originPoint.x); y = \(originPoint.y)")
                            setNeedsDisplay()
                            gesture.setTranslation(CGPoint.zero, in: self)
                        }
                    default: break
                    }
        }

    func printTimestamp() {
        //let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .NoStyle, timeStyle: .MediumStyle)
       // println(timestamp)
    }
    
    override func draw(_ rect: CGRect) {
        contentScaleFactorView = contentScaleFactor//contentScaleFactor = 1.0
     //   println("contentScaleFactor = \(contentScaleFactor); widthView = \(widthView)")
        let graphBounds = CGRect(x: 0, y: 0, width: widthView, height: heightView)
        let axes = AxesDrawer(color: UIColor.red, contentScaleFactor: contentScaleFactor)
        printTimestamp()
        axes.drawAxesInRect(graphBounds, origin: originPoint, pointsPerUnit: pointsPerUnit)
     //   printTimestamp()
        let graphOnPoints = dataSource?.fillStackPoints(self, originPoint: originPoint, widthBounds: widthView, heightBounds: heightView, pointPerUnit: pointsPerUnit)
       // printTimestamp()
      //  println("\(graphOnPoints?.count)")
        bezierPathForGraph(graphOnPoints)
        printTimestamp()
    }

    weak var dataSource: GraphViewDataSource?
    
   // var graphOnPoint = [CGPoint]()
    
    fileprivate func bezierPathForGraph(_ graphOnPoints: [CGPoint]?) {
        let path = UIBezierPath()
        var array = graphOnPoints
        if array != nil {
        //for (index, point) in (array!).enumerate() {
        for (index, _) in (array!).enumerated() {
        if (array![min(index, array!.count - 1)].y).isInfinite || (array![min(index, array!.count - 1)].y).isNaN {
            continue
        } else {
        path.move(to: array![min(index, array!.count - 1)])
//            if /*(array![index].y <= CGFloat(-1100) || array![index].y == -(CGFloat.infinity)) && */array![min(index+1, array!.count - 1)].y == CGFloat.infinity /*|| array![min(index+1, array!.count - 1)].y >= CGFloat(1100)*/ {
//                //array![min(index+1, array!.count - 1)].y = CGFloat(10000)
//                println("will delete \(array![min(index+1, array!.count - 1)].y)")
//                array!.removeAtIndex(min(index+1, array!.count - 1))
//                println("now \(array![min(index+1, array!.count - 1)].y)")
//                continue
//                //path.moveToPoint(array![min(index+1, array!.count - 1)])
//            }
            if abs(array![min(index, array!.count - 1)].y - array![min(index+1, array!.count - 1)].y) > 4000 {
                //array![min(index, array!.count - 1)].y = CGFloat.infinity
                array![min(index+1, array!.count - 1)].y = CGFloat.infinity
                //path.addLineToPoint(array![min(index, array!.count - 1)])
                //continue
            }
            if /*(array![index].y >= CGFloat(1100) || array![index].y == CGFloat.infinity) && array![min(index+1, array!.count - 1)].y <= CGFloat(-1100) ||*/ array![min(index+1, array!.count - 1)].y == -(CGFloat.infinity) || array![min(index+1, array!.count - 1)].y == CGFloat.infinity {
                //array![min(index+1, array!.count - 1)].y = CGFloat(-10000)
               // println("will delete \(array![min(index+1, array!.count - 1)].y)")
                array!.remove(at: min(index+1, array!.count - 1))
              //  println("now \(array![min(index, array!.count - 1)].y) \(array![min(index+1, array!.count - 1)].y)")
                if array![min(index, array!.count - 1)].y - originPoint.y < 0 && array![min(index + 1, array!.count - 1)].y - originPoint.y > 0 {
                    array![min(index, array!.count - 1)].y = -100000.0
                    path.move(to: array![min(index - 1, array!.count - 1)])
                    path.addLine(to: array![min(index, array!.count - 1)])
               //     path.lineWidth = lineWidth
               //     path.stroke()
                    array![min(index + 1, array!.count - 1)].y = 100000.0
                }
                if array![min(index, array!.count - 1)].y - originPoint.y > 0 && array![min(index + 1, array!.count - 1)].y - originPoint.y < 0 {
                    array![min(index, array!.count - 1)].y = 100000.0
                    path.move(to: array![min(index - 1, array!.count - 1)])
                    path.addLine(to: array![min(index, array!.count - 1)])
                  //  path.lineWidth = lineWidth
               //     path.stroke()
                    array![min(index + 1, array!.count - 1)].y = -100000.0
                }
            //    println("now \(array![min(index, array!.count - 1)].y) \(array![min(index+1, array!.count - 1)].y)")
                continue
                //path.moveToPoint(array![min(index+1, array!.count - 1)])
            }
            
            if (array![min(index+1, array!.count - 1)].y).isNaN {
           //     println("will delete \(array![min(index+1, array!.count - 1)].y)")
                array!.remove(at: min(index+1, array!.count - 1))
            //    println("now \(array![min(index+1, array!.count - 1)].y)")
                continue
                //path.moveToPoint(array![min(index+1, array!.count - 1)])
            }
        }
        path.addLine(to: array![min(index+1, array!.count - 1)])
          //  printTimestamp()
        }
        path.lineWidth = lineWidth
        path.stroke()
          //  printTimestamp()
        }}
}
