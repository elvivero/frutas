# Frutas de diseño

## To do

- Placeholders para videos vimeo

## Update dependencies (gems)

```bash
nix-shell -p bundler -p bundix --run 'bundler update; bundler lock; bundler package --no-install --path vendor; bundix; rm -rf vendor'
```
