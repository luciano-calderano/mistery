//
//  UploadVC.swift
//  MysteryClient
//
//  Created by Developer on 07/08/2019.
//  Copyright © 2019 Mebius. All rights reserved.
//

import UIKit
import Alamofire

class UploadVC: MYViewController {
    class func Instance() -> UploadVC {
        return Instance(sbName: "Main") as! UploadVC
    }
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitle = "Upload"
        header?.header.sxButton.setImage(UIImage(named: "ico.back"), for: .normal)
        User.shared.getUserToken(completion: { (redirect_url) in
//            self.reload()
        }) {
            (errorCode, message) in
            self.alert(errorCode, message: message, okBlock: nil)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
//    private func reload () {
//        do {
//            let zipPath = URL(string: Config.Path.zip)!
//            let zipFiles = try FileManager.default.contentsOfDirectory(at: zipPath,
//                                                                       includingPropertiesForKeys: nil,
//                                                                       options:[])
//            for zipUrl in zipFiles {
//                if zipUrl.pathExtension == Config.File.zip {
//                    dataArray.append(zipUrl)
//                }
//            }
//        }
//        catch {
//            print("startUpload: error")
//        }
//        tableView.reloadData()
//    }

    let textView = UITextView()
    private func upload(url: URL) {
        let file = url.lastPathComponent
        textView.frame = tableView.frame
        view.addSubview(textView)
        
        textView.text = url.lastPathComponent
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            append("Creato: \(file)")
            uploadZip(url, data: data)
        }
        catch {
            append("Errore su creazione dati: \(file)")
        }
    }
    
    private func append (_ txt: String) {
        textView.text += txt + "\n"
    }
    
    private func uploadZip (_ zipUrl: URL, data: Data) {
        let jobId = zipUrl.deletingPathExtension().lastPathComponent
        append("Start upload job: \(jobId)" )
        
        let url = URL(string: Config.Url.put)!
        let headers = [
            "Authorization" : User.shared.token
        ]
        let request: URLRequest!
        do {
            let req = try URLRequest(url: url, method: .post, headers: headers)
            request = req
        }
        catch {
            append("Errore Auth: \(zipUrl)" )
            return
        }

        Alamofire.upload(multipartFormData: {
            (formData) in
            formData.append(data,
                            withName: "object_file",
                            fileName:  url.absoluteString,
                            mimeType: "multipart/form-data")
            
            let json = [
                "object"        : "job",
                "object_id"     : jobId,
            ]
            
            for (key, value) in json {
                formData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, with: request, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    (response) in
                    self.append("Result job-\(jobId): \(String(describing: response.result.value))" )
                    if let JSON = response.result.value {
                        print("Upload: Response.JSON: \(JSON)")
                        if MYZip.removeZipFile(zipUrl) {
                            self.append("Job Cancellato")
                        }
                        else {
                            self.append("Errore su cancellazione zip: \(jobId)")
                        }
                        return
                    }
                    self.append("let JSON = response.result.value")
                }
            case .failure(let encodingError):
                self.append(encodingError.localizedDescription)
            }
        })
    }
}


extension UploadVC: UITableViewDataSource {
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UploadCell.dequeue(tableView, indexPath)
        let url = dataArray[indexPath.row] as? URL
        cell.name.text = url?.lastPathComponent
        return cell
    }
}

//MARK: - UITableViewDelegate

extension UploadVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        upload(url: dataArray[indexPath.row] as! URL)
    }
}

class UploadCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView, _ indexPath: IndexPath) -> UploadCell {
        return tableView.dequeueReusableCell(withIdentifier: "UploadCell", for: indexPath) as! UploadCell
    }
    
    @IBOutlet var name: MYLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

