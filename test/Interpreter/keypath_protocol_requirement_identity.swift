// RUN: %target-run-simple-swift | %FileCheck %s
// RUN: %target-run-simple-swift(-O) | %FileCheck %s
// REQUIRES: executable_test

// https://github.com/swiftlang/swift/issues/94059
// Witness-table offsets are local to a protocol; key paths to distinct
// requirements inherited from two protocols must not share an identity.
protocol Base {
  var first: String { get }
  var second: String { get }
  var third: String { get }
}

protocol Derived: Base {
  var fourth: String { get }
  var fifth: String { get }
  var sixth: String { get }
}

extension Derived {
  func checkKeyPaths() {
    let keyPaths: [PartialKeyPath<Self>] = [
      \.first, \.second, \.third, \.fourth, \.fifth, \.sixth
    ]
    // CHECK: distinct: 6
    print("distinct: \(Set(keyPaths).count)")
    var keys: [PartialKeyPath<Self>: Int] = [:]
    for (index, keyPath) in keyPaths.enumerated() {
      keys[keyPath] = index
    }
    // CHECK: dictionary: 6
    print("dictionary: \(keys.count)")
    // CHECK: same: true
    print("same: \(keyPaths[0] == \Self.first)")
    // CHECK: different: true
    print("different: \(keyPaths[1] != keyPaths[3])")
  }
}

struct Concrete: Derived {
  let first = "first"
  let second = "second"
  let third = "third"
  let fourth = "fourth"
  let fifth = "fifth"
  let sixth = "sixth"
}

Concrete().checkKeyPaths()
