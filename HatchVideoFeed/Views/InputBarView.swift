//
//  InputBarView.swift
//  HatchVideoFeed
//
//  Created by Mayuri Patel on 2025-10-08.
//
import UIKit

protocol InputBarViewDelegate: AnyObject {
    func didTapSend(text: String, cell: UICollectionViewCell)
    func didBeginEditing(cell: UICollectionViewCell)
    func didEndEditing(cell: UICollectionViewCell)
}

final class MessageInputBar: UIView, UITextViewDelegate {
    
    // MARK: - Public Callbacks
    var onFocusChange: ((Bool) -> Void)?
    var onSend: ((String) -> Void)?
    
    // MARK: - UI Components
    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    private let heartButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)
    
    // MARK: - Layout
    private var heightConstraint: NSLayoutConstraint!
    private let maxLines: CGFloat = 5
    weak var delegate: InputBarViewDelegate?
    weak var parentCell: UICollectionViewCell?

    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = UIColor.clear
        layer.masksToBounds = true
        layer.cornerRadius = 22
        
        // TextView
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 16)
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 22
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        addSubview(textView)
        
        resetBorderStyle()
        
        // Placeholder
        placeholderLabel.text = "Send message"
        placeholderLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        placeholderLabel.font = textView.font
        addSubview(placeholderLabel)
        
        // Reaction Buttons
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.tintColor = .white
        addSubview(heartButton)
        
        shareButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        shareButton.tintColor = .white
        addSubview(shareButton)
        
        // Send Button
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        sendButton.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: config), for: .normal)
        sendButton.contentMode = .center
        sendButton.tintColor = .darkGray
        sendButton.backgroundColor = .white
        sendButton.alpha = 0
        sendButton.layer.cornerRadius = 15
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        addSubview(sendButton)
    }
    
    private func setupLayout() {
        [textView, placeholderLabel, heartButton, shareButton, sendButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 60)
        heightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            // Reaction buttons (default state)
            shareButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            heartButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -12),
            heartButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            shareButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // TextView
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: heartButton.leadingAnchor, constant: -15),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            // Placeholder
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 12),
            placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Send Button
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            sendButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.didBeginEditing(cell: self.parentCell!)
        onFocusChange?(true)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.heartButton.alpha = 0
            self.shareButton.alpha = 0
            self.resetSendButton()
        }
        updateBorderStyle()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.didEndEditing(cell: self.parentCell!)
        onFocusChange?(false)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.resetSendButton()
            
            if textView.text.isEmpty {
                self.resetBorderStyle()
                self.heartButton.alpha = 1
                self.shareButton.alpha = 1
            } else {
                self.updateBorderStyle()
                self.heartButton.alpha = 0
                self.shareButton.alpha = 0
            }
        }
       
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let hasText = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        // Animate send button visibility
        UIView.animate(withDuration: 0.25) {
            self.sendButton.alpha = hasText ? 1.0 : 0.0
        }
        
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
        let maxHeight = textView.font!.lineHeight * maxLines
        textView.isScrollEnabled = size.height > maxHeight
        
        let newHeight = min(size.height + 16, maxHeight + 16)
        heightConstraint.constant = newHeight + 5
        layoutIfNeeded()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Handle Return key as Send
        if text == "\n" { // Return key pressed
            resetSendButton()
            textView.resignFirstResponder() // Dismiss keyboard
            return false // Prevent newline
        }
        return true
    }
    
    // MARK: - Send Action
    @objc private func sendTapped() {
        guard let text = textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        onSend?(text)
        textView.text = ""
        textViewDidChange(textView)
        resetBorderStyle()
        textView.resignFirstResponder()
    }
    
    private func resetBorderStyle() {
        textView.layer.borderColor = UIColor.white.cgColor
        textView.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0
    }
    
    private func updateBorderStyle() {
        textView.layer.borderColor = UIColor.clear.cgColor
        textView.layer.borderWidth = 0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
    }
    
    func resetSendButton() {
        sendButton.alpha = textView.text.isEmpty ? 0 : 1
    }
    
}
