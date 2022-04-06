[![Swift](https://github.com/richard-clements/appsplus-bootstrap/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/richard-clements/appsplus-bootstrap/actions/workflows/swift.yml)

# appsplus-bootstrap

## Database

### Initialising Database

```
let db = CoreDataPersistentStorage(container: PersistentContainer(name: "Model"))
```

This initialises the Core Data persistent storage container with Core Data model named "Model" in your project.

### Entities

An entity is a mapper to a class of interest inside the Core Data Model. To retrieve an entity you use
```
let entity = db.entity(SomeInterestingModelClass.self)
```

Fetching a resource from the database requires the fetch property of an entity. The fetch property allows predicates to be placed on the entity which will then define the query to run when accessing the object.

```
db.entity(SomeInterestingModelClass.self)
  .fetch()
  .suchThat { \.property1.intProperty == 5 }
  .and { \.property1.stringProperty == "some string" }
  .or(predicate: NSPredicate(...))
  .subscribe()
  .map { ... }
  .receive(in: .main)
  .sink { fetchResults in
    ...
  }
```
