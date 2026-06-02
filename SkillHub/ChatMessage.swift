//
//  ChatMessage.swift
//  SkillHub
//
//  Created by Bilal Ahmed Samoon on 2026-05-29.
//

import Foundation

enum MessageType {
    case user
    case ai
    case system
}

struct ChatMessage {
    let text: String
    let type: MessageType
}
