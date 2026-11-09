# Medienreaktor.NeosOpenApiBundle

The packages behind [neos/openapi](https://github.com/neos/openapi), bundled into one package installable from
Packagist:

| Package | Upstream | In this bundle |
|---|---|---|
| `neos/jsonschema` | https://github.com/neos/jsonschema | `Libraries/jsonschema/` |
| `neos/schematic` | https://github.com/neos/schematic | `Libraries/schematic/` |
| `neos/openapi` | https://github.com/neos/openapi | `Libraries/openapi/` |
| `neos/openapi-flowadapter` | https://github.com/bwaidelich/Neos.OpenApi.FlowAdapter | `Classes/`, `Configuration/` |

The upstream packages aren't released on Packagist yet, and a package on Packagist can't depend on packages that
aren't. This bundle bridges that gap. It's a stopgap: once the upstream packages are released, depend on them
directly and stop using this bundle.

The code is unchanged from upstream, at the commits listed in [Build/upstream.txt](Build/upstream.txt). Please report
issues with it upstream.

## Installation

```bash
composer require medienreaktor/neos-openapi-bundle
```

The bundle declares that it replaces the four `neos/*` packages, so packages that require them by name (for example
`neos/openapi: *`) are satisfied once the bundle is installed. Requirements on a specific upstream version such as
`dev-main` are not: require this bundle instead.

The bundle can't be installed together with any of the upstream packages.

## How it differs from installing the packages separately

- It is one Flow package with the FlowAdapter's package key, `Neos.OpenApi.FlowAdapter`. Settings, routes and
  middlewares keep their names. The FlowAdapter's namespace comes first in `autoload.psr-4`, because the Neos
  Composer installer names the package folder after the first one (`Packages/Application/Neos.OpenApi.FlowAdapter`).
- Flow reflects every class of a Flow package. Installed separately, jsonschema, schematic and openapi are libraries
  that Flow doesn't reflect. [Configuration/Settings.Bundle.yaml](Configuration/Settings.Bundle.yaml) keeps it that
  way by including only the FlowAdapter's classes in object management.
- Upstream tests, tooling and the `neos/openapi` demo (`public/`) are left out.

## Updating

```bash
Build/import-upstream.sh            # re-imports the commits in Build/upstream.txt
Build/import-upstream.sh --latest   # pins every package to the latest upstream commit first, then imports
```

Afterwards, compare the upstream `composer.json` files with this bundle's `composer.json`: new requirements,
namespaces or autoload entries have to be added here by hand. Then tag a new version.

## Switching to the upstream packages

Once they're on Packagist:

1. Replace the requirement on this bundle with requirements on the `neos/*` packages you use.
2. Mark this package as abandoned on Packagist, pointing to `neos/openapi-flowadapter`.

No code changes are needed: namespaces, the package key and settings are the same.

## License

MIT, see [LICENSE](LICENSE). The bundled code is by Bastian Waidelich and contributors, licensed MIT upstream.
