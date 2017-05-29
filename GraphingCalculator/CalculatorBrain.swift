//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Андрей Рыжов on 19.05.15.
//  Copyright (c) 2015 Lazy Team. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    fileprivate enum Op: CustomStringConvertible //протокол, который запускается при свойстве дескриптион
    {
        case operand(Double)
        case unaryOperation(String, (Double) -> Double)
        case binaryOperation(String, (Double, Double) -> Double)
        case constant(String, () -> Double) //для пи
        case mUnaryOperand (String, Double?)
        
        //enum, structs, classes имеют свойства - значения(values)
        var description: String { // нам нужно перевести в стринг
            get {
                switch  self { //switch op
                case .operand(let operand):
                    return "\(operand)"
                case .unaryOperation(let symbol, _):
                    return symbol
                case .binaryOperation(let symbol, _):
                    return symbol
                case .constant(let symbolConstant, _):
                    return symbolConstant
                case .mUnaryOperand(let symbol, _):
                    return symbol
                }
            }
         }
    }
    
    //Array and Dictionary, double, int - это structs. Структуры отличаются от классов: 1) классы могут наследоваться, а структуры нет; 2) структуры передаются по значению, а классы по ссылке
//    var opStack = Array<Op>()
    fileprivate var opStack = [Op]() {
        didSet {
            stackHistory = program
        }
    }
    
//    var knownOps = Dictionary<String, Op>()
    fileprivate var knownOps = [String:Op]()
    
    init(){
        func learnOp(_ op: Op){
            knownOps[op.description] = op
        }
//        knownOps["×"] = Op.BinaryOperation("×", { $0 * $1 })
//        knownOps["×"] = Op.BinaryOperation("×") { $0 * $1 }
//        knownOps["×"] = Op.BinaryOperation("×", *)
        learnOp(Op.binaryOperation("×", *))

        knownOps["÷"] = Op.binaryOperation("÷") { $1 / $0 }
//        knownOps["+"] = Op.BinaryOperation("+", +)
        learnOp(Op.binaryOperation("+", +))
//        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
        learnOp(Op.binaryOperation("−", { $1 - $0 }))
//        knownOps["√"] = Op.UnaryOperation("√") { sqrt($0) }
        knownOps["√"] = Op.unaryOperation("√", sqrt)
        knownOps["sin"] = Op.unaryOperation("sin", sin)
        knownOps["cos"] = Op.unaryOperation("cos", cos)
        knownOps["tan"] = Op.unaryOperation("tan", tan)
        knownOps["ln"] = Op.unaryOperation("ln", log)
        learnOp(Op.constant("π", { .pi })) //swift 3
        learnOp(Op.constant("e", { M_E }))
        
        program = stackHistory
    }
    
    typealias ProperyList = AnyObject
    var program: ProperyList { //guaranted to be a PropertyList
        get {
//            return opStack.map { $0.description } //записываем в наши данные в виде Array<String>, которые станут эниобжектом, new Swift 3:
            var returnValue = Array<String>() //Array bridged to NSArray - поэтому это пропети лист
            for op in opStack {
                returnValue.append(op.description)
            }
            return returnValue as CalculatorBrain.ProperyList
        }
        set { //читаем из данных
            if let opSymbols = newValue as? Array<String>{
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol]{
                        newOpStack.append(op)
                    //} else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                    } else if let operand = Double(opSymbol) {
                        newOpStack.append(.operand(operand))
                    }
                    if opSymbol == "M" {
                        let op = variableValues["M"]
                        newOpStack.append(.mUnaryOperand (opSymbol, op))
                    }
//
                }
                opStack = newOpStack
            }
        }
    }
    fileprivate let defaults = UserDefaults.standard // shared version (целое приложение будет обмениваться этим)
    var stackHistory: ProperyList {
        get { return defaults.object(forKey: History.DefaultsKey) as? [String] as? CalculatorBrain.ProperyList ?? [] as CalculatorBrain.ProperyList} //если по этому адресу достанет массив стрингов, то все ок возвращаем, нет, вернем пустой массив
        set { defaults.set(newValue, forKey: History.DefaultsKey) } //записываем в данные
    }
    
    fileprivate struct History { //если что-то меняем в стори борде, то легко дебажить в коде здесь
        static let DefaultsKey = "MainStorage.History" //мы этого можем не делать (можем завести любой ключ fjdsk), но так как этим пользуется все приложение, то лучше делать граматно
    }
    
    var descriptionForM = false
    fileprivate var descriptionForEqual = false // для равно на конце в хистори буке
    // вычисляем стек рекурсивно, поэтому возвращаем тупл из двух значений: то значение которое достали и оставшийся стек
    fileprivate func evaluate(_ ops: [Op]) -> (result: Double?, remainingOps: [Op]) // 1) происходит копирование Array, когда мы передаем аргумент внутри функции 2) неявный let перед ops, поэтому мы ставим var. И получаем mutable copy для работы внутри функции. Но это не очень хорошо и мы создадим переменную внутри функции и присвоем ей опс.
    {
        if !ops.isEmpty { //если стек не пустой
            var remainingOps = ops
            let op = remainingOps.removeLast() //удаляем верхний элемент из стека
            switch op {
            case .operand(let operand): // let operand - это значение дабл внутри Операнда
                descriptionForEqual = false
                return (operand, remainingOps)
            case .unaryOperation(_, let operation): //нашли корень ощипываем следующее значение в стеке и возвращаем; _ не важно
                //рекурсия
                let operandEvaluation = evaluate(remainingOps) //отщипываем еще значение (2 элемент из стека)
                descriptionForEqual = true
                if let operand = operandEvaluation.result { //избавляемся от Double?
                return (operation(operand), operandEvaluation.remainingOps)
                }
            case .binaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                descriptionForEqual = true
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    descriptionForEqual = true
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .constant(_, let constant):
                descriptionForEqual = false
                return (constant(), remainingOps)
            case .mUnaryOperand(let symbol, var constantM):
                if let checkDictionary = variableValues[symbol] {
                    constantM = checkDictionary
                    descriptionForM = false
                }
                descriptionForEqual = false
                if constantM == nil { //срабатывает, только когда значение не занесено, а пустое
                    descriptionForM = true //зануляю только когда нажимаю кнопку С и нажимаю ->M
                }
                return (constantM, remainingOps)
            }
        }
        return (nil, ops) // защита, чтобы программа не вылетала
    }
    //вычисляет значения в стеке - double опшионал: если у нас в стеке одно числа и мы умножаем, то нам надо вернуть нил. если 2, то умножить
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)  //прогоняем рекурсию, получаем тупл, из него достаем резалт
//        let qos = Int(QOS_CLASS_USER_INTERACTIVE.value)
//        dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
        print("\(opStack) = \(String(describing: result)) with \(remainder) left over")
