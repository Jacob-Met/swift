// RUN: %empty-directory(%t)
// RUN: split-file %s %t
// RUN: %target-build-swift %t/Lib.swift -module-name Lib -emit-library \
// RUN:   -emit-module -emit-module-path %t/Lib.swiftmodule \
// RUN:   -o %t/%target-library-name(Lib)
// RUN: %target-build-swift %t/Client.swift -I %t -L %t -lLib -o %t/a.out
// RUN: %target-codesign %t/a.out
// RUN: %target-run %t/a.out %t/%target-library-name(Lib) | %FileCheck %s
// REQUIRES: executable_test

// https://github.com/swiftlang/swift/issues/94059
// Identity for requirements of a non-resilient protocol must be distinct
// across inherited protocols and stable across module boundaries. The library
// is intentionally built without library evolution support.

//--- Lib.swift
public protocol Base {
  var first: String { get }
  var second: String { get }
}

public protocol Derived: Base {
  var third: String { get }
  var fourth: String { get }
}

public extension Derived {
  func firstKeyPath() -> PartialKeyPath<Self> { \.first }
}

public struct Concrete: Derived {
  public init() {}
  public var first: String { "first" }
  public var second: String { "second" }
  public var third: String { "third" }
  public var fourth: String { "fourth" }
}

//--- Client.swift
import Lib

extension Derived {
  func checkIdentity() {
    let paths: [PartialKeyPath<Self>] = [\.first, \.second, \.third, \.fourth]
    // CHECK: distinct: 4
    print("distinct: \(Set(paths).count)")
    // CHECK: shared: true
    print("shared: \(paths[0] == firstKeyPath())")
  }
}

Concrete().checkIdentity()
