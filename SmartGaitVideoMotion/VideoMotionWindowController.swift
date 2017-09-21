//
//  VideoMotionWindowController.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 31/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Cocoa

class VideoMotionWindowController<ViewModel: VideoMotionViewModel>: NSWindowController {

  convenience init() {
    let viewController = VideoMotionViewController<ViewModel>(nibName: "VideoMotionViewController")
    self.init(window: NSWindow(contentViewController: viewController!))
  }

  override func windowDidLoad() {
    super.windowDidLoad()

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
  }

}
