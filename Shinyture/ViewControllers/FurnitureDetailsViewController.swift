///// Copyright (c) 2017 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import PassKit

class FurnitureDetailsViewController: UIViewController {
  var furnitureItem: Furniture?
  
  private lazy var paymentManager = PaymentManager()
  
  @IBOutlet var furnitureImageView: FurnitureImageView!
  @IBOutlet private var furnitureShippingLabel: UILabel!
  @IBOutlet private var furniturePriceLabel: UILabel!
  @IBOutlet private var furnitureDescriptionLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    showFurnitureDetails()
    addPaymentButtons()
  }
  
  @objc func payPressed() {
    paymentManager.pay(forFurnitureItem: furnitureItem) { (success) in
      
      if success {
        self.performSegue(withIdentifier: "show.paymentconfirmation.view", sender: nil)
      }
      
    }
  }
  
  @objc func setupPressed() {
    
  }
  
  private func showFurnitureDetails() {
    if let furniture = furnitureItem {
      
      if let furnitureImage = furniture.coverImageName {
        furnitureImageView.image = UIImage(named: furnitureImage)
      }
      
      furnitureDescriptionLabel.text = furniture.description
      furniturePriceLabel.text = String("$") + String(describing: furniture.price)
      
      if furniture.shippingPrice.doubleValue > 0.0 {
        furnitureShippingLabel.text = "Shipping: $" + String(describing: furniture.shippingPrice)
      } else {
        furnitureShippingLabel.text = "Free Shipping"
      }
      
    }
  }
  
  private func addPaymentButtons() {
    // Traditional Payment Button
    let defaultPaymentButton = UIButton(type: .custom)
    defaultPaymentButton.setImage(UIImage(named: "cart"), for: .normal)
    defaultPaymentButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
    defaultPaymentButton.titleLabel?.text = "Buy"
    defaultPaymentButton.setTitleColor(.white, for: .normal)
    
    // Apple Pay Button
    var applePayButton: UIButton?
    if PKPaymentAuthorizationController.canMakePayments() {
      applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
      applePayButton?.addTarget(self, action: #selector(payPressed), for: .touchUpInside)
    } else if PKPaymentAuthorizationController.canMakePayments(usingNetworks: paymentManager.SupportedNetworks) {
      applePayButton = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
      applePayButton?.addTarget(self, action: #selector(setupPressed), for: .touchUpInside)
    }
    
    view.addSubview(applePayButton!)
    
    applePayButton?.snp.makeConstraints({ (maker) in
      maker.size.equalTo((applePayButton?.frame.size)!)
      maker.right.equalTo(view.snp.rightMargin)
      maker.bottom.equalTo(view.snp.bottomMargin)
    })
  }
}
