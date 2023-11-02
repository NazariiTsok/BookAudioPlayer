import Foundation
import Combine
import Collections

extension UserDefaults {
    public static let sharedSchema = UserDefaults(suiteName: "headway.premium.group")!
}

@propertyWrapper
public struct PersistedValue<Value> {
    public var value: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }
    
    public var wrappedValue: Value {
        get { value }
        nonmutating set { value = newValue }
    }
    
    public init(
        get: @escaping () -> Value,
        set: @escaping (Value) -> Void
    ) {
        self.get = get
        self.set = set
    }
    
    private let get: () -> Value
    private let set: (Value) -> Void
}

// MARK: - Operators

extension PersistedValue {
    public func map<U>(
        fromValue: @escaping (Value) -> U,
        toValue: @escaping (U) -> Value
    ) -> PersistedValue<U> {
        PersistedValue<U>(
            get: { fromValue(self.get()) },
            set: { self.set(toValue($0)) }
        )
    }
    
    public func withPublisher() -> (persisted: PersistedValue, publisher:  AnyPublisher<Value, Never>) {
        let subject = CurrentValueSubject<Value, Never>(get())
        return (
            persisted: PersistedValue(get: get, set: { subject.send($0); self.set($0) }),
            publisher: subject.eraseToAnyPublisher()
        )
    }
    
    public func unwrap<Wrapped>(withDefault default: Wrapped) -> PersistedValue<Wrapped> where Value == Wrapped? {
        map(fromValue: { $0 ?? `default` }, toValue: { .some($0) })
    }
}

// MARK: - OrderedSet

extension PersistedValue {
    public func toOrderedSet<Element: Hashable>() -> PersistedValue<OrderedSet<Element>?> where Value == [Element]? {
        map(
            fromValue: { $0.map(OrderedSet.init) },
            toValue: { $0.map(Array.init) }
        )
    }
}

// MARK: - Codable

extension PersistedValue where Value == Data? {
    public func codable<U: Codable>(_ value: U.Type = U.self) -> PersistedValue<U?> {
        map(
            fromValue: { $0.flatMap { try? JSONDecoder().decode(U.self, from: $0) } },
            toValue: { $0.flatMap { try? JSONEncoder().encode($0) } }
        )
    }
}

extension PersistedValue where Value == [String: Any]? {
    public func codable<U: Codable>(_ value: U.Type = U.self) -> PersistedValue<U?> {
        map(
            fromValue: { dictionary in
                guard let dictionary else { return nil }
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed)
                    return try JSONDecoder().decode(U.self, from: data)
                } catch {
                    assertionFailure(error.localizedDescription)
                    return nil
                }
            },
            toValue: { value in
                guard let value else { return nil }
                
                do {
                    let data = try JSONEncoder().encode(value)
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    return jsonObject as? [String: Any]
                } catch {
                    assertionFailure(error.localizedDescription)
                    return nil
                }
            }
        )
    }
}

extension UserDefaults {
    public func persistedDictionary(
        forKey key: String
    ) -> PersistedValue<[String: Any]?> {
        PersistedValue(
            get: { self.dictionary(forKey: key) },
            set: { self.set($0, forKey: key) }
        )
    }
    
    public func persistedArray<Element>(
        of elementType: Element.Type = Element.self,
        forKey key: String
    ) -> PersistedValue<[Element]?> {
        PersistedValue(
            get: { self.array(forKey: key) as? [Element] },
            set: { self.set($0, forKey: key) }
        )
    }
    
    public func persistedString(forKey key: String) -> PersistedValue<String?> {
        PersistedValue(
            get: { self.string(forKey: key) },
            set: { self.set($0, forKey: key) }
        )
    }
    
    public func persistedInteger(forKey key: String) -> PersistedValue<Int> {
        PersistedValue(
            get: { self.integer(forKey: key) },
            set: { self.set($0, forKey: key) }
        )
    }
    
    public func persistedData(forKey key: String) -> PersistedValue<Data?> {
        PersistedValue(
            get: { self.data(forKey: key) },
            set: { self.set($0, forKey: key) }
        )
    }
    
    public func persistedBool(forKey key: String) -> PersistedValue<Bool> {
        PersistedValue(
            get: { self.bool(forKey: key) },
            set: { self.set($0, forKey: key) }
        )
    }
    
    public func persistedDate(forKey key: String) -> PersistedValue<Date?> {
        PersistedValue(
            get: { self.object(forKey: key) as? Date },
            set: { self.set($0, forKey: key) }
        )
    }
}
