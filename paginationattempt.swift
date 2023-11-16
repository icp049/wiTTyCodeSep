import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class LandingController: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var allposts: [Post] = []
    @Published var hotposts: [Post] = []
    @Published var latestposts: [Post] = []
    
    @Published var showingNewItemView: Bool = false
    
    @Published var userName: String = ""
    @Published var bumpedPosts: [String: Bool] = [:]
    
    private var currentUserID: String?
    
    private var postsListener: ListenerRegistration?
    private var hotPostsListener: ListenerRegistration?
    
    private var lastDocument: DocumentSnapshot?
    private var isFetching = false
    
    init() {
        listenForPostChanges()
        listenForHotPostChanges()
        fetchInitialPosts()
    }
    
    func fetchAllPosts() {
        guard !isFetching else { return }
        isFetching = true
        
        var query = db.collection("Posts").limit(to: 4)
        
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        query.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            defer { self.isFetching = false }
            
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents in the query result.")
                return
            }
            
            let newPosts = documents.compactMap { document in
                try? document.data(as: Post.self)
            }
            
            self.allposts += newPosts
            
            if let lastDocument = documents.last {
                self.lastDocument = lastDocument
            }
        }
    }
    
    func fetchNextPostsIfNeeded(currentItem item: Post?) {
        guard let item = item, !isFetching, item == allposts.last else {
            return
        }
        
        fetchAllPosts()
    }
    
    // Other methods remain unchanged...
}
