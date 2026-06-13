import UIKit
import UIKitCompatKit
import UIKitExtensions

class SettingsView: UIView {
    
    private var backgroundView: UIView = {
        let bg = UIView()
        bg.backgroundColor = .discordGray
        bg.layer.cornerRadius = 22
        bg.layer.borderWidth = 1
        bg.layer.borderColor = .darkGray
        bg.translatesAutoresizingMaskIntoConstraints = false
        return bg
    }()
    
    private var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var animationsButton: UIView!
    private var logOutButton: UIView!
    
    public init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(backgroundView)
        backgroundView.pinToEdges(of: self)
        
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        animationsButton = makeToggleButton(title: "Enable Animations", isOn: ThemeEngine.enableAnimations) {
            ThemeEngine.enableAnimations.toggle()
            self.updateButtonTint(self.animationsButton, isOn: ThemeEngine.enableAnimations)
        }
        
        logOutButton = makeToggleButton(title: "Log Out", isOn: false) {
            activeClient.disconnect()
            token = nil
            UIApplication.shared.currentKeyWindow?.rootViewController = AuthenticationViewController()
        }
        
        contentStack.addArrangedSubview(animationsButton)
        contentStack.addArrangedSubview(logOutButton)
    }
    
    // MARK: - Utility
    
    private func makeToggleButton(title: String, isOn: Bool, action: @escaping () -> Void) -> UIView {
        let glass = UIView()
        glass.translatesAutoresizingMaskIntoConstraints = false
        glass.heightAnchor.constraint(equalToConstant: 50).isActive = true
        glass.layer.cornerRadius = 16
        glass.backgroundColor = isOn ? UIColor.green.withAlphaComponent(0.3) : UIColor.red.withAlphaComponent(0.3)
        
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        
        button.addAction(for: .touchUpInside, {
            action()
        })
        
        glass.addSubview(button)
        button.pinToEdges(of: glass)
        
        return glass
    }
    
    private func updateButtonTint(_ button: UIView?, isOn: Bool) {
        guard let glass = button as? UIView else { return }
        glass.backgroundColor = isOn ? UIColor.green.withAlphaComponent(0.3) : UIColor.red.withAlphaComponent(0.3)
    }
}
