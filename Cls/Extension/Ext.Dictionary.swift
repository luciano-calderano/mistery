
import Foundation

extension Dictionary {
    private func getUrl (_ file: String) -> URL {
        return  URL(fileURLWithPath: file)
    }
    
    init (fromFile: String) {
        self.init()
        do {
            let data = try Data(contentsOf: getUrl(fromFile))
            
            let dict = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as! Dictionary<Key, Value>
            for key in dict.keys {
                self[key] = dict[key]
            }
        }
        catch let error as NSError {
            print("Error readig Dictionary: \(error.localizedDescription)")
        }
    }
    
    func saveToFile(_ file: String) -> Bool {
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: self,
                                                          format: .binary,
                                                          options: 0)
            try data.write(to: getUrl(file))
            return true
        }
        catch let error as NSError {
            fatalError("Error saving to file: \(error.localizedDescription)")
        }
    }
}

