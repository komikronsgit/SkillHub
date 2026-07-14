//
//  SupabaseManager.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-29.
//

import Foundation
import Supabase

func getUsersIdByEmail(email: String) async -> Int {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    struct User: Decodable {
        let id: Int
    }
    
    var id = 0
    
    do {
        let user: [User] = try await client
            .from("User")
            .select()
            .eq("email", value: email)
            .execute()
            .value
        id = user.count == 0 ? -1 : user[0].id
    } catch let error {
        print("failed to get user: \(error)")
    }
    
    return id
}

func getUserById(id: Int) async -> [String] {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    struct User: Decodable {
        let name: String
        let email: String
        let password: String
        let about_me: String
        let program: String
        let school: String
    }
    
    var name = ""
    var email = ""
    var password = ""
    var about_me = ""
    var program = ""
    var school = ""
    
    do {
        let user: [User] = try await client
            .from("User")
            .select()
            .eq("id", value: id)
            .execute()
            .value
        name = user[0].name
        email = user[0].email
        password = user[0].password
        about_me = user[0].about_me
        program = user[0].program
        school = user[0].school
    } catch let error {
        print("failed to get user: \(error)")
    }
    
    return [name, email, password, about_me, program, school]
}

func addUser(name: String, email: String, password: String, about_me: String, program: String, school: String) async -> Void {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    struct User: Encodable {
        let name: String
        let email: String
        let password: String
        let about_me: String
        let program: String
        let school: String
    }
    
    let user = User(name: name, email: email, password: password, about_me: about_me, program: program, school: school)
    
    do {
        try await client
            .from("User")
            .insert(user)
            .execute()
    } catch let error {
        print("failed to add user: \(error)")
    }
}

func updateUserById(id: Int, name: String, email: String, about_me: String, program: String, school: String) async -> Void {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    do {
        try await client
            .from("User")
            .update([
                "name": name,
                "email": email,
                "about_me": about_me,
                "program": program,
                "school": school,
            ])
            .eq("id", value: id)
            .execute()
    } catch let error {
        print("failed to update user: \(error)")
    }
}

func updateUsersPasswordById(id: Int, password: String) async -> Void {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    do {
        try await client
            .from("User")
            .update(["password": password])
            .eq("id", value: id)
            .execute()
    } catch let error {
        print("failed to update users password: \(error)")
    }
}

func deleteUserById(id: Int) async -> Void {
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!,
        supabaseKey: Config.supabaseAnonKey
    )
    
    struct User: Decodable {
        let profile_pic_path: String?
    }
    
    do {
        try await client
            .from("SkillPost")
            .delete()
            .eq("poster_id", value: id)
            .execute()
        
        let user: [User] = try await client
            .from("User")
            .select("profile_pic_path")
            .eq("id", value: id)
            .execute()
            .value
        
        if let path = user.first?.profile_pic_path, !path.isEmpty {
            try await client.storage
                .from("profile_pics")
                .remove(paths: [path])
        }
        
        try await client
            .from("User")
            .delete()
            .eq("id", value: id)
            .execute()
        
    } catch let error {
        print("failed to delete user: \(error)")
    }
}

func getAllSkillPosts() async -> [[String: String]] {

    let client = SupabaseClient(
        supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!,
        supabaseKey: Config.supabaseAnonKey
    )

    struct SkillPost: Decodable {
        let id: Int
        let title: String
        let category: String
        let description: String
        let availability: String
        let contact_email: String
        let poster_id: Int
    }

    var posts: [[String: String]] = []

    do {
        let skillPosts: [SkillPost] = try await client
            .from("SkillPost")
            .select()
            .execute()
            .value

        for post in skillPosts {
            let poster = await getUserById(id: post.poster_id)
            let posterName = poster[0]

            posts.append([
                "id": String(post.id),
                "title": post.title,
                "category": post.category,
                "description": post.description,
                "availability": post.availability,
                "contactEmail": post.contact_email,
                "poster_id": String(post.poster_id),
                "name": posterName
            ])
        }

    } catch {
        print("❌ failed to get skill posts: \(error)")
    }

    return posts
}

