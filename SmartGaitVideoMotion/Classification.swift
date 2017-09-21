//
//  Classification.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 01/06/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation
import Cocoa

enum Classification: String {
  case balanced
  case imbalanced

  func attributedString(identifier: String) -> NSAttributedString {
    switch self {
    case .balanced:
      return NSAttributedString(string: "\(identifier): balanced", attributes: [NSForegroundColorAttributeName: NSColor.green])
    case .imbalanced:
      return NSAttributedString(string: "\(identifier): imbalanced", attributes: [NSForegroundColorAttributeName: NSColor.red])
    }
  }
}
