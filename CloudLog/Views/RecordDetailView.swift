import SwiftUI
import SwiftData

struct RecordDetailView: View {
    @Bindable var detailRecord: CloudRecord
    @State private var isEditing = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ScrollView {
            if let image = detailRecord.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            VStack(alignment: .leading) {
                HStack(alignment: .bottom)  {
                    Label(detailRecord.cloudType, systemImage: "cloud.circle")
                        .font(.title)
                        .foregroundColor(.primary)
                        .bold()
                    Text(detailRecord.pred)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 5)
                }
                
                Text(detailRecord.dateStr)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Divider()
                Section(header:
                        Label("何に似てる？", systemImage: "questionmark.circle")
                    .font(.title2)
                    .foregroundColor(.primary)
                ) {
                    if isEditing {
                        // 編集モード時はTextEditorを表示
                        TextField("ここに入力", text: $detailRecord.comment)
                    } else {
                        // 通常時はTextを表示
                        Text(detailRecord.comment.isEmpty == true ? "ここに入力" : (detailRecord.comment))
                    }
                }
                // 意味セクション
                Spacer()
            }
            .padding()
        }
        .navigationTitle(detailRecord.cloudType)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // 編集/完了ボタン
                Button(isEditing ? "完了" : "編集") {
                    isEditing.toggle()
                    if !isEditing {
                        // 編集モードを終了時にデータを保存
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save changes: \(error)")
                        }
                    }
                }
            }
        }
    }
}
