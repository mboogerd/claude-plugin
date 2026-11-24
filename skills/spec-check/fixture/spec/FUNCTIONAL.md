# pantry: functional specification

What pantry does, free of technology. Ids are cited bare; `TECHNICAL.md` says how.

## Terms

| Term | Meaning |
|---|---|
| household | The people who share one list, each with one or more phones. |
| list | The items a household needs, the same on every phone of the household. |
| item | One thing on the list: a name and a count. |
| phone | A device of a household member that runs pantry. |
| basket | use list |

## Requirements

### 2.1 Sharing (serves V1, V2)

- **F-SHARE-1** When a person changes the list, pantry sends the change to every reachable phone of the household.
- **F-SHARE-2** When a phone joins the household, pantry gives it the whole list.
- **F-SHARE-3** If a phone has been offline for a day, pantry restores its list from the pantry backup service.
- **F-SHARE-4** When a person leaves the household, pantry removes the list from that person's phones.

### 2.2 Adding (serves V3)

- **F-ADD-1** When a person types an item name and confirms, pantry adds the item to the list.
- **F-ADD-2** When a person opens an item, pantry shows the price history of that item in nearby shops.
- **F-ADD-3** When a person adds an item that is already on the list, pantry adds it a second time.
- **F-ADD-4** pantry never holds two items with the same name on one list.
- **F-ADD-5** When a person holds the add button, pantry offers the ten items added most often.

### 2.3 Quality (serves V1)

- **F-QUAL-1** pantry should show a change from another phone within a minute, when that phone is reachable.

## Journeys

### Shop together

Ana adds milk (F-ADD-1); Ben's phone shows it (F-SHARE-1); Ben buys it and removes it.

## Later

Nothing yet.
