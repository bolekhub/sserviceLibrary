//
//  SLRequestDispatcher.swift
//  ServiceLayerLib
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation

final public class SLRequestDispatcher: RequestDispatcherProtocol {
    public var environment: SLEnvironmentProtocol
    private var networkSession: NetworkSessionProtocol?
    
        /// Initializer for Dispatcher
        /// - Parameters:
        ///   - env: type conforming SLEnvironmentProtocol
        ///   - networkSession: Pass an instance conforming NetworkSessionProtocol. By default we provide a session object wich have a Queue allowing max 3 concurrent operations.
    required public init(env: SLEnvironmentProtocol, networkSession: NetworkSessionProtocol? = nil) {
        self.environment = env
        if networkSession == nil {
            self.networkSession = SLNetworkSession()
        }
    }
    
    public func execute(request: SLRequest, completion: @escaping ((SLResponseProtocol?) -> Void)) -> URLSessionTask? {
        var task: URLSessionTask?
        guard let req = request.urlRequest(environment: self.environment), let session = self.networkSession else {
            return nil
        }
        
        switch request.trafficType {
        case .data:
            task = session.dataTaskWithRequest(req, completion: { data, response, error in
                guard let responseData = data, let result = response?.handleWithData(responseData) else {
                    return
                }
                switch result {
                case let .success(response):
                    completion(response)
                case .failure(_ ):
                    completion(nil)
                }
            })
            //TODO: implement download
        default:
            break
        }
        task?.resume()
        return task
    }
    
}

extension URLResponse {
    func handleWithData(_ data: Data) -> Result<SLResponseProtocol, Error> {
        guard let response = self as? HTTPURLResponse else {
            return .failure(SLAPIError.invalidResponse)
        }
        guard 200..<300 ~= response.statusCode else {
            return .failure(SLAPIError.incorrectStatus)
        }
        let result = ServiceResponse(data: data,
                                       headers: response.allHeaderFields,
                                       code: response.statusCode)
        return .success(result)
    }
}
