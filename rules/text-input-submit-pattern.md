---
alwaysApply: true
---

# TextInput Submit Pattern

`textInput(state).onSubmit(...)` takes a `Runnable`, **not** a `Consumer<String>`. The submitted text is read out of the bound `TextInputState`, not passed as a callback argument. **Why:** most TUI libraries pass the submitted line into the handler; TamboUI does not, and writing the more familiar `onSubmit { line -> ... }` produces either a compile error or a handler that runs but never sees the text — both look like "submit doesn't work."

## The Correct Shape

```kotlin
val state = textInputState()
textInput(state).onSubmit(Runnable {
    val line = state.text()
    if (line.isNotBlank()) {
        send(line)
    }
    state.clear()
})
```

Java equivalent:

```java
TextInputState state = textInputState();
textInput(state).onSubmit(() -> {
    String line = state.text();
    if (!line.isEmpty()) {
        send(line);
    }
    state.clear();
});
```

## Why Read From State, Not From a Callback Arg

- `TextInputState` is the source of truth for the buffer and cursor — reading from there is the same source the next render uses
- Passing the line into the callback would require copying it out of state into the call frame, then the handler still has to call `state.clear()` to reset for the next line — two operations where one suffices

## Always Clear After Submit

- `state.clear()` is mandatory at the end of the handler unless you want the previous line to persist visibly in the input box
- If the field is held as `private val state: TextInputState` (see [[persistent-stateful-elements]]), the handler can safely reference it directly

## Mistakes the Compiler Catches

- `.onSubmit { line -> ... }` (lambda taking a String) — compile error: `Runnable` is zero-arg
- `.onSubmit(Consumer<String> { ... })` — compile error: wrong type

## Mistakes the Compiler Does Not Catch

- Forgetting `state.clear()` — input keeps accumulating across submits
- Holding a fresh `textInput(textInputState())` inline in `render()` — the state object is discarded every frame, see [[persistent-stateful-elements]]
