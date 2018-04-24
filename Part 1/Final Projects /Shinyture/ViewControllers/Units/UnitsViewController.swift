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

struct Unit {
  var value = 0
  var selected = false
}

protocol UnitsViewControllerDelegate {
  func didSelect(unit: Unit)
}

class UnitsViewController: UIViewController {
  var currentUnit = Unit()
  var delegate: UnitsViewControllerDelegate?
  
  private var units: [Unit] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Number of units"
    createUnits()
    selectCurrentUnit()
  }
  
  private func createUnits() {
    let oneUnit = Unit(value: 1, selected: false)
    units.append(oneUnit)
    let twoUnits = Unit(value: 2, selected: false)
    units.append(twoUnits)
    let threeUnits = Unit(value: 3, selected: false)
    units.append(threeUnits)
    let fourUnits = Unit(value: 4, selected: false)
    units.append(fourUnits)
  }
  
  private func selectCurrentUnit() {
    for index in 0..<units.count {
      if currentUnit.value == units[index].value {
        units[index].selected = true
      }
    }
  }
}

// MARK: UITableViewDelegate
extension UnitsViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    for index in 0..<units.count {
      units[index].selected = false
    }
    
    delegate?.didSelect(unit: units[indexPath.row])
    units[indexPath.row].selected = true
    tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension UnitsViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return units.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let unitCell = tableView.dequeueReusableCell(withIdentifier: "rw.units.cell")
    let unit = units[indexPath.row]
    unitCell?.textLabel?.text = String(unit.value)
    
    if unit.selected {
      unitCell?.accessoryType = .checkmark
    } else {
      unitCell?.accessoryType = .none
    }
    
    return unitCell!
  }
  
}
