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
        getListZip()
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
        headerViewDxTapped()
        refreshControl.endRefreshing()
    }
    
    private func loadJobs () {
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
    func maxItemOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = JobsHomeCell.dequeue(tableView, indexPath)
        cell.delegate = self
        cell.job = dataArray[indexPath.row] as? Job
        return cell
    }
}

//MARK: - UITableViewDelegate

extension JobsHome: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedJob(dataArray[indexPath.row] as! Job)
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
        let wheel = MYWheel()
        wheel.start(view)
        let js = JobSelected()
        js.load(job, completion: { (error, msg) in
            wheel.stop()
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
        if zipFilesList.count == 0 {
            return
        }
        
        alert("Attenzione",
              message: "Ci sono degli icarichi de trasmettere.\nLi vuoi inviare adesso ?",
              cancelBlock: nil) {
                (action) in
                self.openListZip()
        }
    }
    
    private func openListZip() {
        let ctrl = UploadVC.Instance()
        navigationController?.show(ctrl, sender: self)
        ctrl.title = "Upload"
        ctrl.dataArray = zipFilesList
    }
}
