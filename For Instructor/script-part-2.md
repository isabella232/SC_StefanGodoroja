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
transactions that are authorized by Apple Pay.

First, I’d like to thank Ștefan Godoroja for preparing the materials for this course. Check him out on twitter!

Apple Pay is supported by a wide range of payment platforms, so you have plenty of ready solutions to use. A payment provider is a party authorized to handle payments. You can find a list of providers on developer.apple.com. Apple recommends to use an existing provider than to handle payments yourself, otherwise you'll need a payment infrastructure able to decrypt and process payments. In this screencast we'll use Stripe because it's very easy to configure and it comes with a built-in test payment enviroment. Using that enviroment you can test purchases in your app without incurring real charges.

## [Slide 01] - [Slide 02]

Let's see first how the transaction flow looks like. After Apple Pay has authorized a payment, app sends the payment token to the Stripe. The payment provider will decrypt PKPayment object and send back a Stripe token - STPToken, and will notify if an error has occured.

## [Slide 03] - [Slide 04]

Now, using STPToken tokenId and any other details you are particullary interested in, like shipping details, amount, etc; you create a request and send
it to the backend. The actual charge of user's card is performed on the custom server, using Stripe web API.

## Talking Head

Now that we have basic idea of how things work together, let's implement each step in details. The first step and very important one, you need to create a free Stripe account. 

## [Slide 05]

Next, you need go to Apple Pay section of your Stripe account at https://dashboard.stripe.com/account/apple_pay. Create a new application which will trigger a CSR file to be downloaded. After that, navigate to developer portal and find Merchant IDs in Certificates, Identifiers & Profiles section. Create
a new certificate using using Stripe's CSR file. As a result we'll get a .cer file, which must be uploaded to your Stripe account. As a result, Stripe is now able to decrypt Apple Pay payment objects.

## Talking Head

Remember that money charge will be triggered from the backend. In an actual app, your server would register customer's order in a database and would
do other manipulations. But in our case, for the sake of simplicity we'll use a local server which will create a charge request and send it to the Stripe, once accepted you will be able to see transaction in your Stripe account. 

## Demo

First step to setup our local server is to install pip utility which is a package managment system. If it's already installed skip this step.

```
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
```

Next install Flask, which is a Python web framework. 

```
sudo pip install Flask
```

Now we'll install Stripe library written in Python.

```
sudo pip install --index-url https://code.stripe.com --upgrade stripe
```

In the root folder of the project there is shinyture-charge.py file, which contains our server code. You don't need to understand much here, the only
thing is required from you is to set your secret key from the Stripe account. You can find it in API Keys section. Remember that this must be the test key!

The last step is to start the server

```
python shinyture-charge.py
```


## Talking Head

At this stage we have a server able to receive payments from the mobile app and to request Stripe to finalize them. Now we need to install Stripe iOS SDK. There are several ways to install and configure the SDK, using Cocoapods, Carthage, Fabric, Static Framework and the last one, Dynamic Framework which we'll use.

## Demo

Initial step is to download the latest release of the Stripe framework from https://github.com/stripe/stripe-ios/releases. Then drag the Stripe framework
file to the "Embedded Binaries" section of your Xcode project. The last step is to create a new "Run Script Build Phase" and paste the following statement

```
bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Stripe.framework/integrate-dynamic-framework.sh"
```

## Talking Head

The last stage which sticks all the parts we've setup, is to write code which initialize Stripe, obtain Stripe token for the payment and send it to our backend which will trigger the payment on Stripe. 

## Demo

In AppDelegate.swift import Stripe framework. 

```
import Stripe
```

Then in didFinishLaunchingWithOptions() method initialize Stripe with your publishable key.

```
STPPaymentConfiguration.shared().publishableKey = "YOUR_PUBLISHABLE_KEY"
```

Replace YOUR_PUBLISHABLE_KEY with the real key. You can find it in the same place as the secret key, under API Keys section of your Stripe account. Now let's switch to PaymentManager.swift file. First we'll add the import statement of the Stripe framework. 

```
import Stripe
```

Now, we'll remove the last line of codes from didAuthorizePayment() which concluded authorization based on received errors.

```
    if errors.isEmpty {
      paymentStatus = .success
    } else {
      paymentStatus = .failure
    }
    
    completion(PKPaymentAuthorizationResult(status: paymentStatus, errors: errors))
```

