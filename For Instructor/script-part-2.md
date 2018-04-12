# # Screencast Metadata

## Screencast Title

PassKit: Integrate Apple Pay in your app. Part 2.

## Screencast Description

A showcase of how Apple Pay makes developers and users life
easier when paying for real world goods and services.

## Language, Editor and Platform versions used in this screencast:

* Language: Swift 4
* Platform: iOS 11
* Editor: Xcode 9

## Introduction

Hey what’s up everybody, this is Brian. In today's screencast I'm going to show how to use a payment processor to fulfill payment 
transations that are authorized by Apple Pay.

First, I’d like to thank Ștefan Godoroja for preparing the materials for this course. Check him out on twitter!

Apple Pay is supported by a wide range of payment platforms, so you have plenty of ready solutions to use. In this screencast we'll
use Stripe because it's very easy to configure and it comes with a built-in test payment enviroment. Using that enviroment you can test purchases
in your app without incurring real charges.

## Talking Head

We won't use any payment provider in this video because there are a lot of them, many providing native SDKs to work with Apple Pay, so it's up to you to choose the one which fits your needs, but I have few more words to say. 

## [Slide 09]

A payment providers is a party authorized to handle payments. You can find a list of providers on developer.apple.com. Apple recommended to use an already existing provider than to handle payments yourself, otherwise you'll need a payment infrastructure able to decrypt and process payments. 

## [Slide 10]

The payment processing certificate is associated with your merchant id. This certificate can be created on developer portal, in Certificates, Identifiers & Profiles page, in the Merchant IDs section, when editing a merchant ID. Usually you ask payment provider for a Certificate Signing Request file, upload it on developer portal then generate the certificate and in the end you send it to the payment provider, but in our case we'll use a local generated CSR file. Don't forget to download and install the generated certificate.

## Demo

We cleared up important things, now let's dive into our demo. In FurnitureDetailsViewController class, first we import PassKit framework at the top of the class. Then in viewDidLoad() method, we check if device is Apple Pay eligible. If so, then we add a PKPaymentButton with buy type and black style to the viewcontroller's view. Apple has rigorous requirements for size, style and even position of an Apple Pay button, so check out the Human Interface Guidelines for more details. 

```
 if PKPaymentAuthorizationController.canMakePayments() {
      let applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
      applePayButton.addTarget(self, action: #selector(payPressed), for: .touchUpInside)
      addApplePay(button: applePayButton)
 }
```

When Apple Pay button is tapped we pass a furniture item object to our payment manager based on which a payment request will be created. A block will be called when payment authorization has completed with or without success. If the payment was authorized, a confirmation viewcontroller will be displayed. Because we don't use any payment provider, we'll consider a successful payment the moment when payment was authorized.

```
  @objc func payPressed() {
    paymentManager.pay(forFurnitureItem: furnitureItem) { (success)  in
      
      if success {
        self.performSegue(withIdentifier: "show.paymentconfirmation.view", sender: nil)
      }
      
    }
```

Now switch to PaymentManager class. First, import PassKit framework at the top of the class. In the pay() method, we create a payment request, set merchant identifier we created a while ago, and set capability 3DS as the payment processing protocol. Country code represents the country where payment will be processed, currency code is describing the currency used by payment request. Supported networks will be Visa, Mastercard and American Express. We also require contact name for billing, for shipping we require postal address, phone number and email address. These are necessary in order to process the payment transaction.

``` 
      let request = PKPaymentRequest()
      request.merchantIdentifier = "merchant.rw.shinyture.raywenderlich"
      request.merchantCapabilities = .capability3DS
      request.countryCode = "US"
      request.currencyCode = "USD"
      request.supportedNetworks = [.visa, .masterCard, .amex]
      request.requiredBillingContactFields = [ .name]
      request.requiredShippingContactFields = [.postalAddress, .phoneNumber, .emailAddress]
```

Next we create a payment summary item which will represent furniture items user wants to buy. Label will contain custmized title indicating units of the selected item. The amount is the item price multiplied by the number of item units. The type of payment summary item will be final, meaning that the costs are known. We store it in paymentItems array for a later reuse. Pay attention that amount is of NSDecimalNumber type because it suits for financial calculations.

``` 
      let totalItemsName = "\(item.units) items of " + item.name
      let totalItemsPrice = item.price.multiplying(by: NSDecimalNumber(value: item.units))
      let itemPayment = PKPaymentSummaryItem(label: totalItemsName,
                                             amount: totalItemsPrice,
                                             type: .final)
      paymentItems.append(itemPayment)
``` 

Next will add free shipping method. Set amount to be zero. It has an identifier and a detail used to show shipping estimation time. We also need to save for later reuse. Why adding it to both arrays ? Well, shippingMethods array contains PKShippingMethods which will be displayed in Method section from the payment sheet. On the other hand, paymentItems contains PKPaymentSummaryItems which will be displayed in costs section. User needs to be able to select a shipping method and see it in costs section because it adds a price. 

``` 
      let freeShippingMethod = PKShippingMethod(label: "Free Shipping", amount: NSDecimalNumber.zero)
      freeShippingMethod.identifier = "free"
      freeShippingMethod.detail = "Free Shipping in 7 days"
      shippingMethods.append(freeShippingMethod)
      paymentItems.append(freeShippingMethod)
``` 

Next we create the paid shipping method the same way we did for free shipping method. The only difference is that we don't add it to paymentItems array, because only one shipping method can be active at one time. 

