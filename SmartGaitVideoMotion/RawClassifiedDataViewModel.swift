//
//  RawClassifiedDataViewModel.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 15/06/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation

struct RawClassifiedDataViewModel: SelectDataViewModel {
  var videoSelector: SelectField
  var iOSDataSelector: SelectField
  var watchOSDataSelector: SelectField

  init() {
    videoSelector = SelectField(title: "Video", value: nil, identifier: .video, pathKey: .video)
    iOSDataSelector = SelectField(title: "iOS Data", value: nil, identifier: .iOSRawData, pathKey: .iOSRawClassifiedData)
    watchOSDataSelector = SelectField(title: "watchOS Data", value: nil, identifier: .watchOSRawData, pathKey: .watchOSRawClassifiedData)
  }

  func selectableFields() -> [SelectField] {
    return [videoSelector, iOSDataSelector, watchOSDataSelector]
  }

  func getVideoMotionViewModel() throws -> DataPath {
    guard let videoPath = videoSelector.value,
      let iOSPath = iOSDataSelector.value,
      let watchOSPath = watchOSDataSelector.value else {
        throw "Some paths were not selectd"
    }
    return try RawClassifiedDataPath(videoPath: videoPath, iOSPath: iOSPath, watchOSPath: watchOSPath)
  }

  mutating func update(selectableFields: [SelectField]) {
    selectableFields.filter { $0.identifier == .video }.first.flatMap { videoSelector = $0 }
    selectableFields.filter { $0.identifier == .iOSRawData }.first.flatMap { iOSDataSelector = $0 }
    selectableFields.filter { $0.identifier == .watchOSRawData }.first.flatMap { watchOSDataSelector = $0 }
  }
}
