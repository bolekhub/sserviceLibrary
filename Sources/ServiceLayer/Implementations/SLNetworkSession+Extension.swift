//
//  SLNetworkSession+Extension.swift
//  ServiceLayerLib
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation
extension SLNetworkSession: NetworkSessionProtocol {
    func dataTaskWithRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
        guard let networkSession = self.session else { return nil }
        let dataTask = networkSession.dataTask(with: request, completionHandler: completion)
        return dataTask
    }

    func downloadTaskWithRequest(_ request: URLRequest, progress: SLProgresHandler?, completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask? {
        guard let networkSession = self.session else { return nil }
        let downloadTask = networkSession.downloadTask(with: request)
        setHandler(handler: (progress, completion), for: downloadTask)
        return downloadTask
    }
}

extension SLNetworkSession: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let handlers = getHandlersForTask(task) else {
            return
        }
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        DispatchQueue.main.async {
            handlers.progress?(progress)
        }
        self.setHandler(handler: nil, for: task)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? URLSessionDownloadTask,
              let handler = getHandlersForTask(task) else {
                  return
              }
        DispatchQueue.main.async {
            handler.completion?(nil, downloadTask.response, downloadTask.error)
        }
        self.setHandler(handler: nil, for: task)
    }
}
