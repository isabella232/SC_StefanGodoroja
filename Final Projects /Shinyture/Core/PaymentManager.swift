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
  
  private var paymentStatus = PKPaymentAuthorizationStatus.failure
  private var shippingMethods: [PKShippingMethod] = []
  private var paymentItems: [PKPaymentSummaryItem] = []
  private var paymentController: PKPaymentAuthorizationController?
  
  func pay(forFurnitureItem item: Furniture?, completion: @escaping PaymentManagerCompletionHandler) {
    completionHandler = completion
    
    if let item = item {
      let request = PKPaymentRequest()
      request.merchantIdentifier = MerchantID
      request.merchantCapabilities = .capability3DS
      request.countryCode = "US"
      request.currencyCode = "USD"
      request.supportedNetworks = SupportedNetworks
      request.requiredBillingContactFields = [ .name]
      request.requiredShippingContactFields = [.postalAddress, .phoneNumber, .emailAddress]
      
      let itemPayment = PKPaymentSummaryItem(label: item.name,
                                             amount: item.price,
                                             type: .final)
      paymentItems.append(itemPayment)
      
      if item.shippingPrice.doubleValue > 0 {
        let paidShippingMethod = PKShippingMethod(label: "Paid Shipping", amount: item.shippingPrice)
        paidShippingMethod.identifier = "Paid Shipping"
        paidShippingMethod.detail = "Paid Shipping in 1 day"
        shippingMethods.append(paidShippingMethod)
      } else {
        let freeShippingMethod = PKShippingMethod(label: "Free Shipping", amount: NSDecimalNumber.zero)
        freeShippingMethod.identifier = "Free Shipping"
        freeShippingMethod.detail = "Free Shipping in 7 days"
        shippingMethods.append(freeShippingMethod)
      }
      
      if item.discountValue.doubleValue > 0 {
        let discountPayment = PKPaymentSummaryItem(label: "Discount",
                                                   amount: item.discountValue.negative(),
                                                   type: .final)
        paymentItems.append(discountPayment)
      }
      
      let totalPrice = item.price.adding(item.shippingPrice).subtracting(item.discountValue)
      let totalPayment = PKPaymentSummaryItem(label: "Shinyture",
                                              amount: totalPrice,
                                              type: .final)
      paymentItems.append(totalPayment)
      request.paymentSummaryItems = paymentItems
      request.shippingMethods = shippingMethods
      
      paymentController = PKPaymentAuthorizationController(paymentRequest: request)
      paymentController?.delegate = self
      paymentController?.present(completion: nil)
    }
  }
}

// MARK: PKPaymentAuthorizationControllerDelegate
extension PaymentManager: PKPaymentAuthorizationControllerDelegate {
  
  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
    
    var updateContact = PKPaymentRequestShippingContactUpdate()
    var errors: [Error] = []
    
    if contact.emailAddress == "" {
      let emailError = PKPaymentRequest.paymentContactInvalidError(withContactField: .emailAddress, localizedDescription: "Shipping requires your email")
      errors.append(emailError)
    } else if contact.postalAddress?.city == "" {
      let cityAddressError = PKPaymentRequest.paymentShippingAddressInvalidError(withKey: CNPostalAddressCityKey, localizedDescription:"Shipping requires your city")
      errors.append(cityAddressError)
    }
    
    if errors.isEmpty {
      updateContact = PKPaymentRequestShippingContactUpdate(paymentSummaryItems: paymentItems)
    } else {
      updateContact = PKPaymentRequestShippingContactUpdate(errors: errors, paymentSummaryItems: paymentItems, shippingMethods: shippingMethods)
    }
    
    completion(updateContact)
  }
  
  func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    
    controller.dismiss {
      DispatchQueue.main.async {
        
        if self.paymentStatus == .success {
          self.completionHandler?(true)
        } else {
          self.completionHandler?(false)
        }
      }
    }
    
  }
  
  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectPaymentMethod paymentMethod: PKPaymentMethod, handler completion: @escaping (PKPaymentRequestPaymentMethodUpdate) -> Void) {
    
    if paymentMethod.type == .debit {
      var discountedItems = paymentItems
      let discountItem = PKPaymentSummaryItem(label: "Debit Card Discount", amount: NSDecimalNumber(string: "-5.00"))
      discountedItems.insert(discountItem, at: paymentItems.count - 1)
      
      if let totalPaidItem = paymentItems.last {
        totalPaidItem.amount = totalPaidItem.amount.subtracting(NSDecimalNumber(string: "5.00"))
      }
      
      completion(PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: discountedItems))
    } else {
      completion(PKPaymentRequestPaymentMethodUpdate(paymentSummaryItems: paymentItems))
    }
  }
  
  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    var errors: [Error] = []
    
    if let emailAddress = payment.shippingContact?.emailAddress {
      
      if emailAddress.isValidEmail() == false {
        let invalidEmailError = PKPaymentRequest.paymentContactInvalidError(withContactField: .emailAddress, localizedDescription: "Email has incorect format")
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
}
