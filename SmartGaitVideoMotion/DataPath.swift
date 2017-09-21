//
//  SmartGaitData.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 29/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation

protocol DataPath {
  var videoPath: String { get set }
}

struct RawDataPath: DataPath {
  var videoPath: String
  var iOSPath: String
  var watchOSPath: String

  init(videoPath: String, iOSPath: String, watchOSPath: String) throws {
    guard videoPath.characters.count > 0 && iOSPath.characters.count > 0 && watchOSPath.characters.count > 0 else {
      throw "Data must be valid"
    }

    self.videoPath = videoPath
    self.iOSPath = iOSPath
    self.watchOSPath = watchOSPath
  }
}

struct RawClassifiedDataPath: DataPath {
  var videoPath: String
  var iOSPath: String
  var watchOSPath: String

  init(videoPath: String, iOSPath: String, watchOSPath: String) throws {
    guard videoPath.characters.count > 0 && iOSPath.characters.count > 0 && watchOSPath.characters.count > 0 else {
      throw "Data must be valid"
    }

    self.videoPath = videoPath
    self.iOSPath = iOSPath
    self.watchOSPath = watchOSPath
  }
}

struct ClassifiedDataPath: DataPath {
  var videoPath: String
  let mergedPath: String

  init(videoPath: String, mergedPath:String) throws {
    guard videoPath.characters.count > 0
      && mergedPath.characters.count > 0
    else {
      throw "Data must be valid"
    }

    self.videoPath = videoPath
    self.mergedPath = mergedPath
  }
}
