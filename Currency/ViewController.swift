//
//  ViewController.swift
//  Currency
//
//  Created by Robert O'Connor on 18/10/2017.
//  Copyright © 2017 WIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK Model holders
    var currencyDict:Dictionary = [String:Currency]()
    var currencyArray = [Currency]()
    var baseCurrency:Currency = Currency.init(name:"EUR", rate:1, flag:"🇪🇺", symbol:"€")!
    var lastUpdatedDate:Date = Date()
    
    var convertValue:Double = 0
    
    let dateformatter = DateFormatter()
    
    @IBOutlet var symbolLabelCollection: [UILabel]!
    @IBOutlet var valueLabelCollection: [UILabel]!
    @IBOutlet var flagLabelCollection: [UILabel]!
    
    @IBOutlet weak var baseSymbol: UILabel!
    @IBOutlet weak var baseTextField: UITextField!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topScrollView: UIScrollView!
    
    var data: [String] = [String]()
    @IBOutlet weak var basePicker: UIPickerView!
    var baseMultiplier: Double = 1.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = ["🇪🇺","🇬🇧","🇺🇸","🇵🇱","🇦🇺","🇨🇦","🇨🇭","🇹🇷","🇳🇴"]
        self.basePicker.delegate = self
        self.basePicker.dataSource = self
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    // The data to return for the row and component (column), that's being  passed in .
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    
    // Catpure the picker view selection. At the moment that he/ she selects something, then it's passed to this func
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeCurrencyBase()
    }
    
    func changeCurrencyBase() {
        let row = self.basePicker.selectedRow(inComponent: 0)
        self.baseCurrency = self.currencyArray[row]
        self.baseMultiplier = 1.00 / baseCurrency.rate
        self.baseSymbol.text = self.baseCurrency.symbol
        let convertValue = Double(self.baseTextField.text!)
        for i in 0 ..< flagLabelCollection.count {
            if row > i {
                symbolLabelCollection[i].text = currencyArray[i].symbol
                valueLabelCollection[i].text = String(format: "%.02f",currencyArray[i].rate * baseMultiplier * convertValue!)
                flagLabelCollection[i].text = currencyArray[i].flag
            } else {
                symbolLabelCollection[i].text = currencyArray[i+1].symbol
                valueLabelCollection[i].text = String(format: "%.02f",currencyArray[i+1].rate * baseMultiplier * convertValue!)
                flagLabelCollection[i].text = currencyArray[i+1].flag
            }
        }
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
    }
    
    func createCurrencyDictionary() {
        let currency1: Currency = Currency(name:"EUR", rate:1, flag:"🇪🇺", symbol:"€")!
        currencyArray.append(currency1)
        let currency2: Currency = Currency(name:"GBP", rate:1, flag:"🇬🇧", symbol: "£")!
        currencyArray.append(currency2)
        let currency3: Currency = Currency(name:"USD", rate:1, flag:"🇺🇸", symbol: "$")!
        currencyArray.append(currency3)
        let currency4: Currency = Currency(name:"PLN", rate:1, flag:"🇵🇱", symbol: "zł")!
        currencyArray.append(currency4)
        let currency5: Currency = Currency(name:"AUD", rate:1, flag:"🇦🇺", symbol: "A$")!
        currencyArray.append(currency5)
        let currency6: Currency = Currency(name:"CAD", rate:1, flag:"🇨🇦", symbol: "C$")!
        currencyArray.append(currency6)
        let currency7: Currency = Currency(name:"CHF", rate:1, flag:"🇨🇭", symbol: "CHf")!
        currencyArray.append(currency7)
        let currency8: Currency = Currency(name:"TRY", rate:1, flag:"🇹🇷", symbol: "₺")!
        currencyArray.append(currency8)
        let currency9: Currency = Currency(name:"NOK", rate:1, flag:"🇳🇴", symbol: "kr")!
        currencyArray.append(currency9)
    }
    
    func displayCurrencyInfo() {
        for i in 1 ..< currencyArray.count {
            symbolLabelCollection[i-1].text = currencyArray[i].symbol
            valueLabelCollection[i-1].text = String(format: "%.02f",currencyArray[i].rate)
            flagLabelCollection[i-1].text = currencyArray[i].flag
        }
    }
    
    
    @IBAction func refreshCurrencies(_ sender: UIButton) {
        self.baseTextField.text = "1"
        self.basePicker.selectRow(0, inComponent: 0, animated: false)
        changeCurrencyBase()
        customActivityIndicatory(self.view, startAnimate: true)
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
            // parse the result as JSON
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
                    let name = String(describing: rate.key)
                    let rate = (rate.value as? NSNumber)?.doubleValue
                    
                    for i in 1 ..< self.currencyArray.count {
                        if self.currencyArray[i].name == name {
                            self.currencyArray[i].rate = rate!
                            DispatchQueue.main.async {
                                let euro = Double(self.baseTextField.text!)
                                let result: Double = euro! * self.currencyArray[i].rate
                                
                                self.valueLabelCollection[i-1].text = String(format: "%.02f", result)
                            }
                        }
                    }
                }
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            DispatchQueue.main.async {
                self.lastUpdatedDate = Date()
                self.lastUpdatedDateLabel.text = self.dateformatter.string(from: self.lastUpdatedDate)
            }
            
        }
        task.resume()
    }
    
    @IBAction func convert(_ sender: Any) {
        for i in 0 ..< self.valueLabelCollection.count {
            let selectedRow = self.basePicker.selectedRow(inComponent: 0)
            var convertValue = Double(self.baseTextField.text!)
            if self.baseTextField.text == "" {
                convertValue = 1;
                self.baseTextField.text = "1"
            }
            if selectedRow > i {
                let result: Double = convertValue! * self.currencyArray[i].rate * baseMultiplier
                self.valueLabelCollection[i].text = String(format: "%.02f", result)
            } else {
                let result: Double = convertValue! * self.currencyArray[i + 1].rate * baseMultiplier
                self.valueLabelCollection[i].text = String(format: "%.02f", result)
            }
        }
    }
}

