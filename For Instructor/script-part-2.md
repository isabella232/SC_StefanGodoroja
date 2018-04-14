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

The last step 


## Demo

Let's run the project. I'll select the first furniture item, we see furniture details like price, unit counter, at the bottom of screen there is a button for standart payment and a Apple Pay button. First, let's select 2 units of this furniture. Now we want to pay for it. Payment sheet contains a lot of information starting with selected payment card, shipping information, shipping method, contact information and list of costs: subtotal, shipping cost and the total amount. Now let's select a paid shipping method. As you can see the list of costs was updated properly and the free shipping was replaced with paid shipping. Now let's remove zip code from the shipping address to see if app reacts and alerts user that zip code is required. We see that the address field is highlighted with red, with a clear message that it requires zip code. We'll type back the zip code, and the error message will disappear. Now let's authorize the payment, it processes the payment and boom! App shows the confirmation screen.

## Conclusion

Alright, that’s everything I’d like to cover in this video. At this point you should feel comfortable with Apple Pay, starting from basic concepts and enviroment setup, and ending with testing using Apple Pay Sandbox Testing enviroment. If you want to learn more check out Apple Pay Programming Guide webpage: https://developer.apple.com/library/content/ApplePay_Guide/index.html#//apple_ref/doc/uid/TP40014764-CH1-SW1, particularly paying attention to PKPaymentAuthorizationControllerDelegate protocol which has few more methods that can fit your more specific needs.

Actually this screencast could be shorter if Ray would be willing to share his credit card credentials, but he nicely refused :[, arguing that he
needs money for the Christmas party.

Bye!