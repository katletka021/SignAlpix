import UIKit
import UniformTypeIdentifiers

// MARK: - Модели
struct AppItem { var name: String; var path: String; var isSigned: Bool }
struct FileItem { var name: String; var size: String; var date: String }

// MARK: - UnsignedViewController
class UnsignedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var apps: [AppItem] = []
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Неподписанные"
        setupTableView()
        loadApps()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importIPA))
    }
    
    func setupTableView() {
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    func loadApps() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documents, includingPropertiesForKeys: nil)
            apps = files.filter { $0.pathExtension == "ipa" }.map { AppItem(name: $0.lastPathComponent, path: $0.path, isSigned: false) }
            tableView.reloadData()
        } catch { print(error) }
    }
    
    @objc func importIPA() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "ipa")!])
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return apps.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = apps[indexPath.row].name
        cell.textLabel?.textColor = .red
        cell.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let certVC = CertificateManagerViewController()
        certVC.appPath = apps[indexPath.row].path
        navigationController?.pushViewController(certVC, animated: true)
    }
}

extension UnsignedViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let dest = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(url.lastPathComponent)
        try? FileManager.default.copyItem(at: url, to: dest)
        loadApps()
    }
}

// MARK: - SignedViewController
class SignedViewController: UnsignedViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Подписанные"
        loadSignedApps()
    }
    
    override func loadApps() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let signedDir = docs.appendingPathComponent("Signed")
        try? FileManager.default.createDirectory(at: signedDir, withIntermediateDirectories: true)
        do {
            let files = try FileManager.default.contentsOfDirectory(at: signedDir, includingPropertiesForKeys: nil)
            apps = files.filter { $0.pathExtension == "ipa" }.map { AppItem(name: $0.lastPathComponent, path: $0.path, isSigned: true) }
            tableView.reloadData()
        } catch { print(error) }
    }
    
    func loadSignedApps() { loadApps() }
}

// MARK: - FilesViewController
class FilesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var files: [FileItem] = []
    let tableView = UITableView()
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Список файлов"
        setupSearchBar()
        setupTableView()
        loadFiles()
    }
    
    func setupSearchBar() {
        searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        searchBar.placeholder = "Поиск"
        searchBar.backgroundColor = .white
        searchBar.searchTextField.textColor = .red
        view.addSubview(searchBar)
    }
    
    func setupTableView() {
        tableView.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 50)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "fileCell")
        view.addSubview(tableView)
    }
    
    func loadFiles() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let items = try FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey])
            files = items.map { url in
                let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
                let size = (attrs?[.size] as? Int64).map { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) } ?? "0 KB"
                let date = (attrs?[.creationDate] as? Date).map { DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none) } ?? ""
                return FileItem(name: url.lastPathComponent, size: size, date: date)
            }
            tableView.reloadData()
        } catch { print(error) }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return files.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath)
        let file = files[indexPath.row]
        cell.textLabel?.text = "\(file.name) • \(file.size)"
        cell.textLabel?.textColor = .red
        cell.backgroundColor = .white
        return cell
    }
}

// MARK: - AppsViewController
class AppsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var collectionView: UICollectionView!
    let apps = ["App1", "App2", "App3", "App4", "App5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Приложения"
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 120)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "appCell")
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return apps.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "appCell", for: indexPath)
        cell.backgroundColor = .red
        cell.layer.cornerRadius = 12
        let label = UILabel(frame: cell.bounds)
        label.text = apps[indexPath.row]
        label.textColor = .white
        label.textAlignment = .center
        cell.addSubview(label)
        return cell
    }
}

// MARK: - AppStoreViewController
class AppStoreViewController: AppsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AppStore"
    }
}

// MARK: - DownloadsViewController
class DownloadsViewController: UIViewController, WKDownloadDelegate {
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Скачать"
        
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.load(URLRequest(url: URL(string: "https://github.com")!))
        view.addSubview(webView)
    }
}
