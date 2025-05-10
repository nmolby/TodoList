Welcome to the best architected 2-screen todo app you've ever seen! 

I went into this project with the goal to lean as far into MVVM as possible. The view should retrieve _all_ data from the view model and send all actions to the view model for processing, allowing for comprehensive unit testing.

Given the above goal, this is the architecture I ended up with:
![Editor _ Mermaid Chart-2025-05-10-190619](https://github.com/user-attachments/assets/fe555f9e-99de-467b-9d4c-93251164520f)

Let's start with the `ViewModel`. The view model stores any local view state (such as `editMode`), passes through any global state (such as `todoItems`) with possible filtering / sorting, and handles any view actions (such as `toggleEditing`). These three responsibilities are easily testable (see [TodoListViewModelTests](TodoListTests/Views/Todo%20List/TodoListViewModelTests.swift)) by validating local data changes and mocking dependencies to ensure the correct actions are taken upon them.

The view model interacts with three services:

1. `TodoItemRepository`. This repository is reponsible for retrieving todos from the `CoreDataManager` and the `APIClient`, processing them (such as converting them to the domain model `TodoItem`), and storing a list of `TodoItem` for access throughout the app. This class is marked `@Observable`, so whenever the store of `TodoItem` changes, the views automatically update to reflect the new items. The interactions with the CoreDataManager and APIClient are also tested in [TodoItemRepositoryTests](TodoListTests/Repositories/TodoItemRepositoryTests.swift). 
2. `NavigationRouter`. This router serves as the navigation source of truth for a specific flow. The router is generic over the type of `NavigationRouteProtocol`, allowing different flows to implement different supported navigation routes. In our case, there is only one type of route: `BaseAppNavigationRoute`, but I also created a sample `OnboardingNavigationRoute` to showcase how one might use this to support multiple flows.
3. `ErrorStore`. This stores any errors retrieved throughout the app, and the `ContentView` has an overlay to display the error as a toast alert to the user. This could be expanded to support different _types_ of errors or add analytics to track user error rate. Alternatively, this toast alert logic could be migrated to the `NavigationRouter`, since in an abstract sense toast alerts are also a sort of navigation. This would allow for different sorts of toast alerts to be propogated, such as success or warning alerts.
