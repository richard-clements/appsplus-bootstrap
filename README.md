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

### Creating & Updating

An entity can be created in a similar way to fetching, you just have to use a different action on the initial entity. Then use the `modify` function to edit the resource with the correct properties. Relationships can be amended by using the second property of the closure which contains the database itself.

```
db.entity(SomeInterestingModelClass.self)
  .create()
  .modify {
    $0.valueShouldBeThis = true
    $0.relationship = $1.entity(AnotherInterestingModelClass.self)
      .fetch()
      .suchThat { \.propertyString == "some string" }
      .limit(1)
      .perform()
      .first
  }
  .perform()
  .save()
  .sink(recieveCompletion: { _ in }, receiveValue: { _ in })
```

An update can be done in a similar way

```
db.entity(SomeInterestingModelClass.self)
  .update(orCreate: true)
  ...
```

Using `update()` will only update an object if it exists, whereas `update(orCreate: true)` will create the object if it doesn't exists.

### Deletions

Deletions are done in exactly the same way, but you instead use the `delete` action on the entity.

```
db.entity(SomeInterestingModelClass.self)
  .delete()
  .suchThat { \.identity == 5 }
  .perform()
  .save()
  .sink(recieveCompletion: { _ in }, receiveValue: { _ in })
```
