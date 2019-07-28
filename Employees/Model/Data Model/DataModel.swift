//
//  DataModel.swift
//  Employees
//
//  Created by Farzana Sultana on 7/27/19.
//

import CoreData

class DataModel: NSObject {

    //@objc  @objc MARK: CoreData Stack
    
    func saveContext(){
        
        guard let moc  = managedObjectContext() else{
            print("did not save context")
            return
        }
        
        if moc.hasChanges {
            do {
                try  moc.save()
            }
            catch{
                print("Unresolved error \(error.localizedDescription)")
            }
        }
    }
    
    func managedObjectContext()-> NSManagedObjectContext?{
        let app = AppDelegate.shared()
        
        if let moc = app.managedObjectContext {
            return moc
        }
        
        guard let psc = persistentStoreCoordinator() else{
            return  nil
        }
        
        app.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        app.managedObjectContext?.retainsRegisteredObjects = true
        app.managedObjectContext?.persistentStoreCoordinator = psc
        
        return  app.managedObjectContext
    }
    
    func persistentStoreCoordinator ()-> NSPersistentStoreCoordinator?{
        
        let app = AppDelegate.shared()
        
        if let psc = app.persistentStoreCoordinator {
            return psc
        }
        else {
            
            let storeURL = applicationStoresDirectory()!.appendingPathComponent("Employee.sqlite")
            
            print(storeURL)
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true, NSSQLitePragmasOption: ["journal_mode": "DELETE"]] as [String : Any]
            
            
            guard let mom = managedObjectModel() else{
                return nil
            }
            
            app.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
            
            do{
                if let _ =  try app.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options) {
                    return app.persistentStoreCoordinator
                }
                
                let fm = FileManager.default
                
                
                // Move Incompatible Store
                if fm.fileExists(atPath: storeURL.path){
                    
                    guard let corruptUrl = applicationIncompatibleStoresDirectory() else{
                        return nil
                    }
                    
                    let corruptURL = corruptUrl.appendingPathComponent(nameForIncompatibleStore())
                    
                    // Move Corrupt Store
                    do {
                        try fm.moveItem(at:storeURL, to:corruptURL)
                    }
                    catch{
                        return nil
                    }
                }
                
                
                do{
                    try app.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
                }
                catch{
                    print("Unable to create persistent store after recovery. \(error.localizedDescription)");
                    return nil
                }
                
            }
            catch{
                print("Failed to create with SQLite")
                return nil
            }
        }
        
        return app.persistentStoreCoordinator
    }
    
    func applicationIncompatibleStoresDirectory()-> URL?{
        
        let fm = FileManager.default
        
        
        guard var url = applicationStoresDirectory() else {
            return nil
        }
        
        url = url.appendingPathComponent("Incompatible")
        
        if !(fm.fileExists(atPath: url.path)) {
            
            do {
                try  fm.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print("Unable to create directory for corrupt data stores.")
                return nil
            }
            
            return url
            
        }
        else{
            return url
        }
        
    }
    
    func applicationStoresDirectory()-> URL?{
        
        let fm = FileManager.default
        let applicationApplicationSupportDirectory = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
        
        let url = applicationApplicationSupportDirectory.appendingPathComponent("Stores")
        
        if !(fm.fileExists(atPath: url.path)) {
            
            do {
                try  fm.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print("Unable to create directory for corrupt data stores.")
                return nil
            }
            
            return url
            
        }
        else{
            return url
        }
        
    }
    
    func managedObjectModel()->NSManagedObjectModel?{
        
        let app = AppDelegate.shared()
        
        if let mom = app.managedObjectModel{
            return mom
        }
        
        guard  let url = Bundle.main.url(forResource: "Employee", withExtension: "momd") else {
            app.managedObjectModel = NSManagedObjectModel .mergedModel(from: nil)
            return app.managedObjectModel
        }
        
        app.managedObjectModel = NSManagedObjectModel(contentsOf :url)
        return app.managedObjectModel
    }
    
    
    func nameForIncompatibleStore()-> String {
        
        let df = DateFormatter()
        df.formatterBehavior = .behavior10_4
        df.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        
        let name = df.string(from: Date.init())
        
        return name
    }
    
    // MARK: - Database operations
    // Insert
    
    func insertData(Array entityObjects:[NSObject], entityName: String) ->Bool{
        
        guard let moc = managedObjectContext() else {
            return false
        }
        
        for eObj in entityObjects {
            
            let entity = NSEntityDescription.entity(forEntityName: entityName, in: moc)
            let mObj = NSManagedObject(entity: entity!, insertInto: moc)
            Mapper.convert(fromEntity: eObj, toManaged: mObj)
        }
        
        do {
            try  moc.save()
            return true
            
        } catch {
            print("error to insert: \(error)")
            return false
        }
        
    }
    
    // Update if exist (by given predicate), otherwise insert
    
    func modify(_ data: NSObject, entity:String, predicate:NSPredicate?)->Bool{
        
        guard let moc = managedObjectContext() else {
            return false
        }
        
        let arr = getData(By: entity, managed:true, sorts: nil, predicate: predicate, context: moc)
        
        if arr.count>0{
            let mObj = arr.first! as! NSManagedObject
            Mapper.convert(fromEntity: data, toManaged: mObj)
            
            do {
                try  moc.save()
                return true
                
            } catch {
                print("error to modify")
                return false
            }
        }
        else{
            return insertData(Array: [data], entityName: entity)
        }
        
    }
    
    // Fetch
    
    func getData(By entity:String, managed: Bool, sorts:[NSSortDescriptor]?, predicate:NSPredicate?) ->[AnyObject]{
        
        guard let moc = managedObjectContext() else {
            return [AnyObject] ()
        }
        
        return getData(By: entity, managed: managed, sorts: sorts, predicate: predicate, context: moc)
    }
    
    fileprivate func getData(By entity:String, managed: Bool, sorts:[NSSortDescriptor]?, predicate:NSPredicate?, context:NSManagedObjectContext) ->[AnyObject]{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        var results = [AnyObject] ()
        
        if let _ = predicate{
            fetchRequest.predicate = predicate
        }
        
        if let _ = sorts{
            fetchRequest.sortDescriptors = sorts
        }
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            
            if fetchResults.count > 0 {
                
                if managed{
                    for obj in fetchResults {
                        results.append(obj as AnyObject)
                    }
                }
                else{
                    for obj in fetchResults {
                        if let eObj = Mapper.convertToEntity(fromManaged:  obj as! NSManagedObject){
                            results.append(eObj)
                            
                        }
                    }
                }
                
            }
            
            
        } catch {
            print("error")
        }
        
        return results
    }
    
    // Update
    
    
    func updateData(with entity: String, predicate:NSPredicate?, entityObject: NSObject)-> Bool{
        
        guard let moc = managedObjectContext() else {
            return  false
        }
        
        
        return updateData(with: entity, predicate: predicate, entityObject: entityObject, context: moc)
    }
    
    
    fileprivate  func updateData(with entity: String, predicate:NSPredicate?, entityObject: NSObject, context:NSManagedObjectContext)-> Bool{
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        if let pred = predicate{
            fr.predicate = pred
        }
        
        
        do {
            let results = try context.fetch(fr)
            
            if results.count > 0 {
                
                for obj in results {
                    let mObj = obj as! NSManagedObject
                    Mapper.convert(fromEntity: entityObject, toManaged: mObj)
                    
                }
                
                do {
                    try  context.save()
                    return true
                    
                } catch {
                    print("error")
                    return false
                }
            }
            else{
                return false
            }
            
        } catch {
            print("error")
            return false
        }
        
    }
    
    // Update (single attribute)
    
    fileprivate  func updateData(with entity: String, predicate:NSPredicate?, updateKey: String, updateValue:AnyObject, context:NSManagedObjectContext)-> Bool{
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        if let pred = predicate{
            fr.predicate = pred
        }
        
        
        do {
            let results = try context.fetch(fr)
            
            if results.count > 0 {
                
                for obj in results {
                    let mobj = obj as! NSManagedObject
                    mobj.setValue(updateValue, forKey: updateKey)
                }
                
                do {
                    try  context.save()
                    return true
                    
                } catch {
                    print("error")
                    return false
                }
            }
            else{
                return false
            }
            
        } catch {
            print("error")
            return false
        }
        
    }
    
    // Delete
    
    func deleteData(With entity:String, predicate:NSPredicate?)->Bool{
        
        guard let moc = managedObjectContext() else {
            return  false
        }
        
        return deleteData(With: entity, predicate: predicate, context: moc)
    }
    
    
    fileprivate  func deleteData(With entity:String, predicate:NSPredicate?, context:NSManagedObjectContext)->Bool{
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        if let pred = predicate{
            fr.predicate = pred
        }
        
        do {
            let results = try context.fetch(fr)
            
            if results.count > 0{
                
                for obj in results{
                    let mobj = obj as! NSManagedObject
                    context.delete(mobj)
                }
                
                do {
                    try  context.save()
                    return true
                    
                } catch {
                    print("error")
                    return false
                }
                
            }
            else{
                return true
            }
            
            
            
        }
        catch{
            print("error")
            return false
        }
    }
    
    //MARK: - Custom CRUD
    