func addSkillPost(title: String, category: String, description: String, availability: String, contact_email: String, poster_id: Int) async -> Void {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    struct SkillPost: Encodable {
        let title: String
        let category: String
        let description: String
        let availability: String
        let contact_email: String
        let poster_id: Int
    }
    
    let user = SkillPost(title: title, category: category, description: description, availability: availability, contact_email: contact_email, poster_id: poster_id)
    
    do {
        try await client
            .from("SkillPost")
            .insert(user)
            .execute()
    } catch let error {
        print("failed to add skill post: \(error)")
    }
}

func deleteSkillPost(id: String) async {

    let client = SupabaseClient(
        supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!,
        supabaseKey: Config.supabaseAnonKey
    )

    let currentUserId = UserDefaults.standard.integer(forKey: "id")

    do {
        try await client
            .from("SkillPost")
            .delete()
            .eq("id", value: id)
            .eq("poster_id", value: currentUserId)
            .execute()

        print("✅ Deleted successfully")

    } catch {
        print("❌ Delete failed: \(error)")
    }
}

func getNotificationsByUserId(id: Int) async -> [[String: String]] {
    let client = SupabaseClient(
        supabaseURL: URL(
            string: "https://eopbyxioxjnyeyxcuikg.supabase.co"
        )!,
        supabaseKey: Config.supabaseAnonKey
    )

    struct Notification: Decodable {
        let id: Int
        let created_at: Date
        let message: String
        let type: String?
        let skill_title: String?
        let skill_post_id: Int?
        let requester_id: Int?
        let status: String?
    }

    var results: [[String: String]] = []

    do {
        let notifications: [Notification] = try await client
            .from("Notification")
            .select()
            .eq("user_id", value: id)
            .order("created_at", ascending: false)
            .execute()
            .value

        for notification in notifications {
            results.append([
                "id": String(notification.id),
                "time": notification.created_at.formatted(),
                "message": notification.message,
                "type": notification.type ?? "general",
                "skill_title": notification.skill_title ?? "",
                "skill_post_id": notification.skill_post_id.map(String.init) ?? "",
                "requester_id": notification.requester_id.map(String.init) ?? "",
                "status": notification.status ?? "info"
            ])
        }
    } catch {
        print("❌ Failed to get notifications: \(error)")
    }

    return results
}

func addNotification(
    user_id: Int,
    message: String,
    type: String = "general",
    skillTitle: String = "",
    skillPostId: Int? = nil,
    requesterId: Int? = nil,
    status: String = "info"
) async {

    let client = SupabaseClient(
        supabaseURL: URL(
            string: "https://eopbyxioxjnyeyxcuikg.supabase.co"
        )!,
        supabaseKey: Config.supabaseAnonKey
    )

    struct Notification: Encodable {
        let user_id: Int
        let message: String
        let type: String
        let skill_title: String
        let skill_post_id: Int?
        let requester_id: Int?
        let status: String
    }

    let notification = Notification(
        user_id: user_id,
        message: message,
        type: type,
        skill_title: skillTitle,
        skill_post_id: skillPostId,
        requester_id: requesterId,
        status: status
    )

    do {
        try await client
            .from("Notification")
            .insert(notification)
            .execute()

        print("✅ Notification added")

    } catch {
        print("❌ Failed to add notification: \(error)")
    }
}
func updateNotificationStatus(id: String, status: String) async {
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!,
        supabaseKey: Config.supabaseAnonKey
    )

    do {
        try await client
            .from("Notification")
            .update(["status": status])
            .eq("id", value: id)
            .execute()
    } catch {
        print("❌ failed to update notification: \(error)")
    }
}

func deleteNotification(id: String) async {
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!,
        supabaseKey: Config.supabaseAnonKey
    )

    do {
        try await client
            .from("Notification")
            .delete()
            .eq("id", value: id)
            .execute()
    } catch {
        print("❌ failed to delete notification: \(error)")
    }
}
// MARK: - Messaging Models

struct ConversationModel: Decodable {
    let id: Int
    let created_at: Date
    let skill_post_id: Int
    let requester_id: Int
    let poster_id: Int
}

struct ChatMessageModel: Decodable {
    let id: Int
    let created_at: Date
    let conversation_id: Int
    let sender_id: Int
    let message: String
}


// MARK: - Conversation Functions

