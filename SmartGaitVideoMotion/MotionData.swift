//
//  MotionData.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 28/02/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation

protocol MotionData {
  var zTimestamp: Double { get set }
  var zClassificationSummary: String? { get set }
  var zCurrentActivity: String? { get set }

  init (dict: [String: String], prefix: String) throws
  func toDictionary() -> NSMutableDictionary
  mutating func set(element: String, in attribute: SettableAttribute)
}

extension MotionData {
  init (dict: [String: String]) throws {
    try self.init(dict: dict, prefix: "")
  }
}

enum SettableAttribute {
  case label
  case activity
}
