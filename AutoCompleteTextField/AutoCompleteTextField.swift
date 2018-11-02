//
//  AutoCompleteTextField.swift
//  AutoCompleteTextField
//
//  Created by Jacob Mendelowitz on 10/19/18.
//  Copyright © 2018 Jacob Mendelowitz. All rights reserved.
//

import UIKit

// MARK: - AutoCompleteTextFieldDelegate
public protocol AutoCompleteTextFieldDelegate: class {
    /// Called when auto-complete results are updated.
    /// - parameter textField: The `AutoCompleteTextField` filtering the results.
    /// - parameter results: A list of `AutoCompletable` results, or `nil` if the text field has no text in it.
    func autoCompleteTextField(_ textField: AutoCompleteTextField, didFilter results: [AutoCompletable]?)
    
    /// Called before a result is about to be selected.
    /// - parameter textField: The `AutoCompleteTextField` the result is selected from.
    /// - parameter result: The `AutoCompletable` result that is about to be selected.
    /// - returns: `true` if the result should be selected, or `false` if it should not.
    func autoCompleteTextField(_ textField: AutoCompleteTextField, shouldSelect result: AutoCompletable) -> Bool
    
    /// Called after a result is selected.
    /// - parameter textField: The `AutoCompleteTextField` the result is selected from.
    /// - parameter result: The `AutoCompletable` result that was just selected.
    func autoCompleteTextField(_ textField: AutoCompleteTextField, didSelect result: AutoCompletable)
}

// MARK: - AutoCompleteTextFieldDelegate Default Implementation
public extension AutoCompleteTextFieldDelegate {
    func autoCompleteTextField(_ textField: AutoCompleteTextField, didFilter results: [AutoCompletable]?) { }
    func autoCompleteTextField(_ textField: AutoCompleteTextField, shouldSelect result: AutoCompletable) -> Bool { return true }
    func autoCompleteTextField(_ textField: AutoCompleteTextField, didSelect result: AutoCompletable) { }
}

