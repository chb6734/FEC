//
//  SupabaseManager.swift
//  FEC
//
//  Supabase 클라이언트 싱글톤
//

import Foundation
import Supabase
import Auth

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        let supabaseURL = URL(string: "https://ofhvphyfmrbrcwgpoehu.supabase.co")!
        let supabaseKey = "sb_publishable_vy22-90pT8X4koBwjYXMRw_IEhvEkxs"

        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey,
            options: .init(
                auth: .init(autoRefreshToken: true)
            )
        )
    }
}
