

@_exported import Contacts

// Internal Static instance of CNContactStore
class ContactStore {
    static var `default` = CNContactStore()
    
#if compiler(>=5.5) && canImport(_Concurrency)
    /// Requests access to the user's contacts.
    /// - Throws: Error information, if an error occurred.
    /// - Returns: returns  true if the user allows access to contacts
    @available(macOS 12.0.0, iOS 15.0.0, *)
    public func requestAccess() async throws -> Bool {
        return try await ContactStore.default.requestAccess(for: .contacts)
    }
#endif
    
    /// Indicates the current authorization status to access contact data.
    /// - Returns: Returns the authorization status for the given entityType.
    public func authorizationStatus() -> CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
    
    // 将函数修改为基于回调的模式
    public func fetchContacts(
        keysToFetch: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()],
        order: CNContactSortOrder = .none,
        unifyResults: Bool = true,
        completion: @escaping (Result<[CNContact], Error>) -> Void // 使用 Result 回调
    ) {
        // 开启后台线程处理耗时的通讯录读取操作
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var contacts: [CNContact] = []
                let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
                fetchRequest.unifyResults = unifyResults
                fetchRequest.sortOrder = order
                
                // 假设 ContactStore.default 是你对 CNContactStore 的封装
                try ContactStore.default.enumerateContacts(with: fetchRequest) { contact, _ in
                    contacts.append(contact)
                }
                
                // 成功后切回主线程回调
                DispatchQueue.main.async {
                    completion(.success(contacts))
                }
            } catch {
                // 失败回调
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Requests access to the user's contacts.
    /// - Parameter completion: returns either a success or a failure,
    /// on sucess: returns true if the user allows access to contacts
    /// on error: error information, if an error occurred.
    public func requestAccess(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        ContactStore.default.requestAccess(for: .contacts) { bool, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(bool))
        }
    }
}
