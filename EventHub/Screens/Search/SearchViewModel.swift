//
//  SearchViewModel.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 01.12.2024.
//

import Foundation

enum SearchScreenType {
    case withData
    case withoutData
}

@MainActor
final class SearchViewModel: ObservableObject {
    
    private let apiService: IAPIServiceForSearch
    private var storage: IStorageService
    
    private let searchScreenType: SearchScreenType
    private var currentSearchTask: Task<Void, Never>?
    private var localData: [ExploreModel] = []
    
    @Published var error: Error? = nil
    @Published var searchResults: [ExploreModel] = []
    @Published var searchText: String = "" {
        didSet {
            debounceSearchTask()
        }
    }
    @Published var recentSearches: [String] = []
    
    // MARK: - Init
    init(
        searchScreenType: SearchScreenType,
        localData: [ExploreModel] = [],
        apiService: IAPIServiceForSearch = DIContainer.resolve(forKey: .networkService) ?? EventAPIService(),
        storage: IStorageService = DIContainer.resolve(forKey: .storageService) ?? UDStorageService()
    ) {
        self.searchScreenType = searchScreenType
        self.localData = localData
        self.apiService = apiService
        self.storage = storage
        self.recentSearches = storage.getRecentSearch()
    }
    
    // MARK: - Вebounce Search Task
    private func debounceSearchTask() {
        currentSearchTask?.cancel()
        currentSearchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            guard !Task.isCancelled else { return }
            if searchText.isEmpty {
                searchResults = []
            }
            if searchScreenType == .withData {
                filterLocalData()
            } else {
                await fetchSearchedEvents()
            }
        }
    }
    
    // MARK: - Filter Events
    func filterEvents(orderType: DisplayOrderType) {
        switch orderType {
        case .alphabetical:
            searchResults = searchResults.sorted(by: { $0.title < $1.title })
        case .date:
            searchResults.sort { Date?.compareAscending($0.eventDate, $1.eventDate) }
        }
    }
    
    // MARK: - Perform Search
       private func performSearch() async {
           switch searchScreenType {
           case .withData:
               filterLocalData()
           case .withoutData:
               await fetchSearchedEvents()
           }
       }
    
    // MARK: - Filter Local Data
    private func filterLocalData() {
        searchResults = localData.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }
    
    // MARK: - Network API Methods
    func fetchSearchedEvents() async {
        do {
            let searchEventsDTO = try await apiService.getSearchedEvents(with: searchText)
            searchResults = searchEventsDTO?.results.map { ExploreModel(searchDTO: $0) } ?? []
            addToReрcents()
        } catch {
            print("No searched func result")
            self.error = error
        }
    }
    

    
    // MARK: - Search History
    func getSuggestions() -> [String] {
        if searchText.isEmpty {
            return Array(recentSearches.prefix(8))
        } else {
            let filteredResults = searchResults
                .map { $0.title }
                .filter { $0.localizedCaseInsensitiveContains(searchText) }
            return Array(filteredResults.prefix(8))
        }
    }
    
    func addToReрcents() {
        guard !searchText.isEmpty && searchText.count > 4 else { return }
        if let index = recentSearches.firstIndex(of: searchText) {
            recentSearches.remove(at: index)
        }
        recentSearches.insert(searchText, at: 0)
        
        if recentSearches.count > 10 {
            recentSearches.removeLast()
        }
        storage.addRecentSearch(text: searchText)
    }
    
    func removeRecentSearch(at offsets: IndexSet) {
        for index in offsets {
            let recent = recentSearches[index]
            storage.removeRecentSearch(text: recent)
        }
        recentSearches.remove(atOffsets: offsets)
    }
}
