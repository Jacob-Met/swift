// RUN: %target-run-simple-swift | %FileCheck %s
// RUN: %target-run-simple-swift(-O) | %FileCheck %s
// REQUIRES: executable_test

// https://github.com/swiftlang/swift/issues/94059
// An associated-type requirement shifts the witness-table indices. Distinct
// requirements on the inherited protocol must still have distinct key paths.
protocol Ancestor {
  associatedtype Value
  var alpha: Value { get }
  var beta: Value { get }
}

protocol Descendant: Ancestor {
  var gamma: Value { get }
  var delta: Value { get }
}

extension Descendant {
  func checkKeyPaths() {
    let paths: [PartialKeyPath<Self>] = [\.alpha, \.beta, \.gamma, \.delta]
    // CHECK: associated-distinct: 4
    print("associated-distinct: \(Set(paths).count)")
    var keys: [PartialKeyPath<Self>: Int] = [:]
    for (index, keyPath) in paths.enumerated() {
      keys[keyPath] = index
    }
    // CHECK: associated-dictionary: 4
    print("associated-dictionary: \(keys.count)")
    // CHECK: associated-same: true
    print("associated-same: \(paths[0] == \Self.alpha)")
    // CHECK: associated-different: true
    print("associated-different: \(paths[0] != paths[2])")
  }
}

struct AssociatedConcrete: Descendant {
  let alpha = 1
  let beta = 2
  let gamma = 3
  let delta = 4
}

AssociatedConcrete().checkKeyPaths()