//    func insertWorkoutAndRelatedExecises(Workout workouts:[MSWorkout])->Bool{
//        
//        guard let moc = managedObjectContext() else {
//            return false
//        }
//        
//        for eObj in workouts {
//            
//            let entity = NSEntityDescription.entity(forEntityName: "Workout", in: moc)
//            let mObj = NSManagedObject(entity: entity!, insertInto: moc) as! Workout
//            Mapper.convert(fromEntity: eObj, toManaged: mObj)
//            
//            for eIObj in eObj.Exercises {
//                
//                let entity = NSEntityDescription.entity(forEntityName: "WorkoutExercise", in: moc)
//                let mIObj = NSManagedObject(entity: entity!, insertInto: moc)
//                Mapper.convert(fromEntity:eIObj, toManaged: mIObj)
//                
//                mObj.addToWorkoutExerciseRelation(mIObj as! WorkoutExercise)
//            
//            }
//            
//        }
//        
//        do {
//            try  moc.save()
//            return true
//            
//        } catch {
//            print("error to insert Input: \(error)")
//            return false
//        }
//        
//    }
    
//    func getWorkoutAndRelatedExecises() -> [MSWorkout] {
//
//        let dm = DataModel()
//
//        let sortDescriptor = NSSortDescriptor(key: "workOutId", ascending: true)
//
//        let savedR = dm.getData(By: "WorkoutExercise", managed: false, sorts:[sortDescriptor], predicate: nil) as! [MSWorkoutExercises]
//        let savedR1 = dm.getData(By: "Workout", managed: false, sorts: nil, predicate: nil) as! [MSWorkout]
//
//        for item in savedR1 {
//            let temp = savedR.filter {$0.Ended == item.Ended}
//            item.Exercises = temp
//
//        }
//
//        return savedR1
//    }
    
}
