// swiftlint:disable type_name
import Argo
import Curry
import Prelude
import Runes

//fixme: always .success?
internal extension Collection where Iterator.Element == LiveStreamChatMessage {
  static func decode(_ snapshots: [FirebaseDataSnapshotType]) -> Decoded<[LiveStreamChatMessage]> {
    return .success(snapshots.flatMap { snapshot in
      LiveStreamChatMessage.decode(snapshot).value
    })
  }
}

public struct LiveStreamChatMessage {
  public fileprivate(set) var id: String
  public fileprivate(set) var isCreator: Bool?
  public fileprivate(set) var message: String
  public fileprivate(set) var name: String
  public fileprivate(set) var profilePictureUrl: String
  public fileprivate(set) var date: TimeInterval
  public fileprivate(set) var userId: Int

  static internal func decode(_ snapshot: FirebaseDataSnapshotType) ->
    Decoded<LiveStreamChatMessage> {
      return (snapshot.value as? [String:Any])
        .map { self.decode(
          JSON($0.withAllValuesFrom([LiveStreamChatMessageDictionaryKey.id.rawValue: snapshot.key])))
        }
        .coalesceWith(.failure(.custom("Unable to parse Firebase snapshot.")))
  }
}

extension LiveStreamChatMessage: Decodable {
  static public func decode(_ json: JSON) -> Decoded<LiveStreamChatMessage> {
    let create = curry(LiveStreamChatMessage.init)

    let tmp1 = create
      <^> json <| LiveStreamChatMessageDictionaryKey.id.rawValue
      <*> json <|? LiveStreamChatMessageDictionaryKey.creator.rawValue
      <*> json <| LiveStreamChatMessageDictionaryKey.message.rawValue
      <*> json <| LiveStreamChatMessageDictionaryKey.name.rawValue

    let tmp2 = tmp1
      <*> json <| LiveStreamChatMessageDictionaryKey.profilePic.rawValue
      <*> json <| LiveStreamChatMessageDictionaryKey.timestamp.rawValue
      <*> ((json <| LiveStreamChatMessageDictionaryKey.userId.rawValue) >>- convertId)

    return tmp2
  }
}

extension LiveStreamChatMessage: Equatable {
  static public func == (lhs: LiveStreamChatMessage, rhs: LiveStreamChatMessage) -> Bool {
    return lhs.id == rhs.id
  }
}

// Currently chat user ID's are prefixed with "id_" and are strings, doing this until that changes
private func convertId(fromJson json: JSON) -> Decoded<Int> {
  switch json {
  case .string(let string):
    let idPrefix = "id_"

    if string.hasPrefix(idPrefix) {
      return Int(string.replacingOccurrences(of: idPrefix, with: ""))
        .map(Decoded.success)
        .coalesceWith(.failure(.custom("Couldn't decoded \"\(string)\" into Int.")))
    }

    return Int(string)
      .map(Decoded.success)
      .coalesceWith(.failure(.custom("Couldn't decoded \"\(string)\" into Int.")))
  case .number(let number):
    return .success(number.intValue)
  default:
    return .failure(.custom("Couldn't decoded Int."))
  }
}

extension LiveStreamChatMessage {
  public enum lens {
    public static let id = Lens<LiveStreamChatMessage, String>(
      view: { $0.id },
      set: { var new = $1; new.id = $0; return new }
    )
    public static let isCreator = Lens<LiveStreamChatMessage, Bool?>(
      view: { $0.isCreator },
      set: { var new = $1; new.isCreator = $0; return new }
    )
    public static let message = Lens<LiveStreamChatMessage, String>(
      view: { $0.message },
      set: { var new = $1; new.message = $0; return new }
    )
    public static let name = Lens<LiveStreamChatMessage, String>(
      view: { $0.name },
      set: { var new = $1; new.name = $0; return new }
    )
    public static let profilePictureUrl = Lens<LiveStreamChatMessage, String>(
      view: { $0.profilePictureUrl },
      set: { var new = $1; new.profilePictureUrl = $0; return new }
    )
    public static let date = Lens<LiveStreamChatMessage, TimeInterval>(
      view: { $0.date },
      set: { var new = $1; new.date = $0; return new }
    )
    public static let userId = Lens<LiveStreamChatMessage, Int>(
      view: { $0.userId },
      set: { var new = $1; new.userId = $0; return new }
    )
  }
}
