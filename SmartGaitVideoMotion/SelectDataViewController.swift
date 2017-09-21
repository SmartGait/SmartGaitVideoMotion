//
//  SelectDataViewController.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 07/03/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Foundation
import Cocoa

enum SelectData: String {
  case video
  case mergedData
  case iOSRawData
  case watchOSRawData
  case iOSProcessedData
  case watchOSProcessedData
}

enum PathKey: String {
  case video
  case mergedData
  case iOSRawData
  case watchOSRawData
  case iOSRawClassifiedData
  case watchOSRawClassifiedData
  case iOSProcessedData
  case watchOSProcessedData
}

class SelectDataViewController: NSViewController {
  @IBOutlet weak var videoTextField: NSTextField!
  @IBOutlet weak var iOSDataTextField: NSTextField!
  @IBOutlet weak var watchOSDataTextField: NSTextField!

  @IBOutlet weak var mainStackView: NSStackView!
  @IBOutlet weak var confirmButton: NSButton!

  var viewModel: SelectDataViewModel!

  var selectedFieldViews: [SelectFieldView]!

  func didSetViewModel() {
    selectedFieldViews = viewModel
      .selectableFields()
      .map(createSelectFieldViews)
      .map(assignDelegate)
      .map(appendToStackView)
  }

  func createSelectFieldViews(forSelectField selectField: SelectField) -> SelectFieldView {
    return SelectFieldView(selectField: selectField)
  }

  func assignDelegate(forSelectFieldView selectFieldView: SelectFieldView) -> SelectFieldView {
    selectFieldView.delegate = self
    return selectFieldView
  }

  func appendToStackView(selectField: SelectFieldView)  -> SelectFieldView {
    mainStackView.addArrangedSubview(selectField)
    mainStackView.insertArrangedSubview(confirmButton, at: mainStackView.arrangedSubviews.count)
    selectField.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor).isActive = true
    selectField.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor).isActive = true
    return selectField
  }

  @IBAction func selectFile(_ sender: NSButton) {
    guard let id = sender.identifier, let data = SelectData(rawValue: id) else {
      return
    }

    openDialog(title: "Select \(data.rawValue)") { findSelectFieldView(forIdentifier: data)?.updateSelectedFileField(file: $0) }
  }

  func findSelectFieldView(forIdentifier identifier: SelectData) -> SelectFieldView? {
    return selectedFieldViews.filter { $0.id == identifier }.first
  }

  func openDialog(title: String, _ callback: ((_ path: String) -> Void)) {
    let dialog = NSOpenPanel()
    dialog.title                   = title
    dialog.showsResizeIndicator    = true
    dialog.showsHiddenFiles        = false
    dialog.canChooseDirectories    = false
    dialog.canCreateDirectories    = false
    dialog.allowsMultipleSelection = false
    dialog.canChooseFiles = true

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
  @IBAction func confirm(_ sender: NSButton) {
    do {
      let selectFields = selectedFieldViews
        .map { $0.selectField }

      selectFields.forEach { $0.save() }
      UserDefaults.standard.synchronize()

      viewModel.update(selectableFields: selectFields)

      let data = try viewModel.getVideoMotionViewModel()

      let appDelegate = NSApp.delegate
      (appDelegate as? AppDelegate)?.showSmartGaitViewController(data: data)
    } catch let error {
      print(error)
    }
  }
}

extension SelectDataViewController: SelectFieldViewDelegate {
  func didSelectSelectFileButton(_ sender : NSButton) {
    selectFile(sender)
  }
}
