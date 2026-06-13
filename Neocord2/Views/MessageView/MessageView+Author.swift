//
//  File.swift
//  Cascade
//
//  Created by JWI on 2/11/2025.
//

import Foundation
import UIKit
import UIKitCompatKit
import UIKitExtensions
import SwiftcordLegacy
import TSMarkdownParser
import FoundationCompatKit

extension MessageView {
    func setupAuthorName() {
        authorName.text = message?.author?.nickname ?? message?.author?.displayname ?? message?.author?.username
        authorName.font = .boldSystemFont(ofSize: 14)
        authorName.textColor = .white
        authorName.backgroundColor = .clear
        authorName.preferredMaxLayoutWidth = messageContent.bounds.width - timestamp.bounds.width
        authorName.numberOfLines = 1
        authorName.lineBreakMode = .byTruncatingTail
        authorName.textAlignment = .left
        authorName.translatesAutoresizingMaskIntoConstraints = false
        authorName.sizeToFit()
    }
    
    func setupAuthorAvatar() {
        guard let author = message?.author else { return }
        
        authorAvatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        authorAvatar.translatesAutoresizingMaskIntoConstraints = false
        
        AvatarCache.shared.avatar(for: author) { [weak self] image, _ in
            guard let self = self else { return }
            guard let image = image else {
                DispatchQueue.main.async {
                    let resized = UIImage(named: "defaultavatar")!.resizeImage(UIImage(named: "defaultavatar")!, targetSize: CGSize(width: 30, height: 30), cornerRadius: 15)
                    self.authorAvatar.image = resized
                }
                return
            }
            
            
            MessageView.avatarQueue.async {
                let resized = image.resizeImage(image, targetSize: CGSize(width: 30, height: 30))
                
                DispatchQueue.main.async {
                    self.authorAvatar.image = resized
                    self.messageBackground.setNeedsLayout()
                }
            }
        }
    }
}
