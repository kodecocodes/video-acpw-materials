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

protocol Validation {
  associatedtype Value
  func validate(_ value: Value) -> Bool

  func sanitize(_ value: Value) -> Value
}

struct WhitespaceValidation: Validation {
  struct Options: OptionSet {
    let rawValue: Int

    static let trailing = Options(rawValue: 1 << 0)
    static let leading = Options(rawValue: 1 << 1)

    static let all: Options = [.leading, .trailing]
  }
  typealias Value = String
  let options: Options

  func validate(_ value: String) -> Bool {
    return !value.isEmpty
  }

  func sanitize(_ value: String) -> String {
    var value = value
    if self.options.contains(.leading) {
      while value.first?.isWhitespace == true {
        value.removeFirst()
      }
    }
    if self.options.contains(.trailing) {
      while value.last?.isWhitespace == true {
        value.removeLast()
      }
    }
    return value
  }

  static let trailing = WhitespaceValidation(options: .leading)
  static let leading = WhitespaceValidation(options: .trailing)
  static let all = WhitespaceValidation(options: .all)
}


@propertyWrapper
struct ValidatableState<Value, V>: DynamicProperty where V: Validation, V.Value == Value {
  @State private var underlying: Value
  private let validations: [V]

  init(wrappedValue: Value, validations: V...) {
    self._underlying = State(wrappedValue: wrappedValue)
    self.validations = validations
  }

  var wrappedValue: Value {
    get { underlying }
    nonmutating set { underlying = newValue }
  }

  var projectedValue: Self {
    self
  }

  var bind: Binding<Value> {
    $underlying
  }

  var sanitizedValue: Value {
    self.validations.reduce(self.wrappedValue) { $1.sanitize($0) }
  }

  var valid: Bool {
    self.validations.allSatisfy { $0.validate(self.sanitizedValue) }
  }

  mutating func update() {
    _underlying.update()
  }
}
