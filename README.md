# NetronixGeo

To start your NetronixGeo server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

## How to get started (DEV)

1. Create postgre user **(netronix_usr)** with createdb privelegies (check first `repo/migration` in `priv` folder)*
2. `mix deps.get` && `mix setup` && `mix phx.server`
3. `mix gen.tokens` // to generate access tokens for 4 base users **(2 drivers and 2 manager)**
4. That's IT ^^

NB: to run test just input `mix test`

## API routes

|Action| Method 	| URL 	| Params Loc 	| Param 	| Access 	|
|- |-	|-	|-	|-	|-	|
|Create task| post 	| /api/tasks 	| body(json) 	| `{ "pickup_coords": [number, number], "delivery_coords": [number, number] }`| Manager 	|
|Assign task| patch 	| /api/tasks/:id/assign 	| path 	| task id 	| Driver 	|
|Complete task| patch 	| /api/tasks/:id/complete 	| path 	| task id 	| Driver 	|
|List 10 nearest tasks | get 	| /api/tasks/nearest 	| query 	| ?lng=number&lat=number 	| Manager, Driver 	|
|List all or assigned or completed tasks| get 	| /api/tasks/:status 	| path 	| all, assigned, completed 	| Manager 	|

