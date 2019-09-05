//
//  Profile.swift
//  MysteryClient
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

class JobsHome: MYViewController {
    class func Instance() -> JobsHome {
        return Instance(sbName: "Jobs", isInitial: true) as! JobsHome
    }

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    private var zipFilesList = [URL]()

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.addSubview(refreshControl)
//        MYJob.shared.clearJobs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Current.job = Job()
        Current.result = JobResult()
        loadJobs()
    }
    
    override func headerViewDxTapped() {
        MYJob.shared.clearJobs()
        loadJobs()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        headerViewDxTapped()
    }
    
    private func loadJobs () {
        getListZip()
        func showJobsList (jobDictArray: [JsonDict]) {
            var jobsArray = [Job]()
            for dict in jobDictArray {
                if let job = MYJob.shared.createJob(withDict: dict), MYZip.zipExists(id: job.id) == false {
                    jobsArray.append(job)
                }
            }
            dataArray = jobsArray
            tableView.reloadData()
        }
        
        func loadJobsList () {
            let param = [ "object" : "jobs_list" ]
            let request = MYHttp(.get, param: param)
            request.load(ok: {
                (response) in
                showJobsList(jobDictArray: response.array("jobs") as! [JsonDict])
            }) {
                (errorCode, message) in
                showError(error: errorCode, message: message)
            }
        }

        func downloadJobs () {
            User.shared.getUserToken(completion: { (redirect_url) in
                loadJobsList()
            }) {
                (errorCode, message) in
                showError(error: errorCode, message: message)
            }
        }
        
        if let jobs = MYJob.shared.loadJobs() {
            showJobsList(jobDictArray: jobs)
        } else {
            downloadJobs()
        }

        func showError (error: String, message: String) {
            alert(error, message: message, okBlock: nil)
        }        
    }
}

//MARK: - UITableViewDataSource

extension JobsHome: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? dataArray.count : zipFilesList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 125 : 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = JobsHomeCell.dequeue(tableView, indexPath)
            cell.delegate = self
            cell.job = dataArray[indexPath.row] as? Job
            return cell
        default:
            let cell = UploadCell.dequeue(tableView, indexPath)
            let url = zipFilesList[indexPath.row].deletingPathExtension()
            cell.name.text = url.lastPathComponent
            return cell
        }
    }
}

//MARK: - UITableViewDelegate

extension JobsHome: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            selectedJob(dataArray[indexPath.row] as! Job)
        default:
            let url = zipFilesList[indexPath.row].deletingPathExtension()
            let jobId = Int(url.lastPathComponent)
            if jobId == 0 {
                return
            }
            Current.job.id = jobId!
            let mySend = MySend()
            mySend.onTerminate = {
                (title, msg) in
                self.alert(title, message: msg)
                self.getListZip()
                tableView.reloadData()
            }
            mySend.uploadZipResult()
        }
    }
}

//MARK: - JobsHomeCellDelegate

extension JobsHome: JobsHomeCellDelegate {
    func mapTapped(_ sender: JobsHomeCell, job: Job) {
        let store = job.store
        _ = Maps(lat: store.latitude, lon: store.longitude, name: store.name)
    }
}

// MARK:- Selected job -

extension JobsHome {
    func selectedJob (_ job: Job) {
        MYHud.show()
        let js = JobSelected()
        js.load(job, completion: { (error, msg) in
            MYHud.hide()
            if (error.isEmpty) {
                self.navigationController?.show(JobDetail.Instance(), sender: self)
            } else {
                self.alert(error, message: msg, okBlock: nil)
            }
        })
    }
}

extension JobsHome {
    private func getListZip () {
        zipFilesList.removeAll()
        do {
            let zipPath = URL(string: Config.Path.zip)!
            let zipFiles = try FileManager.default.contentsOfDirectory(at: zipPath,
                                                                       includingPropertiesForKeys: nil,
                                                                       options:[])
            for zipUrl in zipFiles {
                if zipUrl.pathExtension == Config.File.zip {
                    zipFilesList.append(zipUrl)
                }
            }
        }
        catch {
            print("getListZip: error")
        }
    }
    
    private func openListZip() {
        let ctrl = UploadVC.Instance()
        navigationController?.show(ctrl, sender: self)
        ctrl.title = "Upload"
        ctrl.dataArray = zipFilesList
    }
}
