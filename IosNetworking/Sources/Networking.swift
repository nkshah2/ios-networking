import Foundation

public enum NetworkRequestMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

public protocol NetworkRequest {
    // MARK: Optional Variables
    var headers: [String: String]? { get }
    var properties: [String: Any]? { get }
    var timeout: TimeInterval { get }
    
    // MARK: Mandatory Variables
    var method: NetworkRequestMethod { get }
    var path: String { get }
}

public extension NetworkRequest {
    var headers: [String: String]? {
        return nil
    }
    
    var properties: [String: Any]? {
        return nil
    }
    
    var timeout: TimeInterval {
        return 10
    }
}

public struct NetworkResponse {
    public let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    func codable<T: Decodable>(_ type: T.Type) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch  {
            throw NetworkingError.jsonParsingError(nil)
        }
    }
}

public protocol NetworkManager {
    var baseUrl: String { get }
    
    func doRequest<T>(_ type: T.Type, request: NetworkRequest) async throws -> T where T: Decodable
}

public class NetworkManagerImplementation: NetworkManager {
    #if DEBUG
    public var baseUrl = "http://192.168.29.87:3001"
    #else
    public var baseUrl = "https://api.everylittletwig.com"
    #endif
    
    let appVersion: String
    
    public init(appVersion: String) {
        self.appVersion = appVersion
    }
    
    public func doRequest<T>(_ type: T.Type, request: NetworkRequest) async throws -> T where T : Decodable {
        var path = request.path
        
        if !path.starts(with: "/") {
            path = "/" + path
        }
        
        guard let url: URL = URL(string: "\(baseUrl)\(path)") else {
            throw NetworkingError.invalidURL()
        }
        
        let properties = request.properties ?? [:]
        
        if request.method == .GET || request.method == .DELETE {
            var queryItems: [URLQueryItem] = []
            
            for (key, value) in properties {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = request.timeout
        urlRequest.httpMethod = request.method.rawValue
        
        if request.method == .POST || request.method == .PUT {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let jsonBody = try JSONSerialization.data(withJSONObject: properties)
                urlRequest.httpBody = jsonBody
            } catch {
                throw NetworkingError.malformedBody(error)
            }
        }
        
        urlRequest.setValue("ios", forHTTPHeaderField: "x-platform")
        urlRequest.setValue(appVersion, forHTTPHeaderField: "x-app-version")
        
        if let headers: [String: String] = request.headers {
            for (key, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            let networkResponse = NetworkResponse(data: data)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    throw NetworkingError.unauthorised()
                } else if httpResponse.statusCode == 429 {
                    throw NetworkingError.paymentRequired()
                }
            }
            
            return try networkResponse.codable(type)
        } catch let errorObj as NetworkingError {
            throw errorObj
        } catch {
            throw NetworkingError.apiError(error)
        }
    }
}
