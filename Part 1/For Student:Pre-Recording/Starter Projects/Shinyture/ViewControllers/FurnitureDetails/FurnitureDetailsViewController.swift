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
  private var currentFurnitureUnits = Unit(value: 1, selected: true) {
    didSet {
      furnitureItem?.units = currentFurnitureUnits.value
    }
  }
  
  @IBOutlet private var containerView: UIView!
  @IBOutlet private var furnitureImageView: FurnitureImageView!
  @IBOutlet private var furnitureShippingLabel: UILabel!
  @IBOutlet private var furniturePriceLabel: UILabel!
  @IBOutlet private var furnitureDescriptionLabel: UILabel!
  @IBOutlet private var defaultPaymentButton: UIButton!
  @IBOutlet private var unitsButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    showFurnitureDetails()
    addApplePayButton()
    styleDefaultPaymentButton()
    styleUnitsButton()
  }
  
  private func addApplePayButton() {
    
  }
  
  @objc func payPressed() {
    paymentManager.pay(forFurnitureItem: furnitureItem) { (success)  in
      
      if success {
        self.performSegue(withIdentifier: "show.paymentconfirmation.view", sender: nil)
      }
      
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let unitsViewController = segue.destination as? UnitsViewController
    unitsViewController?.delegate = self
    unitsViewController?.currentUnit = currentFurnitureUnits
  }
  
  private func addApplePay(button: UIButton?) {
    
    if let applePayButton = button {
      containerView.addSubview(applePayButton)
      
      applePayButton.snp.makeConstraints({ (maker) in
        maker.size.equalTo(applePayButton.frame.size)
        maker.bottom.equalTo(containerView.snp.bottom).inset(10)
        maker.right.equalTo(containerView.snp.right).inset(20)
      })
      
      defaultPaymentButton.snp.updateConstraints({ (maker) in
        maker.width.equalTo(applePayButton.snp.width)
      })
    }
  }
  
  private func showFurnitureDetails() {
    if let furniture = furnitureItem {
      
      if let furnitureImage = furniture.coverImageName {
        furnitureImageView.image = UIImage(named: furnitureImage)
      }
      
      title = furniture.name
      furnitureDescriptionLabel.text = furniture.description
      furniturePriceLabel.text = String("$") + String(describing: furniture.price)
      furnitureShippingLabel.text = "Free Shipping"
    }
  }
  
  private func styleDefaultPaymentButton() {
    let defaultPaymentButtonBorderColor = UIColor(red: (34/255.0),
                                                  green: (139/255.0),
                                                  blue: (34/255.0),
                                                  alpha: 1.0)
    defaultPaymentButton.round(radius: 4, withBorderColor: defaultPaymentButtonBorderColor)
  }
  
  private func styleUnitsButton() {
    let discountButtonBorderColor = UIColor(red: (55/255.0),
                                            green: (51/255.0),
                                            blue: (52/255.0),
                                            alpha: 1.0)
    unitsButton.round(radius: 4, withBorderColor: discountButtonBorderColor)
  }
}

extension FurnitureDetailsViewController: UnitsViewControllerDelegate {
  
  func didSelect(unit: Unit) {
    currentFurnitureUnits = unit
    let unitsButtonTitle = "Units: \(currentFurnitureUnits.value)"
    unitsButton.setTitle(unitsButtonTitle, for: .normal)
  }
}
