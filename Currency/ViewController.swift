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
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(
            self,selector: #selector(keyboardWillShowForResizing),
            name:NSNotification.Name.UIKeyboardDidShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillHideForResizing),name:NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        // create currency dictionary
        self.baseTextField.keyboardType = UIKeyboardType.decimalPad
        self.createCurrencyDictionary()
        
        // get latest currency values
        getConvertionRates()
        
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
        
        self.addDoneButtonOnKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @discardableResult
    func customActivityIndicatory(_ viewContainer: UIView, startAnimate:Bool? = true) -> UIActivityIndicatorView {
        let mainContainer: UIView = UIView(frame: viewContainer.frame)
        mainContainer.center = viewContainer.center
        mainContainer.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        mainContainer.alpha = 0.1
        mainContainer.tag = 789456123
        mainContainer.isUserInteractionEnabled = false
        
        let viewBackgroundLoading: UIView = UIView(frame: CGRect(x:0,y: 0,width: 80,height: 80))
        viewBackgroundLoading.center = viewContainer.center
        viewBackgroundLoading.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        viewBackgroundLoading.alpha = 0.8
        viewBackgroundLoading.clipsToBounds = true
        viewBackgroundLoading.layer.cornerRadius = 15
        
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x:0.0,y: 0.0,width: 40.0, height: 40.0)
        activityIndicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorView.center = CGPoint(x: viewBackgroundLoading.frame.size.width / 2, y: viewBackgroundLoading.frame.size.height / 2)
        if startAnimate!{
            viewBackgroundLoading.addSubview(activityIndicatorView)
            mainContainer.addSubview(viewBackgroundLoading)
            viewContainer.addSubview(mainContainer)
            activityIndicatorView.startAnimating()
        }else{
            for subview in viewContainer.subviews{
                if subview.tag == 789456123{
                    subview.removeFromSuperview()
                }
            }
        }
        return activityIndicatorView
    }
    
    
    @objc
    func keyboardWillShowForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
            self.baseTextField.text = ""
        }
    }
    
    @objc
    func keyboardWillHideForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        }
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.baseTextField.inputAccessoryView = doneToolbar
    }
    
    @objc
    func doneButtonAction() {
        self.baseTextField.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createCurrencyDictionary() {
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
        customActivityIndicatory(self.view, startAnimate: true)
        //getConversionTable()
        getConvertionRates()
        customActivityIndicatory(self.view, startAnimate: false)
    }
    
    func getConvertionRates() {
        let endpoint: String = "https://api.fixer.io/latest"
        guard let url = URL(string: endpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("Error calling GET on " + endpoint)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let responseObject = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON")
                    return
                }
                
                // get rates
                guard let rates = responseObject["rates"] as? [String: AnyObject] else {
                    print("Could not get todo title from JSON")
                    return
                }
                for rate in rates{
                    //print("#####")
                    let name = String(describing: rate.key)
                    print(name)
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
                        print()
                    }
                    
                    /*
                     let c:Currency = Currency(name: name, rate: rate!, flag: flag, symbol: symbol)!
                     self.currencyDict[name] = c
                     */
                }
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            DispatchQueue.main.async {
                self.lastUpdatedDate = Date()
                self.lastUpdatedDateLabel.text = self.dateformatter.string(from: self.lastUpdatedDate)
                self.baseTextField.text = "1"
                self.convert(self)
            }
            
        }
        
        task.resume()
        
        
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

