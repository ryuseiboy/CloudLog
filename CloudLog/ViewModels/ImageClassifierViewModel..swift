import Vision
import CoreML

class ImageClassifierViewModel: ObservableObject {
    // 分類結果を保持する公開プロパティ
    @Published var classification: String = ""
    
    // Vision用のCoreMLモデルを保持する私有プロパティ
    private var model: VNCoreMLModel?
    
    init() {
        do {
            // CoreMLモデルの設定を作成
            let config = MLModelConfiguration()
            // davitモデルをロード
            let coreMLModel = try davit_hira(configuration: config)
            // VNCoreMLModelを作成
            model = try VNCoreMLModel(for: coreMLModel.model)
        } catch {
            print("Failed to load Core ML model: \(error)")
        }
    }
    
    func classifyImage(_ image: CGImage) {
        guard let model = model else { return }
        
        // Vision requestを作成
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            // 結果をVNClassificationObservationとしてキャスト
            guard let results = request.results as? [VNClassificationObservation] else { return }
            // 最も確信度の高い結果を取得
            if let topResult = results.first {
                // メインスレッドで分類結果を更新
                DispatchQueue.main.async {
                    self?.classification = "\(topResult.identifier) (\(Int(topResult.confidence * 100))%)"
                }
            }
        }
        
        // 画像を処理するためのハンドラを作成
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            // 分類リクエストを実行
            try handler.perform([request])
        } catch {
            print("Failed to perform classification: \(error)")
        }
    }
    
}
