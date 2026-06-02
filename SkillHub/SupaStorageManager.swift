//
//  SupaStorageManager.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-06-02.
//

import Foundation
import Supabase

func getProfilePic(path: String) async ->  Data {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    var data = Data()
    
    do {
        data = try await client.storage
            .from("profile_pics")
            .download(path: path)
    } catch let error {
        print("failed to get profile pic: \(error)")
    }
    
    return data
}

func addProfilePic(path: String, data: Data) async -> Void {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    do {
        try await client.storage
            .from("profile_pics")
            .upload(path, data: data)
    } catch let error {
        print("failed to add profile pic: \(error)")
    }
}
