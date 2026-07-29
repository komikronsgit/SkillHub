//
//  SupaStorageManager.swift
//  SkillHub
//
//  Created by Kalvin Cusworth on 2026-05-29.
//


import Foundation
import Supabase

func getProfilePic() async -> Data {
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!,
        supabaseKey: Config.supabaseAnonKey
    )
    
    let id: Int = UserDefaults.standard.integer(forKey: "id")
    
    struct User: Decodable {
        let profile_pic_path: String?
    }
    
    var data = Data()
    
    do {
        let users: [User] = try await client
            .from("User")
            .select("profile_pic_path")
            .eq("id", value: id)
            .execute()
            .value
        
        guard let user = users.first,
              let path = user.profile_pic_path,
              !path.isEmpty else {
            return Data()
        }
        
        data = try await client.storage
            .from("profile_pics")
            .download(path: path)
        
    } catch let error {
        print("failed to get profile pic: \(error)")
    }
    
    return data
}

func addOrUpdateProfilePic(
    path: String,
    data: Data
) async -> Bool {

    let client = SupabaseClient(
        supabaseURL: URL(string: "https://eopbyxioxjnyeyxcuikg.supabase.co")!,
        supabaseKey: Config.supabaseAnonKey
    )

    let id = UserDefaults.standard.integer(forKey: "id")

    guard id != 0 else {
        print("❌ User ID is missing")
        return false
    }

    struct UserD: Decodable {
        let profile_pic_path: String?
    }

    do {
        let users: [UserD] = try await client
            .from("User")
            .select("profile_pic_path")
            .eq("id", value: id)
            .execute()
            .value

        if let oldPath = users.first?.profile_pic_path,
           !oldPath.isEmpty {

            try await client.storage
                .from("profile_pics")
                .update(
                    path,
                    data: data,
                    options: FileOptions(cacheControl: "0")
                )

        } else {
            try await client.storage
                .from("profile_pics")
                .upload(
                    path,
                    data: data,
                    options: FileOptions(cacheControl: "0")
                )
        }

        try await client
            .from("User")
            .update(["profile_pic_path": path])
            .eq("id", value: id)
            .execute()

        print("✅ Profile picture updated")
        return true

    } catch {
        print("❌ Failed to add profile picture: \(error)")
        return false
    }

}
