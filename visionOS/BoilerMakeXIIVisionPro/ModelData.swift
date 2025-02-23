import Foundation

struct Model: Identifiable {
    let id = UUID()
    let name: String
    let usdzFileName: String
    let textFileName: String
}

struct Video: Identifiable {
    let id = UUID()
    let name: String
    let fileName: String
}

class ModelDataManager {
    static let shared = ModelDataManager()
    
    let models: [Model] = [
        Model(name: "Coke Can", 
              usdzFileName: "coke-can-model", 
              textFileName: "cokecan")
        // Add more models here as needed
    ]
    
    func getModelURL(fileName: String) -> URL? {
        Bundle.main.url(forResource: fileName, withExtension: "usdz")
    }
    
    func getModelText(fileName: String) -> String? {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt") else {
            return nil
        }
        
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print("Error loading text file: \(error.localizedDescription)")
            return nil
        }
    }
}

class VideoDataManager {
    static let shared = VideoDataManager()
    
    // Update livestream URL to your actual streaming URL
    var livestreamURL: URL? = URL(string: "http://localhost:8080/hls/test.m3u8")
    
    let videos: [Video] = [
        Video(name: "Hackathon 360", fileName: "hackathon360_1")
        // Add more videos here as needed
    ]
    
    func getVideoURL(fileName: String) -> URL? {
        Bundle.main.url(forResource: fileName, withExtension: "mp4")
    }
    
    func getLivestreamURL() -> URL? {
        print("Getting livestream URL: \(livestreamURL?.absoluteString ?? "nil")")
        return livestreamURL
    }
    
    func setLivestreamURL(_ urlString: String) {
        livestreamURL = URL(string: urlString)
    }
} 
