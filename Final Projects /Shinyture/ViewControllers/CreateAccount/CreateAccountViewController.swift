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

class CreateAccountViewController: UIViewController {
  var registrationContact: Contact?
    
    @IBOutlet private var profilePhotoImageView: UIImageView!
    @IBOutlet private var firstNameTextField: UITextField!
    @IBOutlet private var lastNameTextField: UITextField!
    @IBOutlet private var emailTextField: UITextField!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Create Account"
    profilePhotoImageView.round()
    populateContactTextFields()
  }
  
  @IBAction func registerButtonPressed(_ sender: Any) {
    // This will switch back to the rootviewcontroller.
    // The purpose of this viewcontroller is to demonstrate
    // that after making a purchase, developers can use contact
    // information to make easier the process of registration.
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "rw.root.navcontroller")
    
    if let window = UIApplication.shared.keyWindow {
      UIView.transition(with: window,
                        duration: 0.3,
                        options: .transitionCrossDissolve , animations: {
                          window.rootViewController = rootViewController;
      })
    }
  }
  
  private func populateContactTextFields() {
    firstNameTextField.text = registrationContact?.firstName
    lastNameTextField.text = registrationContact?.lastName
    emailTextField.text = registrationContact?.email
  }
}
