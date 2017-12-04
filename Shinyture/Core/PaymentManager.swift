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

import PassKit

typealias PaymentManagerCompletionHandler = (Bool) -> Void

class PaymentManager: NSObject {
  let MerchantID = "merchant.rw.shinyture.raywenderlich"
  let SupportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]
  
  var completionHandler: PaymentManagerCompletionHandler?
  
  private var paymentController: PKPaymentAuthorizationController?
  private var shouldDismissAuthorizationController = true
  
  func pay(forFurnitureItem item: Furniture?, completion: @escaping PaymentManagerCompletionHandler) {
    completionHandler = completion
    
    if let item = item {
      let request = PKPaymentRequest()
      request.merchantIdentifier = MerchantID
      request.merchantCapabilities = .capability3DS
      request.countryCode = "US"
      request.currencyCode = "USD"
      request.supportedNetworks = SupportedNetworks
      //request.requiredBillingContactFields = [.phoneNumber, .name]
      //request.requiredShippingContactFields = [.postalAddress, .phoneNumber, .name]
      
      var payments: [PKPaymentSummaryItem] = []
      
      let itemPayment = PKPaymentSummaryItem(label: item.name,
                                             amount: item.price,
                                             type: .final)
      payments.append(itemPayment)
      
      if item.shippingPrice.doubleValue > 0 {
        let shippingPayment = PKPaymentSummaryItem(label: "Shipping",
                                                   amount: item.shippingPrice,
                                                   type: .final)
        payments.append(shippingPayment)
      }
      
      if item.discountValue.doubleValue > 0 {
        let discountPayment = PKPaymentSummaryItem(label: "Discout",
                                                   amount: item.discountValue.negative(),
                                                   type: .final)
        payments.append(discountPayment)
      }
      
      let totalPrice = item.price.adding(item.shippingPrice).subtracting(item.discountValue)
      let totalPayment = PKPaymentSummaryItem(label: "Shinyture",
                                              amount: totalPrice,
                                              type: .final)
      payments.append(totalPayment)
      request.paymentSummaryItems = payments
      
      paymentController = PKPaymentAuthorizationController(paymentRequest: request)
      paymentController?.delegate = self
      paymentController?.present(completion: nil)
    }
  }
}

// MARK: PKPaymentAuthorizationControllerDelegate
extension PaymentManager: PKPaymentAuthorizationControllerDelegate {
  
  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
    
    print(payment.token)
    print("didAuthorizePayment")
    completion(.success)
  }
  
  func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    
    if shouldDismissAuthorizationController {
      controller.dismiss {
        DispatchQueue.main.async {
          self.shouldDismissAuthorizationController = false
          self.completionHandler?(true)
        }
      }
    }
  }
  
}
