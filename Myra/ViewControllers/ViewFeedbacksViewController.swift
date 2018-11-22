//
//  ViewFeedbacksViewController.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-11-21.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import UIKit

class Contributor {
    var email: String = ""
    var count: Int = 0
}

class ViewFeedbacksViewController: UIViewController {


    @IBOutlet weak var topContributorEmail: UILabel!
    @IBOutlet weak var numberOfAnonymFeedbacks: UILabel!
    @IBOutlet weak var numberOfFeedbacks: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var feedbacks: [FeedbackElement] = [FeedbackElement]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        load()
    }

    @IBAction func reload(_ sender: Any) {
        load()
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }


    func load() {
        getFeedbacks { (feedbacks) in
            self.feedbacks = feedbacks
            self.autofill()
        }
    }

    func style() {
        
    }

    func autofill() {
        var anonym = 0
        numberOfFeedbacks.text = "Total Feedbacks: \(feedbacks.count)"
        for element in feedbacks where element.anonymous {
            anonym += 1
        }
        numberOfAnonymFeedbacks.text = "Anonymous: \(anonym)"
        self.tableView.reloadData()

        var contributors: [Contributor] = [Contributor]()
        for element in feedbacks where !element.email.isEmpty {
            var exists: Bool = false
            for person in contributors where person.email == element.email {
                person.count += 1
                exists = true
            }
            if !exists, element.email != "amir+1@freshworks.io" {
                var contributor = Contributor()
                contributor.email = element.email
                contributor.count = 1
                contributors.append(contributor)
            }
        }
        var topEmail = "Nobody :("
        var topCount = 0
        for person in contributors where person.count > topCount  {
            topCount = person.count
            topEmail = person.email
        }
        topContributorEmail.text = topEmail
    }

    func getFeedbacks(completion: @escaping (_ feedbacks: [FeedbackElement])->Void) {
        guard let endpoint = URL(string: Constants.API.feedbackPath, relativeTo: Constants.API.baseURL!) else {
            return completion([FeedbackElement]())
        }

        API.get(endpoint: endpoint) { (json) in
            var results = [FeedbackElement]()
            guard let response = json else {return completion(results)}
            for element in response {
                var fb: String = ""
                if let feedback = element.1["feedback"].string {
                    fb = feedback
                }

                var sec: String = ""
                if let section = element.1["section"].string {
                    sec = section
                }

                var anonym:Bool = true
                if let section = element.1["userId"].int {
                    anonym = false
                }

                var email = ""
                if !anonym, let user = element.1["user"].dictionaryObject{
                    if let mail = user["email"] as? String {
                        email = mail
                    }
                    print(email)
                }
                var element = FeedbackElement(feedback: fb, section: sec, anonymous: anonym)
                if !email.isEmpty {
                    element.email = email
                }
                results.append(element)
            }
            return completion(results)
        }
    }
}

extension ViewFeedbacksViewController:  UITableViewDelegate, UITableViewDataSource {
    func setUpTable() {
        if self.tableView == nil { return }
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: "UserFeedbackTableViewCell")
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getUserFeedbackTableViewCell(indexPath: IndexPath) -> UserFeedbackTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "UserFeedbackTableViewCell", for: indexPath) as! UserFeedbackTableViewCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getUserFeedbackTableViewCell(indexPath: indexPath)
        cell.setup(with: feedbacks[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbacks.count
    }
}
