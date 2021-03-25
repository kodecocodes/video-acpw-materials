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

struct Shake: GeometryEffect {
  var amount: CGFloat = 10
  var shakesPerUnit = 3
  var animatableData: CGFloat

  func effectValue(size: CGSize) -> ProjectionTransform {
    ProjectionTransform(CGAffineTransform(
      translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
      y: 0))
  }
}

struct UpdateNameView: View {
  @Binding var showModal: Bool

  @ObservedObject
  var model: GolfModel

  @ValidatableState(validations: WhitespaceValidation.all)
  var name: String = ""
  @State var animateCounter = 0

  var body: some View {
    NavigationView {
      VStack {
        Text("Input your name:")
        TextField(model.name, text: $name)
          .padding()
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .modifier(Shake(animatableData: CGFloat(animateCounter)))
          .navigationBarTitle("Update name", displayMode: .inline)
          .navigationBarItems(leading: Button("cancel") {
            self.showModal = false
          }.disabled(model.name.isEmpty), trailing: Button("save") {
            if !self._name.valid {
              withAnimation { self.animateCounter += 1 }
              return
            }
            self.model.name = self._name.sanitizedValue
            self.showModal = false
          })
      }
    }
  }
}

struct UpdateNameView_Previews: PreviewProvider {
  @State static var show: Bool = false
  static var previews: some View {
    UpdateNameView(showModal: $show, model: .init())
  }
}
