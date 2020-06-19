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



Please visit, for more information:

- https://github.com/OdooOps/dockery-odoo
- https://odooops.github.io/dockery-odoo/


## See also:

- [Changelog](./CHANGELOG.md)
- [Code of Conduct](./CODE_OF_CONDUCT.md)