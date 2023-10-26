# Rclex architecture from v0.10.0

```
+-------------+     +-------------+     +-------------+     +-------------+     +--------------+
| Application +--+--+ Node's'     +--+--+ Node        +--+--+ Entities    +--+--+ Publisher    |
| Supervisor  |  |  | Supervisor  |  |  | Supervisor  |  |  | Supervisor  |  |  | GenServer    |
+-------------+  |  +-------------+  |  +-------------+  |  +-------------+  |  +--------------+
                 |                   |                   |                   |
                 |  +-------------+  |                   |  +-------------+  |  +--------------+
                 +--+ Context     |  |                   +--+ Node        |  +--+ Subscription |
                    | GenServer   |  |                      | GenServer   |  |  | GenServer    |
                    +-------------+  |                      +-------------+  |  +--------------+
                                     |                                       |
                                     |                                       |  +--------------+
                                     |                                       +--+ Timer        |
                                     |                                          | GenServer    |
                                     |                                          +--------------+
                                     |
                                     |  +-------------+     +-------------+     +--------------+
                                     +--+ Node        +--+--+ Entities    +--+--+ Publisher    |
                                        | Supervisor  |  |  | Supervisor  |  |  | GenServer    |
                                        +-------------+  |  +-------------+  |  +--------------+
                                                         |                   |
                                                         |  +-------------+  |  +--------------+
                                                         +--+ Node        |  +--+ Subscription |
                                                            | GenServer   |  |  | GenServer    |
                                                            +-------------+  |  +--------------+
                                                                             |
                                                                             |  +--------------+
                                                                             +--+ Timer        |
                                                                                | GenServer    |
                                                                                +--------------+
```

This diagram is written by https://asciiflow.com/
