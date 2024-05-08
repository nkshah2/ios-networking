import Foundation

public struct NetworkingError: Error, Equatable {
    public var code: Code
    public var underlyingError: Error?
    
    init(code: Code, underlyingError: Error? = nil) {
        self.code = code
        self.underlyingError = underlyingError
    }
    
    public static func == (lhs: NetworkingError, rhs: NetworkingError) -> Bool {
        return lhs.code == rhs.code
    }
    
    
    public struct Code: ExpressibleByIntegerLiteral, CustomStringConvertible, Equatable {
        public var description: String {
            switch self {
            case .jsonParsing:
                "jsonparsing"
            case .generic:
                "generic"
            case .invalidURL:
                "invalidurl"
            case .malformedBody:
                "malformedBody"
            case .apiError:
                "apiError"
            case .unauthorised:
                "unauthorised"
            case .paymentRequired:
                "paymentRequired"
            default:
                "unknown"
            }
        }
        
        public let value: Int
        
        static var jsonParsing: Code { 1 }
        static var generic: Code { 0 }
        static var invalidURL: Code { 2 }
        static var malformedBody: Code { 3 }
        static var apiError: Code { 4 }
        static var unauthorised: Code { 5 }
        static var paymentRequired: Code { 6 }
        
        init(value: Int) {
            self.value = value
        }
        
        public init(integerLiteral value: IntegerLiteralType) {
            self.value = value
        }
    }
    
    public static func jsonParsingError(_ error: Error?) -> NetworkingError {
        return .init(code: .jsonParsing, underlyingError: error)
    }
    
    public static func generic() -> NetworkingError {
        .init(code: .generic)
    }
    
    public static func invalidURL() -> NetworkingError {
        .init(code: .invalidURL)
    }
    
    public static func malformedBody(_ error: Error?) -> NetworkingError {
        .init(code: .malformedBody, underlyingError: error)
    }
    
    public static func apiError(_ error: Error?) -> NetworkingError {
        .init(code: .apiError, underlyingError: error)
    }
    
    public static func unauthorised() -> NetworkingError {
        .init(code: .unauthorised)
    }
    
    public static func paymentRequired() -> NetworkingError {
        .init(code: .paymentRequired)
    }
}