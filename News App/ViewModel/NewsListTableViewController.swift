//
//  NewsListTableViewController.swift
//  News App
//
//  Created by Mohan AC on 17/02/22.
//

import UIKit
import SafariServices

class NewsListTableViewController: UITableViewController {
    
    var newsList = [News]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchNews()
    }
    
    func fetchNews() {
        let link = WebService(endpoint: Content.getNews, urlParam: nil, httpBody: nil)
        link.connect { (response:Result<[News]>) in
            
            switch response {
            case .success(let apiData):
                //print(apiData)
                self.newsList = apiData
                
                for news in self.newsList {
                    let newsObj = news
                    var newsArticleId = newsObj.url
                    if newsArticleId != "" {
                        newsArticleId = newsArticleId?.replacingOccurrences(of: "/", with: "-")
                        self.fetchLikesCount(id: newsArticleId!)
                        self.fetchCommentsCount(id: newsArticleId!)
                    }
                }
                
                self.tableView.reloadData()
                
            case .failure(let failureMessage):
                print(failureMessage)
                
            case .error(let errorMessage):
                print(errorMessage)
            }
        }
    }
    
    func fetchLikesCount(id: String) {
        let link = WebService(endpoint: Content.getLikes(newsArticleId: id), urlParam: nil, httpBody: nil)
        link.connect { (response:Result<likes>) in
            
            switch response {
            case .success(let apiData):
                if apiData.likes != 0, apiData.likes != nil {
                    print("Likes Count: ", apiData.likes!)
                }
                
            case .failure(let failureMessage):
                print(failureMessage)
                
            case .error(let errorMessage):
                print(errorMessage)
            }
        }
    }
    
    func fetchCommentsCount(id: String) {
        let link = WebService(endpoint: Content.getComments(newsArticleId: id), urlParam: nil, httpBody: nil)
        link.connect { (response:Result<comments>) in
            
            switch response {
            case .success(let apiData):
                if apiData.comments != 0, apiData.comments != nil {
                    print("Comments Count: ", apiData.comments!)
                }
                
            case .failure(let failureMessage):
                print(failureMessage)
                
            case .error(let errorMessage):
                print(errorMessage)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let footerView = UIView()
    //        footerView.backgroundColor = .clear
    //        return footerView
    //    }
    //
    //    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 20
    //    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
        
        cell.newsImage.downloaded(from: newsList[indexPath.row].urlToImage ?? "")
        cell.newsTitle.text = newsList[indexPath.row].title
        cell.newsDescription.text = newsList[indexPath.row].description
        
        if let newsLikesCount = newsList[indexPath.row].likes, newsLikesCount != 0 {
            cell.newsLikesCount.text = "Likes: \(newsLikesCount)"
        } else {
            cell.newsLikesCount.text = "Likes: NA"
        }
        
        if let newsCommentsCount = newsList[indexPath.row].comments, newsCommentsCount != 0 {
            cell.newsCommentsCount.text = "Comments: \(newsCommentsCount)"
        } else {
            cell.newsCommentsCount.text = "Comments: NA"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsUrl = newsList[indexPath.row].url ?? ""
        
        if let url = URL(string: newsUrl) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension UIImageView {
    func downloaded(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url)
    }
}
