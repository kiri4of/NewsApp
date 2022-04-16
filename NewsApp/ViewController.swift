//
//  ViewController.swift
//  NewsApp
//
//  Created by Kiri4of on 05.01.2022.
//

import UIKit
import SafariServices
//TableView
//Cusom Cell
//API Caller
//Open the News Story
//Search for News Stories
class ViewController: UIViewController {
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    private let searchVC = UISearchController(searchResultsController: nil)
    private var viewModels = [NewsTableViewCellViewModel]() // Получается ячейки(посты)
    private var articles = [Article]()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
        fetchTopStories()
        createSearchBar()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
    }
    private func createSearchBar() {
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
    }
    private func fetchTopStories() {
        APICaller.shared.getStories { [weak self] result in
            switch result {
            case .success(let articles):    //Массив содержимого поста
                self?.articles = articles
                self?.viewModels = articles.compactMap({ result in // проходимся по содержимому и присваеваем модели данные
                    NewsTableViewCellViewModel(title: result.title, subtitle: result.description ?? "No Description", imageURL: URL(string: result.urlToImage ?? "")) //возвращает эту самую модель
                })
                
                DispatchQueue.main.async {  //обновляем тейбл
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

}
extension ViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else { fatalError() } //чтобы метод юзать
        cell.configure(viewModel: viewModels[indexPath.row]) //конфигурируем каждую ячейку
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
//MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]
        guard let url = URL(string: article.url ?? "") else {return}
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
}

extension ViewController: UISearchBarDelegate{
    // Search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {//вызывает метод при нажатии enter и тем самым вызываю нашу функцию которая обновляет новости по поиску (текст введеный нами)
        guard let text = searchBar.text, !text.isEmpty else {return} //!text.isEmpty это text != nil
        print(text)
        APICaller.shared.search(with: text) { [weak self] result in
            switch result {
            case .success(let articles):    //Массив содержимого поста
                self?.articles = articles
                self?.viewModels = articles.compactMap({ result in // проходимся по содержимому и присваеваем модели данные
                    NewsTableViewCellViewModel(title: result.title, subtitle: result.description ?? "No Description", imageURL: URL(string: result.urlToImage ?? "")) //возвращает эту самую модель
                })
                
                DispatchQueue.main.async {  //обновляем тейбл
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
