//
//  ViewController.swift
//  Currency
//
//  Created by Robert O'Connor on 18/10/2017.
//  Copyright © 2017 WIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK Model holders
    var currencyDict:Dictionary = [String:Currency]()
    var currencyArray = [Currency]()
    var baseCurrency:Currency = Currency.init(name:"EUR", rate:1, flag:"🇪🇺", symbol:"€")!
    var lastUpdatedDate:Date = Date()
    
    var convertValue:Double = 0
    
    let dateformatter = DateFormatter()
    
    //MARK Outlets
    //@IBOutlet weak var convertedLabel: UILabel!
    
    @IBOutlet weak var baseSymbol: UILabel!
    @IBOutlet weak var baseTextField: UITextField!
    @IBOutlet weak var baseFlag: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    
    @IBOutlet weak var gbpSymbolLabel: UILabel!
    @IBOutlet weak var gbpValueLabel: UILabel!
    @IBOutlet weak var gbpFlagLabel: UILabel!
    
    @IBOutlet weak var usdSymbolLabel: UILabel!
    @IBOutlet weak var usdValueLabel: UILabel!
    @IBOutlet weak var usdFlagLabel: UILabel!
    
    @IBOutlet weak var plnSymbolLabel: UILabel!
    @IBOutlet weak var plnValueLabel: UILabel!
    @IBOutlet weak var plnFlagLabel: UILabel!
    
    @IBOutlet weak var audSymbolLabel: UILabel!
    @IBOutlet weak var audValueLabel: UILabel!
    @IBOutlet weak var audFlagLabel: UILabel!
    
    @IBOutlet weak var cadSymbolLabel: UILabel!
    @IBOutlet weak var cadValueLabel: UILabel!
    @IBOutlet weak var cadFlagLabel: UILabel!
    
    @IBOutlet weak var chfSymbolLabel: UILabel!
    @IBOutlet weak var chfValueLabel: UILabel!
    @IBOutlet weak var chfFlagLabel: UILabel!
    
    @IBOutlet weak var trySymbolLabel: UILabel!
    @IBOutlet weak var tryValueLabel: UILabel!
    @IBOutlet weak var tryFlagLabel: UILabel!
    
    @IBOutlet weak var nokSymbolLabel: UILabel!
    @IBOutlet weak var nokValueLabel: UILabel!
    @IBOutlet weak var nokFlagLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // print("currencyDict has \(self.currencyDict.count) entries")
        
        // create currency dictionary
        self.baseTextField.keyboardType = UIKeyboardType.decimalPad
        self.createCurrencyDictionary()
        
        // get latest currency values
        getConversionTable()
        convertValue = 1
        
        // set up base currency screen items
        baseTextField.text = String(format: "%.02f", baseCurrency.rate)
        baseSymbol.text = baseCurrency.symbol
        baseFlag.text = baseCurrency.flag
        
        // set up last updated date
        dateformatter.dateFormat = "dd/MM/yyyy hh:mm a"
        lastUpdatedDateLabel.text = self.dateformatter.string(from: lastUpdatedDate)
        
        // display currency info
        self.displayCurrencyInfo()
        
        
        // setup view mover
        baseTextField.delegate = self
        
        self.convert(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createCurrencyDictionary(){
        //let c:Currency = Currency(name: name, rate: rate!, flag: flag, symbol: symbol)!
        //self.currencyDict[name] = c
        currencyDict["GBP"] = Currency(name:"GBP", rate:1, flag:"🇬🇧", symbol: "£")
        currencyDict["USD"] = Currency(name:"USD", rate:1, flag:"🇺🇸", symbol: "$")
        currencyDict["PLN"] = Currency(name:"PLN", rate:1, flag:"🇵🇱", symbol: "zł")
        currencyDict["AUD"] = Currency(name:"AUD", rate:1, flag:"🇦🇺", symbol: "A$")
        currencyDict["CAD"] = Currency(name:"CAD", rate:1, flag:"🇨🇦", symbol: "C$")
        currencyDict["CHF"] = Currency(name:"CHF", rate:1, flag:"🇨🇭", symbol: "CHf")
        currencyDict["TRY"] = Currency(name:"TRY", rate:1, flag:"🇹🇷", symbol: "₺")
        currencyDict["NOK"] = Currency(name:"NOK", rate:1, flag:"🇳🇴", symbol: "kr")
    }
    
    func displayCurrencyInfo() {
        // GBP
        if let c = currencyDict["GBP"]{
            gbpSymbolLabel.text = c.symbol
            gbpValueLabel.text = String(format: "%.02f", c.rate)
            gbpFlagLabel.text = c.flag
        }
        if let c = currencyDict["USD"]{
            usdSymbolLabel.text = c.symbol
            usdValueLabel.text = String(format: "%.02f", c.rate)
            usdFlagLabel.text = c.flag
        }
        if let c = currencyDict["PLN"]{
            plnSymbolLabel.text = c.symbol
            plnValueLabel.text = String(format: "%.02f", c.rate)
            plnFlagLabel.text = c.flag
        }
        if let c = currencyDict["AUD"]{
            audSymbolLabel.text = c.symbol
            audValueLabel.text = String(format: "%.02f", c.rate)
            audFlagLabel.text = c.flag
        }
        if let c = currencyDict["CAD"]{
            cadSymbolLabel.text = c.symbol
            cadValueLabel.text = String(format: "%.02f", c.rate)
            cadFlagLabel.text = c.flag
        }
        if let c = currencyDict["CHF"]{
            chfSymbolLabel.text = c.symbol
            chfValueLabel.text = String(format: "%.02f", c.rate)
            chfFlagLabel.text = c.flag
        }
        if let c = currencyDict["TRY"]{
            trySymbolLabel.text = c.symbol
            tryValueLabel.text = String(format: "%.02f", c.rate)
            tryFlagLabel.text = c.flag
        }
        if let c = currencyDict["NOK"]{
            nokSymbolLabel.text = c.symbol
            nokValueLabel.text = String(format: "%.02f", c.rate)
            nokFlagLabel.text = c.flag
        }
    }
    
    
    @IBAction func refreshCurrencies(_ sender: UIButton) {
        print("updated")
        getConversionTable()
    }
    
    
    func getConversionTable() {
        //var result = "<NOTHING>"
        
        let urlStr:String = "https://api.fixer.io/latest"
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.httpMethod = "GET"
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { response, data, error in
            
            indicator.stopAnimating()
            
            if error == nil{
                print(response!)
                
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                    print(jsonDict)
                    
                    if let ratesData = jsonDict["rates"] as? NSDictionary {
                        //print(ratesData)
                        for rate in ratesData{
                            //print("#####")
                            let name = String(describing: rate.key)
                            let rate = (rate.value as? NSNumber)?.doubleValue
                            //var symbol:String
                            //var flag:String
                            
                            switch(name){
                            case "USD":
                                let c:Currency  = self.currencyDict["USD"]!
                                c.rate = rate!
                                self.currencyDict["USD"] = c
                            case "GBP":
                                let c:Currency  = self.currencyDict["GBP"]!
                                c.rate = rate!
                                self.currencyDict["GBP"] = c
                            case "PLN":
                                let c:Currency  = self.currencyDict["PLN"]!
                                c.rate = rate!
                                self.currencyDict["PLN"] = c
                            case "AUD":
                                let c:Currency  = self.currencyDict["AUD"]!
                                c.rate = rate!
                                self.currencyDict["AUD"] = c
                            case "CAD":
                                let c:Currency  = self.currencyDict["CAD"]!
                                c.rate = rate!
                                self.currencyDict["CAD"] = c
                            case "CHF":
                                let c:Currency  = self.currencyDict["CHF"]!
                                c.rate = rate!
                                self.currencyDict["CHF"] = c
                            case "TRY":
                                let c:Currency  = self.currencyDict["TRY"]!
                                c.rate = rate!
                                self.currencyDict["TRY"] = c
                            case "NOK":
                                let c:Currency  = self.currencyDict["NOK"]!
                                c.rate = rate!
                                self.currencyDict["NOK"] = c
                            default:
                                print("Ignoring currency: \(String(describing: rate))")
                            }
                            
                            /*
                             let c:Currency = Currency(name: name, rate: rate!, flag: flag, symbol: symbol)!
                             self.currencyDict[name] = c
                             */
                        }
                        self.lastUpdatedDate = Date()
                        self.lastUpdatedDateLabel.text = self.dateformatter.string(from: self.lastUpdatedDate)
                    }
                }
                catch let error as NSError{
                    print(error)
                }
            }
            else{
                print("Error")
            }
            
        }
        
    }
    
    @IBAction func convert(_ sender: Any) {
        var resultGBP = 0.0
        var resultUSD = 0.0
        var resultPLN = 0.0
        var resultAUD = 0.0
        var resultCAD = 0.0
        var resultCHF = 0.0
        var resultTRY = 0.0
        var resultNOK = 0.0
        
        if let euro = Double(baseTextField.text!) {
            convertValue = euro
            if let gbp = self.currencyDict["GBP"] {
                resultGBP = convertValue * gbp.rate
            }
            if let usd = self.currencyDict["USD"] {
                resultUSD = convertValue * usd.rate
            }
            if let pln = self.currencyDict["PLN"] {
                resultPLN = convertValue * pln.rate
            }
            if let aud = self.currencyDict["AUD"] {
                resultAUD = convertValue * aud.rate
            }
            if let cad = self.currencyDict["CAD"] {
                resultCAD = convertValue * cad.rate
            }
            if let chf = self.currencyDict["CHF"] {
                resultCHF = convertValue * chf.rate
            }
            if let trY = self.currencyDict["TRY"] {
                resultTRY = convertValue * trY.rate
            }
            if let nok = self.currencyDict["NOK"] {
                resultNOK = convertValue * nok.rate
            }
        }
        //GBP
        
        //convertedLabel.text = String(describing: resultGBP)
        
        gbpValueLabel.text = String(format: "%.02f", resultGBP)
        usdValueLabel.text = String(format: "%.02f", resultUSD)
        plnValueLabel.text = String(format: "%.02f", resultPLN)
        audValueLabel.text = String(format: "%.02f", resultAUD)
        cadValueLabel.text = String(format: "%.02f", resultCAD)
        chfValueLabel.text = String(format: "%.02f", resultCHF)
        tryValueLabel.text = String(format: "%.02f", resultTRY)
        nokValueLabel.text = String(format: "%.02f", resultNOK)

    }
    
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     
     }
     */
    
    
}

