import CoreData

struct DataManager{
    static let shared = DataManager()
    
    let persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "MyData")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Loading of persistent stores failed: \(error)")
            }
        }
        
        return container
    }()
    
    func createSkillPost(availability: String, category: String, contactEmail: String, createdAt: Date, postDescription: String, title: String) -> SkillPost? {
        let context = persistentContainer.viewContext
        
        let skillPost = NSEntityDescription.insertNewObject(forEntityName: "SkillPost", into: context) as! SkillPost
        
        skillPost.availability = availability
        skillPost.category = category
        skillPost.contactEmail = contactEmail
        skillPost.createdAt = createdAt
        skillPost.postDescription = postDescription
        skillPost.title = title
        
        do {
            try context.save()
            return skillPost
        } catch let error {
            print("Failed to create skillPost: \(error)")
            return nil
        }
    }
    
    func fetchskillPosts() -> [SkillPost]? {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SkillPost> = SkillPost.fetchRequest()
        
        do {
            let skillPosts = try context.fetch(fetchRequest)
            return skillPosts
        } catch let error {
            print("Failed to fetch skillPosts: \(error)")
            return nil
        }
    }
    
    func updateSKillPost(skillPost: SkillPost) -> Void {
        let context = persistentContainer.viewContext
        
        do {
            try context.save()
        } catch let error {
            print("Failed to update skillPost: \(error)")
        }
    }
    
    func deleteSKillPost(skillPost: SkillPost) -> Void {
        let context = persistentContainer.viewContext
        
        context.delete(skillPost)
        
        do {
            try context.save()
        } catch let error {
            print("Failed to delete skillPost: \(error)")
        }
    }
    
    func createUser(aboutMe: String, email: String, name: String, password: String) -> User? {
        let context = persistentContainer.viewContext
        
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
        
        user.aboutMe = aboutMe
        user.email = email
        user.name = name
        user.password = password
        
        do {
            try context.save()
            return user
        } catch let error {
            print("Failed to create user: \(error)")
            return nil
        }
    }
    
    func fetchUsers() -> [User]? {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            return users
        } catch let error {
            print("Failed to fetch users: \(error)")
            return nil
        }
    }
    
    func updateUser(user: User) -> Void {
        let context = persistentContainer.viewContext
        
        do {
            try context.save()
        } catch let error {
            print("Failed to update user: \(error)")
        }
    }
    
    func deleteUser(user: User) -> Void {
        let context = persistentContainer.viewContext
        
        context.delete(user)
        
        do {
            try context.save()
        } catch let error {
            print("failed to delete user: \(error)")
        }
    }
}
