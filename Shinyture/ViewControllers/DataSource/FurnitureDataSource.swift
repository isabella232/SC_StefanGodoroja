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

struct Furniture {
  var coverImageName: String?
  var name: String?
  var price: NSDecimalNumber = 0
  var description: String?
  var shippingPrice: NSDecimalNumber = 0
  var discountValue: NSDecimalNumber = 0
}

final class FurnitureDataSource {
  var items: [Furniture] = []
  
  init() {
    let intexChair = Furniture(coverImageName: "intexChair", name: "Intex Pull-out Chair Inflatable Bed", price: 30.95, description: "Built for versatility, the Intex Pull-Out Chair is designed for relaxing just about anywhere, whether you are camping or at home. Watch TV, read a book, or just relax in the chair and then pull out the cushion into a twin size air mattress when you are ready to go to sleep. Inflates and is ready to go in minutes! The Pull-Out Chair is constructed with high quality vinyl and engineered for comfort. It’s ideal for college dorms, guest bedrooms or even road trips. The incredible versatility and durability makes the Pull-Out Chair a must-have for any home.We recommend consumers use high-volume, low-pressure air pumps like our inflators, rather than high-pressure, low-volume pumps like basketball or tire pumps.", shippingPrice: 0, discountValue: 20)
    items.append(intexChair)
    
    let gamingChair = Furniture(coverImageName: "gamingChair", name: "Racing Style Leather Gaming Chair", price: 72.76, description: "The Essentials by OFM seating collection is where quality meets value - and now it's taking the desk chair to a whole new level with the ESS-3085 series. Designed in an ergonomic race car style with contoured segmented padding, a high back, and integrated headrest and lumbar support, this chair provides high-performance comfort whether used during intense gaming sessions or long work days. The thickly padded armrests can be left down for upper body support or flipped up to allow for uninhibited movement whenever you need it. Additional features include seat height adjustment, tilt-lock/tilt-tension control and 360-degree swivel. SofThread Leather and contrasting color mesh upholstery complete the modern, high-quality look and feel of the ESS-3085. The comfort, style, and competitive price of this chair make it a perfect addition to your home or office. This chair meets or exceeds industry standards for safety and durability, and is backed by our Essentials by OFM Limited Lifetime warranty. The ESS-3085 has a 250 pound weight capacity.", shippingPrice: 10.99, discountValue: 0)
    items.append(gamingChair)
    
    let dorelChair = Furniture(coverImageName: "dorelChair", name: "Dorel Living Noa Pushback Recliner", price: 133.23, description: "A comfortable feel with a sleek, transitional look, the Dorel Living noa pushback recliner is a great way to bring style and flair to your living space. This modern recliner features a tailored and sophisticated look, highlighted with the subtle detail of the lightly flared tuxedo and a welting border along the seat cushion. With a compact profile, the noa boasts turned detail on the solid wooden legs and a tall back for increased head support, practically begging you to lean in, recline and relax. Upholstered in an easy-to-clean elegant blue linen-look fabric, the Dorel Living noa pushback recliner brings a needed splash of life and color to any room.", shippingPrice: 0, discountValue: 0)
    items.append(dorelChair)
  }
}
