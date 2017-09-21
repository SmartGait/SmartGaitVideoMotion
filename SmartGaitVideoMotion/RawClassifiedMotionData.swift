//
//  RawClassifiedMotionData.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 15/06/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation

struct RawClassifiedMotionData: MotionData {
  let zMagneticFieldAccuracy: Double
  let zAttitudeW: Double
  let zAttitudeX: Double
  let zAttitudeY: Double
  let zAttitudeZ: Double
  let zGravityX: Double
  let zGravityY: Double
  let zGravityZ: Double
  let zMagneticFieldX: Double
  let zMagneticFieldY: Double
  let zMagneticFieldZ: Double
  let zRotationRateX: Double
  let zRotationRateY: Double
  let zRotationRateZ: Double
  var zTimestamp: Double
  let zUserAccelerationX: Double
  let zUserAccelerationY: Double
  let zUserAccelerationZ: Double
  var zLabel: String?

  var zInitialTimestamp: Double
  var zFinalTimestamp: Double
  var zSamplesUsed: Double
  var zDataClassification: String?
  var zIdentifier: String?
  var zCurrentActivity: String?
  var zClassificationSummary: String?

  var zOldDataClassification: String?
  var zNewCurrentActivity: String?

  init (dict: [String: String], prefix: String = "") throws {
    func map(dict: [String: String], value: String) throws -> Double {
      guard let valueString = dict[value], let valueDouble = Double(valueString) else {
        throw "Couldn't parse"
      }
      return valueDouble
    }

    zMagneticFieldAccuracy = try map(dict: dict, value: "zMagneticFieldAccuracy".uppercased())
    zAttitudeW = try map(dict: dict, value: "zAttitudeW".uppercased())
    zAttitudeX = try map(dict: dict, value: "zAttitudeX".uppercased())
    zAttitudeY = try map(dict: dict, value: "zAttitudeY".uppercased())
    zAttitudeZ = try map(dict: dict, value: "zAttitudeZ".uppercased())
    zGravityX = try map(dict: dict, value: "zGravityX".uppercased())
    zGravityY = try map(dict: dict, value: "zGravityY".uppercased())
    zGravityZ = try map(dict: dict, value: "zGravityZ".uppercased())
    zMagneticFieldX = try map(dict: dict, value: "zMagneticFieldX".uppercased())
    zMagneticFieldY = try map(dict: dict, value: "zMagneticFieldY".uppercased())
    zMagneticFieldZ = try map(dict: dict, value: "zMagneticFieldZ".uppercased())
    zRotationRateX = try map(dict: dict, value: "zRotationRateX".uppercased())
    zRotationRateY = try map(dict: dict, value: "zRotationRateY".uppercased())
    zRotationRateZ = try map(dict: dict, value: "zRotationRateZ".uppercased())
    zTimestamp = try map(dict: dict, value: "zTimestamp".uppercased())
    zUserAccelerationX = try map(dict: dict, value: "zUserAccelerationX".uppercased())
    zUserAccelerationY = try map(dict: dict, value: "zUserAccelerationY".uppercased())
    zUserAccelerationZ = try map(dict: dict, value: "zUserAccelerationZ".uppercased())
    zLabel = dict["zLabel".uppercased()]

    zCurrentActivity = dict["zCurrentActivity".uppercased()]
    zInitialTimestamp = try map(dict: dict, value: "zInitialTimestamp".uppercased())
    zFinalTimestamp = try map(dict: dict, value: "zFinalTimestamp".uppercased())
    zSamplesUsed = try map(dict: dict, value: "zSamplesUsed".uppercased())
    zDataClassification = dict["zDataClassification".uppercased()]
    zIdentifier = dict["zIdentifier".uppercased()]
    zClassificationSummary = dict["zClassificationSummary".uppercased()]

    zOldDataClassification = dict["zOldDataClassification".uppercased()]
    zNewCurrentActivity = dict["zNewCurrentActivity".uppercased()]
  }

  mutating func set(element: String, in attribute: SettableAttribute) {
    switch attribute {
    case .label:
      if zOldDataClassification == nil {
        zOldDataClassification = zDataClassification
      }
      zDataClassification = element
    case .activity:
      zNewCurrentActivity = element
    }
  }

  func toDictionary() -> NSMutableDictionary {
    let motionData = NSMutableDictionary()
    motionData.setObject(zMagneticFieldAccuracy, forKey: "zMagneticFieldAccuracy".uppercased() as NSCopying);
    motionData.setObject(zAttitudeX, forKey: "zAttitudeX".uppercased() as NSCopying);
    motionData.setObject(zAttitudeW, forKey: "zAttitudeW".uppercased() as NSCopying);
    motionData.setObject(zAttitudeY, forKey: "zAttitudeY".uppercased() as NSCopying);
    motionData.setObject(zAttitudeZ, forKey: "zAttitudeZ".uppercased() as NSCopying);
    motionData.setObject(zGravityX, forKey: "zGravityX".uppercased() as NSCopying);
    motionData.setObject(zGravityY, forKey: "zGravityY".uppercased() as NSCopying);
    motionData.setObject(zGravityZ, forKey: "zGravityZ".uppercased() as NSCopying);
    motionData.setObject(zMagneticFieldX, forKey: "zMagneticFieldX".uppercased() as NSCopying);
    motionData.setObject(zMagneticFieldY, forKey: "zMagneticFieldY".uppercased() as NSCopying);
    motionData.setObject(zMagneticFieldZ, forKey: "zMagneticFieldZ".uppercased() as NSCopying);
    motionData.setObject(zRotationRateX, forKey: "zRotationRateX".uppercased() as NSCopying);
    motionData.setObject(zRotationRateY, forKey: "zRotationRateY".uppercased() as NSCopying);
    motionData.setObject(zRotationRateZ, forKey: "zRotationRateZ".uppercased() as NSCopying);
    motionData.setObject(zTimestamp, forKey: "zTimestamp".uppercased() as NSCopying);
    motionData.setObject(zUserAccelerationX, forKey: "zUserAccelerationX".uppercased() as NSCopying);
    motionData.setObject(zUserAccelerationY, forKey: "zUserAccelerationY".uppercased() as NSCopying);
    motionData.setObject(zUserAccelerationZ, forKey: "zUserAccelerationZ".uppercased() as NSCopying);
    motionData.setObject(zLabel ?? "?", forKey: "zLabel".uppercased() as NSCopying);

    motionData.setObject(zCurrentActivity ?? "?", forKey: "zCurrentActivity".uppercased() as NSCopying);
    motionData.setObject(zInitialTimestamp, forKey: "zInitialTimestamp".uppercased() as NSCopying);
    motionData.setObject(zFinalTimestamp, forKey: "zFinalTimestamp".uppercased() as NSCopying);
    motionData.setObject(zSamplesUsed, forKey: "zSamplesUsed".uppercased() as NSCopying);
    motionData.setObject(zDataClassification ?? "?", forKey: "zDataClassification".uppercased() as NSCopying);
    motionData.setObject(zIdentifier ?? "?", forKey: "zIdentifier".uppercased() as NSCopying);

    motionData.setObject(zClassificationSummary ?? "?", forKey: "zClassificationSummary".uppercased() as NSCopying);
    motionData.setObject(zOldDataClassification ?? "?", forKey: "zOldDataClassification".uppercased() as NSCopying);
    motionData.setObject(zNewCurrentActivity ?? "?", forKey: "zNewCurrentActivity".uppercased() as NSCopying);

    return motionData
  }
}
