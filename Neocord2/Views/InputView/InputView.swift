import UIKit
import UIKitCompatKit
import UIKitExtensions
import SwiftcordLegacy
import SFSymbolsCompatKit


public class InputView: UIView, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public let textInputBackgroundView: UIView = {
        let bView = UIView()
        bView.translatesAutoresizingMaskIntoConstraints = false
        bView.layer.cornerRadius = 20
        bView.layer.borderColor = .darkGray
        bView.layer.borderWidth = 1
        bView.backgroundColor = .discordGray.withAlphaComponent(0.8)
        return bView
    }()
    
    public let fullBackgroundView: UIView = {
        let bView = UIView()
        bView.translatesAutoresizingMaskIntoConstraints = false
        bView.layer.borderColor = .darkGray
        bView.layer.borderWidth = 1
        bView.backgroundColor = .discordGray
        return bView
    }()
    
    public var channel: TextChannel?
    public var tokenInputView: Bool?
    
    let sendButtonBackgroundView: UIView = {
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.layer.cornerRadius = 20
        background.backgroundColor = .discordGray.withAlphaComponent(0.8)
        background.layer.borderColor = .darkGray
        background.layer.borderWidth = 1
        background.isUserInteractionEnabled = false
        return background
    }()
    
    let addImageButtonBackgroundView: UIView = {
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.layer.cornerRadius = 20
        background.layer.borderColor = .darkGray
        background.layer.borderWidth = 1
        background.backgroundColor = .discordGray.withAlphaComponent(0.8)
        background.isUserInteractionEnabled = false
        return background
    }()
    
    var replyMessage: Message?
    var editMessage: Message?
    
    public enum inputMode {
        case edit, reply, send
    }
    
    public let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isScrollEnabled = false
        textView.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: -4)
        return textView
    }()
    
    
    public let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    public let sendButton: LargeHitAreaButton = {
        let button = LargeHitAreaButton()
        button.setImage(.init(systemName: "paperplane.fill", tintColor: .white), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public let attachmentButton: LargeHitAreaButton = {
        let button = LargeHitAreaButton()
        button.setImage(.init(systemName: "plus.bubble.fill", tintColor: .white), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    var buttonIsActive: Bool = true

    
    public init(channel: TextChannel, tokenInputView: Bool = false) {
        super.init(frame: .zero)
        self.channel = channel
        self.tokenInputView = tokenInputView
        setupSubviews()
        setupConstraints()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.channel = nil
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupSubviews() {
        addSubview(fullBackgroundView)
        addSubview(textInputBackgroundView)
        
        textView.delegate = self
        textInputBackgroundView.addSubview(textView)
                
        addSubview(sendButtonBackgroundView)
        addSubview(addImageButtonBackgroundView)
        
        sendButton.sendSubviewToBack(sendButtonBackgroundView)
        
        
        //Must use weak self or else the whole inputview gets retained 
        sendButton.addAction(for: .touchUpInside) { [weak self] in
            self?.sendMessageAction()
        }
        
        attachmentButton.addAction(for: .touchUpInside) { [weak self] in
            self?.pickImage()
        }
        
        
        addSubview(sendButton)
        addSubview(attachmentButton)
    }
    
    private func setupConstraints() {
        sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        attachmentButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 6).isActive = true
        attachmentButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor).isActive = true
        attachmentButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        attachmentButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        activateButtonBackgroundConstraints()
        
        // Background view below bubbleStack, minimum height to prevent collapse
        NSLayoutConstraint.activate([
            textInputBackgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            textInputBackgroundView.leadingAnchor.constraint(equalTo: attachmentButton.trailingAnchor, constant: 6),
            textInputBackgroundView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -6),
            textInputBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            //THIS IS NEEDED OR ELSE IT COLLAPSES ON iOS 6
            textInputBackgroundView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        textView.pinToEdges(of: textInputBackgroundView)
    }

    
    func activateButtonBackgroundConstraints() {
        sendButtonBackgroundView.pinToCenter(of: sendButton)
        sendButtonBackgroundView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sendButtonBackgroundView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        addImageButtonBackgroundView.pinToCenter(of: attachmentButton)
        addImageButtonBackgroundView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addImageButtonBackgroundView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func deactivateButtonBackgroundConstraings() {
        sendButtonBackgroundView.constraints.forEach { $0.isActive = false }
    }
    
    
    public func textViewDidChange(_ textView: UITextView) {
        var maxHeight: CGFloat = 0
        if let dmVC = parentViewController as? TextViewController, let navBarHeight = dmVC.navigationController?.navigationBar.frame.height {
            maxHeight = dmVC.view.bounds.height - 50 - navBarHeight
        }
        let width = textView.bounds.width > 0 ? textView.bounds.width : 100 // fallback
        let size = textView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        let clampedHeight = max(40, min(size.height, maxHeight))
        
        textView.isScrollEnabled = size.height > maxHeight
        
        if clampedHeight != self.bounds.height {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    
    public override var intrinsicContentSize: CGSize {
        var maxHeight: CGFloat = 0
        if let dmVC = parentViewController as? TextViewController, let navBarHeight = dmVC.navigationController?.navigationBar.frame.height {
            maxHeight = dmVC.view.bounds.height - 50 - navBarHeight
        } 
        let width = textView.bounds.width > 0 ? textView.bounds.width : 100
        let size = textView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        let height = max(40, min(size.height, maxHeight))
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    private func pickImage() {
        guard let parentVC = parentViewController else { return }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary // or .camera if you want
        picker.allowsEditing = false

        parentVC.present(picker, animated: true)
    }

    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        // send the image using the client
        if let channel = self.channel {
            activeClient.send(image: image, in: channel) { _ in
                
            }
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

}




