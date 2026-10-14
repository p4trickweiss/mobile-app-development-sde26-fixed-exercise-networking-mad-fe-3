//
//  Networking.swift
//  MAD Project
//

import Foundation

class Networking {
    private let session = URLSession(configuration: .default)
    private let apiKey = "AIzaSyDeLs8S6Hpy642JUPC3Pft-xVx8Ocs-uXY"

    func login(email: String, password: String, completionHandler: @escaping (User?, NetworkingError?) -> Void) {
        let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(apiKey)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "email": email,
            "password": password,
            "returnSecureToken": true
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completionHandler(nil, .serializationFailed(error.localizedDescription))
            return
        }

        let task = session.dataTask(with: request) { data, response, error in
            let result = self.result(data: data, response: response, error: error)
            DispatchQueue.main.async {
                switch result {
                case .success(let user): completionHandler(user, nil)
                case .failure(let error): completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }

    private func result(data: Data?, response: URLResponse?, error: Error?) -> Result<User, NetworkingError> {
        if let error = error as NSError? {
            if error.code == NSURLErrorNotConnectedToInternet {
                return .failure(.offline(error.localizedDescription))
            }
            return .failure(.unexpected(error.localizedDescription))
        }

        guard let data = data, let http = response as? HTTPURLResponse else {
            return .failure(.unexpected("No data or response received."))
        }

        if http.statusCode == 200 {
            guard let user = try? JSONDecoder().decode(User.self, from: data) else {
                return .failure(.unexpectedFormat)
            }
            return .success(user)
        }

        switch (try? JSONDecoder().decode(ResponseError.self, from: data))?.error.message {
        case "INVALID_EMAIL": return .failure(.invalidEmail)
        case "EMAIL_NOT_FOUND": return .failure(.unknownEmail)
        case "INVALID_PASSWORD", "INVALID_LOGIN_CREDENTIALS": return .failure(.wrongPassword)
        default: return .failure(.httpError(http.statusCode))
        }
    }
}
