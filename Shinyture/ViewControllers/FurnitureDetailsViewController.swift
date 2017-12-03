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

struct ApplePayKey {
  static let merchantID = "merchant.rw.shinyture.raywenderlich"
}

class FurnitureDetailsViewController: UIViewController {
  
  let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
  
  var paymentController: PKPaymentAuthorizationController?

    @IBOutlet var applePayButtonContainer: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var button: UIButton?
    
    if PKPaymentAuthorizationController.canMakePayments() {
      button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
      button?.addTarget(self, action: #selector(FurnitureDetailsViewController.payPressed), for: .touchUpInside)
    } else if PKPaymentAuthorizationController.canMakePayments(usingNetworks: SupportedPaymentNetworks) {
      button = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
      button?.addTarget(self, action: #selector(FurnitureDetailsViewController.setupPressed), for: .touchUpInside)
    }
    
    if button != nil {
      button!.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
      applePayButtonContainer.addSubview(button!)
    }
    
  }
  
  @objc func payPressed() {
    let request = PKPaymentRequest()
    request.merchantIdentifier = ApplePayKey.merchantID
    request.merchantCapabilities = .capability3DS
    request.countryCode = "US"
    request.currencyCode = "USD"
    request.supportedNetworks = SupportedPaymentNetworks
    
    let paymentItem = PKPaymentSummaryItem(label: "Chair", amount: NSDecimalNumber(value: 12.0), type: .final)
    request.paymentSummaryItems = [paymentItem]
    
    paymentController = PKPaymentAuthorizationController(paymentRequest: request)
    paymentController?.delegate = self
    paymentController?.present(completion: { (present) in
      
    })

  }
  
  @objc func setupPressed() {
    
  }
}

extension FurnitureDetailsViewController: PKPaymentAuthorizationControllerDelegate {
  

  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
    
    print(payment.token)
    print("didAuthorizePayment")
    completion(.success)
  }
  
  func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    controller.dismiss {
      print("paymentAuthorizationControllerDidFinish")
      controller.dismiss(completion: nil)

    }
  }
  
}
