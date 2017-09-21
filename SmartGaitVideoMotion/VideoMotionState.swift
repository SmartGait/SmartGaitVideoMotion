//
//  VideoMotionState.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 30/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation

struct VideoMotionState {
  var iOSIndex = 0
  var watchOSIndex = 0
  var paused = false
  var watchInitialCheck = true

  mutating func reset() {
    iOSIndex = 0
    watchOSIndex = 0
    paused = true
    watchInitialCheck = true
  }
}
