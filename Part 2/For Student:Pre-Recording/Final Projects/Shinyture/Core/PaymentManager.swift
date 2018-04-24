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
  private var completionHandler: PaymentManagerCompletionHandler?
  private var paymentStatus = PKPaymentAuthorizationStatus.failure
  private var shippingMethods: [PKShippingMethod] = []
  private var paymentItems: [PKPaymentSummaryItem] = []
  
  func pay(forFurnitureItem item: Furniture?, completion: @escaping PaymentManagerCompletionHandler) {
    completionHandler = completion
    
    if let item = item {
      let request = PKPaymentRequest()
      request.merchantIdentifier = "merchant.rw.shinyture.raywenderlich"
      request.merchantCapabilities = .capability3DS
      request.countryCode = "US"
      request.currencyCode = "USD"
      request.supportedNetworks = [.visa, .masterCard, .amex]
      request.requiredBillingContactFields = [ .name]
      request.requiredShippingContactFields = [.postalAddress, .phoneNumber, .emailAddress]
      
      let totalItemsName = "\(item.units) items of " + item.name
      let totalItemsPrice = item.price.multiplying(by: NSDecimalNumber(value: item.units))
      let itemPayment = PKPaymentSummaryItem(label: totalItemsName,
                                             amount: totalItemsPrice,
                                             type: .final)
      paymentItems.append(itemPayment)
      
      let freeShippingMethod = PKShippingMethod(label: "Free Shipping", amount: NSDecimalNumber.zero)
      freeShippingMethod.identifier = "free"
      freeShippingMethod.detail = "Free Shipping in 7 days"
      shippingMethods.append(freeShippingMethod)
      paymentItems.append(freeShippingMethod)
      
      let paidShippingMethod = PKShippingMethod(label: "Paid Shipping", amount: item.shippingPrice)
      paidShippingMethod.identifier = "paid"
      paidShippingMethod.detail = "Paid Shipping in 1 day"
      shippingMethods.append(paidShippingMethod)
      
      let totalPayment = PKPaymentSummaryItem(label: "Shinyture",
                                              amount: totalItemsPrice,
                                              type: .final)
      paymentItems.append(totalPayment)
      request.paymentSummaryItems = paymentItems
      request.shippingMethods = shippingMethods
      
      let paymentController = PKPaymentAuthorizationController(paymentRequest: request)
      paymentController.delegate = self
      paymentController.present(completion: nil)
    }
  }
}

// MARK: PKPaymentAuthorizationControllerDelegate
extension PaymentManager: PKPaymentAuthorizationControllerDelegate {
  
  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
    var errors: [Error] = []
    
    if contact.postalAddress?.postalCode == "" {
      let zipError = PKPaymentRequest.paymentShippingAddressInvalidError(withKey: CNPostalAddressPostalCodeKey,
                                                                         localizedDescription: "Shipping requires your ZIP code")
      errors.append(zipError)
    }
    
    if errors.isEmpty {
      completion(PKPaymentRequestShippingContactUpdate(paymentSummaryItems: paymentItems))
    } else {
      completion(PKPaymentRequestShippingContactUpdate(errors: errors, paymentSummaryItems: paymentItems, shippingMethods: shippingMethods))
    }
  }
  
  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
    
    for currentShippingMethod in paymentItems {
      
      if currentShippingMethod is PKShippingMethod {
        
        if let objectIndex = paymentItems.index(of: currentShippingMethod) {
          let previousShippingMethod = currentShippingMethod
          paymentItems[objectIndex] = shippingMethod
          
          if let totalPayment = paymentItems.last {
            totalPayment.amount = totalPayment.amount.subtracting(previousShippingMethod.amount).adding(shippingMethod.amount)
            
            if let lastObjectIndex = paymentItems.index(of: totalPayment) {
              paymentItems[lastObjectIndex] = totalPayment
            }
          }
        }
      }
    }
    
    completion(PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: paymentItems))
  }
  
  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    var errors: [Error] = []
    
    if let emailAddress = payment.shippingContact?.emailAddress {
      
      if emailAddress.isValidEmail() == false {
        let invalidEmailError = PKPaymentRequest.paymentContactInvalidError(withContactField: .emailAddress, localizedDescription: "Email has incorrect format")
        errors.append(invalidEmailError)
      }
    }
    
    if errors.isEmpty {
      paymentStatus = .success
    } else {
      paymentStatus = .failure
    }
    
    completion(PKPaymentAuthorizationResult(status: paymentStatus, errors: errors))
  }
  
  func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    controller.dismiss {
      DispatchQueue.main.async {
        
        if self.paymentStatus == .success {
          self.completionHandler?(true)
        } else {
          self.completionHandler?(false)
        }
        
        self.paymentStatus = .failure
        self.shippingMethods = []
        self.paymentItems = []
      }
    }
  }
  
}
