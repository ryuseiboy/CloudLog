//
//  CloudLogApp.swift
//  CloudLog
//
//  Created by Takumi Yokawa on 2024/08/25.
//

import SwiftUI

@main
struct CloudLogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: CloudRecord.self)
        }
    }
}
