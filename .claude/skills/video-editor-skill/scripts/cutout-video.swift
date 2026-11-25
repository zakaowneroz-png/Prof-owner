import AVFoundation
import CoreImage
import Foundation
import ImageIO
import UniformTypeIdentifiers
import Vision

// Video Editor Skill: per-frame person matte with macOS Vision (macOS 14+). Built by install.sh (key: cutout).
// usage: cutout-video <in.mp4> <outMaskDir>
// Writes one 8-bit grayscale matte PNG per video frame (00001.png …) using macOS Vision's
// foreground-instance mask (keeps held objects like the mic). Combine with ffmpeg alphamerge.
let args = CommandLine.arguments
guard args.count >= 3 else { print("usage: cutout-video <in.mp4> <outMaskDir>"); exit(2) }
let inURL = URL(fileURLWithPath: args[1])
let outDir = URL(fileURLWithPath: args[2], isDirectory: true)
try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

let asset = AVURLAsset(url: inURL)
let sem = DispatchSemaphore(value: 0)
var track: AVAssetTrack?
Task { track = try? await asset.loadTracks(withMediaType: .video).first; sem.signal() }
sem.wait()
guard let videoTrack = track else { print("no video track"); exit(1) }
let reader = try AVAssetReader(asset: asset)
let output = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
output.alwaysCopiesSampleData = false
reader.add(output)
reader.startReading()

let ctx = CIContext()
let gray = CGColorSpaceCreateDeviceGray()
var n = 0, empty = 0
let t0 = Date()
while let sample = output.copyNextSampleBuffer(), let pb = CMSampleBufferGetImageBuffer(sample) {
  n += 1
  let handler = VNImageRequestHandler(cvPixelBuffer: pb)
  let req = VNGenerateForegroundInstanceMaskRequest()
  var maskImage: CIImage
  do {
    try handler.perform([req])
    if let obs = req.results?.first {
      let m = try obs.generateScaledMaskForImage(forInstances: obs.allInstances, from: handler)
      maskImage = CIImage(cvPixelBuffer: m)
    } else {
      empty += 1
      maskImage = CIImage(color: .black).cropped(to: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pb), height: CVPixelBufferGetHeight(pb)))
    }
  } catch { print("frame \(n): \(error)"); exit(1) }
  guard let cg = ctx.createCGImage(maskImage, from: maskImage.extent, format: .L8, colorSpace: gray) else { exit(1) }
  let url = outDir.appendingPathComponent(String(format: "%05d.png", n))
  let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
  CGImageDestinationAddImage(dest, cg, nil)
  CGImageDestinationFinalize(dest)
  if n % 60 == 0 { print("\(n) frames, \(String(format: "%.2f", Date().timeIntervalSince(t0) / Double(n)))s/frame") }
}
print("done: \(n) frames (\(empty) with no subject) in \(String(format: "%.1f", Date().timeIntervalSince(t0)))s")
