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
import Combine

protocol SettingsContainer: ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
  var userDefaults: UserDefaults { get }
}

extension AppStorage where Value: Swift.Codable {
  @propertyWrapper
  struct Observable {
    let key: SettingsKey
    private let defaultValue: Value

    init(wrappedValue: Value, _ key: SettingsKey) {
      self.key = key
      self.defaultValue = wrappedValue
    }

    @available(*, unavailable, message: "@AppStorage.Observable can only be used inside classes")
    var wrappedValue: Value {
      get { fatalError("@AppStorage.Observable can only be used inside classes") }
      // swiftlint:disable:next unused_setter_value
      set { fatalError("@AppStorage.Observable can only be used inside classes") }
    }

    static subscript<OuterSelf: SettingsContainer>(
      _enclosingInstance instance: OuterSelf,
      wrapped wrappedKeyPath: ReferenceWritableKeyPath<OuterSelf, Value>,
      storage storageKeyPath: ReferenceWritableKeyPath<OuterSelf, Self>
    ) -> Value {
      get {
        let data = instance.userDefaults.data(forKey: instance[keyPath: storageKeyPath].key) ?? Data()
        return (try? decoder.decode(Value.self, from: data)) ?? instance[keyPath: storageKeyPath].defaultValue
      }
      set {
        instance.objectWillChange.send()
        let data = (try? encoder.encode(newValue)) ?? Data()
        instance.userDefaults.set(data, forKey: instance[keyPath: storageKeyPath].key)
      }
    }
  }
}
