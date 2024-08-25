import SwiftUI
import PhotosUI
import SwiftData

struct ImageClassifierView: View {
    @Environment(\.modelContext) private var modelContext
    // ビューモデルの状態を管理
    @StateObject private var viewModel = ImageClassifierViewModel()
    // 選択された画像を保持
    @State private var inputImage: UIImage?
    // PhotosPickerで選択されたアイテムを保持
    @State private var selectedItem: PhotosPickerItem?
    @State private var classificationResult = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                // 選択された画像がある場合、表示する
                if classificationResult != "" {
                        VStack {
                            Label("解析結果",systemImage: "magnifyingglass.circle")
                                .font(.headline)
                                .frame(maxWidth: .infinity,alignment: .leading)
                                .padding(.leading)
                            Text(classificationResult)
                                .font(.title)
                                .foregroundColor(.primary)
                                .padding()
                                .bold()
                            Button(action: {
                                saveData()
                                dismiss()
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundStyle(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.purple, Color(#colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1))]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(maxWidth: .infinity, maxHeight: 80.0)
                                    
                                    Text("登録")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                }
                                .padding()
                            })
                            
                            if let inputImage = inputImage {
                                Divider()
                                Image(uiImage: inputImage)
                                    .resizable()
                                    .scaledToFit()
                            }
                        }

                } else {
                    // 画像選択用のPhotosPicker
                    VStack {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.blue, .purple]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(maxWidth: .infinity, maxHeight: 80.0)
                                
                                Text("写真を選択")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                            .padding()
                        } // PhotosPicker終わり
                        
                        GroupBox(label:
                                    Label("Note",systemImage: "info.circle")) {
                            VStack {
                                Text("・雲だけが写るように撮影してください。")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.footnote)
                                Text("・AIによる分類結果は参考情報であり、100%の正確性を保証するものではありません。")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.footnote)
                            }
                        }
                                    .padding()
                    }
                }
                
            }
            // selectedItemが変更されたときの処理
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    // 選択された画像をデータとして読み込み
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            // メインスレッドで画像を設定し、分類を実行
                            inputImage = uiImage
                            classifyImage()
                        }
                    }
                }
            }
            .onChange(of: viewModel.classification) { oldClass, newClass in
                classificationResult = newClass
                //saveData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
        }
        }

    } //body終わり
    
    private func classifyImage() {
        guard let inputImage = inputImage else { return }
        
        // 画像をリサイズ
        let targetSize = CGSize(width: 224, height: 224)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        inputImage.draw(in: CGRect(origin: .zero, size: targetSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return
        }
        UIGraphicsEndImageContext()
        
        // UIImageをCGImageに変換
        guard let cgImage = resizedImage.cgImage else { return }
        
        // 画像を分類
        viewModel.classifyImage(cgImage)
    }
    
    private func saveData() {
        let record = CloudRecord(image: self.inputImage, classification: self.classificationResult)
        modelContext.insert(record)
    }

    
}

// プレビュー用
#Preview {
    ImageClassifierView()
}
