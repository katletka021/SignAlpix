import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .red
        tabBar.unselectedItemTintColor = .white
        tabBar.backgroundColor = .white
        
        let unsigned = UINavigationController(rootViewController: UnsignedViewController())
        unsigned.tabBarItem = UITabBarItem(title: "Неподписанные", image: UIImage(systemName: "doc"), tag: 0)
        let signed = UINavigationController(rootViewController: SignedViewController())
        signed.tabBarItem = UITabBarItem(title: "Подписанные", image: UIImage(systemName: "checkmark.circle"), tag: 1)
        let select = UINavigationController(rootViewController: iOSSelectionViewController())
        select.tabBarItem = UITabBarItem(title: "Выбрать iOS", image: UIImage(systemName: "iphone"), tag: 2)
        let files = UINavigationController(rootViewController: FilesViewController())
        files.tabBarItem = UITabBarItem(title: "Файлы", image: UIImage(systemName: "folder"), tag: 3)
        let apps = UINavigationController(rootViewController: AppsViewController())
        apps.tabBarItem = UITabBarItem(title: "Приложения", image: UIImage(systemName: "app.badge"), tag: 4)
        let appstore = UINavigationController(rootViewController: AppStoreViewController())
        appstore.tabBarItem = UITabBarItem(title: "AppStore", image: UIImage(systemName: "applelogo"), tag: 5)
        let downloads = UINavigationController(rootViewController: DownloadsViewController())
        downloads.tabBarItem = UITabBarItem(title: "Скачать", image: UIImage(systemName: "arrow.down.circle"), tag: 6)
        let settings = UINavigationController(rootViewController: SettingsViewController())
        settings.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gear"), tag: 7)
        
        viewControllers = [unsigned, signed, select, files, apps, appstore, downloads, settings]
    }
}
