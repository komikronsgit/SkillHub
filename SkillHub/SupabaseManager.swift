//
//  SupabaseManager.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-29.
//

import Foundation
import Supabase

func getUsersNameAndPasswordByEmail(email: String) async -> [String] {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: "SECRET_KEY")
    
    struct User: Decodable {
        let name: String
        let password: String
    }
    
    var name = ""
    var password = ""
    
    do {
        let user: [User] = try await client
            .from("User")
            .select()
            .eq("email", value: email)
            .execute()
            .value
        name = user[0].name
        password = user[0].password
    } catch let error {
        print("failed to get user: \(error)")
    }
    
    return [name, password]
}

func postUser(name: String, email: String, password: String, about_me: String, program: String, school: String) async -> Void {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: "SECRET_KEY")
    
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
        print("failed to post user: \(error)")
    }
}
