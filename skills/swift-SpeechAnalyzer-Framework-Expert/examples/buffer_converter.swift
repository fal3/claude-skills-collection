import AVFoundation
import Foundation

@available(macOS 26.0, iOS 26.0, visionOS 26.0, tvOS 26.0, *)
@available(watchOS, unavailable)
final class AnalyzerBufferConverter: @unchecked Sendable {
    enum Failure: LocalizedError, Sendable {
        case converterCreationFailed
        case outputBufferAllocationFailed
        case conversionFailed(String)

        var errorDescription: String? {
            switch self {
            case .converterCreationFailed:
                "AVAudioConverter could not convert between the input and analyzer formats."
            case .outputBufferAllocationFailed:
                "The converted audio buffer could not be allocated."
            case .conversionFailed(let message):
                "Audio conversion failed: \(message)"
            }
        }
    }

    // Safety invariant: every access to converter is serialized by lock.
    // outputFormat is immutable after initialization. ConverterInput owns each
    // non-Sendable input buffer for the synchronous conversion call only.
    private let lock = NSLock()
    private let outputFormat: AVAudioFormat
    private var converter: AVAudioConverter?

    init(outputFormat: AVAudioFormat) {
        self.outputFormat = outputFormat
    }

    func convert(_ inputBuffer: AVAudioPCMBuffer) throws -> AVAudioPCMBuffer {
        lock.lock()
        defer { lock.unlock() }

        if converter == nil
            || converter?.inputFormat.isEqual(inputBuffer.format) == false
            || converter?.outputFormat.isEqual(outputFormat) == false {
            converter = AVAudioConverter(from: inputBuffer.format, to: outputFormat)
            converter?.primeMethod = .none
        }

        guard let converter else {
            throw Failure.converterCreationFailed
        }

        let ratio = outputFormat.sampleRate / inputBuffer.format.sampleRate
        let capacity = max(
            1,
            AVAudioFrameCount(ceil(Double(inputBuffer.frameLength) * ratio))
        )
        guard let outputBuffer = AVAudioPCMBuffer(
            pcmFormat: outputFormat,
            frameCapacity: capacity
        ) else {
            throw Failure.outputBufferAllocationFailed
        }

        let source = ConverterInput(buffer: inputBuffer)
        var conversionError: NSError?
        let status = converter.convert(
            to: outputBuffer,
            error: &conversionError
        ) { _, inputStatus in
            guard !source.wasSupplied else {
                inputStatus.pointee = .noDataNow
                return nil
            }
            source.wasSupplied = true
            inputStatus.pointee = .haveData
            return source.buffer
        }

        if status == .error || conversionError != nil {
            throw Failure.conversionFailed(
                conversionError?.localizedDescription ?? "Unknown converter error"
            )
        }
        return outputBuffer
    }

    private final class ConverterInput: @unchecked Sendable {
        let buffer: AVAudioPCMBuffer
        var wasSupplied = false

        init(buffer: AVAudioPCMBuffer) {
            self.buffer = buffer
        }
    }
}