//        }
        return result
    }
    
    func evaluateForGraph() -> Double? {
        //let (result, remainder) = evaluate(opStack)  //прогоняем рекурсию, получаем тупл, из него достаем резалт
        let (result, _) = evaluate(opStack)  //прогоняем рекурсию, получаем тупл, из него достаем резалт
        return result
    }
    
    fileprivate func evaluateForDescription(_ ops: [Op]) -> (result: Double?, remainingOps: [Op], resultString: String)     {
        if !ops.isEmpty { //если стек не пустой
            var remainingOps = ops
            let op = remainingOps.removeLast() //удаляем верхний элемент из стека
            switch op {
            case .operand(let operand): // let operand - это значение дабл внутри Операнда
                let resultDescription = "\(operand)"
                return (operand, remainingOps, resultDescription)
            case .unaryOperation(let symbols, let operation): //нашли корень ощипываем следующее значение в стеке и возвращаем; _ не важно
                //рекурсия
                let operandEvaluation = evaluateForDescription(remainingOps) //отщипываем еще значение (2 элемент из стека)
                let operand = operandEvaluation.result
                if (operand != nil) || (operand == nil && descriptionForM == true) { //избавляемся от Double?
                    let resultDescription = symbols + "(" + operandEvaluation.resultString + ")"
                    let checkOperand = operand ?? Double.nan
                    return (operation(checkOperand), operandEvaluation.remainingOps, resultDescription)
                } else {
                    let resultDescription = symbols + "?"
                    return (nil, [Op](), resultDescription)
                }
            case .binaryOperation(let symbol, let operation):
                var op1Evaluation = evaluateForDescription(remainingOps)
                let operand1 = op1Evaluation.result //переводим нил в дабл нан
                if ((operand1 != nil) || (operand1 == nil && descriptionForM == true)) {
                    let operand1 = op1Evaluation.result ?? Double.nan
                //if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluateForDescription(op1Evaluation.remainingOps)
                    let operand2 = op2Evaluation.result
                    if ((operand2 != nil) || (operand2 == nil && descriptionForM == true)) && (!op1Evaluation.remainingOps.isEmpty){
                        let operand2 = op2Evaluation.result ?? Double.nan
                        //очень сложная конструкция, чтобы ставить правильно скобочки в хистори дисплеи
                        let resultDescription = op2Evaluation.resultString + symbol + op1Evaluation.resultString
                        if symbol == "×" || symbol == "÷" {
                            let op1ops = remainingOps.removeLast()
                            switch op1ops {
                            case .binaryOperation(let symbols, _):
                                let op2ops = op1Evaluation.remainingOps.removeLast()
                                switch op2ops {
                                case .binaryOperation(let symbols2, _):
                                    if (symbols == "+" || symbols == "−" || symbols == "÷") && (symbols2 == "+" || symbols2 == "−"){
                                        let resultDescription =  "(" + op2Evaluation.resultString + ")" + symbol + "(" + op1Evaluation.resultString + ")"
                                        return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription) //если убрать ретерн отсюда, то он не пойдет в нижней, не заменит резалт дескриптион
                                    }
                                    if (symbols == "×") && (symbols2 == "+" || symbols2 == "−"){
                                        let resultDescription =  "(" + op2Evaluation.resultString + ")" + symbol + op1Evaluation.resultString
                                        return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription) //если убрать ретерн отсюда, то он не пойдет в нижней, не заменит резалт дескриптион
                                    }
                                    if symbols == "+" || symbols == "−" || symbols == "÷" { //чтобы учесть сложные случаи деления [3.0, 6.0, ÷, 3.0, 6.0, ÷, 3.0, 6.0, ÷, ÷, ÷]
                                        let resultDescription = op2Evaluation.resultString + symbol + "(" + op1Evaluation.resultString + ")"
                                        return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription)
                                    }
                                    return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription)
                                default:
                                    if symbols == "+" || symbols == "−" || symbols == "÷" { //простые случаи деления [3.0, 6.0, 3.0, ÷, ÷]
                                        let resultDescription = op2Evaluation.resultString + symbol + "(" + op1Evaluation.resultString + ")"
                                        return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription)
                                    }
                                    return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription)
                                }
                            default: //let op2ops = remainingOps.removeLast()
                                let op2ops = op1Evaluation.remainingOps.removeLast()
                                switch op2ops {
                                case .binaryOperation(let symbols, _):
                                    if symbols == "+" || symbols == "−" {
                                        let resultDescription = "(" + op2Evaluation.resultString + ")" + symbol + op1Evaluation.resultString
                                        return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription)
                                    }
                                    return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription)
                                default: return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription)
                                }
                            }
                        } else {
 //                       чтобы делать (3*5+5)+(4*5+5), но заодно делает (3+5)+(5+6)
                        let op1ops = remainingOps.removeLast()
                        switch op1ops {
                        case .binaryOperation(let symbols, _):
                            let op2ops = op1Evaluation.remainingOps.removeLast()
                            switch op2ops {
                            case .binaryOperation(let symbols2, _):
                                if (symbols == "+" || symbols == "−" || symbols == "÷") && (symbols2 == "+" || symbols2 == "−"){
                                    let resultDescription =  "(" + op2Evaluation.resultString + ")" + symbol + "(" + op1Evaluation.resultString + ")"
                                    return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription) //если убрать ретерн отсюда, то он не пойдет в нижней, не заменит резалт дескриптион
                                }
                            default:
                                return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription)
                            }
                        default:
                            return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription)
                            }
                            return (operation(operand1,operand2), op2Evaluation.remainingOps, resultDescription)
                        }
                    } else {
                        let resultDescription = "?" + symbol + op1Evaluation.resultString
                        return (nil, [Op](), resultDescription)
                    }
                } else {
                        let resultDescription = "?" + symbol + "?"
                        return (nil, [Op](), resultDescription)
                }
            case .constant(let symbol, let constant):
                return (constant(), remainingOps, symbol)
            case .mUnaryOperand(let symbol, var constant):
                if let checkDictionary = variableValues[symbol] {
                    constant = checkDictionary
                }
                return (constant, remainingOps, symbol)
            }
        }
        return (nil, ops, " ") // защита, чтобы программа не вылетала
    }
    
    func getResultString() -> String {
    return evaluateForDescription(opStack).resultString
    }
    
    fileprivate func recurciaForDescription (_ ops: [Op]) -> (remainingOps: [Op], resultString: String) {// для запятой
        let (_, remainder, resultString) = evaluateForDescription(ops)
        if !remainder.isEmpty {
            let evaluate = recurciaForDescription(remainder)
            let resultString = evaluate.resultString + "," + resultString
            return (remainder, resultString)
        } else {
            return (remainder, resultString)
        }
    }
    var description: String {
        get {
            //let (result, remainder, resultString) = evaluateForDescription(opStack)
            let (_, resultString) = recurciaForDescription(opStack)
            if descriptionForEqual {
                let resultStringForEquals = resultString + "="
                return resultStringForEquals
            }
            return resultString
        }
    }
    
    //положить операнд в стек// возвращаем, чтобы обновить дисплей
    func pushOperand(_ operand: Double) -> Double? {
        opStack.append(Op.operand(operand))
        return evaluate()
    }
    
    var variableValues = Dictionary<String, Double>()
    
    func pushOperand(_ symbol: String) -> Double? {
        let operand = variableValues[symbol]
            opStack.append(Op.mUnaryOperand(symbol, operand))
            return evaluate()
    }
    
    func cleanArray(){
        opStack.removeAll()
        variableValues.removeAll()
        descriptionForEqual = false
    }
    
    //положить операцию в стек
    func performOperation(_ symbol: String) -> Double? {
        // ифом избавляемся от нила в оператион
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}
