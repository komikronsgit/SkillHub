//
//  SupaStorageManager.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-06-02.
//

import Foundation
import Supabase

func getProfilePic() async ->  Data {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    let id: Int = UserDefaults.standard.integer(forKey: "id")
    
    struct User: Decodable {
        let profile_pic_path: String
    }
    
    var data = Data()
    
    do {
        let users: [User] = try await client
            .from("User")
            .select("profile_pic_path")
            .eq("id", value: id)
            .execute()
            .value
        
        let user = users[0]
        if user.profile_pic_path.isEmpty {
            return Data()
        }
        
        data = try await client.storage
            .from("profile_pics")
            .download(path: user.profile_pic_path)
    } catch let error {
        print("failed to get profile pic: \(error)")
    }
    
    return data
}

func addOrUpdateProfilePic(path: String, data: Data) async -> Void {
    let client = SupabaseClient(supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!, supabaseKey: Config.supabaseAnonKey)
    
    let id: Int = UserDefaults.standard.integer(forKey: "id")
    
    struct UserE: Encodable {
        let profile_pic_path: String
    }
    
    struct UserD: Decodable {
        let profile_pic_path: String
    }
    
    let user = UserE(profile_pic_path: path)
    
    do {
        let users: [UserD] = try await client
            .from("User")
            .select("profile_pic_path")
            .eq("id", value: id)
            .execute()
            .value
        
        if users.first?.profile_pic_path == nil {
            try await client.storage
                .from("profile_pics")
                .upload(
                    path,
                    data: data,
                    options: FileOptions(cacheControl: "0")
                )
        } else {
            try await client.storage
                .from("profile_pics")
                .update(
                    path,
                    data: data,
                    options: FileOptions(cacheControl: "0")
                )
        }
        
        try await client
            .from("User")
            .update(["profile_pic_path": user.profile_pic_path])
            .eq("id", value: id)
            .execute()
    } catch let error {
        print("failed to add profile pic: \(error)")
    }
}
