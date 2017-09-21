//
//  ClassifiedMotionData.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 01/06/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation

struct ClassifiedMotionData: MotionData {
  //MARK: - iOS
  let identifier: Int?
  let initialTimestamp: Double
  let finalTimestamp: Double

  let maxX: Double
  let maxY: Double
  let maxZ: Double

  let minX: Double
  let minY: Double
  let minZ: Double

  let diffMaxMinX: Double
  let diffMaxMinY: Double
  let diffMaxMinZ: Double

  let averageGravityX: Double
  let averageGravityY: Double
  let averageGravityZ: Double

  let diffAverageGravityX: Double
  let diffAverageGravityY: Double
  let diffAverageGravityZ: Double

  let standardDeviationX: Double
  let standardDeviationY: Double
  let standardDeviationZ: Double

  let rmsX: Double
  let rmsY: Double
  let rmsZ: Double

  let sumOfDifferencesX: Double
  let sumOfDifferencesY: Double
  let sumOfDifferencesZ: Double

  let sumOfMagnitudeDifferences: Double

  let angle: Double?

  let rotationRate: Double?

  let volume: Double?

  let currentActivity: String?
  let samplesUsed: Int?
  var dataClassification: String?

  var zTimestamp: Double

  //MARK: - should never be set
  var zCurrentActivity: String?
  var zClassificationSummary: String?

  init (dict: [String: String], prefix: String = "") throws {
    identifier = try? dict.map(withKey: "\(prefix)zIdentifier".uppercased())
    initialTimestamp = try dict.map(withKey: "\(prefix)zinitialTimestamp".uppercased())
    finalTimestamp = try dict.map(withKey: "\(prefix)zfinalTimestamp".uppercased())

    maxX = try dict.map(withKey: "\(prefix)zGravityXMax".uppercased())
    maxY = try dict.map(withKey: "\(prefix)zGravityYMax".uppercased())
    maxZ = try dict.map(withKey: "\(prefix)zGravityZMax".uppercased())

    minX = try dict.map(withKey: "\(prefix)zGravityXMin".uppercased())
    minY = try dict.map(withKey: "\(prefix)zGravityYMin".uppercased())
    minZ = try dict.map(withKey: "\(prefix)zGravityZMin".uppercased())

    diffMaxMinX = try dict.map(withKey: "\(prefix)zGravityXDiffMaxMin".uppercased())
    diffMaxMinY = try dict.map(withKey: "\(prefix)zGravityYDiffMaxMin".uppercased())
    diffMaxMinZ = try dict.map(withKey: "\(prefix)zGravityZDiffMaxMin".uppercased())

    averageGravityX = try dict.map(withKey: "\(prefix)zGravityXMean".uppercased())
    averageGravityY = try dict.map(withKey: "\(prefix)zGravityYMean".uppercased())
    averageGravityZ = try dict.map(withKey: "\(prefix)zGravityZMean".uppercased())

    diffAverageGravityX = try dict.map(withKey: "\(prefix)zGravityXDiffMean".uppercased())
    diffAverageGravityY = try dict.map(withKey: "\(prefix)zGravityYDiffMean".uppercased())
    diffAverageGravityZ = try dict.map(withKey: "\(prefix)zGravityZDiffMean".uppercased())

    standardDeviationX = try dict.map(withKey: "\(prefix)zGravityXSTDDEV".uppercased())
    standardDeviationY = try dict.map(withKey: "\(prefix)zGravityYSTDDEV".uppercased())
    standardDeviationZ = try dict.map(withKey: "\(prefix)zGravityZSTDDEV".uppercased())

    rmsX = try dict.map(withKey: "\(prefix)ZGRAVITYXRMS".uppercased())
    rmsY = try dict.map(withKey: "\(prefix)ZGRAVITYYRMS".uppercased())
    rmsZ = try dict.map(withKey: "\(prefix)ZGRAVITYZRMS".uppercased())

    sumOfDifferencesX = try dict.map(withKey: "\(prefix)ZGRAVITYXSUMOFDIFFERENCES".uppercased())
    sumOfDifferencesY = try dict.map(withKey: "\(prefix)ZGRAVITYYSUMOFDIFFERENCES".uppercased())
    sumOfDifferencesZ = try dict.map(withKey: "\(prefix)ZGRAVITYZSUMOFDIFFERENCES".uppercased())

    sumOfMagnitudeDifferences = try dict.map(withKey: "\(prefix)SUMOFMAGNITUDEDIFFERENCES".uppercased())

    angle = try? dict.map(withKey: "\(prefix)ANGLE".uppercased())

    rotationRate = try? dict.map(withKey: "\(prefix)GRAVITATIONROTATION".uppercased())

    volume = try? dict.map(withKey: "\(prefix)Z3DVOLUME".uppercased())

    currentActivity = dict["\(prefix)currentActivity".uppercased()]
    samplesUsed = try? dict.map(withKey: "\(prefix)samplesUsed".uppercased())
    dataClassification = dict["\(prefix)zLabel".uppercased()]

    zTimestamp = initialTimestamp
  }

  func toDictionary() -> NSMutableDictionary {
    let motionData = NSMutableDictionary()
    return motionData
  }
}

extension ClassifiedMotionData {
  mutating func set(element: String, in attribute: SettableAttribute) {
    switch attribute {
    case .label:
      dataClassification = element
    default: break
    }
  }
}
