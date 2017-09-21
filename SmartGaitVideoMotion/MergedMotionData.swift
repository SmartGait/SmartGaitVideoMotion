//
//  MergedMotionData.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 01/06/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation

struct MergedMotionData: MotionData {
  var iOSClassifiedData: ClassifiedMotionData
  var watchOSClassifiedData: ClassifiedMotionData
  var dataClassification: String?
  let classificationSummary: String?
  let currentActivity: String?

  var zTimestamp: Double

  var zCurrentActivity: String? {
    get { return currentActivity }
    set { }
  }
  var zClassificationSummary: String? {
    get { return classificationSummary }
    set { }
  }

  init (dict: [String: String], prefix: String = "") throws {
    iOSClassifiedData = try ClassifiedMotionData(dict: dict, prefix: "iOS - ")
    watchOSClassifiedData = try ClassifiedMotionData(dict: dict, prefix: "watchOS - ")
    dataClassification =  dict["dataClassification"]
    classificationSummary = dict["classificationSummary"]
    currentActivity = dict["currentActivity"]
    zTimestamp = iOSClassifiedData.zTimestamp
  }

  mutating func set(element: String, in attribute: SettableAttribute) {
    switch attribute {
    case .label:
      dataClassification = element
      iOSClassifiedData.set(element: element, in: attribute)
      watchOSClassifiedData.set(element: element, in: attribute)
    default: break
    }
  }

  func toDictionary() -> NSMutableDictionary {
    return NSMutableDictionary()
  }
}
