//
//  NetworkActor.swift
//  Purs.iOS
//
//  Created by Artem Mkrtchyan on 1/9/24.
//

import Foundation

let networkActor =  NetworkActor()

actor NetworkActor {
    
    
    private let decoder = JSONDecoder()
    
    private var urlComponents = URLComponents(string: "https://purs-demo-bucket-test.s3.us-west-2.amazonaws.com")!
    
    init() {
        let decoderDateFormatter = DateFormatter()
        decoderDateFormatter.dateFormat = "HH:mm:ss"
        decoderDateFormatter.isLenient = true
        decoderDateFormatter.timeZone = .gmt
        decoder.dateDecodingStrategy = .formatted(decoderDateFormatter)
    }
    
    
    private func getRequest(url: URL, method: String) -> URLRequest{
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        return request
    }
    
    func getData(_ dataPath: String = "/location.json", useDataDump: Bool = false) async throws -> LocationItemResponse {
        urlComponents.path = dataPath
        if useDataDump {
            if let result = try? decoder.decode(LocationItemResponse.self, from: jsonDump.data(using: .utf8)!) {
                return result
            } else {
                throw MyNetworkError.dataIssue
            }
        }
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            
            throw MyNetworkError.networkIssue
            
        }
        if let result = try? decoder.decode(LocationItemResponse.self, from: data) {
            return result
        } else {
            throw MyNetworkError.dataIssue
        }
    }
}

public enum MyNetworkError: Error, Equatable {
    case networkIssue, dataIssue, defaultError
}


private let jsonDump = """
    {
        "location_name": "BEASTRO by Marshawn Lynch",
        "hours": [

            {
                "day_of_week": "WED",
                "start_local_time": "15:00:00",
                "end_local_time": "22:00:00"
            },
            {
                "day_of_week": "SAT",
                "start_local_time": "10:00:00",
                "end_local_time": "24:00:00"
            },
            {
                "day_of_week": "SUN",
                "start_local_time": "00:00:00",
                "end_local_time": "02:00:00"
            },
            {
                "day_of_week": "SUN",
                "start_local_time": "10:30:00",
                "end_local_time": "21:00:00"
            },
            {
                "day_of_week": "WED",
                "start_local_time": "07:00:00",
                "end_local_time": "13:00:00"
            },
            {
                "day_of_week": "TUE",
                "start_local_time": "00:00:00",
                "end_local_time": "03:20:00"
            },
            {
                "day_of_week": "TUE",
                "start_local_time": "15:00:00",
                "end_local_time": "22:00:00"
            },
            {
                "day_of_week": "THU",
                "start_local_time": "00:00:00",
                "end_local_time": "24:00:00"
            },
            {
                "day_of_week": "FRI",
                "start_local_time": "07:00:00",
                "end_local_time": "24:00:00"
            }
        ]
    }
"""

