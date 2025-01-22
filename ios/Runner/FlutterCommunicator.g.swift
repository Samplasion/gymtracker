// Autogenerated from Pigeon (v22.7.2), do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Error class for passing custom error details to Dart side.
final class PigeonError: Error {
  let code: String
  let message: String?
  let details: Any?

  init(code: String, message: String?, details: Any?) {
    self.code = code
    self.message = message
    self.details = details
  }

  var localizedDescription: String {
    return
      "PigeonError(code: \(code), message: \(message ?? "<nil>"), details: \(details ?? "<nil>")"
      }
}

private func wrapResult(_ result: Any?) -> [Any?] {
  return [result]
}

private func wrapError(_ error: Any) -> [Any?] {
  if let pigeonError = error as? PigeonError {
    return [
      pigeonError.code,
      pigeonError.message,
      pigeonError.details,
    ]
  }
  if let flutterError = error as? FlutterError {
    return [
      flutterError.code,
      flutterError.message,
      flutterError.details,
    ]
  }
  return [
    "\(error)",
    "\(type(of: error))",
    "Stacktrace: \(Thread.callStackSymbols)",
  ]
}

private func createConnectionError(withChannelName channelName: String) -> PigeonError {
  return PigeonError(code: "channel-error", message: "Unable to establish connection on channel: '\(channelName)'.", details: "")
}

private func isNullish(_ value: Any?) -> Bool {
  return value is NSNull || value == nil
}

private func nilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}

private class FlutterCommunicatorPigeonCodecReader: FlutterStandardReader {
}

private class FlutterCommunicatorPigeonCodecWriter: FlutterStandardWriter {
}

private class FlutterCommunicatorPigeonCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return FlutterCommunicatorPigeonCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return FlutterCommunicatorPigeonCodecWriter(data: data)
  }
}

class FlutterCommunicatorPigeonCodec: FlutterStandardMessageCodec, @unchecked Sendable {
  static let shared = FlutterCommunicatorPigeonCodec(readerWriter: FlutterCommunicatorPigeonCodecReaderWriter())
}

/// Generated protocol from Pigeon that represents a handler of messages from Flutter.
protocol GymWatchHostAPI {
  func setIsWorkoutRunning(isWorkoutRunning: Bool) throws
  func setExerciseParameters(hasExercise: Bool, exerciseName: String, exerciseColor: Int64, exerciseParameters: String) throws
}

/// Generated setup class from Pigeon to handle messages through the `binaryMessenger`.
class GymWatchHostAPISetup {
  static var codec: FlutterStandardMessageCodec { FlutterCommunicatorPigeonCodec.shared }
  /// Sets up an instance of `GymWatchHostAPI` to handle messages through the `binaryMessenger`.
  static func setUp(binaryMessenger: FlutterBinaryMessenger, api: GymWatchHostAPI?, messageChannelSuffix: String = "") {
    let channelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""
    let setIsWorkoutRunningChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.gymtracker.GymWatchHostAPI.setIsWorkoutRunning\(channelSuffix)", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      setIsWorkoutRunningChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let isWorkoutRunningArg = args[0] as! Bool
        do {
          try api.setIsWorkoutRunning(isWorkoutRunning: isWorkoutRunningArg)
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      setIsWorkoutRunningChannel.setMessageHandler(nil)
    }
    let setExerciseParametersChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.gymtracker.GymWatchHostAPI.setExerciseParameters\(channelSuffix)", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      setExerciseParametersChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let hasExerciseArg = args[0] as! Bool
        let exerciseNameArg = args[1] as! String
        let exerciseColorArg = args[2] as! Int64
        let exerciseParametersArg = args[3] as! String
        do {
          try api.setExerciseParameters(hasExercise: hasExerciseArg, exerciseName: exerciseNameArg, exerciseColor: exerciseColorArg, exerciseParameters: exerciseParametersArg)
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      setExerciseParametersChannel.setMessageHandler(nil)
    }
  }
}
/// Generated protocol from Pigeon that represents Flutter messages that can be called from Swift.
protocol GymWatchFlutterAPIProtocol {
  func markThisSetAsDone(completion: @escaping (Result<Void, PigeonError>) -> Void)
  func requestTrainingData(completion: @escaping (Result<Void, PigeonError>) -> Void)
}
class GymWatchFlutterAPI: GymWatchFlutterAPIProtocol {
  private let binaryMessenger: FlutterBinaryMessenger
  private let messageChannelSuffix: String
  init(binaryMessenger: FlutterBinaryMessenger, messageChannelSuffix: String = "") {
    self.binaryMessenger = binaryMessenger
    self.messageChannelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""
  }
  var codec: FlutterCommunicatorPigeonCodec {
    return FlutterCommunicatorPigeonCodec.shared
  }
  func markThisSetAsDone(completion: @escaping (Result<Void, PigeonError>) -> Void) {
    let channelName: String = "dev.flutter.pigeon.gymtracker.GymWatchFlutterAPI.markThisSetAsDone\(messageChannelSuffix)"
    let channel = FlutterBasicMessageChannel(name: channelName, binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage(nil) { response in
      guard let listResponse = response as? [Any?] else {
        completion(.failure(createConnectionError(withChannelName: channelName)))
        return
      }
      if listResponse.count > 1 {
        let code: String = listResponse[0] as! String
        let message: String? = nilOrValue(listResponse[1])
        let details: String? = nilOrValue(listResponse[2])
        completion(.failure(PigeonError(code: code, message: message, details: details)))
      } else {
        completion(.success(Void()))
      }
    }
  }
  func requestTrainingData(completion: @escaping (Result<Void, PigeonError>) -> Void) {
    let channelName: String = "dev.flutter.pigeon.gymtracker.GymWatchFlutterAPI.requestTrainingData\(messageChannelSuffix)"
    let channel = FlutterBasicMessageChannel(name: channelName, binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage(nil) { response in
      guard let listResponse = response as? [Any?] else {
        completion(.failure(createConnectionError(withChannelName: channelName)))
        return
      }
      if listResponse.count > 1 {
        let code: String = listResponse[0] as! String
        let message: String? = nilOrValue(listResponse[1])
        let details: String? = nilOrValue(listResponse[2])
        completion(.failure(PigeonError(code: code, message: message, details: details)))
      } else {
        completion(.success(Void()))
      }
    }
  }
}
