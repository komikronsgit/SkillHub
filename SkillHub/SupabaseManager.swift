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
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    struct User: Decodable {
        let profile_pic_path: String
    }
    
    do {
        try await client
            .from("SkillPost")
            .delete()
            .eq("poster_id", value: id)
            .execute()
        
        let user: [User] = try await client
            .from("User")
            .select()
            .eq("id", value: id)
            .execute()
            .value
        
        if user.first?.profile_pic_path != nil {
            try await client.storage
                .from("profile_pics")
                .remove(paths: [user.first!.profile_pic_path])
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
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    struct SkillPost: Decodable {
        let title: String
        let category: String
        let description: String
        let avalibility: String
        let contact_email: String
    }
    
    var posts: [[String: String]] = []
    
    do {
        let skillPosts: [SkillPost] = try await client
            .from("SkillPost")
            .select()
            .execute()
            .value
        
        for skillPost in skillPosts {
            posts.append([
                "title": skillPost.title,
                "category": skillPost.category,
                "description": skillPost.description,
                "avalibility": skillPost.avalibility,
                "contactEmail": skillPost.contact_email
            ])
        }
    } catch let error {
        print("failed to get skill post: \(error)")
    }
    
    return posts
}

func addSkillPost(title: String, category: String, description: String, avalibility: String, contact_email: String, poster_id: Int) async -> Void {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    struct SkillPost: Encodable {
        let title: String
        let category: String
        let description: String
        let avalibility: String
        let contact_email: String
        let poster_id: Int
    }
    
    let user = SkillPost(title: title, category: category, description: description, avalibility: avalibility, contact_email: contact_email, poster_id: poster_id)
    
    do {
        try await client
            .from("SkillPost")
            .insert(user)
            .execute()
    } catch let error {
        print("failed to add skill post: \(error)")
    }
}
