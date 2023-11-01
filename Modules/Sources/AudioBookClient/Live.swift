import Foundation
import Dependencies
import SharedFeature
import AVFoundation
import UIKit

extension AudioBookClient {
    public static func live(bundle: Bundle) -> Self {
        let audioBookLoader = AudioBookLoader(bundle: .init(wrappedValue: bundle))
        
        return Self(
            load: { audioBookId in
                let asset = try await audioBookLoader.loadAsset(for: audioBookId)
                let audiobook = try await audioBookLoader.loadAudioBook(from: asset)
                
               return audiobook
            }
        )
    }
}

class AudioBookLoader {

    enum Failure: Error {
        case fileNotFound
        case noAvailableLocales
    }
    
    let bundle: Bundle
    
    init(bundle: UncheckedSendable<Bundle>) {
        self.bundle = bundle.wrappedValue
    }
    
    func loadAsset(for audioBookId: String) async throws -> AVURLAsset {
        guard let dataAsset = NSDataAsset(name: audioBookId), let asset = AVURLAsset(dataAsset) else {
            throw Failure.fileNotFound
        }
        
        return asset
    }
    
    func loadAudioBook(from asset: AVURLAsset) async throws -> AudioBook {
        let availableLocales = try await asset.load(.availableChapterLocales)
        
        guard let availableLocale = availableLocales.first else {
            throw Failure.noAvailableLocales
        }
        
        let artworkItems = AVMetadataItem.metadataItems(
            from: try await asset.load(.commonMetadata),
            withKey: AVMetadataKey.commonKeyArtwork,
            keySpace: AVMetadataKeySpace.common
        )
                            
        
        let previewData = try await artworkItems.first?.load(.dataValue)
        
        let chapterMetadata = try await asset.loadChapterMetadataGroups(withTitleLocale: availableLocale)
        
        var chapters: [Chapter] = []
        for metadata in chapterMetadata {
            guard let titleItem = metadata.items.first(where: { $0.commonKey == .commonKeyTitle }),
                  let title = try await titleItem.load(.value) as? String
            else {
                continue
            }
            
            chapters.append(
                Chapter(
                    id: UUID().uuidString,
                    title: title,
                    startsAt: metadata.timeRange.start.seconds,
                    endsAt: metadata.timeRange.end.seconds,
                    duration: metadata.timeRange.duration.seconds
                )
            )
        }
        
        
        return AudioBook(
            chapters: chapters,
            assetUrl: asset.url,
            preview: previewData
        )
    }
}


