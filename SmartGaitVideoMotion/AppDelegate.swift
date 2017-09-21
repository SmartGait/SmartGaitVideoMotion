//
//  AppDelegate.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 27/02/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  var smartGaitWindowController: NSWindowController?
  var selectDataWindowController: NSWindowController?

  var videoMotionWindow: NSWindowController?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  @IBAction func exportFiles(_ sender: NSMenuItem) {
    openDialog { (path) in
      let window = NSApplication.shared().keyWindow
      let activeController = window?.contentViewController as? Exportable
      activeController?.exportCSV(toPath: path)
    }
  }

  func openDialog(_ callback: ((_ path: String) -> Void)) {
    let dialog = NSOpenPanel();

    dialog.title                   = "Choose a directory";
    dialog.showsResizeIndicator    = true
    dialog.showsHiddenFiles        = false
    dialog.canChooseDirectories    = true
    dialog.canCreateDirectories    = true
    dialog.allowsMultipleSelection = false
    dialog.canChooseFiles = false

    if (dialog.runModal() == NSModalResponseOK) {
      guard let result = dialog.url else {
        return
      }
      callback(result.path)
    } else {
      // User clicked on "Cancel"
      return
    }
  }

  func showSmartGaitViewController<ViewModel: VideoMotionViewModel>(viewModel: ViewModel) throws {
    videoMotionWindow = VideoMotionWindowController<ViewModel>()
    let viewController = videoMotionWindow?.contentViewController as? VideoMotionViewController<ViewModel>

    do {
      viewController?.viewModel = viewModel
      try viewController?.setupData()
    } catch let error {
      print(error)
    }

    let oldWindow = NSApplication.shared().keyWindow
    oldWindow?.close()

    videoMotionWindow?.showWindow(self)
    videoMotionWindow?.window?.makeKey()
  }

  func showSmartGaitViewController(data: DataPath) {
    do {
      switch data {
      case let data as RawDataPath:
        try showSmartGaitViewController(viewModel: try RawVideoMotionViewModel(dataPath: data))
      case let data as RawClassifiedDataPath:
        try showSmartGaitViewController(viewModel: try RawClassifiedVideoMotionViewModel(dataPath: data))
      case let data as ClassifiedDataPath:
        try showSmartGaitViewController(viewModel: try ClassifiedVideoMotionViewModel(dataPath: data))
      default:
        break
      }
    } catch let error {
      print(error)
    }
  }

  func showSelectDataViewController(withViewModel viewModel: SelectDataViewModel) {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    selectDataWindowController = storyboard
      .instantiateController(withIdentifier: "SelectDataWindowController") as? NSWindowController

    let vc = selectDataWindowController?.contentViewController as? SelectDataViewController
    vc?.viewModel = viewModel
    vc?.didSetViewModel()

    let window = NSApplication.shared().keyWindow
    window?.close()

    selectDataWindowController?.showWindow(self)
    selectDataWindowController?.window?.makeKey()
  }
}

