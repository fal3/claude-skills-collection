import AVFoundation
import Speech

/// Example: Audio buffer conversion for SpeechAnalyzer
/// Converts AVAudioPCMBuffer to the format required by SpeechAnalyzer
class BufferConverter {
    private var converter: AVAudioConverter?

    func convertBuffer(_ buffer: AVAudioPCMBuffer,
                       to format: AVAudioFormat) throws -> AVAudioPCMBuffer {
        // Create converter if needed or format changed
        if converter == nil || converter?.outputFormat != format {
            converter = AVAudioConverter(from: buffer.format, to: format)
            // CRITICAL: Prevents timestamp drift
            converter?.primeMethod = .none
        }

        guard let converter = converter else {
            throw ConversionError.converterCreationFailed
        }

        // Calculate output frame capacity
        let ratio = format.sampleRate / buffer.format.sampleRate
        let outputFrameCapacity = AVAudioFrameCount(ceil(Double(buffer.frameLength) * ratio))

        guard let outputBuffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: outputFrameCapacity
        ) else {
            throw ConversionError.bufferAllocationFailed
        }

        var error: NSError?
        let status = converter.convert(to: outputBuffer, error: &error) { inPackets, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }

        guard status != .error, error == nil else {
            throw ConversionError.conversionFailed(error)
        }

        return outputBuffer
    }

    enum ConversionError: Error {
        case converterCreationFailed
        case bufferAllocationFailed
        case conversionFailed(Error?)
    }
}
