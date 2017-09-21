//
//  SelectDataViewModel.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 29/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation

protocol SelectDataViewModel {
  func selectableFields() -> [SelectField]
  func getVideoMotionViewModel() throws -> DataPath
  mutating func update(selectableFields: [SelectField])
}
