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
        let user_id: String?
    }

    var posts: [[String: String]] = []

    do {

        let skillPosts: [SkillPost] = try await client
            .from("SkillPost")
            .select()
            .execute()
            .value

        for post in skillPosts {

            posts.append([
                "id": String(post.id),
                "title": post.title,
                "category": post.category,
                "description": post.description,
                "availability": post.availability,
                "contactEmail": post.contact_email,
                "user_id": post.user_id ?? ""
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

    do {

        try await client
            .from("SkillPost")
            .delete()
            .eq("id", value: id)
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
        let created_at: Date
        let message: String
    }

    var notificationStrings: [[String: String]] = []

    do {

        let notifications: [Notification] = try await client
            .from("Notification")
            .select()
            .eq("user_id", value: id)
            .execute()
            .value

        for notification in notifications {

            notificationStrings.append([
                "time": notification.created_at.formatted(),
                "message": notification.message
            ])
        }

    } catch {

        print("❌ failed to get notifications: \(error)")
    }

    return notificationStrings
}
