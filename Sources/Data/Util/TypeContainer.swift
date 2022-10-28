#if canImport(Foundation)
import Foundation

@dynamicMemberLookup
public struct TypeContainer<Parent, T> {
    private var keyPaths: [String] = []
    
    public init() {
        self.keyPaths = []
    }
    
    private init(keyPaths: [String]) {
        self.keyPaths = keyPaths
    }
    
    public subscript<S>(dynamicMember keyPath: KeyPath<T, S>) -> TypeContainer<Parent, S> where T: NSObject {
        return TypeContainer<Parent, S>(keyPaths: keyPaths + [keyPath.keyPath])
    }
    
    var keyPath: String {
        keyPaths.filter { !$0.isEmpty }.joined(separator: ".")
    }
}

typealias ParentTypeContainer<T: NSObject> = TypeContainer<T, T>

#endif
