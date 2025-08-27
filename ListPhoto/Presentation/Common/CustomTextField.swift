//
//  CustomTextField.swift
//  ListPhoto
//
//  Created by TaiTruong on 26/8/25.
//

import Combine
import UIKit

class CustomTextField: UITextField {
    // MARK: - Properties

    private let maxLength: Int = 15
    private var characterSet = CharacterSet()
    private var newText: String = ""

    let textPublisher = CurrentValueSubject<String, Never>("")

    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.configuration = .plain()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray3
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false // Disable paste
        }
        return super.canPerformAction(action, withSender: sender)
    }

    // MARK: - Setup

    private func setupTextField() {
        delegate = self
        autocorrectionType = .no
        autocapitalizationType = .none
        spellCheckingType = .no
        smartDashesType = .no
        smartQuotesType = .no
        smartInsertDeleteType = .no
        enablesReturnKeyAutomatically = true
        tintColor = .systemGray3

        setupValidationCondition()

        DispatchQueue.main.async { [weak self] in
            self?.addTarget(self, action: #selector(self?.textDidChange), for: .editingChanged)
            self?.showClearButtonIfNeed()
        }
    }

    private func setupValidationCondition() {
        var characterSet = CharacterSet()
        characterSet.formUnion(.lowercaseLetters)
        characterSet.formUnion(.uppercaseLetters)
        characterSet.formUnion(.decimalDigits)
        characterSet.formUnion(.whitespaces)
        characterSet.insert(charactersIn: "!@#$%^&*():.\"")

        self.characterSet = characterSet.inverted
    }

    private func filterText(_ text: String) -> String {
        let components = text.components(separatedBy: characterSet)
        return String(components.joined(separator: "").prefix(maxLength))
    }

    private func showClearButtonIfNeed() {
        if let text = text, !text.isEmpty {
            rightView = clearButton
            rightViewMode = .whileEditing
        } else {
            rightView = nil
            rightViewMode = .never
        }
    }

    @objc
    private func clearButtonTapped() {
        text = ""
        textPublisher.send("")
        showClearButtonIfNeed()
    }

    @objc
    private func textDidChange() {
        guard let currentText = text, currentText != newText else { return }
        text = newText // force showing english character instead of vietnamese. eg: 'Taif' instead of 'Tài'
        textPublisher.send(newText)
        showClearButtonIfNeed()
    }
}

// MARK: - UITextFieldDelegate

extension CustomTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        let filterString = filterText(string)
        if filterString == string {
            newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            if newText.count > maxLength {
                return false
            }
            return true
        }

        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
