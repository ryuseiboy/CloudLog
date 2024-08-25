//
//  EntryListView.swift
//  coreMLtest
//
//  Created by Takumi Yokawa on 2024/08/25.
//

import SwiftUI
import SwiftData

struct EntryListView: View {
    @State private var searchText = ""
    @Environment(\.modelContext) private var context
    @Query(sort: \CloudRecord.date, order: .reverse) private var records: [CloudRecord]
    @State private var isPresented = false
    @State private var selectedCloudType: String? = nil
    var filteredRecords: [CloudRecord] {
        if let selectedType = selectedCloudType {
            return records.filter { $0.cloudType == selectedType }
        } else {
            return records
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        Section(header:
                                    Text("記録")
                            .foregroundColor(.primary)
                            .font(.title2)
                            .bold()
                                
                        ){
                            ForEach(filteredRecords) { record in
                                NavigationLink(value: record) {
                                    HStack {
                                        if let image = record.image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 50, height: 50)
                                                .clipShape(Rectangle())
                                        }
                                        VStack {
                                            Text(record.cloudType)
                                                .font(.body)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundColor(.primary)
                                            Text(record.dateStr)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    
                                }
                            }
                            .onDelete(perform: { indexSet in
                                for index in indexSet {
                                    delete(record: filteredRecords[index])
                                }
                            })
                            
                        }
                    }
                    
                }
                
                VStack {
                    Spacer()
                    Button(action: {
                        isPresented.toggle()
                    }, label: {
                        ZStack{
                            Circle()
                                .frame(width: 80, height: 80)
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Image(systemName: "plus")
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 25, height: 25)
                                .bold()
                            
                        }
                    })
                    .padding()
                }
            }//Z終わり
            // 文字列型の値に基づいてナビゲーション先を決定
            .navigationDestination(for: CloudRecord.self) { cloud in
                RecordDetailView(detailRecord: cloud)
            }
            // メイン画面のナビゲーションタイトルを設定
            .navigationTitle("Main Screen")
            .sheet(isPresented: $isPresented, content: {
                ImageClassifierView()
            })
            .navigationBarItems(trailing:
                                    Menu {
                Button {
                    selectedCloudType = nil
                } label: {
                    HStack {
                        Text("すべて")
                        Spacer()
                        if selectedCloudType == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Divider()
                
                ForEach(["すじ雲 ", "ひつじ雲 ", "うね雲 ", "わた雲 ", "にゅうどう雲 ", "きり雲 ", "晴天 "], id: \.self) { cloudType in
                    Button {
                        selectedCloudType = cloudType
                    } label: {
                        HStack {
                            Text(cloudType)
                            Spacer()
                            if selectedCloudType == cloudType {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.primary)
            }
            )
        }
    } //body終わり
    
    private func delete(record: CloudRecord) {
        context.delete(record)
    }
    
}

#Preview {
    EntryListView()
        .modelContainer(for: CloudRecord.self)
}
