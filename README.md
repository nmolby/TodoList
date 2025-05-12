# A Map of the Code
This README functions as a map of the TodoList app code. This codebase leans heavily into the MVVM architecture, meaning the view retrieves (nearly) all of its data from the view model and sends all actions to the view model for handling. Below, I've written an overview of the different components that the view model interacts with to construct the state for the view and handle actions from the view.

## The Architecture Diagram
Let's start with a visual of the architecture:
![Editor _ Mermaid Chart-2025-05-10-190619](https://github.com/user-attachments/assets/fe555f9e-99de-467b-9d4c-93251164520f)

## Overview of the Components
### The ViewModel
The crux of MVVM is the `ViewModel`, so let's begin with that. The view model stores any local view state (such as `editMode`), passes through any global state (such as `todoItems`) with possible filtering / sorting, and handles any view actions (such as `toggleEditing`). These three responsibilities are easily testable (see [TodoListViewModelTests](TodoListTests/Views/Todo%20List/TodoListViewModelTests.swift)) by validating local data changes and mocking dependencies to ensure the correct actions are taken upon them. Additionally, with the power of `@Observable`, we can combine global and local state data through computed properties:
```
var viewState: TodoListViewState {
    if !firstLoadFinished {
        return .loading
    } else if repository.todoItems.isEmpty {
        return .empty
    } else {
        return .loaded(items: sort(items: repository.todoItems))
    }
}
```
I've found this architecture of combining global and local state into a view state powerful, concise, and incredibly testable. But the ViewModel couldn't do it alone. The view model interacts with three services:

### The Repository
Abstractly, the repository is responsible for retrieving data from any number of sources, processing it (such as converting it to the domain model), and storing read-only state for any screen across the app to access. In this app specifically, the `TodoItemRepository` calls into the `CoreDataManager` to execute any core data operations and calls into the `APIClient` for loading the sample todos. This pattern makes it incredibly easy to write view models: the `AddTodoItemViewModel` can save a new todo to the repository, and the `TodoListView` automatically re-draws with the new data.

#### Core Data Manager
The `CoreDataManager` handles all setup and interaction with the `NSPersistentContainer`. This class currently provides pass-through `perform` and `fetch` functions, but a possible improvement would be to have this manager declare more specific functions for fetching, updating, or deleting, which would allow more granular testing of the repository.

#### API Client
The `APIClient` handles executing a request against an `APIRoute`, which is an enum representing available routes. An `APIRoute` can contain an associated value to provide any necessary parameters for the API call. The client handles setting up the path based on the parameters and identifying the `HTTPMethod` associated with the route. In an app that requires authentication, authentication information could also be passed into necessary requests. 

### The Navigation Router
The navigation router serves as the navigation source of truth for a specific flow. The router is generic over the type of `NavigationRouteProtocol`, allowing different flows to implement different supported navigation routes. In our case, there is only one type of route: `BaseAppNavigationRoute`, but I also created a sample `OnboardingNavigationRoute` to showcase how one might use this to support multiple flows. A view model holds the navigation router that it needs (based on the flow that it is in), and upon receiving an action it can send a navigation route to the router (with any necessary data as an associated value). The router then determines how to display the view (e.g., sheet vs. push). This architecture allows you to comprehensively unit test the navigation of your views.

### The Error Store
The error store stores any errors encountered throughout the app, allowing other places in the app to display the error. In our case, the `ContentView` has an overlay to display the error as a toast alert to the user. This could be expanded to support different types of errors or add analytics to track user errors. Alternatively, this toast alert logic could be migrated to the `NavigationRouter`, since in an abstract sense toast alerts are also a sort of navigation (see [this](https://arc.net/l/quote/ekwjjnhb) quote from the composable architecture that revolutionized how I think about navigation). This would allow for different sorts of toast alerts to be propagated, such as success or warning alerts.

## Conclusion
I'm very satisfied with how this architecture turned out. The flexibility that using `@Observable` gives you is pretty amazing, and the ability to store all important information outside of the view means that you can unit test much more than in an MV app. I think it presents a good middle ground between the (mostly) untestable MV architecture that Apple presents and the more opinionated but fully testable [composable architecture](https://github.com/pointfreeco/swift-composable-architecture) that Point Free has made.
