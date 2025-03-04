import UIKit

class FileSelectorTableViewController: UITableViewController {
    var url: URL
    var files: [URL] = []

    init(at url: URL) {
        self.url = url
        files = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = url.lastPathComponent
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return files.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let url = files[indexPath.row]
        if url.hasDirectoryPath {
            cell.imageView?.image = UIImage(systemName: "folder")
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.imageView?.image = UIImage(systemName: "doc")
        }
        cell.textLabel?.text = url.lastPathComponent
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = files[indexPath.row]
        if url.hasDirectoryPath {
            show(FileSelectorTableViewController(at: url), sender: nil)
            return
        }
        let emulatorVC = EmulatorViewController()
        emulatorVC.emulator.executableURL = url
        emulatorVC.emulator.useJIT = Emulator.checkJITIsAvailable()
        if !emulatorVC.emulator.useJIT {
            let alertController = UIAlertController(title: "JIT is not enabled", message: "You probably want to use JIT for FPS improvement and stability, but it's not enabled.\n\nCurrently any integration about device-only JIT solution (like AltKit) is not introduced, so you need to manually launch CitriOS with AltStore's \"Enable JIT\" option, Jitstreamer, attach from Xcode or something else BEFORE launching the game.\n\n You can still play the emulator without JIT, but it's not recommended.", preferredStyle: .alert)
            alertController.addAction(.init(title: "Launch without JIT (SLOW), anyway", style: .destructive) { _ in
                self.view.window?.rootViewController = emulatorVC
            })
            alertController.addAction(.init(title: "Cancel", style: .cancel) { _ in

            })
            present(alertController, animated: true)
            return
        }
        view.window?.rootViewController = emulatorVC
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
