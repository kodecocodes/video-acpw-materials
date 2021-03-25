/// Copyright (c) 2021 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct GolfView: View {
  @ObservedObject
  var model: GolfModel

  @State var addingAttempt: Bool = false
  @State var attempt: String = ""

  let dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.dateFormat = "MMM d, h:mm a"
    return fmt
  }()

  let numberFormatter: NumberFormatter = {
    let fmt = NumberFormatter()
    fmt.maximumFractionDigits = 2
    fmt.minimumFractionDigits = 1
    return fmt
  }()

  func formatNumber(_ double: Double) -> String {
    let number = NSNumber(value: double)
    return numberFormatter.string(from: number) ?? ""
  }

  func saveAttempt() {
    guard let value = Double(self.attempt) else { return }
    self.model.storeAttempt(distance: value)
    self.addingAttempt = false
    self.attempt = ""
  }

  var body: some View {
    VStack {
      (Text(model.name).bold() + Text(" long drive golf record"))
        .padding(.bottom)

      Text("Total attempts: \(model.$latestAttempt.count)")

      if !model.$latestAttempt.isEmpty {
        let personalBest = formatNumber(model.$latestAttempt.sorted { $0.value > $1.value }.first?.value ?? 0)
        Text("Personal best: \(personalBest) meters")
        Text("Latest attempt: \(formatNumber(model.latestAttempt)) meters")
      }

      Text("Attempt history:")
        .bold()
        .padding(.top)
      List {
        if addingAttempt {
          TextField("Attempt", text: $attempt, onCommit: saveAttempt)
            .keyboardType(.decimalPad)
        }
        ForEach(model.$latestAttempt.sorted { $0.date > $1.date }, id: \.date) { item in
          Text("At \(dateFormatter.string(from: item.date)): \(formatNumber(item.value)) meters")
        }
      }

      Button(self.addingAttempt ? "Save attempt" : "Add attempt") {
        if self.addingAttempt {
          self.saveAttempt()
          return
        }
        self.addingAttempt = true
      }
      .padding()
      .foregroundColor(.white)
      .background(Color("rw-green"))
    }
  }
}


struct GolfView_Previews: PreviewProvider {
  static var previews: some View {
    GolfView(model: .init())
  }
}
