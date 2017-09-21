//
//  ClassifiedDataViewModel.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 29/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation

struct ClassifiedDataViewModel: SelectDataViewModel {
  var videoSelector: SelectField
  var mergedDataSelector: SelectField

  init() {
    videoSelector = SelectField(title: "Video", value: nil, identifier: .video, pathKey: .video)
    mergedDataSelector = SelectField(title: "Merged Data", value: nil, identifier: .mergedData, pathKey: .mergedData)
  }

  func selectableFields() -> [SelectField] {
    return [videoSelector, mergedDataSelector]
  }

  func getVideoMotionViewModel() throws -> DataPath {
    guard let videoPath = videoSelector.value,
      let mergedData = mergedDataSelector.value else {
        throw "Some paths were not selectd"
    }
    return try ClassifiedDataPath (
      videoPath: videoPath,
      mergedPath: mergedData
    )
  }

  mutating func update(selectableFields: [SelectField]) {
    selectableFields.filter { $0.identifier == .video }.first.flatMap { videoSelector = $0 }
    selectableFields.filter { $0.identifier == .mergedData }.first.flatMap { mergedDataSelector = $0 }
  }
}
