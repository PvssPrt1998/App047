import Foundation
import CoreData

final class DataManager {
    private let modelName = "DataModel"
    
    lazy var coreDataStack = CoreDataStack(modelName: modelName)
    
    func saveVideoId(_ id: String, isEffect: Bool) {
        let videoId = VideoID(context: coreDataStack.managedContext)
        videoId.videoID = id
        videoId.isEffect = isEffect
        coreDataStack.saveContext()
    }
    
    func fetchVideoIds() throws -> Array<Video> {
        var array: Array<Video> = []
        let ids = try coreDataStack.managedContext.fetch(VideoID.fetchRequest())
        ids.forEach { videoId in
            array.append(Video(id: videoId.videoID, isEffect: videoId.isEffect, url: videoId.url))
        }
        return array
    }
    
    func editVideo(_ id: String, url: String) {
        do {
            let videosCD = try coreDataStack.managedContext.fetch(VideoID.fetchRequest())
            videosCD.forEach { vcd in
                if vcd.videoID == id {
                    vcd.url = url
                }
            }
            coreDataStack.saveContext()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func removeVideo(_ id: String) throws {
        let videosCD = try coreDataStack.managedContext.fetch(VideoID.fetchRequest())
        guard let videoCD = videosCD.first(where: {$0.videoID == id}) else { return }
        coreDataStack.managedContext.delete(videoCD)
        coreDataStack.saveContext()
    }
}

class CoreDataStack {
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                return print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