// MARK: - AutoCompleteTextField
open class AutoCompleteTextField: UITextField, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Public Enums
    
    /// The direction that the result list will flow.
    public enum ResultListDirection {
        case down
        case up
    }

    // MARK: - Public Properties

    /// The delegate for auto-complete methods.
    open weak var autoCompleteDelegate: AutoCompleteTextFieldDelegate?

    /// The list of objects to use in auto-completion.
    open var dataSource: [AutoCompletable] = [] {
        didSet {
            guard shouldBuildTrieOnNewDataSource else { return }
            createAutoCompleteTrie()
        }
    }
    
    /// If `true`, text field will look for auto-complete results.
    open var shouldAutoComplete: Bool = true
    
    /// If `true`, a search trie will be built when a new `dataSource` is set.
    open var shouldBuildTrieOnNewDataSource: Bool = true
    
    /// If `true`, shows a drop down list of strings for auto-completion.
    open var shouldShowResultList: Bool = true
    
    /// If `true`, shows the rest of an auto-completion result inline with the input text.
    open var shouldShowInlineAutoCompletion: Bool = false
    
    /// If `true`, the auto-complete filtering will be case sensitive.
    open var isCaseSensitive: Bool = false
    
    /// The maximum number of auto-complete results shown in the result list. If `nil`, there is no limit.
    open var maxResultCount: Int? = 50
    
    /// The maximum height of the result list.
    open var maxResultListHeight: CGFloat = 150
    
    /// The distance between the result list and the text field. Positive moves it away, and negative moves it closer.
    open var resultListOffset: CGFloat = 0 {
        didSet {
            resultListTableViewAnchorConstraint?.constant = resultListOffset
            resultListTableView.contentInset = UIEdgeInsets(top: tableViewTopInset, left: 0.0, bottom: tableViewBottomInset, right: 0.0)
            layoutIfNeeded()
        }
    }
    
    /// The color of the text of the auto-complete results.
    open var resultListTextColor: UIColor? = .black
    
    /// The background color of the result list.
    open var resultListBackgroundColor: UIColor? {
        get { return resultListTableView.backgroundColor }
        set { resultListTableView.backgroundColor = newValue }
    }
    
    /// The layer for the result list.
    open var resultListLayer: CALayer {
        return resultListTableView.layer
    }
    
    /// The separator style for cells in the result list.
    open var resultListSeparatorStyle: UITableViewCell.SeparatorStyle {
        get { return resultListTableView.separatorStyle }
        set { resultListTableView.separatorStyle = newValue }
    }
    
    /// The font for the text in the result list.
    open var resultListFont: UIFont? = UIFont.systemFont(ofSize: 14)
    
    /// String attributes for the text in a result that matches the text in the text field.
    open var matchedTextAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 14)
    ]
    
    /// String attributes for the rest of an auto-completion result inline with the input text.
    open var inlineAutoCompletionTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.lightGray, .backgroundColor: UIColor.clear
    ]
    
    /// The direction the result list will flow.
    open var resultListDirection: ResultListDirection = .down {
        didSet {
            resultListTableViewAnchorConstraint?.isActive = false
            resultListTableViewAnchorConstraint = NSLayoutConstraint(
                item: resultListTableView, attribute: resultListDirection == .down ? .top : .bottom,
                relatedBy: .equal,
                toItem: self, attribute: resultListDirection == .down ? .bottom : .top,
                multiplier: 1, constant: adjustedResultListOffset
            )
            resultListTableViewAnchorConstraint?.isActive = true
            resultListTableView.contentInset = UIEdgeInsets(top: tableViewTopInset, left: 0.0, bottom: tableViewBottomInset, right: 0.0)
            layoutIfNeeded()
        }
    }

    // MARK: - Private Properties

    private var loadingView: UIView
    private var loadingActivityIndicatorView: UIActivityIndicatorView
    private var previousRightView: UIView?
    private var previousRightViewMode: UITextField.ViewMode = .never
    
    private var resultListTableView: UITableView
    private var resultListTableViewAnchorConstraint: NSLayoutConstraint?
    private var resultListTableViewHeightConstraint: NSLayoutConstraint?
    
    private weak var textFieldDelegate: UITextFieldDelegate?

    private var autoCompleteTrie: AutoCompleteTrie?
    private var filteredResults: [AutoCompletable] = []

    private var adjustedResultListOffset: CGFloat {
        return resultListDirection == .down ? resultListOffset : -resultListOffset
    }
    
    private var tableViewTopInset: CGFloat {
        return resultListDirection == .down && adjustedResultListOffset < 0 ? -adjustedResultListOffset : 0
    }
    
    private var tableViewBottomInset: CGFloat {
        return resultListDirection == .up && adjustedResultListOffset > 0 ? adjustedResultListOffset : 0
    }
    
    private var currentResultListHeight: CGFloat {
        return tableViewTopInset + tableViewBottomInset
            + (((frame.height * CGFloat(filteredResults.count)) < maxResultListHeight) ? (frame.height * CGFloat(filteredResults.count)) : maxResultListHeight)
    }

    private var currentInputText: String = ""
    private var currentInlineAutoCompletionText: String = ""
    private var autoCompletionResultIndex: Int = 0
    
    private var isFilteringResults: Bool = false
    private var isTextFieldUIUpdating: Bool = false

    private var loadTrieWorkItem: DispatchWorkItem?
    private var filterDataSourceWorkItem: DispatchWorkItem?
    
    // MARK: - Override Properties
    
    open override var delegate: UITextFieldDelegate? {
        didSet {
            if delegate === self { return }
            textFieldDelegate = delegate
            delegate = oldValue
        }
    }
    
    open override var selectedTextRange: UITextRange? {
        didSet {
            guard
                let text = text, let selectedRange = selectedTextRange,
                offset(from: beginningOfDocument, to: selectedRange.start) > text.count - currentInlineAutoCompletionText.count,
                let lastPosition = position(from: beginningOfDocument, offset: text.count - currentInlineAutoCompletionText.count)
                else { return }
            selectedTextRange = textRange(from: lastPosition, to: lastPosition)
        }
    }
    
    // MARK: - Initialzers
    
    public override init(frame: CGRect) {
        loadingView = UIView()
        loadingActivityIndicatorView = UIActivityIndicatorView(style: .gray)
        resultListTableView = UITableView()
        super.init(frame: frame)
        setupAutoCompleteTextField()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        loadingView = UIView()
        loadingActivityIndicatorView = UIActivityIndicatorView(style: .gray)
        resultListTableView = UITableView()
        super.init(coder: aDecoder)
        setupAutoCompleteTextField()
    }
    
    // MARK: - Lifecycle
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        formatResultListTableView()
    }
    
    // MARK: - Setup Functions
    
    private func setupAutoCompleteTextField() {
        delegate = self
        resultListTableView.delegate = self
        resultListTableView.dataSource = self
        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        createLoadingView()
        createResultListTableView()
    }
    
    private func createLoadingView() {
        loadingView.frame = CGRect(x: 0, y: 0, width: frame.height, height: frame.height)
        loadingView.addSubview(loadingActivityIndicatorView)
        loadingActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loadingActivityIndicatorView.isHidden = false
        NSLayoutConstraint(
            item: loadingActivityIndicatorView, attribute: .centerX,
            relatedBy: .equal,
            toItem: loadingView, attribute: .centerX,
            multiplier: 1, constant: 0
        ).isActive = true
        NSLayoutConstraint(
            item: loadingActivityIndicatorView, attribute: .centerY,
            relatedBy: .equal,
            toItem: loadingView, attribute: .centerY,
            multiplier: 1, constant: 0
        ).isActive = true
    }
    
    private func createResultListTableView() {
        addSubview(resultListTableView)
        sendSubviewToBack(resultListTableView)
        resultListTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(
            item: resultListTableView, attribute: .leading,
            relatedBy: .equal,
            toItem: self, attribute: .leading,
            multiplier: 1, constant: 0
        ).isActive = true
        NSLayoutConstraint(
            item: resultListTableView, attribute: .trailing,
            relatedBy: .equal,
            toItem: self, attribute: .trailing,
            multiplier: 1, constant: 0
        ).isActive = true
        resultListTableViewAnchorConstraint = NSLayoutConstraint(
            item: resultListTableView, attribute: .top,
            relatedBy: .equal,
            toItem: self, attribute: .bottom,
            multiplier: 1, constant: adjustedResultListOffset
        )
        resultListTableViewAnchorConstraint?.isActive = true
        resultListTableViewHeightConstraint = NSLayoutConstraint(
            item: resultListTableView, attribute: .height,
            relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute,
            multiplier: 1, constant: 0
        )
        resultListTableViewHeightConstraint?.isActive = true
    }
    
    private func formatResultListTableView() {
        if borderStyle == .roundedRect {
            resultListTableView.layer.borderColor = UIColor.lightGray.cgColor
            resultListTableView.layer.borderWidth = 0.25
            resultListTableView.layer.cornerRadius = 5
            resultListTableView.separatorStyle = .singleLine
            resultListOffset = -15
        } else if borderStyle == .line || borderStyle == .bezel {
            resultListTableView.layer.borderColor = UIColor.black.cgColor
            resultListTableView.layer.borderWidth = 0.5
            resultListTableView.separatorStyle = .singleLine
            resultListOffset = -1
        } else {
            resultListTableView.separatorStyle = .none
            resultListOffset = 0
        }

        resultListTableView.contentInset = UIEdgeInsets(top: tableViewTopInset, left: 0.0, bottom: tableViewBottomInset, right: 0.0)
        resultListTableView.separatorInset = .zero
        
        resultListBackgroundColor = backgroundColor
        resultListFont = font
        if let font = font {
            matchedTextAttributes = [.font: UIFont(name: "\(font.fontName)-Bold", size: font.pointSize) ?? UIFont.systemFont(ofSize: 14, weight: .bold)]
        }
        
        resultListTableView.isHidden = true
        resultListTableView.reloadData()
    }
    
    // MARK: - Public Functions
    
    /// Sets the current text in the text field, to the result at `index`.
    /// - parameter index: The index of the auto-complete result to select.
    open func selectResult(at index: Int) {
        guard index >= 0, index < filteredResults.count else { return }
        let result = filteredResults[index]
        if autoCompleteDelegate?.autoCompleteTextField(self, shouldSelect: result) ?? true {
            currentInputText = result.autoCompleteString
            currentInlineAutoCompletionText = ""
            text = result.autoCompleteString
            playHideResultListAnimation()
            autoCompleteDelegate?.autoCompleteTextField(self, didSelect: result)
        }
    }
    
    /// Sets the current text in the text field to the first result in the list.
    open func selectFirstResult() {
        selectResult(at: 0)
    }
    
    /// Sets the current result to be shown in inline auto-completion.
    /// - parameter index: The index of the auto-complete result to set to appear inline.
    open func setResultForInlineAutoCompletion(at index: Int) {
        autoCompletionResultIndex = index
        if shouldShowInlineAutoCompletion {
            showInlineAutoCompletion(for: currentInputText, at: autoCompletionResultIndex)
        }
    }

    /// Loads an `AutoCompleteTrie` into the `AutoCompleteTextField`.
    /// - parameter autoCompleteTrie: The trie to load.
    open func load(autoCompleteTrie: AutoCompleteTrie) {
        loadTrieWorkItem?.cancel()
        loadTrieWorkItem = nil
        self.autoCompleteTrie = autoCompleteTrie
    }

    // MARK: - Private Logic Functions
    
    private func createAutoCompleteTrie() {
        loadTrieWorkItem?.cancel()
        loadTrieWorkItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.autoCompleteTrie = AutoCompleteTrie(dataSource: strongSelf.dataSource, isCaseSensitive: strongSelf.isCaseSensitive)
            print("Preloaded \(strongSelf.dataSource.count) Total Results")
        }
        guard let loadTrieWorkItem = loadTrieWorkItem else { return }
        DispatchQueue.global(qos: .background).async(execute: loadTrieWorkItem)
    }
    
    private func processResults(for updatedText: String) {
        currentInputText = substring(of: updatedText, before: updatedText.count - currentInlineAutoCompletionText.count)
        autoCompletionResultIndex = 0
        isFilteringResults = true
        filterDataSource(with: currentInputText) { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.shouldShowInlineAutoCompletion, !strongSelf.isTextFieldUIUpdating {
                strongSelf.showInlineAutoCompletion(for: strongSelf.currentInputText, at: strongSelf.autoCompletionResultIndex)
            }
            strongSelf.isFilteringResults = false
            strongSelf.hideLoadingIndicator()
            !strongSelf.currentInputText.isEmpty ? strongSelf.playShowResultListAnimation() : strongSelf.playHideResultListAnimation()
        }
    }
    
    private func filterDataSource(with inputText: String, completion: @escaping () -> Void) {
        filterDataSourceWorkItem?.cancel()
        guard !inputText.isEmpty else {
            filterDataSourceWorkItem = nil
            filteredResults = []
            autoCompleteDelegate?.autoCompleteTextField(self, didFilter: nil)
            completion()
            return
        }
        filterDataSourceWorkItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            if let autoCompleteTrie = strongSelf.autoCompleteTrie {
                strongSelf.filteredResults = autoCompleteTrie.results(for: inputText, limit: strongSelf.maxResultCount) ?? strongSelf.dataSource
            } else {
                strongSelf.filteredResults = strongSelf.filterResultsFrom(unsortedData: strongSelf.dataSource, with: inputText)
            }
            DispatchQueue.main.async {
                strongSelf.autoCompleteDelegate?.autoCompleteTextField(strongSelf, didFilter: strongSelf.filteredResults)
                completion()
            }
        }
        guard let filterDataSourceWorkItem = filterDataSourceWorkItem else { return }
        DispatchQueue.global(qos: .background).async(execute: filterDataSourceWorkItem)
    }
    
    private func filterResultsFrom(unsortedData: [AutoCompletable], with inputText: String) -> [AutoCompletable] {
        var filteredData = [AutoCompletable]()
        for result in unsortedData {
            if isCaseSensitive {
                if result.autoCompleteString.hasPrefix(inputText) {
                    filteredData.append(result)
                }
            } else {
                if result.autoCompleteString.lowercased().hasPrefix(inputText.lowercased()) {
                    filteredData.append(result)
                }
            }
        }
        let sortedData = filteredData.sorted { $0.autoCompleteString.count < $1.autoCompleteString.count }
        if let maxResultCount = maxResultCount {
            return [AutoCompletable](sortedData.prefix(maxResultCount))
        }
        return sortedData
    }
    
    private func showInlineAutoCompletion(for inputText: String, at index: Int) {
        guard let cursorPosition = position(from: beginningOfDocument, offset: inputText.count) else { return }
        var textCompletion = ""
        if !inputText.isEmpty, index >= 0, index < filteredResults.count {
            textCompletion = substring(of: filteredResults[index].autoCompleteString, after: inputText.count)
        }
        currentInlineAutoCompletionText = textCompletion
        attributedText = textByApplying(
            attributes: inlineAutoCompletionTextAttributes,
            to: inputText + textCompletion,
            after: inputText.count
        )
        selectedTextRange = textRange(from: cursorPosition, to: cursorPosition)
    }
    
    // MARK: - Utility Functions
    
    private func substring(of string: String, before index: Int) -> String {
        guard index > -1, index <= string.count else { return "" }
        return String(string[string.startIndex..<string.index(string.startIndex, offsetBy: index)])
    }
    
    private func substring(of string: String, after index: Int) -> String {
        guard index >= -1, index < string.count else { return "" }
        return String(string[string.index(string.startIndex, offsetBy: index)..<string.endIndex])
    }

    private func textByApplying(attributes: [NSAttributedString.Key: Any], to text: String, before index: Int) -> NSAttributedString {
        guard index > -1, index <= text.count else { return NSAttributedString(string: text) }
        let attributedEndIndex = text.index(text.startIndex, offsetBy: index)
        let attributedString = NSMutableAttributedString(string: String(text[text.startIndex..<attributedEndIndex]), attributes: attributes)
        attributedString.append(NSAttributedString(string: String(text[attributedEndIndex..<text.endIndex])))
        return attributedString
    }

    private func textByApplying(attributes: [NSAttributedString.Key: Any], to text: String, after index: Int) -> NSAttributedString {
        guard index >= -1, index < text.count else { return NSAttributedString(string: text) }
        let attributedStartIndex = text.index(text.startIndex, offsetBy: index)
        let attributedString = NSMutableAttributedString(string: String(text[text.startIndex..<attributedStartIndex]))
        attributedString.append(NSAttributedString(string: String(text[attributedStartIndex..<text.endIndex]), attributes: attributes))
        return attributedString
    }
    
    private func showOnlyInputText() {
        currentInlineAutoCompletionText = ""
        text = currentInputText
    }
    
    private func resetAutoCompleteTextField() {
        filteredResults = []
        currentInlineAutoCompletionText = ""
        currentInputText = ""
        text = currentInputText
    }
    
    // MARK: - Override Functions
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in subviews {
            let view = subview.hitTest(convert(point, to: subview), with: event)
            if let view = view { return view }
        }
        return super.hitTest(point, with: event)
    }
    
    // MARK: - UITableViewDelegate
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return frame.height
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "AutoCompleteTableViewCell")
        cell.backgroundColor = .clear
        guard !isFilteringResults, indexPath.row >= 0, indexPath.row < filteredResults.count else { return cell }
        cell.textLabel?.textColor = resultListTextColor
        cell.textLabel?.font = resultListFont
        cell.textLabel?.attributedText = textByApplying(
            attributes: matchedTextAttributes,
            to: filteredResults[indexPath.row].autoCompleteString,
            before: currentInputText.count
        )
        cell.selectionStyle = .none
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectResult(at: indexPath.row)
    }
    
    // MARK: - UITextFieldDelegate
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        isTextFieldUIUpdating = true
        if shouldAutoComplete, let nsText = textField.text as NSString? {
            let updatedText = nsText.replacingCharacters(in: range, with: string)
            processResults(for: updatedText)
        }
        return textFieldDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if shouldAutoComplete {
            if isFilteringResults {
                showLoadingIndicator()
                if shouldShowInlineAutoCompletion {
                    showOnlyInputText()
                }
            } else {
                if shouldShowInlineAutoCompletion {
                    showInlineAutoCompletion(for: currentInputText, at: autoCompletionResultIndex)
                }
            }
        }
        isTextFieldUIUpdating = false
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldReturn?(textField) ?? true
    }
    
    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        resetAutoCompleteTextField()
        playHideResultListAnimation()
        return textFieldDelegate?.textFieldShouldClear?(textField) ?? true
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            currentInputText = text
            autoCompletionResultIndex = 0
            isFilteringResults = true
            filterDataSource(with: text) { [weak self] in
                guard let strongSelf = self else { return }
                if strongSelf.shouldShowInlineAutoCompletion {
                    strongSelf.showInlineAutoCompletion(for: strongSelf.currentInputText, at: strongSelf.autoCompletionResultIndex)
                }
                strongSelf.isFilteringResults = false
                strongSelf.hideLoadingIndicator()
                strongSelf.playShowResultListAnimation()
            }
        }
        textFieldDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        showOnlyInputText()
        playHideResultListAnimation()
        textFieldDelegate?.textFieldDidEndEditing?(textField)
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        showOnlyInputText()
        playHideResultListAnimation()
        textFieldDelegate?.textFieldDidEndEditing?(textField, reason: reason)
    }
    
    // MARK: - Animations
    
    private func playShowResultListAnimation() {
        guard shouldShowResultList else { return }
        resultListTableView.reloadData()
        resultListTableView.isHidden = false
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseOut], animations: {
            self.resultListTableViewHeightConstraint?.constant = self.currentResultListHeight
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func playHideResultListAnimation() {
        guard shouldShowResultList else { return }
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseOut], animations: {
            self.resultListTableViewHeightConstraint?.constant = 0.0
            self.layoutIfNeeded()
        }, completion: { _ in
            self.resultListTableView.isHidden = true
        })
    }
    
    private func showLoadingIndicator() {
        previousRightView = rightView
        previousRightViewMode = rightViewMode
        rightView = loadingView
        rightViewMode = .always
        loadingActivityIndicatorView.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        rightView = previousRightView
        rightViewMode = previousRightViewMode
        loadingActivityIndicatorView.stopAnimating()
    }
}
