# Dockery Odoo Base

This repo contains highly optimized, production ready base images for Odoo.

Dockerfiles are commented to provide information on the
size toll of each layer.

If you find an opporunity to strip them down further, please
file a PR.

## Features

- Minimal (you'll love that one!)
- Startup Greeter (know your environment)
- Postgres connection waiter loop (so startup doesn't fail)
- `get_addons` auto-addons path (making your module dev a little more agile)
- Tiny pyflame binary for live profiling (1.5MB)
- TODO: Rewire `scaffold` subcommand to a mr.bob implementation in dockery-odoo
- and remove from here, completely.

## Environment Convention

These base images try to conventionalize as little as possible.
Still, the following environment is expected to be configured in
downstream images that make proper use of theese base images:

### General
- `APP_UID` -> `1001`
- `APP_GID` -> `1001`

You still can impersonate a different user, e.g. your host's user with docker `--user` flag.

### Scope: Base Image Version

- `ODOO_VERSION`
- `PSQL_VERSION`
- `WKHTMLTOX_MINOR` or `WKHTMLTOX_VERSION`
- `NODE_VERSION`
- `BOOTSTRAP_VERSION` (optional)

### Scope: Project

This is the env contract you must fulfill in your projects.

- `ODOO_CMD` -> the odoo server executable (usually `odoo-bin`)
- `ODOO_FRM` -> the odoo framework path (the odoo repo)
- `ODOO_RC` -> path to the configuration file
- `ODOO_PRST_DIR` -> path where to store local persistent files ("filestore")
- `ODOO_VENDOR` -> path to vendored code for your project, such as odoo itself
- `ODOO_SRC` -> path to the project's own source code

## Code Generators

**tl;dr**: only ever modify `_spec-*`, then run `just regenerate`; commit both actions separatly.

- Specfifications are merged into target folders.
- The in the target folder, `Dockerfiles.##.tmpl` are sorted, merged into `Dockerfile` & finally removed.

This repo uses code generators, because:
- they ease maintenance
- they reduce errors
- they present complete and self-contained build specifications to the reader

---

## Further Information:

- https://github.com/OdooOps/dockery-odoo
- https://odooops.github.io/dockery-odoo/

## See also:

- [Changelog](./CHANGELOG.md)
- [Code of Conduct](./CODE_OF_CONDUCT.md)

# Credits & License

Based on stewardship and contributions by:
 - [@blaggacao](https://github.com/blaggacao)
 - [@ygol](https://github.com/ygol)
 - [@theangryangel](https://github.com/theangryangel)
 - [@ychirino](https://github.com/ychirino)

License: [LGPL-3](https://www.gnu.org/licenses/lgpl-3.0.en.html)
