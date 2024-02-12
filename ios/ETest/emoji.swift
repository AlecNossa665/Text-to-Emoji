//
//  emoji.swift
//  ETest
//
//  Created by Alec Nossa on 2/12/24.
//

import Foundation
import NaturalLanguage

@objc(EmojiModule) class EmojiModule: NSObject {
  let embedding = NLEmbedding.wordEmbedding(for: .english)
  let path = Bundle.main.path(forResource: "fil_trim_data2", ofType: "txt")

  // vector
  func getVector(for label: String) -> [Double] {
    let words = label.split(separator: " ")
    var vectors: [[Double]] = []
    for word in words {
      if let vector = embedding?.vector(for: String(word)) {
        vectors.append(vector)
      }
    }
    guard !vectors.isEmpty else { return [] }
    let vectorSize = vectors[0].count
    var averageVector: [Double] = Array(repeating: 0, count: vectorSize)
    for vector in vectors {
      for i in 0..<vectorSize {
        averageVector[i] += vector[i]
      }
    }
    for i in 0..<vectorSize {
      averageVector[i] /= Double(vectors.count)
    }
    return averageVector
  }

  // cosine similarity
  func cosineSimilarity(_ vec1: [Double], _ vec2: [Double]) -> Double {
    let dotProduct = zip(vec1, vec2).map(*).reduce(0, +)
    let magnitude1 = sqrt(vec1.map { $0 * $0 }.reduce(0, +))
    let magnitude2 = sqrt(vec2.map { $0 * $0 }.reduce(0, +))
    if magnitude1 == 0.0 || magnitude2 == 0.0 {
      return 0.0
    } else {
      return dotProduct / (magnitude1 * magnitude2)
    }
  }

  @objc(getEmoji:resolver:rejecter:)
  func getEmoji(_ text: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    var emojiLabelMapping: [String: String] = [:]

    do {
        let contents = try String(contentsOfFile: path!, encoding: .utf8)
        let lines = contents.components(separatedBy: "\n")
        // extract the emoji and label
        for line in lines {
            let parts = line.components(separatedBy: ": ")
            if parts.count == 2 {
                let emoji = parts[0]
                let label = parts[1]
                emojiLabelMapping[emoji] = label
            }
        }
    } catch {
        print("Error reading file: \(error)")
    }
 

    // precompute label embeddings
    var labelEmbeddings: [String: [Double]] = [:]
    for (emoji, label) in emojiLabelMapping {
      labelEmbeddings[emoji] = getVector(for: label)
    }

    let inputVector = getVector(for: text)
    print("input text: \(text)")
    print("Input vector: \(inputVector)") 

    // similarity calculation
    var similarities: [String: Double] = [:]
    for (emoji, labelVector) in labelEmbeddings {
      similarities[emoji] = cosineSimilarity(inputVector, labelVector)
    }

    let sortedEmojis = similarities.sorted { $0.value > $1.value }
    let topEmojis = sortedEmojis.prefix(10)
    let randomEmojis = Array(topEmojis.shuffled().prefix(3))
    
    var result: [String: Double] = [:]
    for (emoji, similarity) in randomEmojis {
      result[emoji] = similarity
    }
    print("Result: \(result)") 
    resolve(result)
  }
  
  @objc static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