In real-life scenario, if we don't encounter any error, which means all the conditions are met, app will communicate with 
the payment processor and the backend. Now let's check again if there are any errors. If everything is fine, call the 
createToken() which takes as a parameter a PKPayment object and return back a Stripe token and any Stripe error if it's the case.
The if statement is ended by an else case, when validation of email address has failed. As a result we update payment status and
call the completion handler with the status and errors.

```
    if errors.isEmpty {
      STPAPIClient.shared().createToken(with: payment) { token, error in
        
      }
      
    } else {
      paymentStatus = .failure
      completion(PKPaymentAuthorizationResult(status: paymentStatus, errors: errors))
    }
```


Inside of createToken(), we'll check if the cretion of Stripe token didn't encounter any errors. If that's true then
we update payment status and call the completion handler with that status, also we send an empty array for the errors. 

```
       if (error != nil) {
          self.paymentStatus = .failure
          completion(PKPaymentAuthorizationResult(status: self.paymentStatus, errors: []))
          
        } 
```

If Stripe doesn't complain about anything, then we can create a web request using NSMutableURLRequest. Few things to notice here. First, update
ipAddress constant value. Second, we unwrap stripeToken, totalAmount and totalDescription values, if something is not setup, payment can't be
finalized. The body constant represent a dictionary which will be transformed into json data. The Stripe method which is called on backend to
perform the charge, requires 4 values: Stripe token, amount, description and currency code. The last one I've hardcoded on the backend, but the
first 3 are packed in the body dictionary. Special attention to the amount's value, it's measured in cents. 


```
      else {
          let ipAddress = "192.168.1.153"
          let url = URL(string: "http://\(ipAddress):5000/pay")
          var request = URLRequest(url: url!)
          request.httpMethod = "POST"
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")
          request.setValue("application/json", forHTTPHeaderField: "Accept")
          
          if let stripeToken = token?.tokenId,
            let totalAmount = self.paymentItems.first?.amount,
            let totalDescription = self.paymentItems.first?.description {
            
            let body = ["stripeToken": stripeToken,
                        "amount": totalAmount.multiplying(by: NSDecimalNumber(string: "100")),
                        "description": totalDescription,
                        "shipping": [
                          "city": payment.shippingContact?.postalAddress?.city,
                          "street": payment.shippingContact?.postalAddress?.street,
                          "phoneNumber": payment.shippingContact?.phoneNumber?.stringValue]
              ] as [String : Any]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
          }
          
```

The last code snippet to implement is about performing the request using URLSession class. When a response is received 
we update payment status depend of error presence and at the end call the completion handler with the payment status and 
an empty array for errors argument.

```          
          URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            if (error != nil) {
              self.paymentStatus = .failure
            } else {
              self.paymentStatus = .success
            }
            
            completion(PKPaymentAuthorizationResult(status: self.paymentStatus, errors: []))
            
          }).resume()
      }
      
```

That's it. As you see there is nothing complicated in integrating Stripe and a simple backend with our app. What you need to be aware is about Stripe testing keys, they must be updated once you go on production.

## Demo

Now let's run the demo. Again, I'll select the first furniture item. Let's select 2 units of this furniture. Now we want to pay for it. Payment sheet is presented, we check if payment information satisfies us, and now let's authorize the payment. We see that payment is processed, then it change to processing state then done and at the end our confirmation screen is presented. One last thing here is the processing state means that Apple Pay waits for the completion handler to be called after payment was authorized. If it's not called after some amount of time Apple Pay cancels the payment and 
user must start again.

## Conclusion

Alright, that’s everything I’d like to cover in this video. At this point you should feel comfortable with Apple Pay, starting from basic concepts and enviroment setup, and ending with testing using Apple Pay Sandbox Testing enviroment. If you want to learn more check out Apple Pay Programming Guide webpage: https://developer.apple.com/library/content/ApplePay_Guide/index.html#//apple_ref/doc/uid/TP40014764-CH1-SW1, particularly paying attention to PKPaymentAuthorizationControllerDelegate protocol which has few more methods that can fit your more specific needs.

Actually this screencast could be shorter if Ray would be willing to share his credit card credentials, but he nicely refused :[, arguing that he
needs money for the Christmas party.

Bye!