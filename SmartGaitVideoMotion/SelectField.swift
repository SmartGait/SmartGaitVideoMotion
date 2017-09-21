//
//  SelectField.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 29/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation

struct SelectField {
  let title: String
  var value: String?
  let identifier: SelectData
  fileprivate let pathKey: PathKey

  init(title: String, value: String? = nil, identifier: SelectData, pathKey: PathKey) {
    self.title = title
    self.identifier = identifier
    self.pathKey = pathKey
    self.value = value ?? UserDefaults.standard.string(forKey: pathKey.rawValue)
  }

  mutating func update(value: String) {
    self.value = value
  }

  func save() {
    value.flatMap(saveOnUserDefaults)
  }

  private func saveOnUserDefaults(value: String) {
    let preferences = UserDefaults.standard
    preferences.set(value, forKey: pathKey.rawValue)
  }
}
