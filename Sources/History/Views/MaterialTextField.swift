//
//  MaterialTextField.swift
//  RMBT
//
//  Created by Polina on 08.11.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {

    var bottomBorder: CALayer!
    var floatingLabel: UILabel!
    var placeHolderText: String?
    
    var defaultBorderColor: UIColor = .lightGray

    var floatingLabelColor: UIColor = UIColor(named: "greenButtonBackground") ?? .black {
        didSet {
            self.floatingLabel.textColor = floatingLabelColor
        }
    }

    var floatingLabelFont: UIFont = UIFont.systemFont(ofSize: 15) {
      didSet {
        self.floatingLabel.font = floatingLabelFont
      }
    }

    var floatingLabelHeight: CGFloat = 30

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

        let flotingLabelFrame = CGRect(x: 0, y: 0, width: frame.width, height: 0)

        floatingLabel = UILabel(frame: flotingLabelFrame)
        floatingLabel.textColor = floatingLabelColor
        floatingLabel.font = floatingLabelFont
        floatingLabel.text = self.placeholder

        self.addSubview(floatingLabel)
        placeHolderText = placeholder

        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing), name: UITextField.textDidBeginEditingNotification, object: self)

        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditing), name: UITextField.textDidEndEditingNotification, object: self)
        
        self.borderStyle = .none
        bottomBorder = CALayer()
        bottomBorder.backgroundColor = defaultBorderColor.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomBorder.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.width, height: 1.0)
        self.layer.addSublayer(bottomBorder)
    }

    @objc func textFieldDidBeginEditing(_ textField: UITextField) {

        if self.text == "" {
            UIView.animate(withDuration: 0.3) {
                self.floatingLabel.frame = CGRect(x: 0, y: -self.floatingLabelHeight, width: self.frame.width, height: self.floatingLabelHeight)
                self.bottomBorder.backgroundColor = UIColor(named: "greenButtonBackground")?.cgColor
            }
            self.placeholder = ""
        }
    }

    @objc func textFieldDidEndEditing(_ textField: UITextField) {

        if self.text == "" {
            UIView.animate(withDuration: 0.1) {
                self.floatingLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 0)
                self.layer.sublayers?.first?.backgroundColor = UIColor.lightGray.cgColor
                self.bottomBorder.backgroundColor = self.defaultBorderColor.cgColor
            }
            self.placeholder = placeHolderText
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
