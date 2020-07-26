# NetronixGeo

To start your NetronixGeo server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

## How to get started (DEV)

1. Ensure PostgreSQL is installed with PostGIS extension
2. Create postgre user **(netronix_usr)** with superuser privelegies (for postgis activation via migration (check first `repo/migration` in `priv` folder))*
3. `mix deps.get` && `mix setup` && `mix phx.server`
4. `mix generate_access_tokens` // to generate access tokens for 4 base users **(2 drivers and 2 manager)**
5. That's IT ^^

\* - user without superuser privs can be used (but in this case you need to active PostGIS extension manually)

NB: to run test just input `mix test`

## API routes

|Action| Method 	| URL 	| Params Loc 	| Param 	| Access 	|
|- |-	|-	|-	|-	|-	|
|Create task| post 	| /api/tasks 	| body(json) 	| `{ "pickup_coords": [number, number], "delivery_coords": [number, number] }`| Manager 	|
|Assign task| patch 	| /api/tasks/:id/assign 	| path 	| task id 	| Driver 	|
|Complete task| patch 	| /api/tasks/:id/complete 	| path 	| task id 	| Driver 	|
|List 20 nearest tasks | get 	| /api/tasks/nearest 	| query 	| ?lng=number&lat=number 	| Manager, Driver 	|
|List all or assigned or completed tasks| get 	| /api/tasks/:status 	| path 	| all, assigned, completed 	| Manager 	|

