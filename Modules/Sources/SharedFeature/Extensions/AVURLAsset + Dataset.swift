
import Foundation
import UIKit
import AVFoundation

extension AVURLAsset{
    public convenience init?(_ dataAsset:NSDataAsset){
        let tmpPath = NSTemporaryDirectory()
        let filePath = "\(tmpPath).m4b"
        let fileURL = URL(fileURLWithPath: filePath)
        do {
            try dataAsset.data.write(to: fileURL)
        } catch let error as NSError {
            print("failed to write: \(error)")
        }
        
        self.init(url:fileURL)
    }
}

