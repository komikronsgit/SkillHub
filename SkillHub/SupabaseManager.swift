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
        supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!,
        supabaseKey: Config.supabaseAnonKey
    )

    struct Notification: Decodable {
        let id: Int
        let created_at: Date
        let message: String
        let type: String?
        let skill_title: String?
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

        for n in notifications {
            results.append([
                "id": String(n.id),
                "time": n.created_at.formatted(),
                "message": n.message,
                "type": n.type ?? "general",
                "skill_title": n.skill_title ?? "",
                "requester_id": n.requester_id != nil ? String(n.requester_id!) : "",
                "status": n.status ?? "info"
            ])
        }
    } catch {
        print("❌ failed to get notifications: \(error)")
    }

    return results
}

func addNotification(
    user_id: Int,
    message: String,
    type: String = "general",
    skillTitle: String = "",
    requesterId: Int? = nil,
    status: String = "info"
) async {

    let client = SupabaseClient(
        supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!,
        supabaseKey: Config.supabaseAnonKey
    )

    struct Notification: Encodable {
        let user_id: Int
        let message: String
        let type: String
        let skill_title: String
        let requester_id: Int?
        let status: String
    }

    let notification = Notification(
        user_id: user_id,
        message: message,
        type: type,
        skill_title: skillTitle,
        requester_id: requesterId,
        status: status
    )

    do {
        try await client
            .from("Notification")
            .insert(notification)
            .execute()
    } catch {
        print("❌ failed to add notification: \(error)")
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
