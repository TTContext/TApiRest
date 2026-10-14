# TApiRest

The project template the [Trysil Expert](https://github.com/davidlastrucci/Trysil) uses to create a Delphi REST API server built on [Trysil](https://github.com/davidlastrucci/Trysil).

You do not use this repository directly: the Expert downloads it, keeps the features chosen in its wizard, renames the project and writes it to disk.

## Branches

There is one branch per Trysil version line, named after the **minimum** Trysil version the template compiles with: `2.1` needs Trysil 2.1 or later. Each version of the Expert downloads the archive of its own line:

```
https://github.com/TTContext/TApiRest/archive/refs/heads/2.1.zip
```

A line gets a new branch only when the template starts using an API the previous line does not have. Fixes that still compile with the minimum version of a line go on that line's branch, and every Expert of that line picks them up on its next download.

## Layout

Everything the Expert writes is under `Template/`. The files at the root of the repository are not part of the generated project.

`Template/` is a real project, `TApiRestTemplate.dproj`, with **every feature enabled**: open it in the IDE and it compiles. The base units, `TApiRest.*` under `Core/`, are the same in every generated project; the project units, `TApiRestTemplate.*`, are renamed.

One executable runs as a Windows service, as a tray application with `/debug`, and as a console on Linux.

## Features

| Feature | What it adds |
|---|---|
| `multitenant` | The connection is resolved per tenant from the `Host` header, with `_Config\Tenants\<host>\_config.json`. Without it, one connection is registered at startup from the `database` section. |
| `auth` | Login, token renewal, JWT, password hashing, user disabling, and the `/auth` controllers. Without it the server is `AllowAnonymous` and every route is open. |
| `log` | Request, response and action logging to the log database, switched by `log.enabled`, which defaults to `True` when the `log` section is missing. When enabled the `log.database` section is mandatory and the service does not start without it; with `multitenant` the connection comes from each tenant file instead, and `log.enabled` alone decides. |
| `rs256` | JWT signed with an RSA key pair, from the PEM files declared by each `secrets.jwtKeys` entry, using OpenSSL `libcrypto` resolved at runtime. Without it, HS256 with the secret of each entry. Requires `auth`. Every entry needs its public key. The private key is not part of an entry: it is `secrets.jwtKeys.signingKey`, the key the service signs with, and a service without it verifies tokens but cannot issue them. Tokens are signed with the key named by `secrets.jwtKeys.current` and carry its id as the `kid` header; verification resolves the key by the token's own `kid`, so retired keys keep working until the tokens signed with them expire. |
| `sqids` | Primary keys and `TTLazy<T>` relations travel as Sqids in the JSON and in the route parameters; the version of the delete route stays a plain number (`[TNotSqid]`). Available from line `2.1.1`. |
| `openapi` | The OpenAPI 3.1 document on `<BaseUri>/openapi.json`: summaries, request bodies and responses on the base controllers, `EntityClass` on `TReadOnlyController<T>`, and the registration in `THttp`, protected with `auth` and public without it. The title is the description of the service. Available from line `2.1.2`. |

## Markers

The code that belongs to a feature is delimited by comments the Expert understands. The keyword `TFeature` is case-insensitive.

| Where | Marker | The Expert, when the feature is on | when it is off |
|---|---|---|---|
| First lines of a file | `{ TFeature:auth }` (Pascal), `-- TFeature:auth` (SQL) | removes the marker line | deletes the file |
| A block, active in the template | `{ TFeature:auth }` ... `{ /TFeature:auth }`, also inside a line | removes the two markers | removes the block |
| A block, commented in the template | `(* TFeature:!multitenant` ... `*)` | removes the block | removes the two comment lines, and the code becomes active |

A file may start with several markers, one per line: it is kept only when all of them hold. `{ TFeature:!multitenant }` in the first lines means "keep this file only when `multitenant` is off".

A commented block holds the code of a feature that is **off**, so the template, where every feature is on, does not compile it. That code is only checked by generating a project with the feature off.

A byte order mark, when a file has one, stays in front of everything: the markers come after it.

### JSON files

JSON has no comments, so the JSON files carry no markers. Their rules are in `TFeatures.json`, at the root of the repository and therefore never part of a generated project. Each entry maps a path, relative to `Template/`, to the conditions it is kept under; all of them must hold:

| Key | Means |
|---|---|
| `__trysil/user.json` | the file |
| `_Config/Tenants/` | the folder and everything in it |
| `_Config/TApiRestTemplate.json#log.database` | the `database` member of the `log` object in that file |
| `...#secrets.jwtKeys.keys[].secret` | the `secret` member of every element of the `keys` array |

A path the file does not list is always kept.

## Project name

The Expert replaces, in this order:

1. `TApiRestTemplate - API REST` with the description;
2. `ApiRestTemplateService` with the service name;
3. `TApiRestTemplate` with the project name,

in file names and in the text of the `.pas`, `.dfm`, `.dpr`, `.dproj`, `.json` and `.sql` files.

## License

BSD 3-Clause, the same as Trysil. See [LICENSE.md](LICENSE.md).
