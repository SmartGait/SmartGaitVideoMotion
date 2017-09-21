//
//  SelectFieldView.swift
//  SmartGaitVideoMotion
//
//  Created by Francisco Gonçalves on 29/05/2017.
//  Copyright © 2017 Francisco Gonçalves. All rights reserved.
//

import Cocoa

@objc protocol SelectFieldViewDelegate {
  func didSelectSelectFileButton(_ sender : NSButton)
}

final class SelectFieldView: NSView {
  var selectField: SelectField
  let titleField: NSTextField
  let fileField: NSTextField
  let selectFileButton: NSButton
  let stackView: NSStackView

  let id: SelectData

  weak var delegate: SelectFieldViewDelegate?

  required init?(coder: NSCoder) {
    fatalError("Can't init from coder")
  }

  init(selectField: SelectField) {
    self.selectField = selectField
    id = selectField.identifier
    titleField = NSTextField(wrappingLabelWithString: selectField.title)
    fileField = NSTextField(string: selectField.value)
    selectFileButton = NSButton(title: "Select File",
                                target: delegate,
                                action: #selector(SelectFieldViewDelegate.didSelectSelectFileButton(_:)))
    selectFileButton.identifier = id.rawValue

    stackView = NSStackView(views: [titleField, fileField, selectFileButton])
    super.init(frame: .zero)

    setupConstraints()
  }

  func setupConstraints() {
    addSubview(stackView)
    stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    fileField.widthAnchor.constraint(equalToConstant: 500).isActive = true
  }

  func updateSelectedFileField(file: String) {
    fileField.stringValue = file
    selectField.update(value: file)
  }
}