func createOrGetConversation(
    skillPostId: Int,
    requesterId: Int,
    posterId: Int
) async -> Int? {

    let client = SupabaseClient(
        supabaseURL: URL(
            string: "https://eopbyxioxjnyeyxcuikg.supabase.co"
        )!,
        supabaseKey: Config.supabaseAnonKey
    )

    struct NewConversation: Encodable {
        let skill_post_id: Int
        let requester_id: Int
        let poster_id: Int
    }

    do {
        let existing: [ConversationModel] = try await client
            .from("Conversation")
            .select()
            .eq("skill_post_id", value: skillPostId)
            .eq("requester_id", value: requesterId)
            .eq("poster_id", value: posterId)
            .execute()
            .value

        if let conversation = existing.first {
            return conversation.id
        }

        let conversations: [ConversationModel] = try await client
            .from("Conversation")
            .insert(
                NewConversation(
                    skill_post_id: skillPostId,
                    requester_id: requesterId,
                    poster_id: posterId
                )
            )
            .select()
            .execute()
            .value

        return conversations.first?.id

    } catch {
        print("❌ Failed to create or get conversation: \(error)")
        return nil
    }
}

func getConversationsForUser(
    userId: Int
) async -> [ConversationModel] {

    let client = SupabaseClient(
        supabaseURL: URL(
            string: "https://eopbyxioxjnyeyxcuikg.supabase.co"
        )!,
        supabaseKey: Config.supabaseAnonKey
    )

    do {
        let requesterConversations: [ConversationModel] = try await client
            .from("Conversation")
            .select()
            .eq("requester_id", value: userId)
            .execute()
            .value

        let posterConversations: [ConversationModel] = try await client
            .from("Conversation")
            .select()
            .eq("poster_id", value: userId)
            .execute()
            .value

        var combined = requesterConversations

        for conversation in posterConversations {
            if !combined.contains(
                where: { $0.id == conversation.id }
            ) {
                combined.append(conversation)
            }
        }

        return combined.sorted {
            $0.created_at > $1.created_at
        }

    } catch {
        print("❌ Failed to load conversations: \(error)")
        return []
    }
}

// MARK: - Message Functions

func getMessages(
    conversationId: Int
) async -> [ChatMessageModel] {

    let client = SupabaseClient(
        supabaseURL: URL(
            string: "https://eopbyxioxjnyeyxcuikg.supabase.co"
        )!,
        supabaseKey: Config.supabaseAnonKey
    )

    do {
        let messages: [ChatMessageModel] = try await client
            .from("Message")
            .select()
            .eq("conversation_id", value: conversationId)
            .order("created_at", ascending: true)
            .execute()
            .value

        return messages

    } catch {
        print("❌ Failed to load messages: \(error)")
        return []
    }
}

func sendMessage(
    conversationId: Int,
    senderId: Int,
    text: String
) async -> Bool {

    let client = SupabaseClient(
        supabaseURL: URL(
            string: "https://eopbyxioxjnyeyxcuikg.supabase.co"
        )!,
        supabaseKey: Config.supabaseAnonKey
    )

    struct NewMessage: Encodable {
        let conversation_id: Int
        let sender_id: Int
        let message: String
    }

    let cleanText = text.trimmingCharacters(
        in: .whitespacesAndNewlines
    )

    guard !cleanText.isEmpty else {
        return false
    }

    do {
        try await client
            .from("Message")
            .insert(
                NewMessage(
                    conversation_id: conversationId,
                    sender_id: senderId,
                    message: cleanText
                )
            )
            .execute()

        return true

    } catch {
        print("❌ Failed to send message: \(error)")
        return false
    }
}
func getSkillPostTitle(skillPostId: Int) async -> String {
    let client = SupabaseClient(
        supabaseURL: URL(
            string: "https://eopbyxioxjnyeyxcuikg.supabase.co"
        )!,
        supabaseKey: Config.supabaseAnonKey
    )

    struct SkillTitle: Decodable {
        let title: String
    }

    do {
        let posts: [SkillTitle] = try await client
            .from("SkillPost")
            .select("title")
            .eq("id", value: skillPostId)
            .execute()
            .value

        return posts.first?.title ?? "Skill conversation"

    } catch {
        print("❌ Failed to load skill title: \(error)")
        return "Skill conversation"
    }
}
