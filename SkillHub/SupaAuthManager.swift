//
//  SupaAuthManager.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-06-12.
//

import Foundation
import Supabase

func signUpUser(email: String, password: String) async -> Void {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    do {
        let output = try await client.auth.signUp(email: email, password: password)
        print(output)
    } catch let error {
        print("password: \(password)")
        print("failed to signup user: \(error)")
    }
}
