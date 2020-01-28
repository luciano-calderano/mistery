//
//  Upload.swift
//  MysteryClient
//
//  Created by Developer on 28/01/2020.
//  Copyright © 2020 Mebius. All rights reserved.
//

import UIKit

class Upload {
    func upload(image: UIImage, url: URL, _ completion: @escaping ((String?)->())) {
        // the image in UIImage type
        let boundary = UUID().uuidString
        
        //    let filename = "avatar.png"
        //    let fieldName = "reqtype"
        //    let fieldValue = "fileupload"
        //    let fieldName2 = "userhash"
        //    let fieldValue2 = "caa3dce4fcb36cfdf9258ad9c"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        // Add the reqtype field and its value to the raw http request data
        //    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        //    data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
        //    data.append("\(fieldValue)".data(using: .utf8)!)
        //
        //    // Add the userhash field and its value to the raw http reqyest data
        //    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        //    data.append("Content-Disposition: form-data; name=\"\(fieldName2)\"\r\n\r\n".data(using: .utf8)!)
        //    data.append("\(fieldValue2)".data(using: .utf8)!)
        
        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        //    data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            
            if (error != nil){
                print("\(error!.localizedDescription)")
                completion(error?.localizedDescription)
                return
            }
            
            guard let responseData = responseData else {
                completion("no response data")
                return
            }
            
            if let responseString = String(data: responseData, encoding: .utf8) {
                print("uploaded to: \(responseString)")
                completion(nil)
                return
            }
            completion("errore upload")
        }).resume()
    }
}