``` 
      let paidShippingMethod = PKShippingMethod(label: "Paid Shipping", amount: item.shippingPrice)
      paidShippingMethod.identifier = "paid"
      paidShippingMethod.detail = "Paid Shipping in 1 day"
      shippingMethods.append(paidShippingMethod)
``` 

Now we create another payment summary item, which will represent the total amount. For the total amount, label should be the business name, amount itself must contain all prices, taxes and discounts. This is the final amount that user will be charged. Be transparent and don't charge hidden fees. We save this also for a later reuse. 

``` 
      let totalPayment = PKPaymentSummaryItem(label: "Shinyture",
                                              amount: totalItemsPrice,
                                              type: .final)
      paymentItems.append(totalPayment)
``` 

Next we add paymentItems and shippingMethods arrays to payment request.

```
request.paymentSummaryItems = paymentItems
request.shippingMethods = shippingMethods
``` 

The last thing we do, initialize a PKPaymentAuthorizationController with the request, assign the delegate and present it. One cool thing about PKPaymentAuthorizationController is that this class is UIKit independent. Our PaymentManager class was designed in such way that can be reused easily
within iOS, watchOS apps and in extensions.

```
let paymentController = PKPaymentAuthorizationController(paymentRequest: request)
paymentController.delegate = self
paymentController.present(completion: nil)
```

Next our payment manager class should conform to PKPaymentAuthorizationControllerDelegate. Using it's methods app is able to respond to user interactions from the payment sheet. 

```
extension PaymentManager: PKPaymentAuthorizationControllerDelegate {

}
```

First, we'll implement didSelectShippingContact() method called when payment sheet is presented and each time user selects a new shipping contact. We check if the zip code is not set, then we create a custom error using PKPaymentRequest helper method, with a description telling that shipping requires zip code. If the error was detected, we are passing to completion handler a PKPaymentRequestShippingContactUpdate object initalized with errors, existing payment summary items and shipping methods, if not then we pass a PKPaymentRequestShippingContactUpdate object with existing payment summary items. This is a good place to update shipping costs based on contact address. It's important to mention that at this point contact parameter contains information only to calculate shipping costs but anonymize any other data like phone number or email. They will be available later after user authorizes payment request.

```
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
```

didSelectShippingMethod() is called when payment sheet is presented and each time user selects a new shipping method. So it allows to update shipping method and recalculate total amount. Basically, we iterate through existing payment summary items and try to identify current shipping method, once found we replace it with new shipping method, and update total amount. At the end we send back updated payment summary item array through a PKPaymentRequestShippingMethodUpdate object.

```
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
```

didAuthorizePayment() method notifies the delegate that user authorized payment request by using Touch ID or Face ID. At this moment email address becomes available and we try to validate it. If it's not valid we create an error using PKPaymentRequest helper method, telling that email has an incorrect format. Next we check if any error was detected, and set payment request status depend on this. The last thing we do, is create a PKPaymentAuthorizationResult initialized with paymentStatus and errors array and pass it to the completion handler. What's even more important, the 
payment parameter contains the encrypted token which must be send to payment processing.

```
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
```

After user authorized the payment request, paymentAuthorizationControllerDidFinish() method tells the app that request authorization has been completed. Now payment sheet can be dismissed. We also call the completion handler with an authorization flag. At the end, reset parameters to 
initial values for the future payment request.

```
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
 ```

## [Slide 10]

Testing on a simulator is not an option even because it has built-in payment cards. The problem is that payment token which must be send for processing isn't valid, it's just some dummy text. 

## [Slide 11]

The best way to do it is using Apple Pay Sandbox Testing enviroment. In iTunes Connect, on the Users and Roles page, create a sandbox tester. When done, sign in with this new sandbox tester account on your testing device. Important to mention is that device region must be set to a country which supports Apple Pay otherwise you won't be able to add test cards. Now that you have a testing account, you can add a test card in Wallet app, using manual entry. A list of test cards can be found developer.apple.com. After adding a payment
card you can start testing. But don't forget to test Apple Pay on production enviroment using real cards, because test cards won't work there. 

## Demo

Let's run the project. I'll select the first furniture item, we see furniture details like price, unit counter, at the bottom of screen there is a button for standart payment and a Apple Pay button. First, let's select 2 units of this furniture. Now we want to pay for it. Payment sheet contains a lot of information starting with selected payment card, shipping information, shipping method, contact information and list of costs: subtotal, shipping cost and the total amount. Now let's select a paid shipping method. As you can see the list of costs was updated properly and the free shipping was replaced with paid shipping. Now let's remove zip code from the shipping address to see if app reacts and alerts user that zip code is required. We see that the address field is highlighted with red, with a clear message that it requires zip code. We'll type back the zip code, and the error message will disappear. Now let's authorize the payment, it processes the payment and boom! App shows the confirmation screen.

## Conclusion

Alright, that’s everything I’d like to cover in this video. At this point you should feel comfortable with Apple Pay, starting from basic concepts and enviroment setup, and ending with testing using Apple Pay Sandbox Testing enviroment. If you want to learn more check out Apple Pay Programming Guide webpage: https://developer.apple.com/library/content/ApplePay_Guide/index.html#//apple_ref/doc/uid/TP40014764-CH1-SW1, particularly paying attention to PKPaymentAuthorizationControllerDelegate protocol which has few more methods that can fit your more specific needs.

Actually this screencast could be shorter if Ray would be willing to share his credit card credentials, but he nicely refused :[, arguing that he
needs money for the Christmas party.

Bye!