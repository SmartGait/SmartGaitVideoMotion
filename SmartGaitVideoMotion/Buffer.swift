//
//  Buffer.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 05/04/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation
import Cocoa

class Buffer: NSObject {
  fileprivate var initialTimestamp: Double
  fileprivate var limitTimestamp: Double
  fileprivate let interval: Double
  fileprivate var lastMean = (x: 0.0, y: 0.0, z: 0.0)
  fileprivate var lastRMS = (x: 0.0, y: 0.0, z: 0.0)
  fileprivate let identifier: String

  var buffer: [MotionData] = []
  var pendingBuffer: [MotionData] = []


  enum BufferState {
    case nonEmpty
    case full
  }

  init(identifier: String, initialTimestamp: Double, interval: Double = 0.2) {
    self.identifier = identifier
    self.initialTimestamp = initialTimestamp
    self.interval = interval
    self.limitTimestamp = initialTimestamp + interval
  }

  func append(motionData: MotionData) -> BufferState {
    if motionData.zTimestamp < limitTimestamp {
      buffer.append(motionData)
      return .nonEmpty
    }
    else {
      pendingBuffer.append(motionData)
      return .full
    }
  }

  func nextBatch() {
    buffer = pendingBuffer
    limitTimestamp += interval
  }

  func reset() {
    buffer = []
    limitTimestamp = initialTimestamp + interval
  }
}
