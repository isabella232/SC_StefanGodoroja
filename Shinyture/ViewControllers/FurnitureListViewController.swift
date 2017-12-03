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

extension UIView {
  
  func setupShadow() {
    self.layer.cornerRadius = 8
    self.layer.shadowOffset = CGSize.zero
    self.layer.shadowOpacity = 0.3
    self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,
                                         byRoundingCorners: .allCorners,
                                         cornerRadii: CGSize(width: 8, height: 8)).cgPath
    self.layer.shouldRasterize = true
    self.layer.rasterizationScale = UIScreen.main.scale
  }
  
}

class FurnitureOverviewView: UIView {

}

class FurnitureImageView: UIImageView {
  
  override var bounds: CGRect {
    didSet {
      setupShadow()
    }
  }
}

class FurnitureListViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Shinyture"
    let titles = ["Today", "Best Deals", "Categories"]
    let segmentedControl = TwicketSegmentedControl(frame: CGRect.zero)
    segmentedControl.setSegmentItems(titles)
    view.addSubview(segmentedControl)
    
    segmentedControl.snp.remakeConstraints { (maker) in
      maker.height.equalTo(40)
      maker.leadingMargin.equalTo(view.snp.leadingMargin).offset(5)
      maker.topMargin.equalTo(view.snp.topMargin).offset(10)
      maker.trailingMargin.equalTo(view.snp.trailingMargin).offset(5)
    }
  }
}

extension FurnitureListViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "show.furnituredetails.segue", sender: nil)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 6;
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "rw.furnitureoverview.cell")
    return cell!
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 300
  }
  
}
