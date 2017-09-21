//
//  Result.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 15/04/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation

typealias ClassesDistribution = (balanced: Int, imbalanced: Int)

class Result {
  var numberOfRightBalanced = 0
  var numberOfWrongBalanced = 0
  var numberOfRightImbalanced = 0
  var numberOfWrongImbalanced = 0
  let identifier: String

  init(identifier: String) {
    self.identifier = identifier
  }

  func update(classesDistribution: ClassesDistribution, classification: Classification) {

    if classesDistribution.balanced >= classesDistribution.imbalanced {

      if (classification == .balanced) {
        self.numberOfRightBalanced += 1
      }
      else {
        self.numberOfWrongBalanced += 1
      }
    } else if classesDistribution.balanced < classesDistribution.imbalanced {
      if (classification == .imbalanced) {
        self.numberOfRightImbalanced += 1
      }
      else {
        self.numberOfWrongImbalanced += 1
      }
    }

  }

  func reset() {
    numberOfRightBalanced = 0
    numberOfWrongBalanced = 0
    numberOfRightImbalanced = 0
    numberOfWrongImbalanced = 0
  }

  func printReport() {
    print("===========")
    print("Data: \(identifier)")
    print("a b <- classified")
    print("\(numberOfRightBalanced) \(numberOfWrongBalanced) | a = balanced")
    print("\(numberOfWrongImbalanced) \(numberOfRightBalanced) | b = imbalanced")

    let correctlyClassified: Double = Double(numberOfRightBalanced + numberOfRightImbalanced) / Double((numberOfRightBalanced + numberOfWrongBalanced + numberOfRightImbalanced + numberOfWrongImbalanced)) * 100

    let incorrectlyClassified: Double = 100 - correctlyClassified

    print("Correctly classified: \(correctlyClassified)")
    print("Incorrectly classified: \(incorrectlyClassified)")
    print("===========")
  }

}
