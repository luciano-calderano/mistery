
import Foundation

extension Dictionary {
    private func getUrl (_ file: String) -> URL {
        return  URL(fileURLWithPath: file)
    }
    
    init (fromFile: String) {
        self.init()
        if FileManager.default.fileExists(atPath: fromFile) == false {
            return
        }
        let url = getUrl(fromFile)
        do {
            let data = try Data(contentsOf: url)
            
            let dict = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as! Dictionary<Key, Value>
            for key in dict.keys {
                self[key] = dict[key]
            }
        }
        catch let error as NSError {
            bugsnag.sendException("Errore lettura plist \(url.lastPathComponent): \(error.localizedDescription)")
        }
    }
    
    func saveToFile(_ file: String) -> Bool {
        let url = getUrl(file)
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: self,
                                                          format: .binary,
                                                          options: 0)
            try data.write(to: url)
            return true
        }
        catch let error as NSError {
            bugsnag.sendException("Errore salvataggio plist \(url.lastPathComponent): \(error.localizedDescription)")
        }
        return false
    }
}

