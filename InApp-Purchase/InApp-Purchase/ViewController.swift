//
//  ViewController.swift
//  InApp-Purchase
//
//  Created by Gökberk on 29.01.2021.
//

import UIKit
import StoreKit

class ViewController: UIViewController, SKProductsRequestDelegate,SKPaymentTransactionObserver, UITableViewDelegate, UITableViewDataSource {
 
    var models = [SKProduct]()
    @IBOutlet weak var view2: UIView!
    
    let tableview : UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view2.addSubview(tableview)
    
        SKPaymentQueue.default().add(self)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.frame = view.bounds
        fetchProducts()
        
        
    }

    enum Product: String, CaseIterable{
        case removeAds = "com.myapp.removeadds"
        case getCoins = "com.myapp.getcoins"
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async { [self] in
            self.models = response.products
            self.tableview.reloadData()
            
        }
        
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(Product.allCases.compactMap({ ($0.rawValue)})))
            request.delegate = self
        request.start()
        
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = models[indexPath.row]
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(product.localizedTitle) \(product.priceLocale.currencySymbol!)\(product.price)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        let payment = SKPayment(product: models[indexPath.row])
        SKPaymentQueue.default().add(payment)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach ({
            switch $0.transactionState {
            
            case .purchasing:
                print("purchasing")
            case .purchased:
                print("purchased")
                
                SKPaymentQueue.default().finishTransaction($0)
            case .failed:
                print("failed")
                SKPaymentQueue.default().finishTransaction($0)
            case .restored:
                break
            case .deferred:
                break
            @unknown default:
                break
            }
        })
    }
}

